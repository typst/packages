// 博士专用封面与题名页；所有数值来源见 docs/博士规格.md。
#import "../layouts/doc.typ": 基线偏移, 页面坐标
#import "../utils/style.typ": 字体

#let profile(degree) = if degree == "professional" {
  (
    cover-title: (14.2pt, 411.1pt, 425.2pt),
    cover-fields: (99.25pt, 524.5pt, 255.1pt),
    school: (0.5pt, 113.75pt, 439.35pt),
    cn-title: (0.5pt, 311.5pt, 439.35pt),
    cn-fields: (127.6pt, 453.35pt, 255.75pt),
    info-left: (5.9pt, 8.45pt, 127.9pt),
    info-right: (309pt, 8.45pt, 127.85pt),
    en-title: (0.5pt, -0.15pt, 439.35pt),
    en-middle: (0.5pt, 169.65pt, 439.35pt),
    en-by: (-0.45pt, 510.3pt, 439.35pt),
  )
} else {
  (
    cover-title: (14.2pt, 439.45pt, 425.2pt),
    cover-fields: (99.25pt, 567pt, 269.3pt),
    school: (0pt, 113.4pt, 439.35pt),
    cn-title: (0pt, 311.85pt, 439.35pt),
    cn-fields: (127.6pt, 453.6pt, 297.65pt),
    info-left: (5.65pt, 8.5pt, 127.55pt),
    info-right: (309pt, 8.5pt, 127.55pt),
    en-title: (0pt, 0pt, 439.35pt),
    en-middle: (0pt, 170.1pt, 439.35pt),
    en-by: (0pt, 530.25pt, 439.35pt),
  )
}

// 使用行框顶和字号重建基线，不把 PDF 的 bbox 底边当作基线。
#let 行(框, 内容, size: 14pt, step: 30pt, index: 0, font: 字体.宋体,
  weight: "regular", centered: false) = {
  let (x, y, width) = 框
  let Δ = 基线偏移(step, size)
  place(top + left, dx: 30mm + x, dy: y + index * step,
    box(width: width, {
      set text(font: font, size: size, weight: weight,
        top-edge: Δ, bottom-edge: "baseline")
      set par(first-line-indent: 0pt, justify: false)
      context {
        assert(measure(内容).width <= width,
          message: "博士前置页文字超宽，请缩短字段或将题目显式分行。")
        if centered { align(center, 内容) } else { 内容 }
      }
    }))
}

#let 题目(框, 内容, font) = {
  let 列表 = if type(内容) == str { (内容,) } else { 内容 }
  assert(列表.len() in (1, 2, 3), message: "博士题目须为一至三行。")
  for (i, 文本) in 列表.enumerate() {
    行(框, 文本, size: 22pt, font: font, weight: "bold", centered: true, index: i)
  }
}

#let 有导师(导师) = 导师 != none and 导师 != () and 导师.first() != none
#let 导师文字(导师) = if 有导师(导师) { 导师.filter(x => x != none).join(" ") } else { "" }

#let cover(degree: "academic", blind: false, fonts: (:), info: (:), twoside: false) = {
  set page(header: none, footer: none, numbering: none)
  let f = 字体 + fonts
  let p = profile(degree)
  let 字段 = (("作者姓名", info.author),)
  字段 += if degree == "academic" {
    (("指导教师姓名、职称", 导师文字(info.supervisor)),)
  } else {
    (("学校导师姓名、职称", 导师文字(info.supervisor)),)
  }
  if degree == "professional" and 有导师(info.enterprise-supervisor) {
    字段 += (("企业导师姓名、职称", 导师文字(info.enterprise-supervisor)),)
  }
  字段 += (("申请学位类别", info.degree-name),)
  页面坐标({
    题目(p.cover-title, info.title, f.宋体)
    for (i, (标签, 值)) in 字段.enumerate() {
      let (x, y, width) = p.cover-fields
      let 标签宽 = 标签.clusters().len() * 14pt + 3pt
      行((x, y, width), 标签, index: i, font: f.黑体, weight: "bold")
      let 显示值 = if blind and 标签.contains("姓名") { "" } else { 值 }
      行((x + 标签宽, y, width - 标签宽), 显示值, index: i, font: f.宋体, centered: true)
      place(top + left, dx: 30mm + x + 标签宽,
        dy: y + 30pt * i + 基线偏移(30pt, 14pt) + 1.5pt,
        line(length: width - 标签宽, stroke: 0.4pt))
    }
  })
}

