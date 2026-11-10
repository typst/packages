// 双语图表排版
#import "style.typ": 字号

// 一个汉字符的宽度，用于间隔
#let char-width = 字号.五号

// 双语图片，图片标题在图片下方
#let bifigure(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bifigure",
  supplement-zh: "图",
  supplement-en: "Figure",
  numbering: "1-1",
  ..args,
) = {
  // 使用 metadata 存储双语标题
  // 存储格式: (中文标题, 英文标题, 图注, 中文前缀, 英文前缀)
  // 创建内部 figure 以便 i-figured 可以处理标签前缀
  let fig = figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata((
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
    )),
    numbering: numbering,
    ..args,
  )

  // 返回 figure，但如果 args 中有 label，我们需要特殊处理
  // i-figured 会自动添加 fig: 前缀到标签
  fig
}

// 双语表格，表格标题在表格上方
#let bitable(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bitable",
  supplement-zh: "表",
  supplement-en: "Table",
  numbering: "1-1",
  ..args,
) = {
  // 使用 metadata 存储双语标题
  // 存储格式: (中文标题, 英文标题, 表注, 中文前缀, 英文前缀)
  // 创建内部 figure 以便 i-figured 可以处理标签前缀
  let fig = figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata((
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
    )),
    numbering: numbering,
    ..args,
  )

  // 返回 figure，但如果 args 中有 label，我们需要特殊处理
  // i-figured 会自动添加 tbl: 前缀到标签
  fig
}

// Show 规则，渲染双语图片标题
// 图片标题在图片下方
#let show-bifigure(fonts, kind: "bifigure") = it => {
  // 从 metadata 提取双语标题
  let (cap-zh, cap-en, note, supp-zh, supp-en) = it.caption.body.value

  // 获取编号
  let num = it.counter.display(it.numbering)

  // 渲染图片主体
  it.body

  // 渲染中文标题
  parbreak()
  set align(center)
  set text(font: fonts.宋体, size: 字号.五号, weight: "bold")
  // 图片标题使用1.25倍行距
  set par(leading: 1.25em)
  // 中文段前6磅，段后0磅
  block(above: 6pt + 1.25em, below: 0pt + 1.25em)[
    #supp-zh #num #h(char-width) #cap-zh
  ]

  // 英文段前0磅，段后12磅
  if cap-en != none {
    block(above: 0pt + 1.25em, below: 12pt)[
      #supp-en #num #h(char-width) #cap-en
    ]
  }

  // 渲染图注（可选）
  if note != none {
    set align(left)
    set par(leading: 1.25em)
    block(above: 6pt + 1.25em, below: 0pt + 1.25em, inset: (left: 2em))[
      *注：* #note
    ]
  }
}

// Show 规则，渲染双语表格标题
// 表格标题在表格上方
#let show-bitable(fonts, kind: "bitable") = it => {
  // 从 metadata 提取双语标题
  let (cap-zh, cap-en, note, supp-zh, supp-en) = it.caption.body.value

  // 获取编号
  let num = it.counter.display(it.numbering)

  // 渲染中文标题：段前6磅，段后0磅
  set align(center)
  set text(font: fonts.宋体, size: 字号.五号, weight: "bold")
  // 表格标题使用1.25倍行距
  set par(leading: 1.25em)
  // 中文段前6磅，段后0磅
  block(above: 6pt + 1.25em, below: 0pt + 1.25em)[
    #supp-zh #num #h(char-width) #cap-zh
  ]

  // 英文段前0磅，段后12磅
  if cap-en != none {
    block(above: 0pt + 1.25em, below: 12pt)[
      #supp-en #num #h(char-width) #cap-en
    ]
  }

  // 渲染表格主体
  it.body

  // 渲染表注（可选）：位于表格下方
  if note != none {
    parbreak()
    set align(left)
    set par(leading: 1.25em)
    block(above: 6pt + 1.25em, below: 0pt + 1.25em, inset: (left: 2em))[
      *注：* #note
    ]
  }
}

// Outline Entry 处理
// 自定义图表目录项，只显示中文标题
#let show-bilingual-outline-entry(fonts) = it => {
  // 获取 figure 的 caption
  let fig = it.element
  let caption = fig.caption

  // 如果 caption 是 metadata，提取中文标题
  if caption != none and caption.body != none {
    let body = caption.body
    if type(body) == metadata {
      let (cap-zh, ..rest) = body.value
      // 只显示中文标题
      it.supplement + " " + fig.counter.display(fig.numbering) + " " + cap-zh
    } else {
      // 非双语 figure，使用默认显示
      it
    }
  } else {
    it
  }
}

// 导出
#let bilingual-figure-rules(fonts) = {
  // 双语图片的 show 规则
  show figure.where(kind: "bifigure"): show-bifigure(fonts, kind: "bifigure")

  // 双语表格的 show 规则
  show figure.where(kind: "bitable"): show-bitable(fonts, kind: "bitable")

  // 自定义图表目录项，只显示中文标题
  show outline.entry.where(level: 1): show-bilingual-outline-entry(fonts)
}
