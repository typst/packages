#import "basic.typ": typesetting

#let default-page-args = (
  paper: "a4",
  margin: 1em,
  flipped: true,
)

/// Cheat paper template
///
/// - title (str): title
/// - authors (str | array<str>): list of authors
/// - lang (str): language identifier used in `set text(lang: lang)`
/// - use-patch (bool | (list?: bool, enum?: bool)):
///   whether to use the patch for list and/or enum, default enabled when
///   ignored
/// - spacing (length | relative | auto): spacing between lines,
///   paragraphs, and headings, default to `par.leading`
/// - font-size (length): font size for text and headings, default to `10pt`
/// - num-columns (int): number of columns, default to `4`
/// - page-setting (named arguments): arguments for `set page(...)`, default to
///   flipped A4 paper with 1em margin
/// - body (content): content
/// -> content
#let template(
  lang: "en",
  title: "Cheat Sheet",
  authors: "Fr4nk1in",
  spacing: auto,
  font-size: 10pt,
  num-columns: 4,
  body,
  ..page-setting,
) = {
  // typesetting
  show: typesetting.with(
    title: title,
    authors: authors,
    lang: lang,
    use-patch: false,
  )
  set heading(numbering: "1.1")
  // page
  let page-args = default-page-args
  for (key, value) in page-setting.named() {
    page-args.update(key, value)
  }
  set page(..page-args)
  // font size
  set text(size: font-size)
  show heading: it => text(size: font-size, it)
  // spacing
  context {
    let spacing = if spacing == auto {
      par.leading
    } else if type(spacing) == length {
      spacing
    } else if type(spacing) == relative { spacing } else {
      assert(false, message: "Invalid spacing type: " + type(spacing))
    }
    set par(spacing: spacing)
    show heading: set block(above: spacing, below: spacing)
    set block(above: spacing, below: spacing)
    show: columns.with(num-columns, gutter: spacing)
    body
  }
}

#let pencil-color = luma(50%)
#let pencil = text.with(fill: pencil-color)
