---
title: golang RWMutex RLock重入导致死锁
date: 2019-07-10 16:52:29
categories:
    - concurrency
tags:
    - golang
    - rwlock
---

RWMutex，即读写锁，可以被多个的reader或一个writer获取使用。

## 死锁例子

在使用RWMutex的时候，同一个reader是不应该连续调用`Rlock`多次的，这样做不但没有意义，还有可能导致死锁，具体代码如下：

```go
func main() {
	var l = sync.RWMutex{}
	var wg sync.WaitGroup
	wg.Add(2)

	c := make(chan int)
	go func() {
		l.RLock()
		defer l.RUnlock()
		c <- 1
		runtime.Gosched()

		l.RLock()
		defer l.RUnlock()
		wg.Done()
	}()

	go func() {
		<-c
		l.Lock()
		defer l.Unlock()
		wg.Done()
	}()

	wg.Wait()
}
```

## 分析

下面[RWMutex的实现](https://github.com/golang/go/blob/master/src/sync/rwmutex.go)，我们来看这段代码的具体执行。为了方便理解，把`if race.Enabled {...}`的相关代码都去除了。

1. **goroutine 1**：`l.RLock()`

    ```go
    func (rw *RWMutex) RLock() {
    	if atomic.AddInt32(&rw.readerCount, 1) < 0 {
    		// A writer is pending, wait for it.
    		runtime_SemacquireMutex(&rw.readerSem, false, 0)
    	}
    }
    ```

    执行`l.RLock()`后，goroutine 1获得写锁。

    * 状态：获得读锁
    * readerCount = 1，readerWait = 0

2. **goroutine 2**：`l.Lock()`

    ```go
    func (rw *RWMutex) Lock() {
    	// First, resolve competition with other writers.
    	rw.w.Lock()
    	// Announce to readers there is a pending writer.
    	r := atomic.AddInt32(&rw.readerCount, -rwmutexMaxReaders) + rwmutexMaxReaders
    	// Wait for active readers.
    	if r != 0 && atomic.AddInt32(&rw.readerWait, r) != 0 {
    		runtime_SemacquireMutex(&rw.writerSem, false, 0)
    	}
    }
    ```

    由于goroutine 1已获得写锁，此时goroutine 2等待。

    * 状态：等待reader释放读锁
    * readerCount = 1 - rwmutexMaxReaders，readerWait = 1

3. **goroutine 1**：`l.RLock()`

    ```go
    func (rw *RWMutex) RLock() {
    	if atomic.AddInt32(&rw.readerCount, 1) < 0 {
    		// A writer is pending, wait for it.
    		runtime_SemacquireMutex(&rw.readerSem, false, 0)
    	}
    }
    ```

    goroutine 1发现readerCount为负，认为有writer获得了写锁，接着也进入了等待状态。

    * 状态：等待
    * readerCount = 2 - rwmutexMaxReaders，readerWait = 1

最后goroutine 1和goroutine 2都进入了等待状态。

## 总结

1. readerCount的作用？
    持有读锁的reader数。置为负时，代表了writer正在或者已经获得了读锁，此时其他reader不能再获得写锁。
2. readerWait的作用，以及在`Lock()`中，为何需要同时判断`r != 0`和`atomic.AddInt32(&rw.readerWait, r) != 0`？
    置readerCount为负的时候，获得了写锁，但尚未RULock的reader数。writer需要等待这些reader执行结束。

    * 若`r == 0`，则无正在持有读锁的reader，可以直接完成读锁的加锁。
    * 若`r != 0`，writer需要等待获得了写锁，但尚未RULock的reader执行结束。如何判断是否需要等待呢，即readerWait不为0的时候。同时reader决定是否能唤醒writer，也需要等到readerWait为0的时候。

    ```go
    func (rw *RWMutex) Lock() {
    	rw.w.Lock()
    	r := atomic.AddInt32(&rw.readerCount, -rwmutexMaxReaders) + rwmutexMaxReaders
    	// 此刻起，其他reader不再能够获得读锁。
    	// 此时，尚未释放写锁的reader数为readerWait个，等待他们结束才能完成读锁的加锁。
    	if r != 0 && atomic.AddInt32(&rw.readerWait, r) != 0 {
    		runtime_SemacquireMutex(&rw.writerSem, false)
    	}
    }
    ```
