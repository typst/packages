#import "utils.typ"

#import "@preview/transl:0.1.1": transl
// \RequirePackage{lettrine}
// \RequirePackage{Royal}

// \RequirePackage{bookman}
// \RequirePackage[type1]{gillius2}
// \RequirePackage[notext,nomath,nott]{kpfonts}
// \RequirePackage[T1]{fontenc}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// config-info

#let config-info(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  logo: none,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[CONFIG | INFO]` has unexpected arguments: #args])
  }

  return (
    info: (
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      logo: logo,
    ),
  )
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/// config-page
/// using-parts is used to let the formatter know if you are using parts (=), so that the outline can be correctly indented if you set `style -> indent` to true.
#let config-page(
  paper: "us-letter",
  background: "/assets/paper/default.jpg",
  lang: "en",
  show-part: true,
  show-chapter: true,
  using-parts: true,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[CONFIG | PAGE]` has unexpected arguments: #args])
  }

  return (
    page: (
      paper: paper,
      background: background,
      lang: lang,
      show-part: show-part,
      show-chapter: show-chapter,
      using-parts: using-parts,
    ),
  )
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// config-colors

#let colors = (
  // Global text
  darkest: rgb(0, 0, 0),
  // Page
  bgtan: rgb("F7F2E5"), // DndReadAloud background
  bgtan2018: rgb("F9EFD6"), // lighter version of bgtan from the 2018 Basic Rules
  pagegold: rgb("B89A67"), // pagenumbers and footer
  // Type
  titlered: rgb("58180D"), // titles
  titlegold: rgb("C9AD6A"), // titlerules
  rulered: rgb("9C2B1B"), // triangular rule in statsblock
  contourgray: rgb("CACCBE"), // outline color in part & chapter font
  // Trim
  BrGreen: rgb("E8E6DC"), // Basic Rules
  PhbLightGreen: rgb("E0E5C1"), // PHB Part 1
  PhbLightCyan: rgb("B5CEB8"), // PHB Part 2
  PhbMauve: rgb("DCCCC5"), // PHB Part 3
  PhbTan: rgb("E5D5AC"), // PHB appendix
  DmgLavender: rgb("E3CED3"), // DMG Part 1
  DmgCoral: rgb("F3D7C1"), // DMG Part 2
  DmgSlateGray: rgb("DBE4E4"), // DMG Part 3
  DmgLilac: rgb("D7D4D6"), // DMG appendix
  statblockribbon: rgb("E69A28"), // stat block top/bottom borders (gold)
  statblockbg: rgb("FDF1DC"), // stat block background (tan)
)

#let config-colors(
  global-text: colors.darkest,
  headers-level-1: colors.titlered,
  headers-level-2: colors.titlered,
  headers-level-3: colors.titlered,
  headers-level-4: colors.titlered,
  headers-level-4-line: colors.titlegold,
  headers-level-5: colors.titlered,
  par: colors.darkest,
  subpar: colors.darkest,
  outline-level-1: colors.titlered,
  outline-level-2: colors.titlered,
  outline-level-3: colors.titlered,
  outline-level-4: colors.darkest,
  outline-level-5: colors.darkest,
  outline-line-fill: colors.titlegold,
  table-title: colors.darkest,
  table-header: colors.darkest,
  table-body: colors.darkest,
  table-cell: colors.PhbLightGreen,
  area-text: colors.titlered,
  area-line: colors.titlegold,
  commentbox: colors.PhbLightGreen,
  feat-heading-1: colors.titlered,
  feat-heading-2: colors.titlered,
  feat-line: colors.titlegold,
  item-heading-1: colors.titlered,
  readaloud-background: colors.bgtan,
  readaloud-edges: colors.titlered,
  readaloud-transparentize: 30%,
  sidebar-background: colors.PhbLightGreen,
  sidebar-edge: colors.darkest,
  spell-title: colors.titlered,
  monster-title: colors.titlered,
  monster-bar: colors.rulered,
  monster-ribbon: colors.statblockribbon,
  monster-background: colors.statblockbg,
  monster-background-transparency: 40%,
  footer: colors.titlegold,
  footer-debug-circle: none,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[CONFIG | COLORS]` has unexpected arguments: #args])
  }

  return (
    fill: (
      global: (
        text: global-text,
      ),
      headers: (
        level-1: headers-level-1,
        level-2: headers-level-2,
        level-3: headers-level-3,
        level-4: headers-level-4,
        level-4-line: headers-level-4-line,
        level-5: headers-level-5,
      ),
      par: par,
      subpar: subpar,
      outline: (
        level-1: outline-level-1,
        level-2: outline-level-2,
        level-3: outline-level-3,
        level-4: outline-level-4,
        level-5: outline-level-5,
        line: outline-line-fill,
      ),
      table: (
        title: table-title,
        header: table-header,
        body: table-body,
        cell: table-cell,
      ),
      area: (
        text: area-text,
        line: area-line,
      ),
      commentbox: (
        fill: commentbox,
      ),
      feat: (
        headers: (
          level-1: feat-heading-1,
          level-2: feat-heading-2,
        ),
        line: feat-line,
      ),
      item: (
        headers: (
          level-1: item-heading-1,
        ),
      ),
      readaloud: (
        background: readaloud-background,
        edges: readaloud-edges,
        transparentize: readaloud-transparentize,
      ),
      sidebar: (
        background: sidebar-background,
        edge: sidebar-edge,
      ),
      spell: (
        title: spell-title,
      ),
      monster: (
        title: monster-title,
        bar: monster-bar,
        ribbon: monster-ribbon,
        background: monster-background,
        transparency: monster-background-transparency,
      ),
      footer: (
        fill: footer,
        debug: footer-debug-circle,
      ),
    ),
  )
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// config-fonts

