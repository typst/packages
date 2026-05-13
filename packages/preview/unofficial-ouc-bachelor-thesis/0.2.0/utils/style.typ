#import "@preview/pointless-size:0.1.2": zh
#import "@preview/zebraw:0.6.3": zebraw, zebraw-init
#import "@preview/itemize:0.2.0": default-enum-list
#import "chapnum.typ": chap-num
#import "three-line-table.typ": three-line-table, continue-table
#import "@preview/cuti:0.4.0": fakebold, fakeitalic, show-cn-fakebold

#let global-style(
  fonts: (:),
  body,
) = context {
  set text(lang: "zh", region: "cn")
  set text(font: fonts.宋体, size: zh("小四"))
  set par(
    leading: 24pt
      - zh("小四")
      + (
        measure(text(font: fonts.宋体, size: zh("小四"), top-edge: "ascender", bottom-edge: "descender")[你]).height
          - measure(text(
            font: fonts.宋体,
            size: zh("小四"),
            top-edge: "cap-height",
            bottom-edge: "baseline",
          )[你]).height
      ),
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )

  show heading: it => {
    set text(font: fonts.黑体, weight: "bold")
    set block(spacing: 1.5em)
    if it.level == 1 {
      set text(size: zh("三号"))
      // Note: headings are block elements so it.body acts normally, but we can set align here:
      if it.numbering != none {
        it
      } else {
        set align(center)
        it
      }
    } else {
      set text(size: zh("四号"))
      it
    }
  }

  show raw: set text(font: fonts.等宽)
  show raw.where(block: true): set par(leading: .65em)

  show math.equation: set text(font: fonts.数学)

  show: show-cn-fakebold
  
  show emph: it => context {
    show regex("[\p{script=Han}！-･〇-〰—]+"): it => {
      fakeitalic(it)
    }
    it
  }

  body
}

#let apply-style(title: "", body, chap-num-config: ()) = {
  show: chap-num.with(
    config: chap-num-config
      + (
        (figure.where(kind: image), figure, "1-1"),
        (figure.where(kind: table), figure, "1-1"),
        (figure.where(kind: raw), figure, "1-1"),
        (math.equation, math.equation, "(1-1)"),
      ),
  )
  counter(page).update(1)

  set page(
    header: block(width: 100%, stroke: (bottom: .5pt), inset: (bottom: .15em), align(center, text(
      size: zh("小五"),
      title,
    ))),
    footer: context align(center, {
      set text(size: zh("小五"))
      counter(page).display()
    }),
  )

  set heading(numbering: "1.1")

  show table: three-line-table

  show heading.where(level: 1): it => {
    if counter(heading).get().at(0) > 1 {
      pagebreak(weak: true)
    }
    it
  }

  show: zebraw-init
  show raw.where(block: true): zebraw.with(
    radius: .25em,
    background-color: (luma(245), luma(235)),
    lang: false,
    hanging-indent: true,
  )

  // show raw.where(block: true): set text(bottom-edge: "baseline", top-edge: "ascender")

  show raw.where(block: false): it => {
    // set text(size: .9em)
    box(inset: (x: .25em), fill: luma(240), outset: (y: .25em), radius: .25em, it)
  }

  show: default-enum-list.with(auto-resuming: auto, indent: 1em, label-width: .55em, body-indent: .35em)


  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set par(leading: .65em)
  show table: set par(leading: .65em)
  show table: set text(size: zh("五号"))
  show raw.where(block: true): set par(leading: .65em)
  show figure: set block(breakable: false)
  show figure.where(kind: table): set block(breakable: true)

  show figure.caption: set text(size: zh("五号"))
  show table: it => continue-table.update(false) + it

  body
}
