title: Cache coherence和data race
date: 2017-06-04 13:54:34
categories:
    - concurrency
    - cache
---

问题：[最近在看lock-free算法，没搞明白多核cpu如何实现数据一致性？](https://www.zhihu.com/question/60629009/answer/179943569)

谢邀，我来尝试回答题主的问题，如果回答有错误的地方，请指出，谢谢：）。

题主需要知道 Cache coherence（缓存一致性）。Cache coherence 指的是存储在多个本地 cache 中共享的 cache line 之间的一致性。协议的实现根据维护 cache block 状态的方法不同分为：Snooping 和 Directory 两类。MSI Protocol 是一个简单的 Bus-Snooping Cache Coherence 协议。

下面以 MSI 协议为例回答题主的问题。

* PrRd 和 PrWr 表示本地读写请求，后面的数字代表进行操作的 core 序号。
* BusRd：core 向总线 issue 的读请求。
* BusRdx：core 向总线 issue 的读请求，读到的 cache line 可能会用于写。

```
Time Request    Core1   Core2   Bus-Request Response
0    -          I       I       -           -

1    PrRd1      S       I       BusRd       core1 从内存加载数据到自己的 cache line
     (read miss)                            core1 向总线 issue BusRd
                                            
2    PrRd2      S       S       BusRd       core2 从 core1 的 cache line 加载数据到自己的 cache line
     (read miss)                            core2 向总线 issue BusRd

3    PrWr1      M       I       BusRdx      core1 广播 RFO (Request For Ownership)，
                                            core1 向总线 issue BusRdx，
                                            core2 的 cache line 置为 Invalid
                                            
4    PrWr2      I       M       BusRdx      core2 广播 RFO，并向总线 issue BusRdX，
     (write miss)                           core1 的 cache line 被 flushed 到内存，
                                            core2 的 cache line 置为 Invalid，
                                            core2 write miss，从 core1 获得 cache line，然后写入
                                            
```

重点从第 3 步看起，此时 core1 要写入，因此广播 RFO，把其他 core 的 cache line 置为 Invalid。接着第 4 步，core2 要写入，由于 core1 的状态是 Modified，需要先将 core1 的 cache line 写入内存。又因为 core2 此时的状态是 Invalid，自己的数据无效，所以发生 write miss，需要从 core1 获得 cache line，然后写入。

