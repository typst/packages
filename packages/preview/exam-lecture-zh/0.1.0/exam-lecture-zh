#import "src/outline.typ": *
#import "src/question.typ": explain, fillin, paren, question, score, text-figure
#import "src/choice.typ": *

#let setup(
  mode: LECTURE,
  paper: a4,
  page-numbering: auto,
  page-align: center,
  gap: 1in,
  show-gap-line: true,
  footer-is-separate: true,
  outline-page-numbering: "⚜ I ⚜",
  font-size: 11pt,
  font: page-font,
  font-math: page-font,
  line-height: 20pt,
  par-spacing: 2em,
  first-line-indent: 2em,
  heading-size: 10.5pt,
  heading-font: hei-ti,
  heading-color: black,
  heading-top: 10pt,
  heading-bottom: 15pt,
  show-answer: false,
  answer-color: blue,
  seal-line-student-info: (:),
  seal-line-type: "dashed",
  seal-line-supplement: "密封线内不得答题",
  doc,
) = {
  mode-state.update(mode)
  let _custom-footer(label, position: center, is-separate: true) = context {
    if label == none { return }
    let _label = label
    if label == auto {
      if mode == EXAM {
        _label = zh-arabic(suffix: "试题")
      } else {
        _label = "1 ✏ 1"
      }
    }
    let current = counter(page).get().first()
    let total = counter(page).final().first()
    let arr = (current,)
    let arr2 = (current + 1,)
    // 如果传进来的label包含两个1,两个1中间不能是连续空格、包含数字
    // 支持双：阿拉伯数字、小写、大写罗马，带圈数字页码
    let reg-1 = "^[\D]*1[\D]*[^\d\s]+[\D]*1[\D]*$"
    let reg-i = reg-1.replace("1", "i")
    let reg-I = reg-1.replace("1", "I")
    let reg-circled-number = reg-1.replace("1", "①")
    let reg-circled-number-2 = reg-1.replace("1", "⓵")
    let reg = reg-1 + "|" + reg-i + "|" + reg-I + "|" + reg-circled-number + "|" + reg-circled-number-2

    if (type(_label) == str and regex(reg) in _label) or (type(_label) == function) {
      arr.push(total)
      arr2.push(total)
    }

    let _page-numbering = numbering(_label, ..arr)
    // 处于分栏模式下的separate
    if page.columns == 2 and is-separate {
      grid(
        columns: (1fr, 1fr),
        align: center + horizon,
        // 左页码
        _page-numbering,
        // 右页码
        numbering(_label, ..arr2),
      )
      counter(page).step()
      return
    }
    // 如果页面的页脚是未分离状态, 则让奇数页在右侧，偶数页在左侧
    let _position = position
    if not is-separate {
      if calc.odd(current) {
        _position = right
      } else {
        _position = left
      }
    }
    align(_position, _page-numbering)
  }

  set page(
    ..paper,
    header: if mode == EXAM and seal-line-student-info.len() > 0 {
      _seal-line(
        student-info: seal-line-student-info,
        dash: seal-line-type,
        supplement: seal-line-supplement,
        is-separate: footer-is-separate,
      )
    },
    footer: _custom-footer(page-numbering, is-separate: footer-is-separate, position: page-align),
    background: if paper.columns == 2 and show-gap-line {
      line(angle: 90deg, length: 100% - paper.margin * 2, stroke: .5pt)
    },
  )
  set columns(gutter: gap)

  set outline(
    target: if mode == EXAM { <chapter> } else { heading },
    title: text(size: 15pt)[目#h(1em)录],
  )
  show outline: it => {
    set page(header: none, footer: _custom-footer(
      outline-page-numbering,
      is-separate: footer-is-separate,
      position: page-align,
    ))
    align(center, it)
    pagebreak(weak: true)
    counter(page).update(1) // 正文页码从1开始
  }

  set par(leading: line-height, spacing: par-spacing, first-line-indent: (amount: first-line-indent, all: true))
  set text(
    lang: "zh",
    font: font,
    size: font-size,
    fallback: true,
  )

  set heading(numbering: "1.1.1 ")
  set heading(numbering: "一、", hanging-indent: 2.3em) if mode == EXAM
  show heading: it => {
    set text(fill: heading-color, font: heading-font)
    set text(size: heading-size) if mode == EXAM
    v(heading-top)
    it
    v(heading-bottom)
    if mode == LECTURE { counter("question").update(0) }
  }
  set enum(numbering: "（1.1.i.a）", spacing: 2em)
  set table(stroke: .5pt, align: center)
  set table.cell(align: horizon)

  // 分段函数样式
  set math.cases(gap: 1em)
  show math.equation: it => {
    // features: 一些特殊符号的设置，如空集符号设置更加漂亮
    set text(font: font-math, features: ("cv01",))
    if it.block {
      math.display(it)
      return
    }
    //  1. 行内样式默认块级显示样式;2.添加数学符号和中文之间间距
    let space = h(0.25em, weak: true)
    space + math.display(it) + space
  }

  if show-answer {
    answer-state.update(true)
    answer-color-state.update(answer-color)
  }
  doc
}