#let title-cn(degree: "academic", blind: false, fonts: (:), info: (:)) = {
  set page(header: none, footer: none, numbering: none)
  let f = 字体 + fonts
  let p = profile(degree)
  let 字段 = (("作者姓名：", info.author),)
  字段 += if degree == "academic" {
    (("一级学科：", info.discipline), ("二级学科（研究方向）：", info.subdiscipline),
      ("学位类别：", info.degree-name), ("指导教师姓名、职称：", 导师文字(info.supervisor)))
  } else {
    (("领　　域：", info.domain), ("学位类别：", info.degree-name),
      ("学校导师姓名、职称：", 导师文字(info.supervisor)))
  }
  if degree == "professional" and 有导师(info.enterprise-supervisor) {
    字段 += (("企业导师姓名、职称：", 导师文字(info.enterprise-supervisor)),)
  }
  字段 += (("学　　院：", info.department),
    ("提交日期：", str(info.submit-date.year) + "年" + str(info.submit-date.month) + "月"))
  页面坐标({
    for (框, 条目, 线x, 线宽) in (
      (p.info-left, (("学校代码", info.school-code), ("分类号", info.clc)), 144.5pt, 52.55pt),
      (p.info-right, (("学　号", if blind { "" } else { info.student-id }), ("密　级", info.secret-level)), 431.9pt, 80.5pt),
    ) {
      for (i, (标签, 值)) in 条目.enumerate() {
        行(框, 标签, size: 10.5pt, step: 16.35pt, index: i, font: f.宋体, weight: "bold")
        行((线x - 30mm, 框.at(1), 线宽), 值,
          size: 10.5pt, step: 16.35pt, index: i, font: f.宋体, centered: true)
        place(top + left, dx: 线x,
          dy: 框.at(1) + 16.35pt * i + 基线偏移(16.35pt, 10.5pt) + 1.5pt,
          line(length: 线宽, stroke: 0.4pt))
      }
    }
    行(p.school, "西安电子科技大学", size: 26pt, font: f.黑体, weight: "bold", centered: true)
    行(p.school, "博士学位论文", size: 24pt, index: 3, font: f.宋体, weight: "bold", centered: true)
    题目(p.cn-title, info.title, f.宋体)
    for (i, (标签, 值)) in 字段.enumerate() {
      let 显示值 = if blind and 标签.contains("姓名") { "" } else { 值 }
      行(p.cn-fields, [#text(weight: "bold", 标签)#h(2mm)#显示值],
        step: 32pt, index: i, font: f.宋体)
    }
  })
}

#let title-en(degree: "academic", blind: false, fonts: (:), info: (:)) = {
  set page(header: none, footer: none, numbering: none)
  let p = profile(degree)
  let f = ("Times New Roman",)
  let 学科 = if degree == "professional" { info.category-en } else { info.discipline-en }
  let 中部 = ("A dissertation submitted to", "XIDIAN UNIVERSITY",
    "in partial fulfillment of the requirements", "for the degree of " + info.degree-name-en,
    "in " + 学科)
  let 导师 = if degree == "professional" and 有导师(info.enterprise-supervisor-en) {
    (info.supervisor-en, info.enterprise-supervisor-en)
  } else { (info.supervisor-en,) }
  let 月 = ("January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December")
  let 日期 = 月.at(info.submit-date.month - 1) + " " + str(info.submit-date.year)
  页面坐标({
    题目(p.en-title, info.title-en, f)
    for (i, 文本) in 中部.enumerate() {
      行(p.en-middle, 文本, size: 16pt, index: i, font: f, centered: true)
    }
    行(p.en-by, "By", size: 16pt, font: f, centered: true)
    if not blind {
      行(p.en-by, info.author-en, size: 16pt, index: 1, font: f, centered: true)
      for (i, 对) in 导师.enumerate() {
        if 有导师(对) {
          if degree == "professional" {
            行((47.1pt, 570.2pt, 191.6pt), "Supervisor: " + 对.first(),
              size: 16pt, index: i, font: f)
            行((230.85pt, 571.15pt, 219.1pt), "Title: " + 对.at(1, default: ""),
              size: 16pt, index: i, font: f)
          } else {
            行(p.en-by, "Supervisor: " + 导师文字((对.first(),)) + "  Title: " + 对.at(1, default: ""),
              size: 16pt, index: i + 2, font: f, centered: true)
          }
        }
      }
    }
    行(p.en-by, 日期, size: 16pt,
      index: if degree == "professional" { 4 } else { 3 }, font: f, centered: true)
  })
}
