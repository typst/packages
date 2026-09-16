#import "/utils/style.typ": 字体, 字号
// #import "@preview/cuti:0.3.0": show-cn-fakebold
// #show: show-cn-fakebold

#let contents-page(twoside: false) = {
  show outline.entry: it => {
    if text.lang == "zh" {
      if it.element.numbering != none and it.element.level == 1 {
        strong(link(
          it.element.location(),
          it.indented("第" + it.prefix() + "章", it.inner()),
        ))
      } else if it.element.level == 1 {
        strong(it)
      } else {
        it
      }
    }

    if text.lang == "en" {
      if it.element.numbering != none and it.element.level == 1 {
        strong(link(
          it.element.location(),
          it.indented("Chapter " + it.prefix(), it.inner()),
        ))
      } else if it.element.level == 1 {
        strong(it)
      } else {
        it
      }
    }
  }


  outline()
  pagebreak(weak: true, to: if twoside { "odd" })
  {
    set text(lang: "en")
    show heading.where(level: 1): it => {
      show text: set text(font: "Times New Roman", weight: "bold")
      it
    }
    outline()
  }
  pagebreak(weak: true, to: if twoside { "odd" })
}

