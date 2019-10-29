title: ElasticSearch笔记
date: 2017-10-31 13:54:34
categories:
    - elasticsearch
---

# 基本概念

Document：es里的文档，其实可以看做一个序列化以后的对象，并非通常意义上的文档。
Index：

1. 做名词时，类似关系型数据库里面的数据库；
2. 做动词时，指存储一个文档到一个 索引（名词）中。

索引中每个文档都有类型。每种类型都有它自己的映射。

Types：es中的type代表某类相似的文档，包含两个部分name和mapping。类似关系型数据库中的表。

Scroll：类似关系型数据库中的cursor。

# 文档的分布式存储

## Index

默认情况下，indexing文档的时候会创建index，并通过动态mapping的方式来添加field到type mapping里。可以通过手动的方式，控制index的创建。

master又叫做协调节点（coordinating node）。

文档存放到哪个分片由：`shard = hash(routing) % number_of_primary_shards`决定，`routing`是个可变值，默认是文档的`_id`。而`number_of_primary_shards`是创建索引的时候就确定了的，如果在创建之后修改了分片数，那么就会导致找不到文档。

## Type

在Lucene看来，一个文档包含多个field-vaule对，同时，Lucene不关心value的类型，所有value都被存储为opaque bytes。

es的type便是基于上述基础构建的：

1. Lucene并没有文档类型这个概念，es负责维护，并把类型名字放在元数据的`_type`中；
2. Lucene也没有mapping的概念，es使用mapping将复杂的json文档展平，以便存储到Lucene中；
    * 不允许在同一个index下、不同的type内、创建名字相同的、mapping不同类型的fields。因为实际存储的时候，这些mapping会被展开，放在一起存储。如果有上述情况，那么将无法区分两个mapping。
3. 进一步的，由于同一个index下的mapping会被展开和放在一起，因此如果两个type是完全互斥的，那么会导致浪费存储空间。最好是type之间有相似的schema。

stored field和indexed field：

* stored field：索引一个字段的值，并且存储原始字段值，字段can be retrieved；
* indexed field：索引一个字段的值，但不存储原始字段值，searchable。

## Mappping

映射定义了类型中的域，每个域的数据类型，以及es如何处理这些域。类似关系数据库中的schema。

es支持了几种域类型，需要关注的是string域。默认情况下，string域会被认为包含全文，即索引时，会先使用分析器；针对这个域的查询，也会使用分析器。

string域的两个重要属性是：

1. index：控制怎样索引字符串；
    * analyzed（默认）：分析，并索引
    * not_analyzed：不分析，索引；
    * no：不索引；
2. analyzer：指定在搜索和索引时使用的分析器。

es还提供了动态mapping，以及`dynamic_templates`的功能。

## Shard

分片是一个底层的工作单元，保存了整个索引的一部分。

### Lucene的index

一个es的shard就是lucene的index。

lucene有一个per-segment search的概念。一个segment就是一个倒排索引，一个lucene的index是 *一组segment+commit point*。segment是不可变的（immutable），commit point保存了当前的shard中包含哪些segment。

segment的产生过程如下：

1. 新文档被加入到in-memory索引缓存；
2. 每隔一段时间，buffer会被提交：
    * 新segment被写入磁盘；
    * 包含了新segment名字的新commit point被写入磁盘；
    * `fsync`，执行物理写入；
3. 新segment（上一步提交的）被开启，使其对搜索可见；
4. 清空in-memory索引缓存。

* 搜索时，所有segment都会被轮流查找。
* 删除时，commit point包含一个`.del`文件，这个文件列出了*哪个segment中的哪个文档*已经删除了。删除操作会将文档在`.del`文件中标记。搜索时，在`.del`文件中被标记的文档仍然能被match到，但不会返回到协调节点。
* 更新时，先执行上一步删除操作，然后在新segment中索引新文档。

### Type vs Index in ES

概念上es的Index类似关系型数据库里面的数据库，Types类似关系型数据库中的表，但是从数据存储的方式上，这两者与关系型数据库并不沾边。

* Index：Index存储了shard的集合，每个shard是Lucene的index。
    1. Lucene的index在磁盘空间、内存占用和文件描述符上有固定的开销。基于这个原因，一个大索引会比很多小索引高效得多；
    2. 搜索数据时，es最终需要merge来自所有shard的结果。如果有来自很多个shard的结果需要合并，或者查询导致了shard产生了很大的结果，这会导致merge消耗很多CPU和内存资源。

