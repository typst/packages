#import "@preview/ctheorems:1.1.2": *

// 文本和代码的字体
#let songti = "SimSun"
#let heiti = "SimHei"
#let kaiti = "SimKai"
#let text-font = "Times New Roman"
#let code-font = "DejaVu Sans Mono"

#let cover(
  title: "全国大学生数学建模竞赛 Typst 模板",
  problem-chosen: "A",
  team-number: "1234",
  college-name: " ",
  member: (
    A: " ",
    B: " ",
    C: " ",
  ),
  advisor: " ",
  date: none,
  body,

) = {

  // cover
  text(size: 14pt)[赛区评阅编号（由赛区组委会填写）：]
  v(-8pt)
  align(left)[#line(length: 96%, stroke: (thickness: 0.8pt, dash: "solid"))]

  show strong: it => {
    show regex("[\p{hani}\s]+"): set text(stroke: 0.02857em)
    it
  }

  align(center)[
    #text(size: 15pt, font: heiti, stroke: 0.02857em)[#date.display("[year]")年高教社杯全国大学生数学建模竞赛] \ \
    #text(size: 16pt, font: songti)[*承 诺 书*]
    #v(8pt)
  ]

  [
    #set par(leading: 13pt)
    #show par: set block(spacing: 13pt)
  
    #par[我们仔细阅读了《全国大学生数学建模竞赛章程》和《全国大学生数学建模竞赛参赛规则》（以下简称 “竞赛章程和参赛规则”，可从http://www.mcm.edu.cn下载）。] 
  
    #par[我们完全清楚，在竞赛开始后参赛队员不能以任何方式，包括电话、电子邮件、“贴吧”、QQ群、微信群等，与队外的任何人（包括指导教师）交流、讨论与赛题有关的问题；无论主动参与讨论还是被动接收讨论信息都是严重违反竞赛纪律的行为。] 

    #par[*我们以中国大学生名誉和诚信郑重承诺，严格遵守竞赛章程和参赛规则，以保证竞赛的公正、公平性。如有违反竞赛章程和参赛规则的行为，我们将受到严肃处理。* ]
  
    #par[我们授权全国大学生数学建模竞赛组委会，可将我们的论文以任何形式进行公开展示（包括进行网上公示，在书籍、期刊和其他媒体进行正式或非正式发表等）。]
  ]
  
  v(15pt)

  let fieldvalue(value, height: 10pt) = [
    #set align(center + horizon)
    #grid(
      rows: (height, auto),
      row-gutter: 0.2em,
      value,
      line(length: 100%, stroke: 0.6pt)
    )
  ]

  block(width: 100%)[
    #grid(
      columns: (315pt, auto),
      text[#h(2em)我们参赛选择的题号（从A/B/C/D/E中选择一项填写）：],
      fieldvalue(problem-chosen),
    )#v(-4pt)
    #grid(
      columns: (285pt, auto),
      text[#h(2em)我们的报名参赛队号（12位数字全国统一编号）：],
      fieldvalue(team-number)
    )#v(-4pt)
    #grid(
      columns: (255pt, auto),
      text[#h(2em)参赛学校（完整的学校全称，不含院系名）：],
      fieldvalue(college-name)
    )
    #v(8pt)
    #grid(
      columns: (175pt, auto),
      row-gutter: 22pt,
      text[#h(2em)参赛队员 (打印并签名) ：1.#h(0.4em)],
      fieldvalue(member.A),
      text[#h(1fr)2.#h(0.4em)],
      fieldvalue(member.B),
      text[#h(1fr)3.#h(0.4em)],
      fieldvalue(member.C),
    )
    #v(8pt)
    #grid(
      columns: (270pt, auto),
      text[#h(2em)指导教师或指导教师组负责人 (打印并签名)：],
      fieldvalue(advisor)
    )

    #text(font: kaiti)[#h(2em)（指导教师签名意味着对参赛队的行为和论文的真实性负责） ]

    #v(8pt)
    #align(right)[#grid(
      columns: (auto, 55pt, auto, 25pt, auto, 25pt, auto),
      column-gutter: 2pt,
      text[日期：],
      fieldvalue(date.display("[year]")),
      text[年],
      fieldvalue(date.display("[month padding:none]")),
      text[月],
      fieldvalue(date.display("[day padding:none]")),
      text[日],
    )]
  ]

  v(8pt)
  text(font: kaiti)[*（请勿改动此页内容和格式。此承诺书打印签名后作为纸质论文的封面，注意电子版论文中不得出现此页。以上内容请仔细核对，如填写错误，论文可能被取消评奖资格。）*]

  pagebreak()

  v(25pt)
  block()[
    #set align(center)
    #grid(
      columns: (100pt, 115pt, 115pt, 115pt),
      column-gutter: 2pt,
      text(size: 14pt)[赛区评阅编号：\ （由赛区填写）],
      fieldvalue(v(30pt), height: 30pt),
      text(size: 14pt)[全国评阅编号：\ （全国组委会填写）],
      fieldvalue(v(30pt), height: 30pt),
    )
    #v(10pt)
    #line(length: 100%, stroke: (thickness: 1.5pt, dash: "solid"))
  ]
  v(4pt)
  align(center)[
    #text(size: 15pt, font: heiti, stroke: 0.02857em)[#date.display("[year]")年高教社杯全国大学生数学建模竞赛]
    #v(6pt)
    #text(size: 16pt, font: songti)[*编 号 专 用 页*]
  ]

  block(width: 100%)[
    #v(32pt)
    #set text(size: 14pt)
    #text[#h(48pt)赛区评阅记录（可供赛区评阅时使用）：]
    #v(-14pt)

    #align(center)[#table(
      columns: (40pt, 56pt, 56pt, 56pt, 56pt, 56pt, 56pt),
      stroke: 0.5pt,
      inset: (y: 18pt),
      par(leading: 4pt)[评 \ 阅 \ 人], "", "", "", "", "", "",
      par(leading: 4pt)[备 \ 注]
    )]

    #v(50pt)
    #par(leading: 4pt)[#h(3em)送全国评阅统一编号: \ #h(3em)（赛区组委会填写）]

  ]

  v(138pt)
  text(font: kaiti)[*（请勿改动此页内容和格式。此编号专用页仅供赛区和全国评阅使用，参赛队打印后装订到纸质论文的第二页上。注意电子版论文中不得出现此页。）*]

  body
}



