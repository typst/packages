#import "i18n.typ"
#import "util.typ": is-some

/// Helper function that takes an array of content and puts it together as a block
#let header-section(xs) = box(
  for i in xs.filter(is-some).intersperse(linebreak()) { i },
)

/// Create the contents of the header
///
/// This function is not exposed to the user,
/// all configuration is done in the `assignment` template function.
#let header-content(
  course,
  title,
  authors,
  date,
  date-format,
  tutor,
  tutor-prefix,
  show-title-on-first-page,
  extra-left,
  extra-center,
  extra-right,
  columns,
  align,
  column-gutter,
  row-gutter,
  padding-top,
  padding-bottom,
) = {
  let header = grid(
    columns: columns,
    align: align,
    rows: (auto, auto),
    column-gutter: column-gutter,
    row-gutter: row-gutter,

    // left
    header-section((
      if date != none {
        context date.display(if date-format == auto {
          i18n.date-format()
        } else { date-format })
      },
      if tutor != none [#tutor-prefix: #tutor],
      extra-left,
    )),

    // center
    header-section((
      course,
      if show-title-on-first-page { title } else {
        context {
          let n = counter(page).get().first()
          if n != 1 { title }
        }
      },
      extra-center,
    )),

    // right
    header-section(authors + (extra-right,)),

    grid.hline(),
  )

  return pad(top: padding-top, bottom: padding-bottom, header)
}
