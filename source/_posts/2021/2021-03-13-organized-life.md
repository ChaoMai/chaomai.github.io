---
title: 用org mode管理生活和工作
date: 2021-03-13 22:40:00
categories:
    - emacs
tags:
    - gdt
---

# 起因

notion 是个方便高效的工具，用起来很顺手，但是最近频繁的 Notion Incident 邮件报警看得我着实心烦，很担心哪天要用的时候服务挂了干着急。所以决定寻找 notion 的替代。

![img](/images/2021/03/Snipaste_2021-03-13_22-03-37.png)

# 目标

对我来说，一个高效的任务管理系统需要有一下功能：

1.  任务管理：管理 deadline、与他人共同工作的项目。
2.  材料记录和收集：记录想法、临时的一些思路、可以灵活的添加链接、图片等。
3.  保存和分享：持久化保存数据、不限于工具限制，便于导出分享。
4.  定期 review：达成一个长期的目标需要定期 review 短期的 task，保证方向合理和根据达成情况适当调整目标。
5.  易用：学习和维护成本低，用工具管理 task，而不是被工具牵制。

# 工具选择

基于前面描述的功能点，很多工具就被否定了，

1.  各种 todo 管理 app，以及附带番茄钟计时器的 app，例如：[Pomotodo](https://pomotodo.com/intl/en/)，[Wunderlist](https://www.wunderlist.com/)。 过于简单。
2.  专门的任务管理 app，例如：[omnifocus](https://www.omnigroup.com/omnifocus/)。 不便于添加各种资料。
3.  notion：不便于导出，服务频繁出问题。

最终我选择了 emacs 的 org mode。因为我有 emacs 的使用经历，上手 org-mode 较为容易；其次是会简单的写和改 elisp 代码，配置起来难度不大。

1.  简单但是比 markdown 强大的多的纯文本记录格式。
2.  task 支持状态、标签和时间，能方便的移动 task，便于调整 task 和 review。
3.  agenda view 过滤和查看 task。
4.  通过 pandoc 实现丰富的导出功能，就算哪天不用 org mode，也不影响查阅内容。
5.  添加图片确实不方便，但通过 org-download 也基本能实现拖拽添加。
6.  能**华丽呼哨**的定制，~~感觉这个才是从 notion 换到 emacs 的动力~~。

![img](/images/2021/03/Snipaste_2021-03-13_21-36-25.png)

# 管理框架

参考了[别人的用法](http://www.cachestocaches.com/2020/3/my-organized-life/)，我是这样使用 org mode 的。系统使用 task 和 notes 来组织。将一个 project 分为小的 task，用 notes 来记录具体的结果、图片等临时资料。

## task

每个 task 包含：

-   状态：TODO、NEXT 等
-   时间信息：deadline、defer date
-   tag：用于过滤和标识 task，设置优先级
-   子 task

提供视图来从各种维度过滤和展示 task：

-   周视图：便于 review
-   NEXT 视图

## review

完成 task 并不是目的，只是达成长期目标的过程，需要有定期的 review，

1.  确保 note 记录了所有的重点，清理收集的各种资料。
2.  查看 NEXT 和 WAITING 的 task，进行必要的修改、清理和 follow up。
3.  根据长期目标调整 task，并设置新的 task。

# References

1.  [A Guide to My Organizational Workflow: How to Streamline Your Life](http://www.cachestocaches.com/2020/3/my-organized-life/)
