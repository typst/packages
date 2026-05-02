#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字体
#import "../utils/custom-numbering.typ": custom-numbering

// 附录布局
#let appendix(
  twoside: false,
  fonts: (:),
  // 重置计数
  reset-counter: true,
  it,
) = {
  fonts = 字体 + fonts

  pagebreak(weak: true, to: if twoside { "odd" })

  context {
    let appendix-headings = query(
      selector(heading.where(level: 1)).after(selector(<appendix-start>)).before(selector(<appendix-end>)),
    )
    let has-appendix = appendix-headings.len() > 0
    let appendix-prefix = if has-appendix {
      numbering("A", 1)
    } else {
      "A"
    }

    let appendix-numbering = if appendix-headings.len() > 1 {
      custom-numbering.with(
        first-level: n => [附录#numbering("A", n)#h(0.7em)],
        depth: 4,
        "A.1 ",
      )
    } else {
      custom-numbering.with(
        first-level: n => [附录#appendix-prefix#h(0.7em)],
        depth: 4,
        "A.1 ",
      )
    }

    set heading(numbering: appendix-numbering)
    if reset-counter {
      counter(heading).update(0)
    }

    show heading: i-figured.reset-counters
    show figure: i-figured.show-figure.with(numbering: if appendix-headings.len() > 1 { "A-1" } else { "A-1" })
    show math.equation.where(block: true): i-figured.show-equation.with(
      numbering: if appendix-headings.len() > 1 { "(A-1)" } else { "(A-1)" },
    )

    [
      #metadata(none) <appendix-start>
      #it
      #metadata(none) <appendix-end>
    ]
  }
}
