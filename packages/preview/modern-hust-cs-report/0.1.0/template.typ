#import "@preview/cuti:0.4.0": show-cn-fakebold

#let zihao = (
  z0: 42pt,
  z2: 22pt,
  z3: 16pt,
  zm2: 18pt,
  z4: 14pt,
  zm4: 12pt,
  z5: 10.5pt,
)

#let _font-latin = "Times New Roman"
#let _font-cjk-FangSong = "FangSong"
#let _font-cjk-sans = "Microsoft YaHei"
#let _font-cjk-kaishu = "KaiTi"
#let _font-cjk = "SimSun"



#let _hust_header() = {
  v(15mm)
  stack(
    spacing: 3mm,
    align(center, text(fill: rgb(192, 0, 0), font: _font-cjk-kaishu, size: 15pt, tracking: 0.3em)[
      华 中 科 技 大 学 课 程 设 计 报 告
    ]),
    stack(
      spacing: 0.4mm,
      line(length: 100%, stroke: 0.5pt + blue),
      line(length: 100%, stroke: 0.5pt + blue),
    ),
    
    v(100mm),
  )
}

#let _hust_footer(footline-length: 6.7cm) = {
  grid(
    columns: (1fr, auto, 1fr),
    align: (left, center, right),
    inset: (top: 0pt),
    align(left, rect(width: footline-length, height: 0.4pt, fill: black)),
    align(center, text(font: _font-cjk, size: zihao.z5)[#context counter(page).display("1")]),
    align(right, rect(width: footline-length, height: 0.4pt, fill: black)),
  )
}

#let _underline_field(body, width: 12em, pad: 2pt) = {
  box(
    width: width,
    inset: (bottom: pad),
    stroke: (bottom: 0.6pt),
    outset: (bottom: 3pt),
    body,
  )
}

#let _cover(
  title: "",
  course-name: "",
  author: "",
  school: "",
  class-num: "",
  stu-num: "",
  instructor: "",
  report-date: "",
  logo-path: none,
  line_width: 12em,
) = {
  set page(header: none, footer: none)
  align(
    center,
    stack(
      spacing: 0pt,
      v(5em),
      (if logo-path != none { image(logo-path, height: 1.61cm) } else { none }),
      v(3em),
      text(font: _font-cjk, size: 40pt, spacing: 0.1em)[*课 程 设 计 报 告*],
      v(8em),
      stack(
        dir: ltr,
        spacing: 0.5em,
        text(font: _font-cjk-sans, size: zihao.z2, weight: "bold")[题目：],
        _underline_field(text(font: _font-cjk, size: zihao.z2, weight: "bold")[#title], width: 26em),
      ),
      v(8em),
      {
        set text(font: _font-cjk, size: 18pt, weight: "bold")
        stack(
          spacing: 1.5em,
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*课程名称*],
            _underline_field(course-name, width: line_width),
          ),
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*专业班级*],
            _underline_field(class-num, width: line_width),
          ),
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*学　　号*],
            _underline_field(stu-num, width: line_width),
          ),
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*姓　　名*],
            _underline_field(author, width: line_width),
          ),
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*指导教师*],
            _underline_field(instructor, width: line_width),
          ),
          stack(
            dir: ltr,
            spacing: 1em,
            box(width: 6em)[*报告日期*],
            _underline_field(report-date, width: line_width),
          ),
        )
      },
      v(5em),
      text(font: _font-cjk-FangSong, size: zihao.z3)[*#school*],
    ),
  )
  
  pagebreak()
}

#let _set_outline_style(depth: 2) = {
  show outline: set par(first-line-indent: 0pt)
  
  set outline(indent: auto)
  
  show outline.entry: it => {
    let page-num = counter(page).at(it.element.location()).first()
    let heading-num = if it.element.numbering != none {
      numbering(it.element.numbering, ..counter(heading).at(it.element.location()))
    } else {
      none
    }
    
    let content = if heading-num != none and heading-num.contains(regex("[A-Z]")) {
      [附录#heading-num #it.element.body]
    } else {
      [#heading-num #it.element.body]
    }
    
    if it.level == 1 {
      v(1.5em, weak: true)
      link(it.element.location())[
        #text(font: _font-cjk-sans, size: zihao.z4, weight: "bold")[
          #content
          #box(width: 1fr, repeat[.])
          #h(0.3em)
          #page-num
        ]
      ]
      v(0.5em)
    } else if it.level == 2 {
      link(it.element.location())[
        #text(font: _font-cjk, size: zihao.zm4)[
          #h(3em)
          #if heading-num != none [#heading-num#h(1em)]
          #it.element.body
          #box(width: 1fr, repeat[.])
          #h(0.3em)
          #page-num
        ]
      ]
      v(0.7em, weak: true)
    } else {
      it
    }
  }
  
  v(2em)
  align(center, text(font: _font-cjk-sans, size: zihao.z3, weight: "bold")[
    目#h(2em)录
  ])
  v(1em)
  outline(title: none, depth: depth)
}



