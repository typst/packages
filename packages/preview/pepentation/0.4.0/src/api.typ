#import "utils.typ"
#import "layout.typ"
#import "blocks.typ"
#import "cards.typ"
#import "themes.typ" as themes
#import "toc.typ"

// The public API of the package: the definitions `lib.typ` re-exports.
//
// Users import `lib.typ`, never this file. Keeping the implementation here
// means the module handles above (`utils`, `layout`, `blocks`, `cards`, `toc`)
// stay out of the package's public surface: `lib.typ` imports only the names
// it means to expose.

/// A styled block for definitions.
///
/// = Example
/// ```typ
/// #definition[*Term.* A definition.]
/// ```
#let definition = blocks.definition

/// A styled block for warnings.
///
/// = Example
/// ```typ
/// #warning[Something to avoid.]
/// ```
#let warning = blocks.warning

/// A styled block for remarks.
///
/// = Example
/// ```typ
/// #remark[An additional note.]
/// ```
#let remark = blocks.remark

/// A styled block for hints.
///
/// = Example
/// ```typ
/// #hint[A helpful tip.]
/// ```
#let hint = blocks.hint

/// A styled block for informational content.
///
/// = Example
/// ```typ
/// #info[A factual note.]
/// ```
#let info = blocks.info

/// A styled block for examples.
///
/// = Example
/// ```typ
/// #example[A worked example.]
/// ```
#let example = blocks.example

/// A styled block for quotations.
///
/// = Example
/// ```typ
/// #quote[A quotation.]
/// ```
#let quote = blocks.quote

/// A styled block for success messages.
///
/// = Example
/// ```typ
/// #success[A successful outcome.]
/// ```
#let success = blocks.success

/// A styled block for failure messages.
///
/// = Example
/// ```typ
/// #failure[An unsuccessful outcome.]
/// ```
#let failure = blocks.failure

/// A card: a tinted panel with an accent bar, a title and a body.
///
/// Cards lay a slide out in pieces rather than running text. The panel is filled
/// with the theme's `card-background`, and a bar is drawn along one edge in the
/// accent color.
///
/// = Example
/// ```typ
/// #card("Title", [Body text])
/// ```
///
/// = Parameters
/// - `title` (str, content or none): The card's title.
/// - `body` (content or none): The card's body.
/// - `num` (str, content or none): A label set before the title.
/// - `accent` (color, string or none): The bar's color, as a color or a theme
///   key. Defaults to the theme's `primary`.
/// - `edge` (alignment or none, default: `left`): The side the accent bar is
///   drawn on; `none` draws no bar.
/// - `fill` (color, string or none): The card's background, as a color or a
///   theme key. Defaults to the theme's `card-background`.
/// - `width` (relative, auto or length, default: `100%`): The card's width.
/// - `height` (auto or length): The card's height. `card-grid` sets this itself.
///
/// = Returns
/// A styled box containing the card.
#let card = cards.card

/// A grid whose cells are drawn as cards.
///
/// Cells are laid out where `grid` would place them, including `colspan`,
/// `rowspan`, `x` and `y`, but each is drawn as a card and every card in a row
/// gets the height of the tallest. A cell is written as a `(title, body)` pair,
/// a dictionary of `card` options plus the placement keywords, `none` for an
/// empty slot, or a `grid` element passed through untouched.
///
/// = Example
/// ```typ
/// #card-grid(
///   columns: 2,
///   ("Title", [Body]),
///   ("Title", [Body]),
/// )
/// ```
///
/// = Parameters
/// - `columns` (int or array, default: `2`): Column track sizes, as in `grid`.
/// - `gutter` (length, default: `card-grid-gutter`): Gap between the columns.
/// - `row-gutter` (length): Gap between the rows; defaults to `gutter`.
/// - `edge` (alignment, none or array): The side the accent bar is drawn on. An
///   array is cycled over the cards in reading order.
/// - `accent` (color, string or none): The bar's color for cells that do not set
///   their own.
/// - `numbered` (boolean, default: `false`): Number the cards in reading order,
///   starting at `01`.
/// - `fill` (color, string or none): The card background for cells that do not
///   set their own.
/// - `..cells` (content, array or dictionary): The cells of the grid.
///
/// = Returns
/// A grid whose cells are cards.

#let card-grid = cards.card-grid

