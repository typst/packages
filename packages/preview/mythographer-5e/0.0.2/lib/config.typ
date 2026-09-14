// 18/02/2026 - Sa1g - Completely rewritten configuration management: one to rule them all!
// Previous strategy was too confusing also for its creator. :|
//
//
// Default values are set in `config`, whenever you want to override something simply set any
// argument to the value you want it to be set.

#import "config-utils.typ": colors, font-family, font-size, font-weight

#let config-area(
  line-fill: colors.titlegold,
  line-thickness: 1.2pt,
  text-fill: colors.darkest,
  font: font-family.main,
  heading-1-size: font-size.Large,
  heading-1-weight: font-weight.normal,
  heading-1-style: smallcaps,
  heading-1-fill: colors.titlered,
  heading-1-font: font-family.main,
  heading-2-size: font-size.normalsize,
  heading-2-weight: font-weight.normal,
  heading-2-style: smallcaps,
  heading-2-fill: colors.darkest,
  heading-2-font: font-family.main,
  text-size: font-size.small,
) = {
  return (
    area: (
      line: (
        fill: line-fill,
        thickness: line-thickness,
      ),
      body: (
        font: font,
        size: text-size,
        fill: text-fill,
      ),
      headers: (
        level-1: (
          size: heading-1-size,
          weight: heading-1-weight,
          style: heading-1-style,
          fill: heading-1-fill,
          font: heading-1-font,
        ),
        level-2: (
          size: heading-2-size,
          weight: heading-2-weight,
          style: heading-2-style,
          fill: heading-2-fill,
          font: heading-2-font,
        ),
      ),
    ),
  )
}

#let config-comment(
  background-fill: colors.PhbLightGreen,
  title-font: font-family.secondary,
  title-size: font-size.small,
  title-style: smallcaps,
  title-weight: font-weight.bold,
  title-fill: colors.darkest,
  fill: colors.darkest,
  font: font-family.secondary,
  size: font-size.small,
  weight: font-weight.normal,
) = {
  return (
    commentbox: (
      title: (
        font: title-font,
        size: title-size,
        style: title-style,
        weight: title-weight,
        fill: title-fill,
      ),
      body: (
        font: font,
        size: size,
        weight: weight,
        fill: fill,
      ),
      background: (
        fill: background-fill,
      ),
    ),
  )
}

#let config-dropcap(
  font: font-family.initial,
) = {
  return (
    dropcap: (
      font: font,
    ),
  )
}

#let config-feat(
  heading-1-fill: colors.titlered,
  heading-1-font: font-family.main,
  heading-1-size: font-size.large,
  heading-1-weight: font-weight.normal,
  heading-1-style: smallcaps,
  heading-2-fill: colors.titlered,
  heading-2-font: font-family.main,
  heading-2-size: font-size.small,
  heading-2-weight: font-weight.normal,
  heading-2-style: emph,
  fill: colors.darkest,
  font: font-family.main,
  size: font-size.small,
  line-fill: colors.titlegold,
  line-thickness: 1.2pt,
) = {
  return (
    feat: (
      headers: (
        level-1: (
          fill: heading-1-fill,
          font: heading-1-font,
          size: heading-1-size,
          weight: heading-1-weight,
          style: heading-1-style,
        ),
        level-2: (
          fill: heading-2-fill,
          font: heading-2-font,
          size: heading-2-size,
          weight: heading-2-weight,
          style: heading-2-style,
        ),
      ),
      body: (
        font: font,
        size: size,
        fill: fill,
      ),
      line: (
        fill: line-fill,
        thickness: line-thickness,
      ),
    ),
  )
}

#let config-item(
  heading-1-fill: colors.titlered,
  heading-1-font: font-family.main,
  heading-1-size: font-size.small,
  heading-1-weight: font-weight.normal,
  heading-1-style: smallcaps,
  heading-2-font: font-family.main,
  heading-2-size: font-size.small,
  heading-2-weight: font-weight.normal,
  heading-2-style: emph,
  font: font-family.main,
  size: font-size.small,
  fill: colors.darkest,
) = {
  return (
    item: (
      headers: (
        level-1: (
          fill: heading-1-fill,
          font: heading-1-font,
          size: heading-1-size,
          weight: heading-1-weight,
          style: heading-1-style,
        ),
        level-2: (
          font: heading-2-font,
          size: heading-2-size,
          weight: heading-2-weight,
          style: heading-2-style,
        ),
      ),
      body: (
        font: font,
        size: size,
        fill: fill,
      ),
    ),
  )
}