* Type：提供了一种在同一个Index中存储多个type的方法。
    1. 不同type中的fields需要保持一致，即：同一个index下、不同的type内、创建名字相同的fields，mapping的类型也要相同；
    2. 没有在某个type中出现的filed也会消耗存储资源。同一个index中的mapping在Lucene中是展开存储的；
    3. Score是索引级别的统计，所以一个type的文档score会被其他type的文档影响。

### Near Real-Time Search

按段搜索减少了index一个文档到文档对搜索可见的时间，但提交segment时候的`fsync`仍然是瓶颈，不可能不造成性能影响的情况下，每index一个文档就`fsync`一次。

Lucene允许新segment在提交前，被打开和写入，使得文档对搜索可见。这个过程比提交更轻量级，在es中这个过程叫做`refresh`，默认的刷新间隔是1s，Near Real-Time。

### 持久化

短时间周期的`refresh`可提供near real-time search的功能，完整的提交才能保证数据的持久化。在提交完成之前，有可能会有更改文档的操作，此时in-memory buffer被清空，无法存放新的文档，es使用translog（transaction log）来防止这些操作丢失。

translog提供了还没有被`flush`到磁盘的所有操作的持久化记录，即：在文档被加入到in-memory buffer的时候，以及`refresh`的时候。当translog满了，新的translog会被创建，同时执行一次提交。

当启动的时候，es会使用上一次的commit point来恢复磁盘上已知的segment，并重播translog中的所有操作。

当通过id来获取、更新或者删除一个文档的时候，es会在从segment中获取文档之前，先检查translog，这就意味着es能够实时的获取最新版本的文档。（这个过程与`refresh`是什么关系？）

除了上述的自动触发新建translog并提交，还可以手动调用es的`flush`，es会定期进行`flush`。

translog的安全性：

1. 在主分片和副分片，每5分钟`fsync`到磁盘，或者一个写操作完成后；
2. 以同步的方式进行写入是最安全的，但也意味着主副分片完成前，client都不会收到响应；
3. 以异步的方式写入，性能高，但是`index.translog.sync_interval`期间的数据一定会在crash的时候丢失。

### 合并segment

定时的`refresh`会导致创建过多的segment，造成不必要的开销。es在索引和搜索的时候，会合并多个小的segment为大segment，并丢弃已删除的文档，同时写入一个新的commit point。合并segment是一个消耗cpu和io的操作，触发合并时，es会进行相关的限制。

`optimize`可用于执行强制合并，它强制分片把segment的数目合并到小于`max_num_segments`。一般情况不需要调用，但如果数据本身是很少变动的，如：log，可以将每天或者每周的数据合并到一个segment。调用`optimize`进行合并时，es不会进行相关的限制。

## 新建、索引和删除

新建、索引和删除请求都是写操作，具体过程如下：

1. 节点在确定主分片位置后，将操作转发给主分片；
2. 在主分片完成操作之后，将操作转发到相关的副本分片；
3. 副分片完成后，主分片节点向协调节点报告成功；
4. 协调节点返回结果给client，此时数据在主副分片都可用。

写操作的一致性，`consistency`：

1. 可为`one`，即主分片可用就写；
2. 可为`all`，即主分片以及所有副分片可用才写；
3. 可为`quorum`，即写操作需要一定数量的副分片可用才会进行，`quorum`的计算方式为`int( (primary + number_of_replicas) / 2 ) + 1`。

这里的特殊情况是当`number_of_replicas`为1时，`int( (primary + number_of_replicas) / 2 ) + 1 = 2`，如果`consistency = quorum`，那么永远都无法满足副分片的数量要求。因此`number_of_replicas >= 1`时，`quorum`才会起效。

## 读操作

1. 节点在确定所有分片位置，并向下一个节点转发请求；
2. 下一个节点返回文档给当前节点，当前节点返回给client。

在处理读取请求时，协调结点在每次请求的时候都会通过轮询所有的副分片来达到负载均衡。

## 局部更新文档

类似新建、索引和删除，当主分片完成后，转发的是新版的文档，而不是转发操作。

1. 节点在确定主分片位置后，将操作转发给主分片；
2. 主分片以cas的方式进行更新，如果失败，retry；超过`retry_on_conflict`，则放弃；
3. 主分片完成更新后，转发新版本的文档；
4. 副分片完成后，主分片节点向协调节点报告成功；
5. 协调节点返回结果给client，此时数据在主副分片都可用。