#let experimental-report(
  body,
  title: "",
  course-name: "",
  author: "",
  school: "",
  class-num: "",
  stu-num: "",
  instructor: "",
  report-date: "",
  logo-path: none,
  footline-length: 6.7cm,
  toc-depth: 2,
) = {
  show: show-cn-fakebold.with(stroke: 0.04em)
  
  if logo-path == none {
    logo-path = "./HUSTBlack.png"
  }
  
  _cover(
    title: title,
    course-name: course-name,
    author: author,
    school: school,
    class-num: class-num,
    stu-num: stu-num,
    instructor: instructor,
    report-date: report-date,
    logo-path: logo-path,
  )
  
  set page(
    numbering: "I",
    header: _hust_header(),
    footer: _hust_footer(footline-length: footline-length),
    margin: (top: 1.2in),
  )
  counter(page).update(1)
  _set_outline_style(depth: toc-depth)
  pagebreak()
  
  set page(
    numbering: "1",
    header: _hust_header(),
    footer: _hust_footer(footline-length: footline-length),
    margin: (top: 1.2in),
  )
  counter(page).update(1)
  
  
  set text(font: (_font-latin, _font-cjk), size: 13pt)
  set par(first-line-indent: 2em, justify: true)
  
  set heading(numbering: "1.1")
  show heading: set par(first-line-indent: 0pt)
  
  show heading.where(level: 1): it => {
    align(center, text(font: _font-cjk-sans, size: zihao.zm2, weight: "bold")[#counter(heading).display() #it.body])
    v(0.5em)
  }
  
  show heading.where(level: 2): it => {
    v(0.5em)
    text(font: _font-cjk-sans, size: zihao.z4, weight: "bold")[#counter(heading).display() #it.body]
    v(0.3em)
  }
  
  show heading.where(level: 3): it => {
    text(font: _font-cjk-sans, size: zihao.zm4, weight: "bold")[#counter(heading).display() #it.body]
  }
  
  show figure.where(kind: table): set figure(gap: 0.5em)
  show figure.where(kind: table): it => {
    v(0.5em)
    it.caption
    v(0.3em)
    it.body
    v(0.5em)
  }
  
  body
}


// from: https://github.com/DzmingLi/hust-cse-report/blob/main/template.typ , thanks!
#let tbl(content, caption: "") = {
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  figure(
    content,
    caption: text(font: ("Times New Roman", "SimHei"), size: 12pt)[#caption],
    supplement: text(font: _font-cjk)[表],
    numbering: (..nums) => {
      let values = nums.pos()
      if values.len() == 1 {
        context {
          let section = counter(heading).get()
          if section.len() >= 2 {
            numbering("1-1-1", section.at(0), section.at(1), values.at(0))
          } else if section.len() == 1 {
            numbering("1-1", section.at(0), values.at(0))
          } else {
            numbering("1", values.at(0))
          }
        }
      }
    },
    kind: table,
    placement: none,
  )
}

// from: https://github.com/DzmingLi/hust-cse-report/blob/main/template.typ , thanks!
#let fig(image-path, caption: "", width: auto) = {
  figure(
    image(image-path, width: width),
    caption: text(font: ("Times New Roman", "SimHei"), size: 12pt)[#caption],
    supplement: [图],
    numbering: (..nums) => {
      let values = nums.pos()
      if values.len() == 1 {
        context {
          let section = counter(heading).get()
          if section.len() >= 2 {
            numbering("1-1-1", section.at(0), section.at(1), values.at(0))
          } else if section.len() == 1 {
            numbering("1-1", section.at(0), values.at(0))
          } else {
            numbering("1", values.at(0))
          }
        }
      }
    },
  )
}

#let citation(bib-path) = {
  show heading.where(level: 1): it => {
    align(center, text(font: _font-cjk-sans, size: zihao.zm2, weight: "bold")[#it.body])
  }
  heading(level: 1, numbering: none)[参考文献]
  
  bibliography(bib-path, title: none, full: true)
}

#let appendix-section(body) = {
  set heading(numbering: "A")
  counter(heading).update(0)
  show heading.where(level: 1): it => {
    align(center, text(font: _font-cjk-sans, size: zihao.zm2, weight: "bold")[附录#counter(heading).display() #it.body])
  }
  body
}