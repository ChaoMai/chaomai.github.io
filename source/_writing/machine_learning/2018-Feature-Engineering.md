# Feature-Engineering

特征工程是将原始数据处理为特征向量的过程。

# 数据预处理

# 特征选择

特征选择是一个从给定的特征集合中选择与当前学习任务相关特征子集的过程。无关特征是与当前学习任务无关。冗余特征是所包含的信息可以从其他特征中推演出来的特征。

从初始的特征集合中选取相关特征子集，需要持续的进行：

1. 子集搜索（subset search）：产生候选集

    在上一轮轮候选子集的基础上，新增一个相关特征或去掉一个无关特征。直到k+1轮时，候选特征子集不如上一轮的，则停止生成。每轮逐渐新增相关特征、减少无关特征的策略或同时增减，分别叫做前向搜索、后向搜索和双向搜索。
    这些策略是贪心的，仅保证了局部最优。
    
2. 子集评价（subset evaluation）：评价候选集好坏

    特征子集A确定了对数据集D的一个划分，每个划分子集对应着A上的一个取值，而样本标记信息Y对应着D的真实划分，评估这两个划分的差异，就能评价A。与Y对应的划分差异越小，那么A越好。
    
常见的特征选择方法本质上都是显式或者隐式的结合了某种（或多种）子集搜索机制和子集评价机制，主要有三类。

不同于降维，降维会创建特征的组合，但特征选择只是在现有的数据中包括或者排除特征，并不会改变这些特征。

* sklearn相关，

| 类 | 方式 | 说明 |
| --- | --- | --- |
| VarianceThreshold | Filter | 方差选择 |
| SelectKBest, SelectPercentile, SelectFpr, SelectFdr, SelectFwe, GenericUnivariateSelect  | Filter | 相关系数、卡方检验、信息增益、信息增益率、基尼系数 |
| RFE | Wrapper |  |
| SelectFromModel | Embedded |  |

## 过滤式（filter）

过滤式是一种使用统计指标来计算每个特征分数，并根据分数进行选择的方法。这个方法通常是单变量的，且独立的考虑特征，或者考虑因变量。

过滤式首先对数据集进行特征选择，然后把得到的相关特征用作训练。

1. 方差
    方差大于阈值的特征才进行选择。
    
2. 相关系数
    计算各个特征对目标值的相关系数以及相关系数的p值。

3. 卡方检验
    检验特征对目标值的相关性。 

4. 信息增益

5. 信息增益率

6. 基尼指数

7. Relief算法
    使用了一个向量作为“相关统计量”来度量特征的重要性，每个分量对应一个初始特征，特征子集的重要性是由每个特征对应的统计量分量之和来决定。对于每个样本$x_i$，寻找正负例样本中的near-hit，$x_{i, nh}$与near-miss，$x_{i, nm}$。在相关统计量$j$上，计算，

    $$\delta^j=\sum(-diff(x^j_i, x^j_{i, nh})^2 + diff(x^j_i, x^j_{i, nm})^2)$$

    其中，$x^j_a$表示$x_a$在属性$j$上的取值。如果样本$x_i$在属性$j$上与near hit更近，那么属性$j$对区分正负例样本是有效的，反之则无效。

    可以仅在抽样的数据集上进行估计相关统计量。

8. Relief-F算法
    Relief算法扩展，能够处理多分类问题，关键点就是对于Y个类别的中的某一类k，将其视作同类，其余类别的视作异类，然后使用Relief算法。

## 包裹式（wrapper）

包裹式把特征选择看做一个搜索问题，比较不同的特征组合。这个方法常常会使用一个预测模型来评估特征的组合，并基于模型的准确度给出分数。

过滤式不考虑后续的学习器。包裹式则会直接将要使用的学习器的性能作为特征子集的评价准则，最终效果优于过滤式。 

1. LVW（Las Vegas Wrapper）
    在Las Vegas方法框架下，使用随机策略进行特征子集搜索，并使用交叉验证的方式来评估当前的特征子集与原有特征子集的的好坏。若当前特征子集的误差更小，或者误差相同的情况下特征数更少，则保留当前特征子集。
    
    由于每次特征子集的评价都需要训练学习器，因此开销较大。给定时间内不一定能够给出解。

2. RFE（Recursive Feature Elimination）

## 嵌入式（embedding）

嵌入式在训练模型的时候就会学习哪个特征对模型的准确度贡献最大，将特征选择与模型的训练过程融为一体，两者在同一个优化过程中完成。

最常用的嵌入式方法就是正则化。

1. 正则化
    * L1/LASSO（Least Absolute Shrinkage and Selection Operator）
    * L2/Ridge Regression

2. 树
    基于树的模型在训练过程中就进行了特征选择，选择的依据有两种，
    
    * Mean decrease impurity
        使用信息增益、信息增益率和基尼指数来选择特征，目的是使得结点的纯度越来越高。
        
    * Mean decrease accuracy
        通过直接测量每个特征对模型准确度的影响来选择。具体做法是随机划分训练和测试集，针对某个特征，在保留原有分布的情况下，为这个特征的随机赋值，然后测量模型准确度降低的情况。
    
    相关的模型有，
    
    * 决策树
    * GBDT
    * 随机森林

# 特征组合

# 降维

# References

1. [An Introduction to Feature Selection](https://machinelearningmastery.com/an-introduction-to-feature-selection/)
2. [使用sklearn做单机特征工程](http://www.cnblogs.com/jasonfreak/p/5448385.html)
3. [使用sklearn优雅地进行数据挖掘](http://www.cnblogs.com/jasonfreak/p/5448462.html)
4. [1.13. Feature selection](http://scikit-learn.org/stable/modules/feature_selection.html#feature-selection)
5. [Selecting good features – Part I: univariate selection](http://blog.datadive.net/selecting-good-features-part-i-univariate-selection/)