/// Resolves a theme over the defaults and returns the complete theme.
///
/// The result is an ordinary dictionary of plain values, usable anywhere a
/// color is expected and with no `context` needed.
///
/// = Example
/// ```typ
/// #let my-theme = resolve-theme(themes.theme-azure-breeze)
/// #show: setup-presentation.with(theme: my-theme)
///
/// #rect(fill: my-theme.primary, width: 2em)
/// ```
///
/// = Parameters
/// - `theme` (dictionary or none): A theme dictionary, a preset, or a
///   `..`-spread of one. `none` yields the default theme.
///
/// = Returns
/// A dictionary containing every theme key, with defaults filled in.
#let resolve-theme(theme) = themes.resolve(theme)

/// Returns the theme the presentation resolved to.
///
/// Requires a `context` block. Prefer `resolve-theme` if the theme can be bound
/// up front.
///
/// = Example
/// ```typ
/// #context {
///   let t = active-theme()
///   rect(fill: t.primary)
/// }
/// ```
///
/// = Returns
/// A dictionary containing every theme key, with defaults filled in.
#let active-theme() = themes.theme-state.get()

/// Returns one color from the theme the presentation resolved to.
///
/// Accepts a top-level token or a dotted path into `blocks`, and reports the
/// valid keys if the name is wrong. Requires a `context` block.
///
/// = Example
/// ```typ
/// #context rect(fill: theme-color("blocks.warning-color"), width: 2em)
/// ```
///
/// = Parameters
/// - `key` (string): The token to read, e.g. `"primary"` or
///   `"blocks.info-color"`.
/// - `fallback` (any, default: `none`): Returned when the token is `none`.
///
/// = Returns
/// The color stored under `key`.
#let theme-color(key, fallback: none) = themes.color-at(themes.theme-state.get(), key, fallback: fallback)

/// Styles text in one of the theme's colors.
///
/// A shorthand for `text(fill: theme-color(key), ..)` that needs no `context`.
///
/// = Example
/// ```typ
/// #theme-text("primary")[Highlighted text]
/// ```
///
/// = Parameters
/// - `key` (string): The theme token.
/// - `fallback` (any, default: `none`): Returned when the token is `none`.
/// - `body` (content): The text to style.
///
/// = Returns
/// The styled text.
#let theme-text(key, fallback: none, body) = context {
  text(fill: themes.color-at(themes.theme-state.get(), key, fallback: fallback), body)
}

/// Fills a box with one of the theme's colors.
///
/// The default radius and inset match the built-in blocks.
///
/// = Example
/// ```typ
/// #theme-box("primary")[Callout]
/// ```
///
/// = Parameters
/// - `key` (string): The theme token.
/// - `fallback` (any, default: `none`): Returned when the token is `none`.
/// - `radius` (length, default: `1em`): Corner radius.
/// - `inset` (length, default: `1em`): Padding.
/// - `body` (content): The content to place inside the box.
///
/// = Returns
/// A box containing the body.
#let theme-box(
  key,
  fallback: none,
  radius: 1em,
  inset: 1em,
  body,
) = context {
  box(
    fill: themes.color-at(themes.theme-state.get(), key, fallback: fallback),
    radius: radius,
    inset: inset,
    body,
  )
}

/// Runs a function with the resolved theme, supplying the `context`.
///
/// = Example
/// ```typ
/// #with-theme(t => [
///   #rect(fill: t.primary, width: 2em)
///   #rect(fill: t.blocks.info-color, width: 2em)
/// ])
/// ```
///
/// = Parameters
/// - `body` (function): Called with the resolved theme dictionary.
#let with-theme(body) = context body(active-theme())

/// Returns the inline-code background a presentation block uses for its own
/// code.
///
/// A derived color computed from the block's color and the theme's `dark` flag.
/// Requires a `context` block.
///
/// = Example
/// ```typ
/// #context rect(fill: theme-block-code-background("info"), width: 2em)
/// ```
///
/// = Parameters
/// - `block-type` (string): The block type, e.g. `"warning"`.
///
/// = Returns
/// The background color for inline code inside that block.
#let theme-block-code-background(block-type) = {
  blocks.block-code-background(block-type, themes.theme-state.get())
}