#let config-readaloud(
  background-fill: colors.bgtan,
  edges-fill: colors.titlered,
  background-transparentize-fill: 30%,
  font: font-family.secondary,
  size: 0.82em,
  fill: colors.darkest,
) = {
  return (
    readaloud: (
      body: (
        font: font,
        size: size,
        fill: fill,
      ),
      background: (
        fill: background-fill,
        transparentize: background-transparentize-fill,
      ),
      edge: (
        fill: edges-fill,
      ),
    ),
  )
}

#let config-sidebar(
  background-fill: colors.PhbLightGreen,
  edge-fill: colors.darkest,
  title-font: font-family.secondary,
  title-size: font-size.small,
  title-weight: font-weight.normal,
  title-style: smallcaps,
  title-fill: colors.darkest,
  font: font-family.secondary,
  size: font-size.small,
  fill: colors.darkest,
) = {
  return (
    sidebar: (
      title: (
        font: title-font,
        size: title-size,
        weight: title-weight,
        style: title-style,
        fill: title-fill,
      ),
      body: (
        font: font,
        size: size,
        fill: fill,
      ),
      background: (
        fill: background-fill,
      ),
      edge: (
        fill: edge-fill,
      ),
    ),
  )
}

#let config-spell(
  title-fill: colors.titlered,
  font: font-family.main,
  size: font-size.small,
  fill: colors.darkest,
) = {
  return (
    spell: (
      title: (
        fill: title-fill,
      ),
      font: font,
      size: size,
      fill: fill,
    ),
  )
}

#let config-monster(
  style: 2014,
  title-fill: colors.titlered,
  bar-fill: colors.rulered,
  ribbon-fill: colors.statblockribbon,
  background-fill: colors.statblockbg,
  background-transparency-fill: 40%,
  title-font: font-family.main,
  title-weight: font-weight.bold,
  title-style: none,
  title-size: font-size.Large,
  subtitle-size: font-size.large,
  subtitle-style: smallcaps,
  size: font-size.small,
  font: font-family.secondary,
) = {
  return (
    monster: (
      background: (
        fill: background-fill,
        transparency: background-transparency-fill,
      ),
      title: (
        fill: title-fill,
        font: title-font,
        weight: title-weight,
        style: title-style,
        size: title-size,
      ),
      subtitle: (
        size: subtitle-size,
        style: subtitle-style,
      ),
      body: (
        size: size,
        font: font,
      ),
      bar: (
        fill: bar-fill,
      ),
      ribbon: (
        fill: ribbon-fill,
      ),
      style: style,
    ),
  )
}

#let config-table(
  table-title-fill: colors.darkest,
  table-header-fill: colors.darkest,
  table-body-fill: colors.darkest,
  table-cell-fill-primary: colors.PhbLightGreen,
  table-cell-fill-secondary: none,
  table-title-font: font-family.secondary,
  table-title-style: smallcaps,
  table-title-weight: font-weight.bold,
  table-title-size: font-size.large,
  table-header-font: font-family.secondary,
  table-header-weight: font-weight.bold,
  table-body-font: font-family.secondary,
  table-body-size: font-size.small,
) = {
  return (
    table: (
      title: (
        font: table-title-font,
        style: table-title-style,
        weight: table-title-weight,
        size: table-title-size,
        fill: table-title-fill,
      ),
      header: (
        font: table-header-font,
        weight: table-header-weight,
        fill: table-header-fill,
      ),
      body: (
        font: table-body-font,
        size: table-body-size,
        fill: table-body-fill,
      ),
      cell: (
        primary-fill: table-cell-fill-primary,
        secondary-fill: table-cell-fill-secondary,
      ),
    ),
  )
}

