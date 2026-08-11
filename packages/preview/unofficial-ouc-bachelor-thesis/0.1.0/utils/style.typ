#import "@preview/pointless-size:0.1.2": zh
#import "@preview/zebraw:0.6.1": zebraw
#import "@preview/itemize:0.2.0": default-enum-list
#import "chapnum.typ": chap-num
#import "three-line-table.typ": three-line-table
#import "@preview/cuti:0.4.0": fakebold, fakeitalic

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
        align(center, it)
      }
    } else {
      set text(size: zh("四号"))
      it
    }
  }

  show figure.where(kind: table): set figure.caption(position: top)
  show table: three-line-table

  show raw: set text(font: fonts.等宽)
  show raw.where(block: true): set par(leading: .65em)

  show math.equation: set text(font: fonts.数学)
  
  show strong: it => context {
    if "simsun" in text.font {
      fakebold(it)
    } else {
      it
    }
  }
  show emph: it => context {
    if "simsun" in text.font {
      fakeitalic(it)
    } else {
      it
    }
  }


  show bibliography: it => pagebreak(weak: true) + it
  show figure: set block(breakable: true)


  body
}

#let apply-style(title: "", body) = {
  show: chap-num

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

  // show link: it => underline(text(blue, it))

  body
}
