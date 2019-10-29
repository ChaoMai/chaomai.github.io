# golang sync.WaitGroup源码阅读
go的sync.WaitGroup从最初的版本到现在经历了不少的变化，要理解为什么是现在的样子，为什么有这些优化，最好的方式就是看commit的历史。

# 最初版本的[sync.WaitGroup](https://github.com/golang/go/blob/c007ce824d9a4fccb148f9204e04c23ed2984b71/src/sync/waitgroup.go)