#let font-size = (
  "tiny": 5pt,
  "scriptsize": 7pt,
  "footnotesize": 8pt,
  "small": 9pt,
  "normalsize": 10pt,
  "large": 12pt,
  "Large": 14.4pt,
  "LARGE": 17.28pt,
  "huge": 20.74pt,
  "Huge": 24.88pt,
)

#let font-weight = (
  "thin": "thin",
  "extralight": "extralight",
  "light": "light",
  "normal": "regular",
  "medium": "medium",
  "semibold": "semibold",
  "bold": "bold",
  "extrabold": "extrabold",
  "black": "black",
)

#let font-main-family = "Tex Gyre Bonum"
#let font-secondary-family = "Gillius ADF No2"
#let font-initial-family = "Royal Initialen"

#let config-fonts(
  global-text-font: font-main-family,
  global-text-size: font-size.normalsize,
  global-text-weight: font-weight.normal,
  headers-level-1-font: font-main-family,
  headers-level-1-weight: font-weight.normal,
  headers-level-1-stroke: 0pt,
  headers-level-1-size: font-size.Huge,
  headers-level-1-linespread: 0.9pt,
  headers-level-1-style: none,
  headers-level-2-font: font-main-family,
  headers-level-2-weight: font-weight.normal,
  headers-level-2-stroke: 0pt,
  headers-level-2-size: font-size.huge,
  headers-level-2-linespread: 0.9pt,
  headers-level-2-style: none,
  headers-level-3-font: font-main-family,
  headers-level-3-weight: font-weight.normal,
  headers-level-3-size: font-size.LARGE,
  headers-level-3-linespread: 0.9pt,
  headers-level-3-style: smallcaps,
  headers-level-4-font: font-main-family,
  headers-level-4-weight: font-weight.normal,
  headers-level-4-size: font-size.Large,
  headers-level-4-linespread: 0.9pt,
  headers-level-4-style: smallcaps,
  headers-level-5-font: font-main-family,
  headers-level-5-weight: font-weight.normal,
  headers-level-5-size: font-size.large,
  headers-level-5-linespread: 0.9pt,
  headers-level-5-style: smallcaps,
  headers-level-6-font: font-main-family,
  headers-level-6-style: emph,
  headers-level-6-size: font-size.normalsize,
  headers-level-7-font: font-main-family,
  headers-level-7-style: emph,
  headers-level-7-size: font-size.normalsize,
  outline-level-1-font: font-main-family,
  outline-level-1-weight: font-weight.normal,
  outline-level-1-size: font-size.LARGE,
  outline-level-1-style: smallcaps,
  outline-level-2-font: font-main-family,
  outline-level-2-weight: font-weight.normal,
  outline-level-2-size: font-size.Large,
  outline-level-2-style: smallcaps,
  outline-level-3-font: font-main-family,
  outline-level-3-weight: font-weight.normal,
  outline-level-3-size: font-size.large,
  outline-level-3-style: none,
  outline-level-4-font: font-main-family,
  outline-level-4-weight: font-weight.normal,
  outline-level-4-size: font-size.normalsize,
  outline-level-4-style: none,
  outline-level-5-font: font-main-family,
  outline-level-5-weight: font-weight.normal,
  outline-level-5-size: font-size.normalsize,
  outline-level-5-style: none,
  table-title-font: font-secondary-family,
  table-title-style: smallcaps,
  table-title-weight: font-weight.bold,
  table-title-size: font-size.large,
  table-header-font: font-secondary-family,
  table-header-weight: font-weight.bold,
  table-body-font: font-secondary-family,
  table-body-size: font-size.small,
  area-font: font-main-family,
  area-heading-1-size: font-size.Large,
  area-heading-1-weight: font-weight.normal,
  area-heading-1-style: smallcaps,
  area-heading-2-size: font-size.normalsize,
  area-heading-2-weight: font-weight.normal,
  area-heading-2-style: smallcaps,
  area-text-size: font-size.small,
  commentbox-title-font: font-secondary-family,
  commentbox-title-size: font-size.small,
  commentbox-title-style: smallcaps,
  commentbox-title-weight: font-weight.bold,
  commentbox-font: font-secondary-family,
  commentbox-size: font-size.small,
  commentbox-weight: font-weight.normal,
  dropcap-font: font-initial-family,
  feat-heading-1-font: font-main-family,
  feat-heading-1-size: font-size.large,
  feat-heading-1-weight: font-weight.normal,
  feat-heading-1-style: smallcaps,
  feat-heading-2-font: font-main-family,
  feat-heading-2-size: font-size.small,
  feat-heading-2-weight: font-weight.normal,
  feat-heading-2-style: emph,
  feat-font: font-main-family,
  feat-size: font-size.small,
  item-heading-1-font: font-main-family,
  item-heading-1-size: font-size.small,
  item-heading-1-weight: font-weight.normal,
  item-heading-1-style: smallcaps,
  item-heading-2-font: font-main-family,
  item-heading-2-size: font-size.small,
  item-heading-2-weight: font-weight.normal,
  item-heading-2-style: emph,
  item-font: font-main-family,
  item-size: font-size.small,
  readaloud-font: font-secondary-family,
  readaloud-size: font-size.small,
  sidebar-title-font: font-secondary-family,
  sidebar-title-size: font-size.small,
  sidebar-title-weight: font-weight.normal,
  sidebar-title-style: smallcaps,
  sidebar-font: font-secondary-family,
  sidebar-size: font-size.small,
  spell-font: font-main-family,
  spell-size: font-size.small,
  monster-title-font: font-main-family,
  monster-title-weight: font-weight.bold,
  monster-title-style: none,
  monster-title-size: font-size.Large,
  monster-subtitle-size: font-size.large,
  monster-subtitle-style: smallcaps,
  monster-size: font-size.small,
  monster-font: font-secondary-family,
  footer-font: font-main-family,
  footer-size-number: font-size.normalsize, //or normal
  footer-weight-number: font-weight.medium,
  footer-size-chapter: font-size.small,
  footer-weight-chapter: font-weight.medium,
  footer-chapter-style: smallcaps,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[CONFIG | FONTS]` has unexpected arguments: #args])
  }

  return (
    font: (
      global: (
        font: global-text-font,
        size: global-text-size,
        weight: global-text-weight,
      ),
      headers: (
        level-1: (
          font: headers-level-1-font,
          weight: headers-level-1-weight,
          stroke: headers-level-1-stroke,
          size: headers-level-1-size,
          linespread: headers-level-1-linespread,
          style: headers-level-1-style,
        ),
        level-2: (
          font: headers-level-2-font,
          weight: headers-level-2-weight,
          stroke: headers-level-2-stroke,
          size: headers-level-2-size,
          linespread: headers-level-2-linespread,
          style: headers-level-2-style,
        ),
        level-3: (
          font: headers-level-3-font,
          weight: headers-level-3-weight,
          size: headers-level-3-size,
          linespread: headers-level-3-linespread,
          style: headers-level-3-style,
        ),
        level-4: (
          font: headers-level-4-font,
          weight: headers-level-4-weight,
          size: headers-level-4-size,
          linespread: headers-level-4-linespread,
          style: headers-level-4-style,
        ),
        level-5: (
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
      outline: (
        level-1: (
          font: outline-level-1-font,
          weight: outline-level-1-weight,
          size: outline-level-1-size,
          style: outline-level-1-style,
        ),
        level-2: (
          font: outline-level-2-font,
          weight: outline-level-2-weight,
          size: outline-level-2-size,
          style: outline-level-2-style,
        ),
        level-3: (
          font: outline-level-3-font,
          weight: outline-level-3-weight,
          size: outline-level-3-size,
          style: outline-level-3-style,
        ),
        level-4: (
          font: outline-level-4-font,
          weight: outline-level-4-weight,
          size: outline-level-4-size,
          style: outline-level-4-style,
        ),
        level-5: (
          font: outline-level-5-font,
          weight: outline-level-5-weight,
          size: outline-level-5-size,
          style: outline-level-5-style,
        ),
      ),
      table: (
        title: (
          font: table-title-font,
          style: table-title-style,
          weight: table-title-weight,
          size: table-title-size,
        ),
        header: (
          font: table-header-font,
          weight: table-header-weight,
        ),
        body: (
          font: table-body-font,
          size: table-body-size,
        ),
      ),
      area: (
        font: area-font,
        size: area-text-size,
        headers: (
          level-1: (
            size: area-heading-1-size,
            weight: area-heading-1-weight,
            style: area-heading-1-style,
          ),
          level-2: (
            size: area-heading-2-size,
            weight: area-heading-2-weight,
            style: area-heading-2-style,
          ),
        ),
      ),
      commentbox: (
        title: (
          font: commentbox-title-font,
          size: commentbox-title-size,
          style: commentbox-title-style,
          weight: commentbox-title-weight,
        ),
        font: commentbox-font,
        size: commentbox-size,
        weight: commentbox-weight,
      ),
      dropcap: (
        font: dropcap-font,
      ),
      feat: (
        headers: (
          level-1: (
            font: feat-heading-1-font,
            size: feat-heading-1-size,
            weight: feat-heading-1-weight,
            style: feat-heading-1-style,
          ),
          level-2: (
            font: feat-heading-2-font,
            size: feat-heading-2-size,
            weight: feat-heading-2-weight,
            style: feat-heading-2-style,
          ),
        ),
        font: feat-font,
        size: feat-size,
      ),
      item: (
        headers: (
          level-1: (
            font: item-heading-1-font,
            size: item-heading-1-size,
            weight: item-heading-1-weight,
            style: item-heading-1-style,
          ),
          level-2: (
            font: item-heading-2-font,
            size: item-heading-2-size,
            weight: item-heading-2-weight,
            style: item-heading-2-style,
          ),
        ),
        font: item-font,
        size: item-size,
      ),
      readaloud: (
        font: readaloud-font,
        size: readaloud-size,
      ),
      sidebar: (
        title: (
          font: sidebar-title-font,
          size: sidebar-title-size,
          weight: sidebar-title-weight,
          style: sidebar-title-style,
        ),
        font: sidebar-font,
        size: sidebar-size,
      ),
      spell: (
        font: spell-font,
        size: spell-size,
      ),
      monster: (
        title: (
          font: monster-title-font,
          weight: monster-title-weight,
          style: monster-title-style,
          size: monster-title-size,
        ),
        subtitle: (
          size: monster-subtitle-size,
          style: monster-subtitle-style,
        ),
        size: monster-size,
        font: monster-font,
      ),
      footer: (
        font: footer-font,
        number: (
          size: footer-size-number,
          weight: footer-weight-number,
        ),
        chapter: (
          size: footer-size-chapter,
          weight: footer-weight-chapter,
          style: footer-chapter-style,
        ),
      ),
    ),
  )
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// config-style

#let config-style(
  headers-level-4-line-spacing: 3pt,
  headers-level-4-line-thickness: 1.2pt,
  outline-repeated-symbol: ".",
  outline-indent: true,
  footer-image-left: "../assets/footer/default/r.svg",
  footer-image-right: "../assets/footer/default/l.svg",
  footer-chapter-dx: -6%,
  footer-chapter-dy: 76%,
  footer-number-dx: -15.5%,
  footer-number-dy: 77%,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[CONFIG | STYLE]` has unexpected arguments: #args])
  }


  return (
    style: (
      headers: (
        level-4: (
          line-spacing: headers-level-4-line-spacing,
          line-thickness: headers-level-4-line-thickness,
        ),
      ),
      outline: (
        repeated-symbol: outline-repeated-symbol,
        indent: outline-indent,
      ),
      footer: (
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
}


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// default-config
//
#let default-config = utils.merge-dicts(
  config-info(),
  config-page(),
  config-colors(),
  config-fonts(),
  config-style(),
)


//
// easy colors
// Is a wrapper that lets you easily remap colors given the same mapping of the defualts.
#let easy-colors(
  darkest: colors.darkest,
  primary: colors.titlered,
  secondary: colors.titlegold,
  tertiary: colors.PhbLightGreen,
  quaternary: colors.bgtan,
  ..args,
) = {
  if args.pos().len() > 0 or args.named().len() > 0 {
    panic([`[EASY COLORS]` has unexpected arguments: #args])
  }

  return config-colors(
    global-text: darkest,
    headers-level-1: primary,
    headers-level-2: primary,
    headers-level-3: primary,
    headers-level-4: primary,
    headers-level-4-line: secondary,
    headers-level-5: primary,
    par: darkest,
    subpar: darkest,
    outline-level-1: primary,
    outline-level-2: primary,
    outline-level-3: primary,
    outline-level-4: darkest,
    outline-level-5: darkest,
    outline-line-fill: secondary,
    table-title: darkest,
    table-header: darkest,
    table-body: darkest,
    table-cell: tertiary,
    area-text: primary,
    area-line: secondary,
    commentbox: tertiary,
    feat-heading-1: primary,
    feat-heading-2: primary,
    feat-line: secondary,
    item-heading-1: primary,
    readaloud-background: quaternary,
    readaloud-edges: primary,
    readaloud-transparentize: 30%,
    sidebar-background: tertiary,
    sidebar-edge: darkest,
    spell-title: primary,
  )
}


/// Pre-Defined config inspired by Tomb of Annihilation
/// 23-11-25 | Don't use it, it's not ready yet!
#let toa-config = utils.merge-dicts(
  default-config,
  config-page(
    background: "/assets/paper/toa.jpg",
    show-part: false,
    show-chapter: false,
    using-parts: false,
  ),
  config-colors(
    table-cell: rgb("d5d9cf"),
    commentbox: rgb("d5d9cf"),
    readaloud-background: rgb("dbdcd6"),
    readaloud-edges: rgb("565d59"),
    readaloud-transparentize: 30%,
    sidebar-background: rgb("dbdec8"),
    footer: colors.titlered,
  ),
  config-style(
    footer-chapter-dx: 3%,
    footer-chapter-dy: 80%,
    footer-image-left: "../assets/footer/toa/l.svg",
    footer-image-right: "../assets/footer/toa/r.svg",
    footer-number-dx: -14.3%,
    footer-number-dy: 77%,
  ),
  config-fonts(
    headers-level-2-style: smallcaps,
    outline-level-1-style: none,
    outline-level-1-size: font-size.normalsize,
    outline-level-1-weight: font-weight.bold,
    outline-level-2-style: none,
    outline-level-2-size: font-size.normalsize,
    outline-level-2-weight: font-weight.bold,
    outline-level-3-size: 10pt,
    outline-level-3-weight: "bold",
  ),
)

