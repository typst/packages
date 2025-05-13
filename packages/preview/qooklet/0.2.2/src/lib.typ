#import "utils.typ": *
#import "styles.typ": *

#let qooklet(
  title: "",
  info: toml("../config/info.toml").global,
  outline-on: false,
  paper: "iso-b5",
  doc,
) = {
  set-database(config-sections)

  let author = info.author
  let header-cap = info.header-cap
  let footer-cap = info.footer-cap
  let lang = info.lang

  show: common-style

  set page(
    paper: paper-base,
    header: context {
      set text(size: 8pt)
      align-odd-even(header-cap, emph(hydra(1)))
      line(length: 100%)
    },
    footer: context {
      set text(size: 8pt)
      let page_num = here().page()
      align-odd-even(footer-cap, page_num)
    },
    margin: 10%,
  )

  set heading(numbering: "1.1")
  set par(
    first-line-indent: (
      amount: if lang == "zh" { 2em } else { 0em },
      all: if lang == "zh" { true } else { false },
    ),
    justify: true,
    leading: 1em,
    spacing: 1em,
  )

  set block(above: 1em, below: 1em, radius: 20%)
  set text(
    font: config-fonts.family.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )

  set ref(
    supplement: it => {
      if it.func() == heading {
        linguify("chapter")
      } else if it.func() == table {
        it.caption
      } else if it.func() == image {
        it.caption
      } else if it.func() == figure {
        it.supplement
      } else if it.func() == math.equation {
        linguify("eq")
      } else { }
    },
  )

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show heading: it => {
    v(1em, weak: true)
    it
    v(1em, weak: true)
  }

  show: equation-style
  show ref: ref-style
  show figure: figure-style
  show: code-block-style

  align(
    center,
    text(size: 20pt, font: config-fonts.family.at(lang).title)[
      *#title*
    ],
  )

  if outline-on == true {
    show: contents-style
  }

  show link: underline
  show: thmrules
  doc
}
