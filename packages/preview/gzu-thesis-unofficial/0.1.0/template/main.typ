// typst 源码中中文换行会导致编译出的内容多一个空白符，使用此包可移除换行空白
#import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space

// 这是一个用于显示占位文本的包，用于填充文本。实际使用删除即可。
#import "@preview/kouhu:0.2.0": kouhu

// 导入模板
#import "@preview/gzu-thesis-unofficial:0.1.0": *

#show: remove-cjk-break-space

// 关于此函数的详细用法可查看代码仓库中的 manual.pdf
// 其中除了有此函数的详细说明，还包括一些常见问题的解决方案。
#show: gzu-thesis.with(
  title-zh: [基于 Typst 的贵州大学本科生毕业论文（设计）模板],
  title-en: [Guizhou University Undergraduate Graduation Thesis (Design) Template Based on Typst],
  author: [姓名],
  college: [#h(1em)学院名称#h(1em)],
  major: [专业名称],
  class: [班级],
  id: [学号],
  teacher: [指导教师],
  sign: image("sign.jpg", width: 5em), // 签名图片
  // 中文摘要和关键词
  abstract-zh: (
    abstract: kouhu(indices: range(3), builtin-text: "xiangyu"), // 可以在一个单独的文件中写摘要正文，然后在这里使用 #include "文件名.typ"
    keywords: ("Typst模板", "贵州大学毕业论文"),
  ),
  // 英文摘要和关键词
  abstract-en: (
    abstract: lorem(200), // 同样建议在单独的文件中写内容
    keywords: ("Typst template", "GZU thesis"),
  ),
  // 参考文献，必须是 bibliography 函数的返回值，支持 BibTeX 和 Hayagriva 两种类型，
  // 通常可由你的文献管理工具导出。
  bibliography: bibliography("ref.bib"),
  // 致谢正文
  acknowledgment: kouhu(indices: range(7), builtin-text: "nanshanjing"), // 建议在单独的文件中写，用法同摘要部分的描述
  // 附录正文，可省略
  appendix: kouhu(indices: range(2), builtin-text: "zhufu"), // 建议在单独的文件中写，用法同摘要部分的描述
)

// 这里开始写正文部分（论文的正文部分）
= 介绍
== 图片示例
#figure(
  caption: [用于测试的图片],
  image("sign.jpg", width: 20%),
) <fig.1> // 为图片打一个标签
如@fig.1 是一张在雪地里写了文字的图片

== 公式示例
牛顿第二定律的代数表如@eq.nu
#set terms(indent: 4em, separator: [：], spacing: 0.4em)
$ F = m a $ <eq.nu>

== 引用文献和脚注
引用文献 @netwok2020#footnote[必须在前面使用`gzu-thesis`函数时传入正确的`bibliography`才能引用]，
之后便能在参考文献页自动显示。

== 表格示例
=== 非跨页表
#figure(
  caption: [用于测试的表格],
  table(
    columns: 5,
    toprule(),
    table.header[表头1][表头2][表头4][表头4][表头5],
    midrule(),
    ..for _ in range(5) { ([A], [B], [C], [D], [E]) },
    bottomrule(),
  ),
)
=== 跨页表
表格也支持跨页，跨页会显示续表。
#{
  show figure: set block(breakable: true) // 只有使用了这行代码才会跨页
  figure(
    caption: [用于测试的跨页表格],
    table(
      columns: 4,
      toprule(continued: true),
      continued-header(
        columns: 4,
        table.cell(rowspan: 2, align: horizon)[材料],
        table.cell(colspan: 3)[化学元素（%）],
        cmidrule(),
        [C],
        [Al],
        [V],
      ),
      midrule(),
      ..for i in range(5) {
        ([Ti6Al4V], [0.1], [0.2], [0.3])
      },
      bottomrule(),
    ),
  )
}
