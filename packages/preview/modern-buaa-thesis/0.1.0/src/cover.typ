#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "./constant.typ": font-size, font-type
#import "./utils.typ": distr

#let page-break-with-print(is-print: false) = {
  if is-print {
    pagebreak()
    pagebreak()
  } else {
    pagebreak()
  }
}

#let chinese-cover-leading(lib-number: "", stu-id: "") = {
  set text(size: font-size.five, font: font-type.hei, lang: "cn")
  set par(spacing: 1em, leading: 1.5em)
  show: show-cn-fakebold

  v(2.5pt)
  [*中图分类号 ：#lib-number*]
  v(2.5pt)

  v(2.5pt)
  context {
    let max-width = measure([中图分类号]).width
    text(weight: "bold", distr("论文编号", max-width))
    [
      *：100006#stu-id*
    ]
  }
  v(2.5pt)
}

#let chinese-cover-type() = {
  set align(alignment.center)

  set par(spacing: 1em, leading: 1em)

  // set logo
  image("logo.png", height: 1cm)
  v(0.5cm)

  // set type title
  block(text(size: 48pt, font: "STXingkai", [博士学位论文]))
}

#let chinese-cover-title(title: "") = {
  set align(alignment.center)
  set par(spacing: 1.25em, leading: 1.25em)
  show: show-cn-fakebold

  // set title
  v(96pt)
  block(text(size: 32pt, font: font-type.sun, weight: "bold", title, lang: "cn"))
  v(96pt)
}

#let chinese-cover-info(author: "", major: "", teacher: "", college: "") = {
  set text(size: font-size.four, font: font-type.hei, lang: "cn")
  set par(spacing: 1.25em, leading: 1.25em, first-line-indent: (amount: 8em, all: true))

  show par: it => {
    v(2.5pt)
    it
    v(2.5pt)
  }

  [
    作者姓名
    #h(2em)
    #author

    学科专业
    #h(2em)
    #major

    指导教师
    #h(2em)
    #teacher

    培养学院
    #h(2em)
    #college
  ]
}

#let chinese-cover(
  title: "",
  author: "",
  major: "",
  teacher: "",
  college: "",
  lib-number: "",
  stu-id: "",
) = {
  // set library number and thesis number
  chinese-cover-leading(lib-number: lib-number, stu-id: stu-id)

  // computing the leading height, and set the vertical space
  context {
    let height = measure(chinese-cover-leading(lib-number: lib-number, stu-id: stu-id)).height

    v(3.5cm - height)
  }

  chinese-cover-type()

  chinese-cover-title(title: title)

  chinese-cover-info(
    author: author,
    major: major,
    teacher: teacher,
    college: college,
  )
}

#let english-cover-title(title: "", degree: "") = {
  // set english title
  block(text(size: font-size.small-two, font: font-type.hei, weight: "bold", lang: "en", title))

  // set degree
  v(57pt)
  block(text(
    size: font-size.four,
    font: font-type.hei,
    lang: "en",
    "A Dissertation Submitted for the Degree of " + degree,
  ))
  v(114pt)
}

#let english-cover-info(author: "", teacher: "") = {
  set text(size: font-size.small-three, font: font-type.hei, weight: "bold", lang: "en")
  set par(spacing: 1em, leading: 1em, first-line-indent: (amount: 4cm, all: true))
  set align(alignment.left)

  [
    Candidate: #author

    \

    Supervisor: #teacher
  ]

  v(180pt)
}

#let english-cover-college(college: "") = {
  set text(size: font-size.small-three, font: font-type.hei, lang: "en")
  set par(spacing: 1em, leading: 1em)

  // set college
  [
    #college

    Beihang University, Beijing, China
  ]
}

#let english-cover(title: "", degree: "", author: "", teacher: "", college: "") = {
  set page(margin: (top: 6cm, x: 2.5cm, bottom: 3cm))
  set align(alignment.center)

  english-cover-title(title: title, degree: degree)

  // set author and teacher
  english-cover-info(author: author, teacher: teacher)

  // set college
  english-cover-college(college: college)
}

#let title-cover-title(title: "") = {
  set align(alignment.center)
  set par(spacing: 1.25em, leading: 1.25em)

  show: show-cn-fakebold

  block(text(size: font-size.small-two, font: font-type.hei, distr("博士学位论文", 11em), lang: "cn"))

  v(80pt)

  set par(spacing: 1em, leading: 1em)
  block(text(size: font-size.small-one, font: font-type.hei, weight: "bold", title, lang: "cn"))
}

