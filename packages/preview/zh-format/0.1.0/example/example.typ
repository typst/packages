#import "@preview/zh-kit:0.1.0": *
// #import "../lib.typ": *

#show: zh-format

#set page(paper: "a4", margin: 2cm)
#set text(font: ("Times New Roman", "SimSun"), size: 12pt)
#set par(justify: true, first-line-indent: 0em)
#set heading(numbering: "1.1.1")

= zh-format 库功能测试文档

本文档用于测试 zh-format 库的各项中文格式化功能。

== 粗体效果测试

=== 纯中文粗体
这是*普通中文粗体文本*的效果展示。通过描边实现更好的视觉效果。

*完整段落的中文粗体测试：中文字体的粗体处理采用描边方式，能够在不改变字形结构的前提下，实现更加清晰的加粗效果。这种方法特别适合宋体等衬线字体。*

=== 纯英文粗体
This is *bold English text* for testing purposes.

*Complete paragraph in bold English: The bold formatting for English text uses native font weight, which provides optimal rendering for Latin characters.*

=== 中英文混合粗体
*中英文混合 Mixed Chinese and English 粗体效果测试 bold text rendering*

== 下划线效果测试

=== 基本下划线
这是#underline[中文下划线]的效果。

This is #underline[English underline] effect.

#underline[中英文混合下划线 Mixed underline test 测试]

=== 自定义下划线函数 #u
基本效果（需提供 width 参数）：#u(width: 8em)[居中文本]

调整偏移量：#u(width: 8em, offset: 0.4em)[较低的下划线]

+ 填空题示例：

  + 中国的首都是 #u(width: 4em)[]。

  + 1 + 1 = #u(width: 2em)[]。

  + Typst 是一个现代的 #u(width: 6em)[] 系统。

+ 签名栏：#h(1fr) #u(width: 8em)[签名] #h(2em) 日期：#u(width: 6em)[]

== 斜体效果测试

=== 纯中文斜体
这是_中文斜体文本_的效果，使用倾斜变换实现。

_完整段落的中文斜体测试：中文斜体采用 skew 变换，倾斜角度为 -18 度，这样可以在保持字形清晰的同时实现倾斜效果。_

=== 纯英文斜体
This is _italic English text_ using native font style.

_Complete paragraph in italic English: The italic formatting for English text uses the native italic font variant for optimal typography._

=== 中英文混合斜体
_中文倾斜 and English italic 混合效果 mixed rendering test 测试_

== 组合效果测试

=== 粗体 + 下划线
*#underline[中文粗体下划线]*

*#underline[English bold underline]*

=== 粗体 + 斜体
*_中文粗斜体组合_*

*_English bold italic combination_*

=== 斜体 + 下划线
_#underline[中文斜体下划线]_

_#underline[English italic underline]_

=== 三重组合
*_#underline[中文粗斜体下划线]_*

*_#underline[English bold italic underline]_*

== 实际应用场景

=== 文章摘要
*摘要：*本文介绍了一个用于 Typst 的中文格式化库 _zh-format_，该库提供了#underline[更适合中文排版]的粗体、斜体和下划线处理方案。传统的 LaTeX 或其他排版系统往往*直接套用西文规则*，导致中文显示效果不佳。

=== 强调重点
在学习过程中，我们需要特别注意以下几点：
- *重点内容*使用粗体标注
- _次要强调_使用斜体表示
- #underline[关键术语]使用下划线突出

=== 表格中的格式化

#table(
  columns: (1fr, 2fr),
  [*功能*], [*说明*],
  [粗体], [使用 `*text*` 或 `#strong[]` 实现],
  [斜体], [使用 `_text_` 或 `#emph[]` 实现],
  [下划线], [使用 `#underline[]` 或 `#u[]` 实现],
  [自定义宽度], [使用 `#u(width: )[]` 指定固定宽度],
)

== 特殊符号与标点

=== 中文标点符号
*中文标点：，。！？；：""''《》【】（）*

_中文标点：、…—·「」『』〈〉_

=== 混合标点
*Mixed punctuation test: 中文，English, 混合！ What? 测试。*

== 总结

zh-format 库提供了三个主要功能：
+ *setup-bold*：优化中文粗体显示
+ *setup-underline*：改进下划线渲染
+ *setup-emph*：智能处理中英文斜体

通过 `#show: zh-format` 可以一次性应用所有格式化规则，让您的中文文档排版更加美观专业。