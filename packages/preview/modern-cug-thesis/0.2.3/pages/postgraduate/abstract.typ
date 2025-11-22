#import "../../utils/style.typ": 字号, 字体

// 研究生中文摘要页
#let postgraduate-abstract(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  keywords: (),
  abstract-title-weight: "bold",
  leading: 20pt - 1.0em,
  spacing: 20pt - 1.0em,
  body,
) = {
  // 默认参数
  fonts = 字体 + fonts

  // 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  [ 
    // #v(1.27em)
    #align(center, par(
      leading: 1.0em, spacing: 1.0em,
      text(
        font: fonts.黑体, size: 字号.小二, 
        weight: abstract-title-weight, "摘　　要", 
        bottom-edge: "descender", top-edge: "ascender", 
        )
      )
    )
    // #v(1.27em)

    #set text(
      font: fonts.宋体, size: 字号.小四,
      bottom-edge: "descender", top-edge: "ascender",
    )
    #set par(leading: leading, justify: true, spacing: spacing)
    #par(first-line-indent: 2em, body)
    *关键词*：#(("",)+ keywords.intersperse("；")).sum()
  ]
}

// 测试代码
// #postgraduate-abstract(
//   keywords: ("关键词1", "关键词2", "关键词3"),
//   [中文摘要是论文内容的简要陈述，是一篇具有独立性和完整性的短文，一般以第三人称语气写成，不加评论和补充的解释。摘要具有自含性，即不阅读论文的全文，就能获得必要的信息。摘要的内容应包括与论文等同的主要信息，供读者确定有无必要阅读全文，也可供二次文献采用。摘要一般应说明研究工作的目的、研究方法、研究成果和结论，要突出本论文的创造性成果。

//   中文摘要力求语言精炼准确，篇幅以一页为宜。如需要，字数可以略多。

//   用外文撰写学位论文时，中文摘要应不少于6000字。

//   摘要中不可出现图、表、化学方程式、非公知公用的符号和术语。

//   关键词在摘要内容后另起一行标明，一般3～5个，之间用分号分开。关键词是为了便于做文献索引和检索工作而从论文中选取出来用以表示全文主题内容信息的单词或术语，应体现论文特色，具有语义性，在论文中有明确出处。应尽量采用《汉语主题词表》或各专业主题词表提供的规范词。]
// ) 