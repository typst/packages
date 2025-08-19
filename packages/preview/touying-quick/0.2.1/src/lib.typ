#import "referable.typ": *
#import "utils.typ": *

#let touying-quick(
  title: "",
  subtitle: "",
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

  set list(indent: styles.spaces.list-indent * 1em)
  set enum(indent: styles.spaces.list-indent * 1em)
  set block(
    above: styles.spaces.block-above * 1em,
    below: styles.spaces.block-below * 1em,
    radius: 20%,
  )

  set page(background: bgimg)

  set par(
    first-line-indent: (
      amount: styles.spaces.par-indent * 1em,
      all: if lang == "zh" { true } else { false },
    ),
    justify: true,
    leading: styles.spaces.par-leading * 1em,
    spacing: styles.spaces.par-spacing * 1em,
  )

  set text(
    size: styles.sizes.context * 1pt,
    font: styles.fonts.at(lang).context,
    lang: lang,
  )

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }
  show math.equation: equation-numbering-style
  show ref: ref-style.with(lang: lang, names: names)
  show figure: figure-supplement-style
  show figure.where(kind: table): set figure.caption(position: top)
  show raw.where(block: true): code-block-style

  show link: underline

  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: text(
      footer,
      size: styles.sizes.footer * 1pt,
      font: styles.fonts.at(lang).footer,
    ),
    config-info(
      title: text(
        title,
        size: styles.sizes.title * 1pt,
        font: styles.fonts.at(lang).title,
      ),
      subtitle: subtitle,
      author: text(
        author,
        size: styles.sizes.author * 1pt,
        font: styles.fonts.at(lang).author,
      ),
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
  )

  set-inherited-levels(1)
  show: show-theorion

  title-slide()
  outline(
    title: names.sections.at(lang).outline,
    indent: styles.spaces.contents-indent * 1pt,
    depth: 1,
  )
  doc

  slide(align: center + horizon)[
    #text(
      ending,
      size: styles.sizes.ending * 1pt,
      font: styles.fonts.at(lang).ending,
    )
  ]
}
