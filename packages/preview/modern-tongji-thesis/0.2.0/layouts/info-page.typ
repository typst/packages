#import "../utils/fonts.typ": TJFONT_INFO, TJFONT_HEADING, TJFONT_BODY

// Info page — matches LaTeX's information page
#let make-info-page(
  title: "", subtitle: "", school: "", major: "", infotype: "thesis",
  infoabstract: "", infodrawings: "", infowordcount: "", infothesiswords: "",
  infomaterials: (), header-text: "毕业设计（论文）", fonts: none,
) = {
  let f = if fonts != none { fonts } else { font-family }
  set align(center)
  text(font: f.hei, size: TJFONT_INFO)[同济大学本科#header-text 信息说明页]
  v(1em)

  set align(left)
  set par(first-line-indent: 0pt, leading: 1.2em)
  set text(font: f.song, size: TJFONT_HEADING)

  let field-line(key, value) = {
    [#key： #value]
    v(0.5em)
  }

  // 课题名称: title — subtitle
  field-line("课题名称", {
    let t = title
    if subtitle != "" { t = t + "——" + subtitle }
    t
  })

  // 成果类型: design and engineering both map to 毕业设计
  let is-design = (infotype == "design" or infotype == "engineering")
  let check-box(w: 0.8em, h: 0.8em, ..body) = box(
    width: w, height: h, stroke: 0.5pt, align(center + horizon, ..body),
    baseline: 0.12em,
  )
  let checked-box = check-box(text(size: 0.8em)[✓])
  let unchecked-box = check-box([])
  field-line("成果类型", {
    if is-design { [#checked-box 毕业设计 #h(2em) #unchecked-box 毕业论文] }
    else { [#unchecked-box 毕业设计 #h(2em) #checked-box 毕业论文] }
  })

  field-line("学科专业", major)

  // 内容简述 (300字以内)
  field-line("内容简述（请用300字以内简要概述）", {
    v(0.2em)
    set text(size: TJFONT_BODY)
    set par(first-line-indent: 2em, leading: 0.65em)
    infoabstract
  })

  let ul-box(w, body) = box(
    width: w, outset: (bottom: 3pt), stroke: (bottom: 0.6pt), align(center, body)
  )

  // 毕业设计 (if design or engineering): 图纸 + 字数
  if is-design {
    let dwg = if infodrawings != "" { ul-box(4em, infodrawings) } else { ul-box(4em, []) }
    let wc = if infowordcount != "" { ul-box(6em, infowordcount) } else { ul-box(6em, []) }
    field-line("毕业设计", [主要图纸 #dwg 张，正文总字数 #wc 字])
  } else {
    let wc = if infothesiswords != "" { ul-box(6em, infothesiswords) } else { ul-box(6em, []) }
    field-line("毕业论文", [正文总字数 #wc 字])
  }

  // 随附资料
  field-line("随附资料", {
    if infomaterials.len() > 0 {
      enum(numbering: n => str(n) + ".", ..infomaterials)
    } else {
      v(0.5em)
      []
    }
  })

  [（请列出所有提交的支撑材料名称，如：毕业设计—全套图纸、毕业作品、计算书、程序代码、附录等）]
}
