# Hadoop权威指南笔记
# BigPicture
Hadoop宏观来看包括两个点，存储（HDFS）和计算（MapReduce）。

HDFS源自Google的[The Google File System](https://ai.google/research/pubs/pub51)，可看作是GFS的简化版实现，去除了多客户端并发写入和快照。

MapReduce源自Google的[MapReduce: Simplified Data Processing on Large Clusters]，总结起来，就是分而治之。

# MapReduce
# HDFS

* [Hadoop之HDFS原理及文件上传下载源码分析（上）](http://www.cnblogs.com/qq503665965/p/6696675.html)
* [Hadoop之HDFS原理及文件上传下载源码分析（下）](https://www.cnblogs.com/qq503665965/p/6740992.html)
* [HDFS写文件过程分析](http://shiyanjun.cn/archives/942.html)

## 设计
* 超大文件。
* 流式数据访问：基于一次写多次读的访问模式，在每次数据分析都需要读取大量文件的情况下，读取整个数据集的时间（吞吐量）比访问第一个记录的延迟（数据访问延迟）更重要。
* 商用硬件，节点故障率高。

HDFS并不适用于，

* 低延迟数据访问。
* 存储大量小文件：受限于namenode内存大小限制。
* 多客户端写入同一个文件、修改文件的任意位置。

## 概念
### Block
最小文件读写单位，默认128MB。不同于操作系统的block，HDFS里小于一个block size的文件并不会占据整个block的大小。

HDFS的block之所以这么大，是为了减少磁盘寻道时间在传输数据时间中的占比。如果每次寻道的时间为10ms、磁盘的传输速度为100MB/s，为了保证寻道时间占1%的传输时间，block的大小应该为100MB左右。

block的好处：

1. 能够存储比磁盘大的文件；
2. 分布式文件系统的block抽象，而不是文件抽象，简化了存储管理（block大小固定，便于计算磁盘可以存放多少block）和元数据（例如：文件权限可以与block分开存储）的管理；
3. block与replicate提供了容错和可用性。

```bash
# 列出构成文件的所有block
hdfs fsck / -files -blocks
```

### Namenodes和Datanodes
HDFS集群是主从模式的，由namenode和datanode构成。

1. namenode：管理文件系统的命名空间。维护文件系统树、目录和文件的元数据，这些信息是持久化存储在磁盘的，使用两种形式的文件存储，namespace image和edit log。

    namenode维护了*文件有哪些block*，以及*文件的这些block在哪些datanode上有保存*，但namenode并不持久化的存储后者，仅在系统启动时由datanode重新构建。

2. datanode：存储和拉取block，定期向namenode发送所存储块的列表。

*文件夹*是作为元数据存储在namenode里面的。

**namenode容错**：hadoop有两种方式保证namenode可从错误中恢复。

1. 备份文件系统的元数据。相关的写操作是实时同步的和原子的。
2. secondary namenode（checkpoint node）
    
    由于每次重放较大的edit log很耗时，secondary namenode定期从namenode获取edit log，并与namespace image进行merge，供namenode出故障时使用。但secondary namenode的操作是有滞后的，因此在namenode挂了的时候，可能会有数据丢失。
    
**namenode扩展**：hadoop 2允许添加namenode来扩展namenode，每个namenode维护一个namespace volume，其中包含namespace的元数据和block pool，目的是管理文件系统的一部分目录。datanode对管理的目录不做区分，因此datanode会注册到所有的namenode。

### HDFS高可用
namenode存在单点故障的可能，每次从故障到恢复，对于大集群都需要大量的时间（load namespace image、重放edit log、等待datanode汇报足够的block并退出安全模式）。

hadoop2提供了active-standby namenode，通过如下方式来实现HDFS高可用支持，
1. namenode之间使用高可用共享存储来共享edit log。
    * 通过NFS filter或着quorum journal manager（QJM）来实现。
    * QJM一般是多个节点，但实现时并未使用zk。
2. datanode需要同时所有namenode发送block的处理报告。
3. client需要透明的处理namenode失效的问题。
    * 可以向所有namenode请求，知道操作完成。
    * 可以通过zk来实现。

## Hadoop文件系统
hadoop有一个抽象文件系统的概念，hdfs是它的一个实现。具体的实现包括，

* `fs.LocalFileSystem`
* `hdfs.DistributedFileSystem`
* 等

### 访问HDFS的接口
1. http方式，namenode和datanode内置的web server提供服务。client直接访问或者通过代理的方式。
2. c实现的libhdfs，基于http方式实现。
3. NFSv3网关。
4. FUSE，挂载为Unix文件系统。
