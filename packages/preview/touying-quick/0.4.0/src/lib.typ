#import "referable.typ": *
#import "utils.typ": *

#let touying-quick(
  title: "",
  subtitle: "",
  heading-idx: true,
  bgimg: bgsky,
  theme: "blue",
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

  let theme = styles.colors.at(theme)

  set list(indent: styles.spaces.list-indent * 1em)
  set enum(indent: styles.spaces.list-indent * 1em)
  set block(
    above: styles.spaces.block-above * 1em,
    below: styles.spaces.block-below * 1em,
    radius: 20%,
  )

  set page(background: image(bgimg, width: 100%))

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

  set heading(numbering: "1.1.") if heading-idx == true

  show heading: heading-size-style.with(lang: lang, styles: styles)
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

  let subt = if subtitle == "" { info.series } else { subtitle }

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
      subtitle: text(
        subt,
        size: styles.sizes.subtitle * 1pt,
        font: styles.fonts.at(lang).subtitle,
      ),
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
      // primary
      primary: rgb(theme.at("primary")),
      primary-dark: rgb(theme.at("primary-dark")),
      primary-darkest: rgb(theme.at("primary-darkest")),
      primary-light: rgb(theme.at("primary-light")),
      primary-lightest: rgb(theme.at("primary-lightest")),
      // secondary
      secondary: rgb(theme.at("secondary")),
      secondary-dark: rgb(theme.at("secondary-dark")),
      secondary-darkest: rgb(theme.at("secondary-darkest")),
      secondary-light: rgb(theme.at("secondary-light")),
      secondary-lightest: rgb(theme.at("secondary-lightest")),
      // tertiary
      tertiary: rgb(theme.at("tertiary")),
      tertiary-dark: rgb(theme.at("tertiary-dark")),
      tertiary-darkest: rgb(theme.at("tertiary-darkest")),
      tertiary-light: rgb(theme.at("tertiary-light")),
      tertiary-lightest: rgb(theme.at("tertiary-lightest")),
      // neutral
      neutral: rgb(theme.at("neutral")),
      neutral-dark: rgb(theme.at("neutral-dark")),
      neutral-darkest: rgb(theme.at("neutral-darkest")),
      neutral-light: rgb(theme.at("neutral-light")),
      neutral-lightest: rgb(theme.at("neutral-lightest")),
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

  [
    #set heading(numbering: none)
    ==
  ]

  slide(align: center + horizon)[
    #text(
      ending,
      size: styles.sizes.ending * 1pt,
      font: styles.fonts.at(lang).ending,
    )
  ]
}