> 当主分片把更改转发到副本分片时，它不会转发更新请求。相反，它转发完整文档的新版本。请记住，这些更改将会异步转发到副本分片，并且不能保证它们以发送它们相同的顺序到达。如果Elasticsearch仅转发更改请求，则可能以错误的顺序应用更改，导致得到损坏的文档。

# 查询

es数据可以概括的分为两类：

1. 精确值：如id。查询时，要么匹配查询，要么不匹配。
2. 全文：指文本数据。查询时，不仅仅看是否匹配，还看匹配度多高，即该文档与给定查询的相关性，很少对全文类型的数据做精确匹配。

## Analysis

分析包含三个模块的处理过程：

1. 字符过滤器：整理字符串，例如：去掉HTML，或者将 & 转化成 `and`；
2. 分词器；
3. Token 过滤器：处理大小写、stop words，增加同义词。

es中内置了多种分析器，在查询*全文域*的时候，会对查询字符串应用相同的分析器；查询*精确域*的时候，不会使用分析器。

## 排序与相关性

默认情况下，查询是按照相关性倒序排列的，用`_score`表示，`_score`的计算方式依赖于查询的方式。其中计算全文本字段的值相对于全文本检索词相似程度使用`TF/IDF`:

1. TF，检索词频率：检索词在该字段出现的频率？出现频率越高，相关性也越高。字段中出现过5次要比只出现过1次的相关性高；
2. IDF，逆文档频率：每个检索词在索引中出现的频率？频率越高，相关性越低。检索词出现在多数文档中会比出现在少数文档中的权重更低；
3. 字段长度准则：字段的长度是多少？长度越长，相关性越低。 检索词出现在一个短的title要比同样的词出现在一个长的content字段权重更大。

## 分布式文档查询

查询不同于CRUD，CRUD可以使用`_index`、`_type`和`routing`值来唯一的确定文档在哪个分片。但查询并不知道哪个文档能够match查询条件，因此必须检查每个分片上的索引（query），并将这些结果合并（fetch）。

### Query

1. 向某个节点发送查询请求，此时这个节点就是协调节点，并创建一个大小为`from + size`的空优先级队列；
2. 这个节点（以round-robin的方式，分散负载）向主分片或副分片广播查询请求；
3. 各个节点查询并返回包含doc id和排序值的优先级队列给协调节点；
4. 协调节点merge这些值到自己的优先级队列。

### Fetch

1. 协调节点识别出需要取得的文档以后，发送`multi get`到相关分片；
2. 相关分片读取并enrich（加入metadata和高亮）文档，如果有需要，则把文档返回给协调节点；
3. 一旦所有取得了所有文档，协调节点就把结果返回给client。

query-then-fetch处理支持通过`from`和`size`来完成分页，但是如果分页的过深，则导致集群过高的负载。协调节点需要排序`number_of_shards * (from + size)`个文档来找到正确`size`的文档。

# 并发控制

es的并发控制是通过版本号来实现的。

## 版本控制

1. 当多个process修改同一个文档时，有可能会有修改丢失的情况；
2. es是分布式的，新的文档会被异步、并发的发送到其他结点，并可能会以乱序的形式到达，需要避免老的文档覆盖新的文档。

es使用乐观并发控制的机制来避免上述情况发生。具体来说：es把每个文档都给一个`_version`，当文档被修改时版本号递增。

对于情况1，在process更新或删除文档时，指定一个`_version`，只有当指定的`_version`与存储的一致时，才会进行更新或者删除操作。相当于在es内部实现了cas语义。

对于情况2，如果旧版本的文档在新版本之后到达，则被忽略。

## 其他解决方法

# 共识算法

# 一致性

## 通过外部系统使用版本控制

如果使用es的场景是：将主数据库作为存储，而将es作为检索，那么多个process将数据同步到es时，可能会出现冲突的问题。此时，如果主数据库有能作为版本号的字段，那么可以设置`version_type=external`，并把外部字段值作为`_version`。es处理时，并不判断`_version`是否一致，而是判断当前`_version`是否小于指定的版本号。



# References

1. [面试小结之Elasticsearch篇](http://ginobefunny.com/post/elasticsearch_interview_questions/)