#let cumcm(
  title: "全国大学生数学建模竞赛 Typst 模板",
  problem-chosen: "A",
  team-number: "1234",
  college-name: " ",
  member: (
    first: " ",
    second: " ",
    third: " ",
  ),
  advisor: " ",
  date: none,
  cover-display: false,

  abstract: [],
  keywords: (),

  body,
) = {

  // 设置正文和代码的字体
  set text(font: (text-font, songti), size: 12pt, lang: "zh", region: "cn")
  show strong: it => {
    show regex("[\p{hani}\s]+"): set text(stroke: 0.02857em)
    it
  }
  show raw: set text(font: code-font, 8pt)

  // 设置文档元数据和参考文献格式
  set document(title: title)

  //设置标题
  set heading(numbering: "1.1 ")

  show heading: it => box(width: 100%)[
    #set text(font: (text-font, heiti))
    #if it.numbering != none { counter(heading).display() }
    #it.body
    #v(8pt)
  ]

  show heading.where(
    level: 1
  ): it => box(width: 100%)[
    #set text(size: 15pt)
    #set align(center)
    #set heading(numbering: "一、")
    #v(4pt)
    #it
  ]

  show heading.where(
    level: 2
  ): it => box(width: 100%)[
    #set text(size: 13pt)
    #it
  ]

  // 配置公式的编号、间距和字体
  set math.equation(numbering: "(1.1)")
  show math.equation: eq => {
    set block(spacing: 0.65em)
    eq
  }
  show math.equation: it => {
    show regex("[\p{hani}\s]+"): set text(font: songti)
    it
  }

  show figure: it => [
    #v(4pt)
    #it
    #v(4pt)
  ]

  show figure.where(
    kind: raw
  ): it => {
    set block(width: 100%, breakable: true)
    it
  }
  
  // 段落配置
  set par(
    first-line-indent: 2em,
    linebreaks: "optimized",
    justify: true
  )

  // 配置列表
  set list(tight: false, indent: 1em, marker: ([•], [◦], [•], [◦]))
  show list: set text(top-edge: "ascender")

  set enum(tight: false, indent: 1em)
  show enum: set text(top-edge: "ascender")

  // 封面显示
  if cover-display == true [
    #show: cover.with(
      title: title,
      problem-chosen: problem-chosen,
      team-number: team-number,
      college-name: college-name,
      member: (
        A: member.A,
        B: member.B,
        C: member.C,
      ),
      advisor: advisor,
      date: date,
    )

    #counter(page).update(0)
  ]

  // 设置页面
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    footer: align(center)[#text(counter(page).display("1"), font: songti, size: 12pt)]
  )

  // 摘要
  align(center)[
    #set text(font: (text-font, heiti))
    #text(size: 16pt)[#title] #v(2pt)
    #text(size: 14pt)[摘 要]
  ]

  abstract

  if keywords != () [
    #v(5pt)
    #h(-2em)#text("关键字：", font: heiti)
    #keywords.join(h(1em))
  ]

  pagebreak()
  
  body
}

#let bib(bibliography-file) = {
  show bibliography: set text(10.5pt)
  set bibliography(title: "参考文献", style: "gb-7714-2015-numeric")
  bibliography-file
  v(12pt)
}

#let appendix-num = counter("appendix")

#let appendix(title, body) = {
  appendix-num.step()
  table(
    fill: (_, row) => if row == 0 or row == 1 {luma(200)} else {none},
    rows: 3,
    columns: 1fr,
    text[*附录 #appendix-num.display()：*],
    text[*#title*],
    body
  )
}

// 定理环境

#let envbox = thmbox.with(
  base: none,
  inset: 0pt,
  breakable: true,
  padding: (top: 0em, bottom: 0em),
)

#let definition = envbox(
  "definition",
  "定义",
).with(numbering: "1")

#let lemma = envbox(
  "lemma",
  "引理",
).with(numbering: "1")

#let corollary = envbox(
  "corollary",
  "推论",
).with(numbering: "1")

#let assumption = envbox(
  "assumption",
  "假设",
).with(numbering: "1")

#let conjecture = envbox(
  "conjecture",
  "猜想",
).with(numbering: "1")

#let axiom = envbox(
  "axiom",
  "公理",
).with(numbering: "1")

#let principle = envbox(
  "principle",
  "定律",
).with(numbering: "1")

#let problem = envbox(
  "problem",
  "问题",
).with(numbering: "1")

#let example = envbox(
  "example",
  "例",
).with(numbering: "1")

#let proof = envbox(
  "proof",
  "证明",
).with(numbering: "1")

#let solution = envbox(
  "solution",
  "解",
).with(numbering: "1")