#let config-global(
  global-text-fill: colors.darkest,
  global-text-font: font-family.main,
  global-text-size: font-size.normalsize,
  global-text-weight: font-weight.normal,
) = {
  return (
    global: (
      text: (
        font: global-text-font,
        size: global-text-size,
        fill: global-text-fill,
        weight: global-text-weight,
      ),
    ),
  )
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// DEFAULT CONFIG

#let default-config(
  // Info
  title: none,
  subtitle: none,
  author: none,
  date: none,
  // Page
  paper: "us-letter",
  background: image("/assets/paper/default.jpg"),
  lang: "en",
  show-part: true,
  show-chapter: true,
  using-parts: true,
  // Common/Global text
  global-text-fill: colors.darkest,
  global-text-font: font-family.main,
  global-text-size: font-size.normalsize,
  global-text-weight: font-weight.normal,
  // Header
  headers-level-1-fill: colors.titlered,
  headers-level-1-font: font-family.main,
  headers-level-1-weight: font-weight.normal,
  headers-level-1-stroke: 0pt,
  headers-level-1-size: font-size.Huge,
  headers-level-1-linespread: 0.9pt,
  headers-level-1-style: none,
  headers-level-1-to: none, // odd, even
  headers-level-2-fill: colors.titlered,
  headers-level-2-font: font-family.main,
  headers-level-2-weight: font-weight.normal,
  headers-level-2-stroke: 0pt,
  headers-level-2-size: font-size.huge,
  headers-level-2-linespread: 0.9pt,
  headers-level-2-style: none,
  headers-level-3-fill: colors.titlered,
  headers-level-3-font: font-family.main,
  headers-level-3-weight: font-weight.normal,
  headers-level-3-size: font-size.LARGE,
  headers-level-3-linespread: 0.9pt,
  headers-level-3-style: smallcaps,
  headers-level-4-font: font-family.main,
  headers-level-4-weight: font-weight.normal,
  headers-level-4-size: font-size.Large,
  headers-level-4-linespread: 0.9pt,
  headers-level-4-style: smallcaps,
  headers-level-4-line-spacing: 3pt,
  headers-level-4-line-thickness: 1.2pt,
  headers-level-4-fill: colors.titlered,
  headers-level-4-line-fill: colors.titlegold,
  headers-level-5-font: font-family.main,
  headers-level-5-weight: font-weight.normal,
  headers-level-5-size: font-size.large,
  headers-level-5-linespread: 0.9pt,
  headers-level-5-fill: colors.titlered,
  headers-level-5-style: smallcaps,
  headers-level-6-font: font-family.main,
  headers-level-6-style: emph,
  headers-level-6-size: font-size.normalsize,
  headers-level-7-font: font-family.main,
  headers-level-7-style: emph,
  headers-level-7-size: font-size.normalsize,
  // Paragraph
  par-fill: colors.darkest,
  // Subparahraph
  subpar-fill: colors.darkest,
  // Outline
  outline-repeated-symbol: ".",
  outline-indent: true,
  outline-line-fill: colors.titlegold,
  outline-line-thickness: 1.2pt,
  outline-level-1-fill: colors.titlered,
  outline-level-1-font: font-family.main,
  outline-level-1-weight: font-weight.normal,
  outline-level-1-size: font-size.LARGE,
  outline-level-1-style: smallcaps,
  outline-level-2-fill: colors.titlered,
  outline-level-2-font: font-family.main,
  outline-level-2-weight: font-weight.normal,
  outline-level-2-size: font-size.Large,
  outline-level-2-style: smallcaps,
  outline-level-3-fill: colors.titlered,
  outline-level-3-font: font-family.main,
  outline-level-3-weight: font-weight.normal,
  outline-level-3-size: font-size.large,
  outline-level-3-style: none,
  outline-level-4-fill: colors.darkest,
  outline-level-4-font: font-family.main,
  outline-level-4-weight: font-weight.normal,
  outline-level-4-size: font-size.normalsize,
  outline-level-4-style: none,
  outline-level-5-fill: colors.darkest,
  outline-level-5-font: font-family.main,
  outline-level-5-weight: font-weight.normal,
  outline-level-5-size: font-size.normalsize,
  outline-level-5-style: none,
  // Table
  table-title-fill: colors.darkest,
  table-header-fill: colors.darkest,
  table-body-fill: colors.darkest,
  table-cell-fill-primary: colors.PhbLightGreen,
  table-cell-fill-secondary: none,
  table-title-font: font-family.secondary,
  table-title-style: smallcaps,
  table-title-weight: font-weight.bold,
  table-title-size: font-size.large,
  table-header-font: font-family.secondary,
  table-header-weight: font-weight.bold,
  table-body-font: font-family.secondary,
  table-body-size: font-size.small,
  // drop-cap
  dropcap-font: font-family.initial,
  // dnd-area
  area-line-fill: colors.titlegold,
  area-line-thickness: 1.2pt,
  area-text-fill: colors.darkest,
  area-font: font-family.main,
  area-heading-1-size: font-size.Large,
  area-heading-1-weight: font-weight.normal,
  area-heading-1-style: smallcaps,
  area-heading-1-fill: colors.titlered,
  area-heading-1-font: font-family.main,
  area-heading-2-size: font-size.normalsize,
  area-heading-2-weight: font-weight.normal,
  area-heading-2-style: smallcaps,
  area-heading-2-fill: colors.darkest,
  area-heading-2-font: font-family.main,
  area-text-size: font-size.small,
  // dnd-commentbox
  commentbox-background-fill: colors.PhbLightGreen,
  commentbox-title-font: font-family.secondary,
  commentbox-title-size: font-size.small,
  commentbox-title-style: smallcaps,
  commentbox-title-weight: font-weight.bold,
  commentbox-title-fill: colors.darkest,
  commentbox-fill: colors.darkest,
  commentbox-font: font-family.secondary,
  commentbox-size: font-size.small,
  commentbox-weight: font-weight.normal,
  // dnd-feat
  feat-heading-1-fill: colors.titlered,
  feat-heading-1-font: font-family.main,
  feat-heading-1-size: font-size.large,
  feat-heading-1-weight: font-weight.normal,
  feat-heading-1-style: smallcaps,
  feat-heading-2-fill: colors.titlered,
  feat-heading-2-font: font-family.main,
  feat-heading-2-size: font-size.small,
  feat-heading-2-weight: font-weight.normal,
  feat-heading-2-style: emph,
  feat-font: font-family.main,
  feat-size: font-size.small,
  feat-fill: colors.darkest,
  feat-line-fill: colors.titlegold,
  feat-line-thickness: 1.2pt,
  // dnd-item
  item-heading-1-fill: colors.titlered,
  item-heading-1-font: font-family.main,
  item-heading-1-size: font-size.small,
  item-heading-1-weight: font-weight.normal,
  item-heading-1-style: smallcaps,
  item-heading-2-font: font-family.main,
  item-heading-2-size: font-size.small,
  item-heading-2-weight: font-weight.normal,
  item-heading-2-style: emph,
  item-font: font-family.main,
  item-size: font-size.small,
  item-fill: colors.darkest,
  // dnd-readaloud
  readaloud-background-fill: colors.bgtan,
  readaloud-edges-fill: colors.titlered,
  readaloud-transparentize-fill: 30%,
  readaloud-font: font-family.secondary,
  readaloud-size: 0.82em,
  readaloud-fill: colors.darkest,
  // dnd-sidebar
  sidebar-background-fill: colors.PhbLightGreen,
  sidebar-edge-fill: colors.darkest,
  sidebar-title-font: font-family.secondary,
  sidebar-title-size: font-size.small,
  sidebar-title-weight: font-weight.normal,
  sidebar-title-style: smallcaps,
  sidebar-title-fill: colors.darkest,
  sidebar-font: font-family.secondary,
  sidebar-size: font-size.small,
  sidebar-fill: colors.darkest,
  // dnd-spell
  spell-title-fill: colors.titlered,
  spell-font: font-family.main,
  spell-size: font-size.small,
  spell-fill: colors.darkest,
  // dnd-monster
  monster-style: 2014,
  monster-title-fill: colors.titlered,
  monster-bar-fill: colors.rulered,
  monster-ribbon-fill: colors.statblockribbon,
  monster-background-fill: colors.statblockbg,
  monster-background-transparency-fill: 40%,
  monster-title-font: font-family.main,
  monster-title-weight: font-weight.bold,
  monster-title-style: none,
  monster-title-size: font-size.Large,
  monster-subtitle-size: font-size.large,
  monster-subtitle-style: smallcaps,
  monster-size: font-size.small,
  monster-font: font-family.secondary,
  // footer
  footer-image-left: image("../assets/footer/default/r.svg"),
  footer-image-right: image("../assets/footer/default/l.svg"),
  footer-chapter-dx: -6%,
  footer-chapter-dy: 76%,
  footer-number-dx: -15.5%,
  footer-number-dy: 77%,
  footer-scale: 133%,
  footer-fill: colors.titlegold,
  footer-debug-circle-fill: none,
  footer-font: font-family.main,
  footer-size-number: font-size.normalsize, //or normal
  footer-weight-number: font-weight.medium,
  footer-size-chapter: font-size.small,
  footer-weight-chapter: font-weight.medium,
  footer-chapter-style: smallcaps,
) = {
  assert(monster-style == 2014, message: "Currently supported monster styles: `2014`")

  let config = (
    info: (
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
    ),
    page: (
      paper: paper,
      background: background,
      lang: lang,
      show-part: show-part,
      show-chapter: show-chapter,
      using-parts: using-parts,
    ),
    headers: (
      level-1: (
        fill: headers-level-1-fill,
        font: headers-level-1-font,
        weight: headers-level-1-weight,
        stroke: headers-level-1-stroke,
        size: headers-level-1-size,
        linespread: headers-level-1-linespread,
        style: headers-level-1-style,
        to: headers-level-1-to,
      ),
      level-2: (
        fill: headers-level-2-fill,
        font: headers-level-2-font,
        weight: headers-level-2-weight,
        stroke: headers-level-2-stroke,
        size: headers-level-2-size,
        linespread: headers-level-2-linespread,
        style: headers-level-2-style,
      ),
      level-3: (
        fill: headers-level-3-fill,
        font: headers-level-3-font,
        weight: headers-level-3-weight,
        size: headers-level-3-size,
        linespread: headers-level-3-linespread,
        style: headers-level-3-style,
      ),
      level-4: (
        fill: headers-level-4-fill,
        font: headers-level-4-font,
        weight: headers-level-4-weight,
        size: headers-level-4-size,
        linespread: headers-level-4-linespread,
        style: headers-level-4-style,
        line: (
          fill: headers-level-4-line-fill,
          spacing: headers-level-4-line-spacing,
          thickness: headers-level-4-line-thickness,
        ),
      ),
      level-5: (
        fill: headers-level-5-fill,
        font: headers-level-5-font,
        weight: headers-level-5-weight,
        size: headers-level-5-size,
        linespread: headers-level-5-linespread,
        style: headers-level-5-style,
      ),
      level-6: (
        font: headers-level-6-font,
        style: headers-level-6-style,
        size: headers-level-6-size,
      ),
      level-7: (
        font: headers-level-7-font,
        style: headers-level-7-style,
        size: headers-level-7-size,
      ),
    ),
    par: (
      fill: par-fill,
    ),
    subpar: (
      fill: subpar-fill,
    ),
    outline: (
      level-1: (
        fill: outline-level-1-fill,
        font: outline-level-1-font,
        weight: outline-level-1-weight,
        size: outline-level-1-size,
        style: outline-level-1-style,
      ),
      level-2: (
        fill: outline-level-2-fill,
        font: outline-level-2-font,
        weight: outline-level-2-weight,
        size: outline-level-2-size,
        style: outline-level-2-style,
      ),
      level-3: (
        fill: outline-level-3-fill,
        font: outline-level-3-font,
        weight: outline-level-3-weight,
        size: outline-level-3-size,
        style: outline-level-3-style,
      ),
      level-4: (
        fill: outline-level-4-fill,
        font: outline-level-4-font,
        weight: outline-level-4-weight,
        size: outline-level-4-size,
        style: outline-level-4-style,
      ),
      level-5: (
        fill: outline-level-5-fill,
        font: outline-level-5-font,
        weight: outline-level-5-weight,
        size: outline-level-5-size,
        style: outline-level-5-style,
      ),
      line: (fill: outline-line-fill, thickness: outline-line-thickness),
      repeated-symbol: outline-repeated-symbol,
      indent: outline-indent,
    ),
    footer: (
      body: (
        font: footer-font,
        fill: footer-fill,
      ),
      number: (
        size: footer-size-number,
        weight: footer-weight-number,
      ),
      chapter: (
        size: footer-size-chapter,
        weight: footer-weight-chapter,
        style: footer-chapter-style,
      ),
      image: (
        debug: footer-debug-circle-fill,
        scale: footer-scale,
        left: (
          image: footer-image-left,
          number: (
            dx: footer-number-dx,
            dy: footer-number-dy,
          ),
          chapter: (
            dx: footer-chapter-dx,
            dy: footer-chapter-dy,
          ),
        ),
        right: (
          image: footer-image-right,
          number: (
            dx: -footer-number-dx,
            dy: footer-number-dy,
          ),
          chapter: (
            dx: -footer-chapter-dx,
            dy: footer-chapter-dy,
          ),
        ),
      ),
    ),
  )

  config.insert(
    "area",
    config-area(
      line-fill: area-line-fill,
      line-thickness: area-line-thickness,
      text-fill: area-text-fill,
      font: area-font,
      heading-1-size: area-heading-1-size,
      heading-1-weight: area-heading-1-weight,
      heading-1-style: area-heading-1-style,
      heading-1-fill: area-heading-1-fill,
      heading-1-font: area-heading-1-font,
      heading-2-size: area-heading-2-size,
      heading-2-weight: area-heading-2-weight,
      heading-2-style: area-heading-2-style,
      heading-2-fill: area-heading-2-fill,
      heading-2-font: area-heading-2-font,
      text-size: area-text-size,
    ).area,
  )

  config.insert(
    "commentbox",
    config-comment(
      background-fill: commentbox-background-fill,
      title-font: commentbox-title-font,
      title-size: commentbox-title-size,
      title-style: commentbox-title-style,
      title-weight: commentbox-title-weight,
      title-fill: commentbox-title-fill,
      fill: commentbox-fill,
      font: commentbox-font,
      size: commentbox-size,
      weight: commentbox-weight,
    ).commentbox,
  )

  config.insert("dropcap", config-dropcap(font: dropcap-font).dropcap)

  config.insert(
    "feat",
    config-feat(
      heading-1-fill: feat-heading-1-fill,
      heading-1-font: feat-heading-1-font,
      heading-1-size: feat-heading-1-size,
      heading-1-weight: feat-heading-1-weight,
      heading-1-style: feat-heading-1-style,
      heading-2-fill: feat-heading-2-fill,
      heading-2-font: feat-heading-2-font,
      heading-2-size: feat-heading-2-size,
      heading-2-weight: feat-heading-2-weight,
      heading-2-style: feat-heading-2-style,
      font: feat-font,
      size: feat-size,
      fill: feat-fill,
      line-fill: feat-line-fill,
      line-thickness: feat-line-thickness,
    ).feat,
  )

  config.insert(
    "item",
    config-item(
      heading-1-fill: item-heading-1-fill,
      heading-1-font: item-heading-1-font,
      heading-1-size: item-heading-1-size,
      heading-1-weight: item-heading-1-weight,
      heading-1-style: item-heading-1-style,
      heading-2-font: item-heading-2-font,
      heading-2-size: item-heading-2-size,
      heading-2-weight: item-heading-2-weight,
      heading-2-style: item-heading-2-style,
      font: item-font,
      size: item-size,
      fill: item-fill,
    ).item,
  )

  config.insert(
    "readaloud",
    config-readaloud(
      background-fill: readaloud-background-fill,
      edges-fill: readaloud-edges-fill,
      background-transparentize-fill: readaloud-transparentize-fill,
      font: readaloud-font,
      size: readaloud-size,
      fill: readaloud-fill,
    ).readaloud,
  )

  config.insert(
    "sidebar",
    config-sidebar(
      background-fill: sidebar-background-fill,
      edge-fill: sidebar-edge-fill,
      title-font: sidebar-title-font,
      title-size: sidebar-title-size,
      title-weight: sidebar-title-weight,
      title-style: sidebar-title-style,
      title-fill: sidebar-title-fill,
      font: sidebar-font,
      size: sidebar-size,
      fill: sidebar-fill,
    ).sidebar,
  )

  config.insert(
    "spell",
    config-spell(
      title-fill: spell-title-fill,
      font: spell-font,
      size: spell-size,
      fill: spell-fill,
    ).spell,
  )

  config.insert(
    "monster",
    config-monster(
      style: monster-style,
      title-fill: monster-title-fill,
      bar-fill: monster-bar-fill,
      ribbon-fill: monster-ribbon-fill,
      background-fill: monster-background-fill,
      background-transparency-fill: monster-background-transparency-fill,
      title-font: monster-title-font,
      title-weight: monster-title-weight,
      title-style: monster-title-style,
      title-size: monster-title-size,
      subtitle-size: monster-subtitle-size,
      subtitle-style: monster-subtitle-style,
      size: monster-size,
      font: monster-font,
    ).monster,
  )

  config.insert(
    "table",
    config-table(
      table-title-fill: table-title-fill,
      table-header-fill: table-header-fill,
      table-body-fill: table-body-fill,
      table-cell-fill-primary: table-cell-fill-primary,
      table-cell-fill-secondary: table-cell-fill-secondary,
      table-title-font: table-title-font,
      table-title-style: table-title-style,
      table-title-weight: table-title-weight,
      table-title-size: table-title-size,
      table-header-font: table-header-font,
      table-header-weight: table-header-weight,
      table-body-font: table-body-font,
      table-body-size: table-body-size,
    ).table,
  )

  config.insert(
    "global",
    config-global(
      global-text-fill: global-text-fill,
      global-text-font: global-text-font,
      global-text-size: global-text-size,
      global-text-weight: global-text-weight,
    ).global,
  )

  return config
}


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// SHORTCUTS

