#import "../types.typ": *
#import "../settings.typ": *


/// Header banner that displays the course name, term, and code.
#let header_banner = e.element.declare(
  "header_banner",
  prefix: PREFIX,
  doc: "A header banner for the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)
    set text(fill: opts.colors.primary, size: 1.2em)
    show: smallcaps

    block(breakable: false, width: 100%, {
      place(left + bottom, {
        set text(size: 1.5em)
        opts.code
      })
      place(center + bottom, {
        opts.name
      })
      place(right + bottom, { opts.term })
      place(bottom, dy: 6pt, box(width: 100%, height: 2pt, fill: opts.colors.primary, none))
    })
  }),
  fields: (),
)

/// A table for displaying basic information in the syllabus.
#let basic_info_table = e.element.declare(
  "basic_info_table",
  prefix: PREFIX,
  doc: "A table for displaying basic information in the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)
    let sans = opts.font_sans.font

    let basic_info = opts.basic_info
    if opts.tutorial_start_date != none {
      basic_info.push((
        title: "Tutorials:",
        value: [Starting #opts.tutorial_start_date.display("[weekday], [month repr:long] [day]")],
      ))
    }

    block(breakable: false, width: 100%, {
      show table.cell: it => {
        // Make the headings sans-serif
        if calc.rem(it.x, 3) == 0 {
          sans(text(fill: gray.darken(10%), it))
        } else {
          it
        }
      }
      table(
        stroke: none,
        columns: (auto, auto, 1fr, auto, auto, 0pt),
        align: (right, left, right, left),
        ..basic_info
          .map(info_item => {
            (info_item.title, info_item.value, [])
          })
          .join(),
      )
    })
  }),
  fields: (),
)
