#import "i18n.typ"
#import "util.typ": is-some

/// Helper function that takes an array of content and puts it together as a block
#let header-section(xs) = box(
  for i in xs.filter(is-some).intersperse(linebreak()) { i }
)

/// Create the contents of the header
#let header-content(
  course: none,
  title: none,
  authors: none,
  tutor: none,

  date: datetime.today(),
  date-format: none,

  show-title-on-first-page: false,

  extra-left: none,
  extra-center: none,
  extra-right: none,
) = {
  let header = grid(
    columns: (1fr, 3fr, 1fr),
    align: (left, center, right),
    rows: (auto, auto),
    row-gutter: 0.5em,

    // left
    header-section((
      if date != none {
        context date.display(if date-format != none { date-format } else { i18n.default-date() })
      },
      if date-format != none { datetime.today().display(date-format) },
      if tutor != none [Tutor: #tutor],
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

  return pad(top: 0.8cm, bottom: 1cm, header)
}
