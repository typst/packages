#import "@preview/uo-tsinghua-thesis:0.2.0": conf
#import "设置.typ": settings
#import "其他内容.typ": other_contents, tupian, biaoge
#show: this_doc => conf(..settings, doc: this_doc, others: other_contents)

#import "@preview/cuti:0.3.0": show-cn-fakebold
#show: show-cn-fakebold //中文粗体支持




= 简要教程

== 基础信息设置

论文的基础信息请前往 `论文信息设置.typ`

== 符号和缩略语说明

== 标题

使用等号衔接空格标记标题，等号数量对应标题等级等级，例如：`= 一级标题（章节标题）`、`== 二级标题`，以此类推。

== 正文

普通文本（Regular Text）。 
两侧添加星号显示为*加粗文本（Bold text）*。
两侧添加下划线将中文显示为_楷体_，西文显示为斜体/意大利体（_Italic Text_）。
两侧添加反单引号显示为行内代码（`Inline Code`）样式。
两侧添加Dollar符号显示为数学公式 $dot(z) = 6$ 。
两侧添加斜杠和星号，不显示/*被包含在其中的*/文本。 //在文本前添加双斜杠也可以做到。

段落之间应空行，而不是简单换行。


== 图片

简单图片可以使用 `#tupian()` 添加，如 @图片示例 所示。该函数支持便捷地添加说明文本（figure legend），且图片本体与图题、说明文本不会跨页。

#tupian(
  body:"images/tupianhint.png",
  width: 70%,
  caption: [图题],
  legend: [图片的补充说明文本，即图注。],
  label: <图片示例>
) // width, legend 和 label可以不填

更复杂的图片排版请使用原生的`#figure()`函数搭配`#image()`函数实现，详见 https://typst.app/docs/reference/model/figure/。两种方式添加的图片编号互通。

== 表格

简单表格片可以使用 `#biaoge()` 添加，如@表格示例 所示。该函数支持使用Markdown语法便捷地生成三线表（Powered by `tablem`），且跨页自动生成续表题。

#biaoge(
  caption: [表题],
  body:[
      | *`#biaoge()` 参数名*          | *示例*                  |
      | ---------------------------- | ----------------------- |
      | `caption:`                   | `[Some caption]`        |
      | `body:`                      | `[Markdown-like table]` |
      | `label:`                     | `<Some_Label>`          |
      | ^/*垂直(^)或水平(<)合并单元格*/ | or no label             |
  ],
  label: <表格示例>
)

更复杂的表格排版请使用原生的`#figure()`函数搭配`#table()`函数实现。两种方式添加的表格编号互通。

== 引用

=== 提及本文内容 <提及> 

为了防止正文中小节、表格、图片等编号与实际内容不对应的情况发生，行文时提及被编号的内容应当避免直接输入其编号，而应首先在被提及的内容后使用尖括号 `< >` 添加标签，然后在提及他们的地方使用 `@` 来引用标签。例如：本节是 @提及

=== 引用参考文献

在你的内容管理软件（如Zotero）中将文献库导出为BibLaTeX格式，粘贴到 `参考文献.bib` 中，然后在正文中使用 `@` 来引用即可。例如：我将引用AlphaFold3的论文@AF3。

引用文献的格式可以在`论文信息设置.typ`中设置。详见 https://typst.app/docs/reference/model/bibliography/#parameters-style











// 参考文献

#heading(numbering: none, outlined: true)[参考文献]
#set text(lang: "en")
#bibliography("文献库.bib",
title: none, 
style: "cell" // https://typst.app/docs/reference/model/bibliography/#parameters-style
)
#set text(lang: "zh")