#import "deps.typ": *

#let touying-quick(
  title: "",
  subtitle: "",
  author-size: 14pt,
  footer-size: 14pt,
  bgimg: image("config/sky.png", width: 100%),
  info: default-info,
  styles: default-styles,
  names: default-names,
  lang: "en",
  doc,
) = {
  let lang = info.lang
  let author = info.author
  let institution = info.institution
  let footer = info.footer
  let ending = info.ending

  let indent-base = 1.2em

  set block(above: 1em, below: 0.5em)
  set list(indent: indent-base)
  set enum(indent: indent-base)

  set page(background: bgimg)

  set par(
    first-line-indent: 2em,
    justify: true,
    leading: 1em,
    linebreaks: "optimized",
  )

  set text(
    font: styles.fonts.at(lang).context,
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

  show math.equation: it => {
    let count = counter(heading).get()
    let h1 = count.first()
    let h2 = count.at(1, default: 0)
    if it.has("label") {
      math.equation(
        block: true,
        numbering: n => {
          numbering("(1.1)", h1, n)
        },
        it,
      )
    } else {
      it
    }
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let loc = el.location()
      let h1 = counter(heading).at(loc).first()
      let index = counter(math.equation).at(loc).first()
      link(loc, numbering("(1.1)", h1, index + 1))
    } else {
      it
    }
  }

  show figure.caption: it => [
    #it.supplement
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.where(kind: table): set figure.caption(position: top)
  show link: underline

  show: codly-init.with()
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: text(footer, size: footer-size, font: styles.fonts.at(lang).footer),
    config-info(
      title: text(title, size: 40pt),
      subtitle: subtitle,
      author: text(author, size: author-size, font: styles.fonts.at(lang).author),
      date: datetime.today(),
      institution: institution,
      logo: emoji.school,
    ),
    config-colors(
      primary-light: rgb("#fcbd00"),
      secondary: rgb("#3297df"),
      secondary-light: rgb("#ff0000"),
      neutral-lightest: rgb("#ffffff"),
      neutral-dark: rgb("#3297df"),
    ),
    config-common(
      preamble: {
        codly(
          languages: codly-languages,
          display-name: false,
          fill: rgb("#F2F3F4"),
          number-format: none,
          zebra-fill: none,
          inset: (x: .3em, y: .2em),
          radius: .5em,
        )
      },
    ),
  )

  set-inherited-levels(1)
  show: show-theorion

  title-slide()
  outline(title: names.sections.at(lang).outline, indent: 2em, depth: 1)
  doc

  slide(align: center + horizon)[
    #text(ending, font: styles.fonts.at(lang).ending, size: 50pt)
  ]
}
