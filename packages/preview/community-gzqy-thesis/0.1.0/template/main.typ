#import "@preview/community-gzqy-thesis:0.1.0": *

#show: community-gzqy-thesis.with(
  title: "论文题目",
  major: "XXXXXXX",
  advisor: "XXX",
  student-id: "202XXXXXXXXX",
  student-name: "XXX",
  year: "2026",
  month: "6",
  abstract-zh: [在此填写中文摘要内容。摘要应简明扼要地概括论文的主要内容，包括研究目的、方法、结果和结论。],
  keywords-zh: ("关键词1", "关键词2", "关键词3"),
  abstract-en: [Write your English abstract here.],
  keywords-en: ("keyword1", "keyword2", "keyword3"),
)

= 绪论

== 研究背景

在此编写研究背景内容。

=== 小节标题

在此编写小节内容。引用参考文献示例 @wang2023python @zhang2024dl。

== 研究意义

在此编写研究意义。

= 相关技术

== 技术一

在此介绍相关技术。

== 技术二

在此介绍相关技术。

= 系统设计与实现

== 总体设计

在此描述系统总体设计。

== 详细设计

在此描述系统详细设计。

= 系统测试

== 测试环境

在此描述测试环境。

== 测试结果

在此描述测试结果与分析。

= 总结与展望

在此总结全文并展望未来工作。

#thesis-bibliography(bibliography("refs.bib", title: none, style: "gb-7714-2015-numeric"))

#thesis-acknowledgement[在此编写致谢内容。]