/// Returns the inline-code background a card uses for its own code.
///
/// A derived color computed from the theme's `card-background` and `dark` flag.
/// Requires a `context` block.
///
/// = Example
/// ```typ
/// #context rect(fill: theme-card-code-background(), width: 2em)
/// ```
///
/// = Returns
/// The background color for inline code inside a card.
#let theme-card-code-background() = {
  cards.card-code-background(themes.theme-state.get())
}

/// Returns the dimmed color the navigation header draws inactive entries with.
///
/// `sub-text` at half transparency. Requires a `context` block.
///
/// = Example
/// ```typ
/// #context text(fill: theme-header-dim-color())[Matches the header]
/// ```
///
/// = Returns
/// The dimmed header text color.
#let theme-header-dim-color() = layout.header-dim-color(themes.theme-state.get())

/// Creates a section slide with an optional subtitle.
///
/// The title appears in the table of contents and the header.
///
/// = Example
/// ```typ
/// #section-slide(title: "Section", subtitle: "Subtitle")
/// ```
///
/// = Parameters
/// - `title` (string or content): The section title.
/// - `subtitle` (string or content, default: `none`): The subtitle.
#let section-slide(title: none, subtitle: none) = {
  assert(title != none, message: "section-slide requires a title")
  if subtitle != none {
    heading(level: 1, [#title #metadata(subtitle) <section-subtitle>])
  } else {
    heading(level: 1, title)
  }
}

/// Sets up the presentation.
///
/// Call it at the top of the document with `#show: setup-presentation.with(..)`.
///
/// = Example
/// ```typ
/// #show: setup-presentation.with(
///   title-slide: (enable: true, title: "Title", authors: ("Author",)),
///   footer: (enable: true, title: "Title"),
/// )
///
/// = Section
/// == Slide
/// ```
///
/// = Parameters
/// - `title-slide` (dictionary): Title-slide configuration: `enable`, `title`,
///   `authors` and `institute`.
/// - `footer` (dictionary): Footer configuration: `enable`, `title`, `authors`,
///   `institute`, `date`, `text-size`, `secondary-size`, `min-text-size`,
///   `line-height` and `max-lines`.
/// - `theme` (dictionary): Color scheme, merged over the default theme.
/// - `height` (length, default: `12cm`): Slide height; the aspect ratio is fixed
///   at 16:10.
/// - `table-of-contents` (string, default: `"detailed"`): `"none"`, `"detailed"`
///   or `"simple"`.
/// - `header` (boolean, default: `true`): Show the navigation header.
/// - `tracker` (boolean, default: `true`): Draw the progress dots in the header.
/// - `locale` (string, default: `"EN"`): `"EN"` or `"RU"`.
/// - `content` (content): The content of the presentation.
#let setup-presentation(
  title-slide: none,
  footer: none,
  theme: none,
  height: 12cm,
  table-of-contents: "detailed",
  header: true,
  tracker: true,
  locale: "EN",
  content
) = {
  assert(locale in ("RU", "EN"), message: "pepentation: locale must be \"RU\" or \"EN\", got " + repr(locale))
  assert(
    table-of-contents in ("none", "detailed", "simple"),
    message: "pepentation: table-of-contents must be \"none\", \"detailed\" or \"simple\", got " + repr(table-of-contents),
  )

  let theme-state = themes.theme-state

  let title-slide-config = utils.merge-dictionary((
    enable: false, title: none, authors: (), institute: none
  ), title-slide, owner: "title-slide")

  let footer-config = utils.merge-dictionary((
    enable: false,
    title: none,
    institute: none,
    authors: (),
    date: utils.today(locale),
    text-size: layout.footer-text-size,
    secondary-size: layout.footer-secondary-size,
    min-text-size: layout.footer-min-text-size,
    line-height: layout.footer-line-height,
    max-lines: layout.footer-max-lines,
  ), footer, owner: "footer")
  if footer-config.authors == none {
    footer-config.authors = ()
  }

  let theme-config = themes.resolve(theme)

  theme-state.update(theme-config)

  let page-width = height * 16 / 10
  // The reservation is the height of the tallest band the configuration allows,
  // not of the band this footer ends up needing: a page margin cannot depend on
  // measured text, and a footer that outgrew the margin would cover slide
  // content instead of pushing it up. A footer that fits into fewer rows than
  // that leaves the rest of the margin empty above the band.
  let footer-h = layout.footer-reserved-height(footer-config)
  // Absolute on purpose: an `em` here would be relative to the default text
  // size, while the body text below is set to 14pt, and the header needs to do
  // exact arithmetic with the page margins.
  let page-margin = 11pt
  // The margin only has to keep the band off the content, and `footer-gap` is a
  // length instead of an `em` to stay on the same scale as the band.
  let bottom-margin = if footer-config.enable { footer-h + layout.footer-gap } else { 0pt }

  // Centred: the band is as wide as the page, so centring it is what makes it
  // reach both page edges, exactly like the navigation header.
  let footer-content = align(bottom + center,
    layout.create-footer(footer-config, theme-config, page-width)
  )

  set page(
    width: page-width,
    height: height,
    fill: theme-config.background,
    margin: (top: 0em, right: page-margin, left: page-margin, bottom: bottom-margin),
    header: none,
    footer: footer-content,
    footer-descent: 0pt,
  )

  set text(size: 14pt, fill: theme-config.main-text)
  set par(first-line-indent: (amount: 1em, all: true), justify: true)
  set heading(numbering: "1.")

  let code-bg = theme-config.code-background
  let code-text = theme-config.code-text
  show raw.where(block: false): it => {
    let styled-content = if code-text != none {
      text(fill: code-text, it.text)
    } else {
      it.text
    }
    box(
      fill: code-bg,
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 5pt,
      styled-content
    )
  }

  if title-slide-config.enable {
    set page(header: none, footer: none, margin: 2em)
    align(center + horizon, box(
      fill: theme-config.primary,
      radius: 15pt, inset: 2em, width: 100%,
      text(size: 2.2em, weight: "bold", fill: theme-config.sub-text, title-slide-config.title)
    ))
    align(center, text(size: 1.8em, title-slide-config.authors.join(", ")))
    align(center, text(size: 1.4em, title-slide-config.institute))
  }

  if table-of-contents != "none" {
    pagebreak()
    set page(header: none)
    context toc.render-toc(table-of-contents, theme-config, locale)
  }

show heading.where(level: 1): it => {
  // Read before the page break, because a section that opts out of its slide
  // must not break the page or suppress the header either.
  let parts = utils.heading-parts(it.body)
  if parts.section-slide == false {
    // Structural only: the heading still numbers, still appears in the table of
    // contents and still owns the slides below it.
    return none
  }
  pagebreak(weak: true)
  set page(header: none)
  let title-content = parts.title
  let subtitle = parts.subtitle
  let subtitle-position = theme-config.section-subtitle-position
  align(center + horizon, {
    // A title and a subtitle read as labels, so they are neither hyphenated nor
    // justified. Turning justification off also lets a title that runs over two
    // lines centre itself instead of being stretched.
    set par(justify: false)
    if subtitle != none and subtitle-position == "inside" {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        [
          #text(
            size: 2.2em,
            weight: "bold",
            fill: theme-config.sub-text,
            hyphenate: false,
            title-content,
          )
          #line(length: 50%, stroke: theme-config.sub-text-dimmed + 1pt)
          #v(0.3em)
          #text(
            size: theme-config.section-subtitle-size,
            weight: "regular",
            fill: theme-config.sub-text-dimmed,
            hyphenate: false,
            subtitle,
          )
        ]
      )
    } else if subtitle != none and subtitle-position == "below" {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        text(
          size: 2.2em,
          weight: "bold",
          fill: theme-config.sub-text,
          hyphenate: false,
          title-content,
        )
      )
      v(0.5em)
      align(center, text(
        size: theme-config.section-subtitle-size,
        weight: "regular",
        fill: theme-config.sub-text-dimmed,
        hyphenate: false,
        subtitle,
      ))
    } else {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        text(
          size: 2.2em,
          weight: "bold",
          fill: theme-config.sub-text,
          hyphenate: false,
          title-content,
        )
      )
    }
  })
}

  let render-slide(title) = {
    pagebreak(weak: true)
    if header {
      grid(box(
        width: 100%,
        outset: (left: 2em, right: 2em, top: 1em, bottom: 0.2em),
        fill: theme-config.primary,
        layout.create-header(theme-config, page-width - page-margin * 2, tracker: tracker)
      ))
    }

    if title != [] {
      set align(center)
      set text(size: 20pt)
      box(inset: 0.2em, text(weight: "bold", title))
      v(-0.6em)
    }
  }

  show heading.where(level: 2): it => render-slide(it.body)
  show heading.where(level: 3): it => render-slide(it.body)

  content
}