#let title-cover-info(
  author: "",
  degree: "",
  teacher: "",
  teacher-degree: "",
  major: (
    discipline: "",
    direction: "",
    discipline-first: "",
    discipline-direction: "",
  ),
  date: (
    start: "",
    end: "",
    summit: "",
    defense: "",
  ),
) = {
  set text(size: font-size.small-four, font: font-type.sun, lang: "cn")
  set par(justify: true)

  grid(
    columns: (0.8fr, 1fr, 0.8fr, 1fr),
    rows: 2.5em,
    [作者姓名], author, [申请学位级别], degree,
    [指导教师姓名], teacher, [#distr("职称", 4em)], teacher-degree,
    [学科专业], major.discipline, [研究方向], major.direction,
    [一级学科], major.discipline-first, [学科方向], major.discipline-direction,
    [学习时间自], date.start, [至], date.end,
    [论文提交日期], date.summit, [论文答辩日期], date.defense,
    [学位授予单位], [北京航空航天大学], [学位授予日期], [#h(2.3em)年#h(1.45em)月#h(1.48em)日],
  )
}

#let title-cover(
  title: "",
  author: "",
  degree: "",
  teacher: "",
  teacher-degree: "",
  major: (
    discipline: "",
    direction: "",
    discipline-first: "",
    discipline-direction: "",
  ),
  date: (
    start: "",
    end: "",
    summit: "",
    defense: "",
  ),
  lib-number: "",
  stu-id: "",
) = {
  // set library number and thesis number
  chinese-cover-leading(lib-number: lib-number, stu-id: stu-id)

  v(100pt)

  title-cover-title(title: title)

  v(150pt)

  title-cover-info(
    author: author,
    degree: degree,
    teacher: teacher,
    teacher-degree: teacher-degree,
    major: major,
    date: date,
  )
}

#let statement-cover() = {
  set text(size: font-size.small-four, font: font-type.sun, lang: "cn")
  set par(spacing: 1.25em, leading: 1.25em, first-line-indent: (amount: 2em, all: true), justify: true)

  show par: it => {
    v(2.5pt)
    it
    v(2.5pt)
  }

  [
    #set text(size: font-size.three, font: font-type.hei, lang: "cn")
    #set par(spacing: 1em, leading: 1em)
    #set align(alignment.center)

    *关于学位论文的独创性声明*
  ]

  [
    \

    本人郑重声明：所呈交的论文是本人在指导教师指导下独立进行研究工作所取得的成果，论文中有关资料和数据是实事求是的。
    尽我所知，除文中已经加以标注和致谢外，本论文不包含其他人已经发表或撰写的研究成果，也不包含本人或他人为获得北京航空航天大学或其它教育机构的学位或学历证书而使用过的材料。
    与我一同工作的同志对研究所做的任何贡献均已在论文中作出了明确的说明。

    若有不实之处，本人愿意承担相关法律责任。

    \

  ]

  [
    #set text(size: font-size.five)
    学位论文作者签名：#underline("                               ")#h(5em)日期：#h(2.3em)年#h(1.45em)月#h(1.48em)日
  ]

  v(100pt)

  [
    #set text(size: font-size.three, font: font-type.hei, lang: "cn")
    #set par(spacing: 1em, leading: 1em)
    #set align(alignment.center)

    *学位论文使用授权书*
  ]

  [
    \

    本人完全同意北京航空航天大学有权使用本学位论文（包括但不限于其印刷版和电子版），使用方式包括但不限于：保留学位论文，按规定向国家有关部门（机构）送交学位论文，以学术交流为目的赠送和交换学位论文，允许学位论文被查阅、借阅和复印，将学位论文的全部或部分内容编入有关数据库进行检索，采用影印、缩印或其他复制手段保存学位论文。

    保密学位论文在解密后的使用授权同上。

    \

  ]

  [
    #set text(size: font-size.five)
    学位论文作者签名：#underline("                               ")#h(5em)日期： #h(2.3em)年#h(1.45em)月#h(1.48em)日

    指导教师签名：#underline("                                       ")#h(5em)日期： #h(2.3em)年#h(1.45em)月#h(1.48em)日
  ]
}

#let cover(
  title: (zh: "", en: ""),
  author: (zh: "", en: ""),
  teacher: (zh: "", en: ""),
  teacher-degree: (zh: "", en: ""),
  college: (zh: "", en: ""),
  major: (
    discipline: "",
    direction: "",
    discipline-first: "",
    discipline-direction: "",
  ),
  date: (
    start: "",
    end: "",
    summit: "",
    defense: "",
  ),
  degree: (zh: "工学博士", en: "Doctor of Philosophy"),
  lib-number: "",
  stu-id: "",
  is-print: false,
) = {
  chinese-cover(
    title: title.zh,
    author: author.zh,
    major: major.discipline,
    teacher: teacher.zh + "    " + teacher-degree.zh,
    college: college.zh,
    lib-number: lib-number,
    stu-id: stu-id,
  )

  page-break-with-print(is-print: is-print)

  english-cover(
    title: title.en,
    degree: degree.en,
    author: author.en,
    teacher: teacher-degree.en + " " + teacher.en,
    college: college.en,
  )

  page-break-with-print(is-print: is-print)

  title-cover(
    author: author.zh,
    title: title.zh,
    degree: degree.zh,
    teacher: teacher.zh,
    teacher-degree: teacher-degree.zh,
    major: major,
    date: date,
    lib-number: lib-number,
    stu-id: stu-id,
  )
  page-break-with-print(is-print: is-print)

  statement-cover()

  page-break-with-print(is-print: is-print)
}
