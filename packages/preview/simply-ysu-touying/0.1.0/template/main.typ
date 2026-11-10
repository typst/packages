// The starter content in this template file is additionally available under
// MIT No Attribution. See LICENSE-MIT-0.txt and README.md for details.

#import "@preview/simply-ysu-touying:0.1.0": *

#show: ysu-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [燕山大学 Touying 演示模板],
    short-title: [YSU Touying 模板],
    subtitle: [面向中文学术汇报的新版 Typst 幻灯片主题],
    author: [张三],
    institution: [燕山大学\\ 信息科学与工程学院],
    date: datetime.today(),
  ),
)

#title-slide(
  extra: [适用于课程汇报、组会、开题、中期检查与学术报告。],
)

#outline-slide()

= 模板概览

== 第一页

#tblock(title: [使用说明])[
  - 本模板基于 Touying 构建，适用于中文学术展示。
  - 中文默认使用楷体，英文默认使用 Times New Roman。
  - 可继续扩展页眉、页脚、分节页和内容块样式。
]