#let easy-colors(
  primary: red,
  secondary: red,
  tertiary: red,
  fourth: black,
  text-fill: black,
  readaloud-background: colors.bgtan,
  monster-ribbon: colors.statblockribbon,
  monster-background: colors.statblockbg,
  monster-bar: colors.rulered,
) = {
  return default-config(
    global-text-fill: text-fill,
    table-title-fill: text-fill,
    table-header-fill: text-fill,
    table-body-fill: text-fill,
    area-text-fill: text-fill,
    area-heading-2-fill: text-fill,
    outline-level-4-fill: text-fill,
    outline-level-5-fill: text-fill,

    par-fill: fourth,
    subpar-fill: fourth,
    sidebar-edge-fill: fourth,

    headers-level-1-fill: primary,
    headers-level-2-fill: primary,
    headers-level-3-fill: primary,
    headers-level-4-fill: primary,
    headers-level-5-fill: primary,
    outline-level-1-fill: primary,
    outline-level-2-fill: primary,
    outline-level-3-fill: primary,
    feat-heading-1-fill: primary,
    feat-heading-2-fill: primary,
    item-heading-1-fill: primary,
    area-heading-1-fill: primary,
    readaloud-edges-fill: primary,
    spell-title-fill: primary,
    monster-title-fill: primary,

    table-cell-fill-primary: secondary,
    commentbox-background-fill: secondary,
    sidebar-background-fill: secondary,

    feat-line-fill: tertiary,
    area-line-fill: tertiary,
    headers-level-4-line-fill: tertiary,
    outline-line-fill: tertiary,
    footer-fill: tertiary,
    readaloud-background-fill: readaloud-background,
    monster-bar-fill: monster-background,
    monster-ribbon-fill: monster-ribbon,
    monster-background-fill: monster-background,
  )
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// PRE-BUILT STYLES :)

// Pre-Defined config inspired by Tomb of Annihilation
/// 23-11-25 | Don't use it, it's not ready yet!
#let toa-config(lang: "en") = (
  default-config(
    background: image("/assets/paper/toa.jpg"),
    lang: lang,
    // show-part: false,
    // show-chapter: false,
    // using-parts: false,
    table-cell-fill: rgb("d5d9cf"),
    commentbox-background-fill: rgb("d5d9cf"),
    readaloud-background-fill: rgb("dbdcd6"),
    readaloud-edges-fill: rgb("565d59"),
    readaloud-transparentize-fill: 30%,
    sidebar-background-fill: rgb("dbdec8"),
    footer-fill: colors.titlered,
    footer-chapter-dx: 3%,
    footer-chapter-dy: 80%,
    footer-image-left: image("../assets/footer/toa/l.svg"),
    footer-image-right: image("../assets/footer/toa/r.svg"),
    footer-number-dx: -14.3%,
    footer-number-dy: 77%,
    headers-level-2-style: smallcaps,
    outline-level-1-style: none,
    outline-level-1-size: font-size.normalsize,
    outline-level-1-weight: font-weight.bold,
    outline-level-2-style: none,
    outline-level-2-size: font-size.normalsize,
    outline-level-2-weight: font-weight.bold,
    outline-level-3-size: 10pt,
    outline-level-3-weight: "bold",
  )
)
