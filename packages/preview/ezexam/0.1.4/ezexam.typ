#import "utils/outline.typ": *
#import "utils/question.typ": answer, fillin, fillinn, paren, parenn, question, score, solution, text-figure
#import "utils/choice.typ": *

#let setup(
  mode: HANDOUTS,
  paper: a4,
  page-numbering: auto,
  page-align: center,
  gap: 1in,
  show-gap-line: false,
  footer-is-separate: true,
  outline-page-numbering: "⚜ I ⚜",
  font-size: 11pt,
  font: source-han,
  font-math: source-han,
  line-height: 2em,
  par-spacing: 2em,
  first-line-indent: 0em,
  heading-numbering: auto,
  heading-hanging-indent: auto,
  heading-size: auto,
  heading-font: hei-ti,
  heading-color: luma(0%),
  heading-top: 10pt,
  heading-bottom: 15pt,
  enum-numbering: "（1.1.i.a）",
  enum-spacing: 2em,
  enum-indent: 0pt,
  show-watermark: false,
  watermark: "ezexam",
  watermark-color: red,
  watermark-font: source-han,
  watermark-size: 88pt,
  watermark-rotate-degree: -45deg,
  watermark-opacity: -66%,
  show-answer: false,
  answer-color: blue,
  show-seal-line: true,
  seal-line-student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: inline-square(14),
    考场号: inline-square(2),
    座位号: inline-square(2),
  ),
  seal-line-type: "dashed",
  seal-line-supplement: "弥封线内不得答题",
  doc,
) = {
  mode-state.update(mode)
  let _custom-footer(label) = context {
    if label == none { return }
    let _label = label
    if label == auto {
      if mode == EXAM {
        _label = zh-arabic(suffix: "试题")
      } else {
        _label = "1 ✏ 1"
      }
    }
    // 如果传进来的label包含两个1,两个1中间不能是连续空格、包含数字
    // 支持双：阿拉伯数字、小写、大写罗马，带圈数字页码
    let reg-1 = "^[\D]*1[\D]*[^\d\s]+[\D]*1[\D]*$"
    let reg-i = reg-1.replace("1", "i")
    let reg-I = reg-1.replace("1", "I")
    let reg-circled-number = reg-1.replace("1", "①")
    let reg-circled-number2 = reg-1.replace("1", "⓵")
    let reg = reg-1 + "|" + reg-i + "|" + reg-I + "|" + reg-circled-number + "|" + reg-circled-number2

    let current = counter(page).get()
    if (type(_label) == str and regex(reg) in _label) or (type(_label) == function) {
      current += counter(page).final()
    }

    let _numbering = numbering(_label, ..current)

    // 处于分栏下且左右页脚分离
    if page.columns == 2 and footer-is-separate {
      current.at(0) += 1
      grid(
        columns: (1fr, 1fr),
        align: center + horizon,
        // 左页码
        _numbering,
        // 右页码
        numbering(_label, ..current),
      )
      counter(page).step()
      return
    }

    // 页面的页脚是未分离, 则让奇数页在右侧，偶数页在左侧
    let position = page-align
    if not footer-is-separate {
      if calc.odd(current.first()) {
        position = right
      } else {
        position = left
      }
    }
    align(position, _numbering)
  }
  let _custom-header(
    student-info: seal-line-student-info,
    line-type: seal-line-type,
    supplement: seal-line-supplement,
  ) = context {
    if mode != EXAM or not show-seal-line { return }
    // 根据页码决定是否显示弥封线
    // 如果当前页面有<title>,则显示弥封线,并在该章节最后一页的右侧也设置弥封线
    let chapter-location = for value in query(<title>) {
      counter(page).at(value.location())
    }

    if chapter-location == none or chapter-location.len() == 0 { return }
    let current = counter(page).get().first()
    let last = counter(page).final()

    // 获取上一章最后一页的页码,给最后一页加上弥封线
    let chapter-last-page-location = chapter-location.map(item => item - 1) + last
    if page.columns == 2 and footer-is-separate {
      chapter-last-page-location = chapter-location.map(item => item - 2) + (last.first() - 1,)
    }

    // 去除第一章,因为第一章前面没有章节了
    let _ = chapter-last-page-location.remove(0)

    let _margin-y = page.margin * 2
    let _width = page.height - _margin-y
    if page.flipped { _width = page.width - _margin-y }
    block(width: _width)[
      // 判断当前是在当前章节第一页还是章节最后一页
      //当前章节第一页弥封线
      #if chapter-location.contains(current) {
        place(
          dx: -_width - 1em,
          dy: -2em,
        )[
          #rotate(-90deg, origin: right + bottom)[
            #_create-seal(dash: line-type, info: student-info, supplement: supplement)
          ]
        ]
        return
      }

      #if (chapter-last-page-location).contains(current) {
        _width = if page.flipped {
          page.height
        } else { page.width }
        // 章节最后页的弥封线
        place(dx: _width - page.margin - 2em, dy: 2em)[
          #rotate(90deg, origin: left + top, _create-seal(dash: line-type, supplement: supplement))
        ]
      }
    ]
  }
  let _custom-background() = {
    if paper.columns == 2 and show-gap-line {
      line(angle: 90deg, length: 100% - paper.margin * 2, stroke: .5pt)
    }

    if show-watermark {
      set text(size: watermark-size, fill: watermark-color.opacify(watermark-opacity))
      set par(leading: .5em)
      place(horizon)[
        #grid(
          columns: paper.columns * (1fr,),
          ..paper.columns * (rotate(watermark-rotate-degree, watermark),),
        )
      ]
    }
  }
  set page(
    ..paper,
    header: _custom-header(),
    footer: _custom-footer(page-numbering),
    background: _custom-background(),
  )
  set columns(gutter: gap)

  set outline(
    target: if mode == EXAM { <chapter> } else { heading },
    title: text(size: 15pt)[目#h(1em)录],
  )
  show outline: it => {
    set page(header: none, footer: _custom-footer(outline-page-numbering))
    align(center, it)
    pagebreak(weak: true)
    counter(page).update(1) // 正文页码从1开始
  }

  set par(leading: line-height, spacing: par-spacing, first-line-indent: (amount: first-line-indent, all: true))
  set text(
    lang: "zh",
    font: font,
    size: font-size,
    top-edge: "ascender",
    bottom-edge: "descender",
  )

  if heading-numbering == auto {
    if mode == EXAM {
      heading-numbering = "一、"
      heading-hanging-indent = 2.3em
    } else { heading-numbering = "1.1.1" }
  }
  set heading(numbering: heading-numbering, hanging-indent: heading-hanging-indent)
  show heading: it => {
    let size = heading-size
    if size == auto {
      if mode == HANDOUTS { size = 11.5pt } else { size = 10.5pt }
    }
    v(heading-top)
    text(fill: heading-color, font: heading-font, size: size, it)
    v(heading-bottom)
  }
  set enum(numbering: enum-numbering, spacing: enum-spacing, indent: enum-indent)
  set table(stroke: .5pt, align: center)
  set table.cell(align: horizon)

  // 分段函数样式
  set math.cases(gap: 1em)
  show math.equation: it => {
    // features: 一些特殊符号的设置，如空集符号设置更加漂亮
    set text(font: font-math, features: ("cv01",))
    //  1. 行内样式默认块级显示样式; 2. 添加数学符号和中文之间间距
    let space = h(.25em, weak: true)
    space + math.display(it) + space
  }

  if show-answer {
    answer-state.update(true)
    answer-color-state.update(answer-color)
  }

  doc
}
