#import "lib/state.typ": *
#import "lib/const.typ": EVERY_PAGE, EXAM, FIRST_PAGE, HANDOUTS, ODD_PAGE
#import "lib/counter.typ": counter-chapter, counter-question, counter-title
#import "lib/config.typ": a3, a4, heiti, kaiti, roman
#import "lib/tools.typ": page-restart, tag, text-figure, zh-arabic
#import "lib/choice.typ": choices
#import "lib/question.typ": question
#import "lib/paren-fillin.typ": fillin, fillinn, paren, parenn
#import "lib/outline.typ": (
  chapter, cover, draft, exam-info, exam-type, notice, score, score-box, scoring-box, secret, solution, solution-block,
  subject, title,
)

#let setup(
  mode: HANDOUTS,
  paper: a4,
  page-numbering: auto,
  page-align: center,
  gap: 1in,
  show-gap-line: false,
  footer-is-separate: true,
  outline-page-numbering: "I",
  font: roman,
  font-size: 11pt,
  line-height: 2em,
  par-spacing: 2em,
  par-justify: false,
  first-line-indent: 0em,
  heading-numbering: auto,
  heading-hanging-indent: auto,
  h1-size: auto,
  heading-font: heiti,
  heading-color: black,
  heading-top: 10pt,
  heading-bottom: 15pt,
  enum-numbering: "（1.i.a）",
  enum-spacing: 2em,
  enum-indent: 0pt,
  list-marker: ([•], [‣], [–]),
  list-spacing: auto,
  list-indent: 0pt,
  ref-color: rgb("#0a6e96"),
  resume: true,
  watermark: none,
  watermark-color: rgb("#f666"),
  watermark-font: roman,
  watermark-size: 88pt,
  watermark-rotate: -45deg,
  show-answer: false,
  answer-color: blue,
  show-seal-line: true,
  seal-line-student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: table(
      columns: 14,
      inset: .8em,
      [],
    ),
    考场号: table(
      columns: 2,
      inset: .8em,
      [],
    ),
    座位号: table(
      columns: 2,
      inset: .8em,
      [],
    ),
  ),
  seal-line-type: "dashed",
  seal-line-decoration: none,
  seal-line-supplement: "弥封线内不得答题",
  seal-line-scope: EVERY_PAGE,
  doc,
) = {
  assert(mode in (HANDOUTS, EXAM), message: "mode expected " + HANDOUTS + ", " + EXAM)
  mode-state.update(mode)

  assert(
    type(font) == array and type(heading-font) == array,
    message: "font expected array",
  )

  // 为页码添加在不同模式下的默认值
  if page-numbering == auto {
    page-numbering = "1 / 1"
    if mode == EXAM {
      page-numbering = zh-arabic(prefix: context {
        subject-state.get()
        import "lib/const.typ": SOLUTION
        if (mode-state.get() == SOLUTION) [参考答案] else [试题]
      })
    }
  }

  assert(
    (type(page-numbering), type(outline-page-numbering)).all(item => item in (str, function, type(none))),
    message: "page numbering expected str, function, none",
  )

  paper = a4 + paper
  let paper-columns = paper.columns
  let margin = paper.margin

  let gap-line = if paper-columns > 1 and show-gap-line {
    line(angle: 90deg, length: 100% - margin * 2, stroke: .5pt)
  }

  watermark = if watermark != none {
    place(horizon)[
      #set par(leading: .5em)
      #set text(watermark-size, watermark-color)
      #grid(
        columns: paper-columns * (1fr,),
        ..paper-columns * (rotate(watermark-rotate, watermark),),
      )
    ]
  }

  // 页码的正则：包含两个1,两个1中间不能是连续空格、包含数字
  // 支持双：阿拉伯数字、小写、大写罗马，带圈数字页码
  let matcher = regex(
    "^\D*1\D*[^\d\s]\D*1\D*$|^\D*i\D*[^\d\s]\D*i\D*$|^\D*I\D*[^\d\s]\D*I\D*$|^\D*①\D*[^\d\s]\D*①\D*$|^\D*⓵\D*[^\d\s]\D*⓵\D*$",
  )

  let is-match = (
    type(page-numbering) == function
      or (
        page-numbering != none and matcher in page-numbering
      )
  )

  let seal-line = if mode == EXAM and show-seal-line {
    assert(
      seal-line-scope in (EVERY_PAGE, FIRST_PAGE, ODD_PAGE),
      message: "seal-line-scope expected " + EVERY_PAGE + ", " + FIRST_PAGE + ", " + ODD_PAGE,
    )
    assert(
      seal-line-decoration in ("text", "circle", none),
      message: "seal-line-decoration expected 'text', 'circle', none",
    )
    import "lib/tools.typ": _create-seal
    _create-seal = _create-seal.with(
      line-type: seal-line-type,
      decoration: seal-line-decoration,
      supplement: seal-line-supplement,
      rotate-deg: -90deg,
      rotate-origin: left + bottom,
    )
    let seal = (first: _create-seal(info: seal-line-student-info))
    if seal-line-scope != FIRST_PAGE {
      seal.insert("left", _create-seal())
      if seal-line-scope == EVERY_PAGE {
        seal.insert("right", _create-seal(rotate-deg: 90deg, rotate-origin: right + bottom))
      }
    }
    seal
  }

  let is-odd-r-even-l = page-align == "odd-r-even-l"
  footer-is-separate = paper-columns == 2 and footer-is-separate and not is-odd-r-even-l

  let flipped = paper.flipped

  let _footer(label, label-is-current-total-format: false, is-outline-page: false) = {
    if label == none { return }
    let current = counter(page).get()
    let final = counter(page).final().last()
    let chapter-first-last-pages = chapter-pages-state.final()
    let (first-page, last-page, total-page) = chapter-first-last-pages.at(counter-title.get().first() - 1, default: (
      first-page: 1,
      last-page: final,
      total-page: final,
    ))

    if label-is-current-total-format { current.push(total-page) }

    let _numbering = numbering(label, ..current)
    // 处于分栏下且左右页脚分离
    if footer-is-separate {
      current.first() += 1
      grid(
        columns: (1fr, 1fr),
        align: center + horizon,
        // 左页码
        _numbering,
        // 右页码
        numbering(label, ..current),
      )
      counter(page).step()
    } else {
      // 页面的页脚是未分离, 则让奇数页在右侧，偶数页在左侧
      align(
        if is-odd-r-even-l {
          if calc.odd(current.first()) { right } else { left }
        } else { page-align },
        _numbering,
      )
    }

    // 添加弥封线
    if mode-state.get() == EXAM and seal-line != none and not is-outline-page {
      let current-page = current.first()
      let width = page.height
      if flipped {
        width = page.width
        if footer-is-separate { current-page -= 1 }
      }

      place(
        bottom,
        dx: -1em,
        dy: -margin,
        block(width: width - margin * 2)[
          //当前章节第一页弥封线
          #if current-page == first-page {
            seal-line.first
            return
          }

          #if seal-line-scope == FIRST_PAGE { return }

          // 其它页码是否加弥封线的算法
          #(current-page -= first-page - 1) // 在组多套试卷时，重新把页码按照1，2，3，4... 重新计算
          // 分页时，一页纸页码增加 2
          #if flipped and footer-is-separate {
            current-page = calc.ceil(current-page / 2)
          }

          #if calc.odd(current-page) {
            seal-line.left
            return
          }

          #if seal-line-scope == ODD_PAGE { return }

          #move(
            dx: if flipped { page.height } else { page.width } - margin * 2 - 100% + 2em,
            seal-line.right,
          )
        ],
      )
    }
  }

  set page(
    ..paper,
    background: gap-line,
    foreground: watermark,
    footer: context _footer(
      page-numbering,
      label-is-current-total-format: is-match,
    ),
  )
  set columns(gutter: gap)

  set outline(
    target: if mode == EXAM { <chapter> } else { heading },
    title: text(1.5em)[目#h(1em)录],
  )
  show outline: it => {
    set page(footer: _footer(outline-page-numbering, is-outline-page: true))
    align(center, it)
    pagebreak(weak: true)
    counter(page).update(1)
  }

  set par(
    leading: line-height,
    spacing: par-spacing,
    first-line-indent: (amount: first-line-indent, all: true),
    justify: par-justify,
  )
  set text(font: font, font-size)

  if heading-numbering == auto {
    heading-numbering = "1.1.1.1.1."
    if mode == EXAM {
      heading-numbering = (..item) => numbering("一、", ..item) + h(-.3em)
      heading-hanging-indent = 2em
    }
  }
  set heading(
    numbering: heading-numbering,
    hanging-indent: heading-hanging-indent,
    bookmarked: if mode == EXAM {
      false
    } else { auto },
  )
  // 试卷模式下，书签只显示章节
  show <chapter>: set heading(bookmarked: true)
  if h1-size == auto {
    h1-size = font-size
    if mode == HANDOUTS { h1-size = 1em }
  }
  show heading: it => {
    set par(leading: 1.3em)
    set text(h1-size) if it.level == 1
    v(heading-top)
    text(heading-color, font: heading-font + text.font, it)
    v(heading-bottom)
    if not resume { counter-question.update(0) }
  }

  set enum(numbering: enum-numbering, spacing: enum-spacing, indent: enum-indent)
  set list(marker: list-marker, spacing: list-spacing, indent: list-indent)
  set table.cell(align: horizon + center, stroke: .5pt)
  set underline(offset: .25em)

  show ref: set text(ref-color)
  import "lib/const.typ": QUESTION
  show figure.where(kind: QUESTION): it => {
    set block(breakable: true)
    align(left, it.body)
  }

  set math.cases(gap: 1em)
  set math.equation(numbering: "（1）", supplement: [Eq -]) if mode == HANDOUTS
  show math.equation: set text(font: font)
  import "lib/const.typ": INLINE_MATH_SPACE
  let space = h(INLINE_MATH_SPACE, weak: true)
  show math.equation.where(block: false): it => space + math.display(it) + space
  let pi = if font == roman { "" + [_π_] } else [\u{03c0}]
  show "π": pi
  show "∥": [#space\//#space]
  show "∅": set text(font: "New Computer Modern Math", features: ("cv01",))

  // 中文着重号
  let han-zi = regex("\p{Han}")
  show strong: content => {
    show han-zi: it => box(place(text("·", .8em), dx: .45em, dy: .75em) + it)
    content.body
  }

  if show-answer {
    answer-state.update(true)
    answer-color-state.update(answer-color)
  }

  doc
}

