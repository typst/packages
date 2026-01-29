// lib.typ
#import "@preview/pointless-size:0.1.2": zh
#import "@preview/cjk-spacer:0.2.0": cjk-spacer
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "src/bibliography.typ": *
#import "src/fontset.typ": get-text-fonts, get-math-fonts
#import "src/math.typ": *
#import "src/utils.typ": *

// 配置函数
#let culsc-record(
  session: "",
  serial: "",
  start-year: "",
  start-month: "",
  start-day: "",
  start-time: "",
  end-year: "",
  end-month: "",
  end-day: "",
  end-time: "",
  text-fontset: "web",
  // 文本字体集：可选 "windows", "macos", "web" 或自定义字典
  math-fontset: "web",
  // 数学字体集：可选 "recommend", "windows", "macos", "web" 或自定义字典，使用 "recommend" 效果最佳，但需要自行安装额外字体
  body
) = {
  // 获取字体配置
  let text-fonts = get-text-fonts(text-fontset)
  let math-fonts = get-math-fonts(math-fontset)
  
  show: cjk-spacer // 改善 CJK 文本间距表现

  // 中易系列需要伪粗体
  let body = if text-fontset == "windows" {
    show-cn-fakebold(body)
  } else {
    body
  }
  
  show: doc => gb-math-style(doc, text-fonts, math-fonts) // 国标数学公式

  // 现在 Hayagriva 不支持添加多个文献源
  // citegeist 这一工具又不成熟
  // 而本模板又期望每一实验后都可以打印参考文献
  // 因此暂时不在示例中给出目录用法

  // 隐藏作为目录锚点的 level 1 标题
  // 在 heading 生成之前定义这个规则
  show heading.where(level: 1): it => {
    if it.numbering == none { none } else { it }
  }

  // 设置页面参数
  // 这会强制开始新的一页，确保后续的内容都在新页面上
  set page(
    paper: "a4",
    margin: (top: 3.6925cm + 3.5pt, bottom: 2cm + .75cm, left: 2cm, right: 2cm),
    header-ascent: 1em - 5.5pt,
    header: align(left)[
      #set par(spacing: 0.5em + 2.5pt, leading: 0.5em + 2.5pt, first-line-indent: 0em)
      #set text(font: (text-fonts.en, text-fonts.serif), size: zh(5))
      #text("第", size: zh(-3), font: text-fonts.sans)
      #text(session, size: zh(-3), font: text-fonts.sans)
      #text("届全国大学生生命科学竞赛（科学探究类）实验记录\u{3000}\u{3000}", size: zh(-3), font: text-fonts.sans)
      #text("序号", size: zh(5), font: text-fonts.sans)
      #text("：", size: zh(3), font: text-fonts.sans)
      #h(0.8397645669pt)
      #box(
        align(center)[
          #text(serial, font: text-fonts.sans, size: zh(3))
        ],
        width: 2.5em - 2.2pt,
        stroke: (bottom: 0.5pt),
        outset: (bottom: 1.75pt),
      )
      \     
      #v(3.75mm)
      *实验时间：*
      #underline-box(start-year, width: 3em) *年* #underline-box(start-month, width: 3em) *月* #underline-box(start-day, width: 3em) *日* #underline-box(start-time, width: 4em)
      －
      #underline-box(end-year, width: 3em) *年* #underline-box(end-month, width: 3em) *月* #underline-box(end-day, width: 3em) *日* #underline-box(end-time, width: 4em)
      #v(2mm)
      *请勿出现团队编号、学校、参赛师生信息*
      #v(0.5em + 0.2pt - 2pt)
      #line(length: 100%, stroke: 0.75pt)
    ],
    //footer-descent: 0em,
    numbering: "- 1 -",
  )

  // 重置计数器
  if serial == "01" or serial == "1" {
    counter(page).update(1)
  }
  
  // 标题计数器总是重置，每个实验内部从一开始
  counter(heading).update(0)

  // 插入目录锚点
  // 此时页码已经是重置后的正确页码了
  heading(level: 1, numbering: none, outlined: true)[序号：#serial]

  // 设置标题偏移
  // 这会让正文里的 `=` 变成 level 2，从而不影响上面的 level 1 锚点
  set heading(offset: 1)

  // 设置正文文本格式
  set text(
    font: (text-fonts.en, text-fonts.serif),
    size: zh(-4),
    lang: "zh",
    top-edge: .66375em
  )

  // 引号用宋体
  // 英文引号可以用傻引号""，结合 Typst 的智能引号实现
  show regex("[‘’“”]"): it => {
    text(font: text-fonts.serif, it)
  }
  
  set par(
    spacing: .9625em,
    leading: .9625em,
    first-line-indent:(
      all: true,
      amount: 2em
    ),
    justify: true
  )
  
  // 代码与正文字号相同
  show raw: set text(size: 1.25em)

  // 设置标题编号模式
  set heading(numbering: (..nums) => {
    let nums = nums.pos()
    if nums.len() == 2 {
      [#numbering("一、", nums.last())#h(-0.3em)]
    } else if nums.len() > 2 {
      numbering("1.1", ..nums.slice(1))
    }
  })
  
  // 设置标题格式
  show heading.where(level: 2): it => {
    set par(leading: 1.55em, spacing: 1.55em)
    set text(size: zh(4))
    
    let pos-y = here().position().y
    let top-pad = if pos-y < 4cm { 0.4em + 0.5375em } else { 0.5375em }
    
    pad(top: top-pad)[#it]
    v(1.2em, weak: true)
  }

  // 不知道为什么用循环就不生效了，这里手动写到五级，应该不会更多了...
  show heading.where(level: 3): it => {
    set par(leading: .9625em, spacing: .9625em)
    set text(size: zh(-4))
    v(.9625em, weak: true)//.75
    it
    v(.9625em, weak: true)
  }
  show heading.where(level: 4): it => {
    set par(leading: .9625em, spacing: .9625em)
    set text(size: zh(-4))
    v(.9625em, weak: true)
    it
    v(.9625em, weak: true)
  }
  show heading.where(level: 5): it => {
    set par(leading: .9625em, spacing: .9625em)
    set text(size: zh(-4))
    v(.9625em, weak: true)
    it
    v(.9625em, weak: true)
  }

  // 表题位置
  show figure.where(kind: table): set figure.caption(position: top)

  body
}
