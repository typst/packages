#import "../types.typ": *
#import "../settings.typ": *

/// Smallcaps text that is meant to appear as a heading used in the gutter of the syllabus.
#let gutter_label = e.element.declare(
  "gutter_label",
  prefix: PREFIX,
  doc: "A label for the gutter of the syllabus.",
  display: it => box(baseline: 50%, block(breakable: false, {
    set align(right)
    set par(justify: false, leading: 0.1em)
    show: smallcaps
    it.body
  })),

  fields: (
    e.field("body", content, doc: "The text of the gutter label", required: true),
  ),
)

/// A divider for sections in the syllabus.
#let section_divider = e.element.declare(
  "section_divider",
  prefix: PREFIX,
  doc: "A divider for sections in the syllabus.",
  display: it => e.get(get => {
    let opts = get(settings)
    let gutter_width = opts.gutter_width
    //    set text(fill: opts.colors.primary)

    // Lay out the label and vertically center it
    let label = block(
      width: gutter_width,
      breakable: false,
      inset: (right: 4pt),

      {
        set align(right)
        gutter_label(it.title)
      },
    )
    block(sticky: true, {
      context {
        // Measure the height, but since we want to center based on the height of the lower case letters
        // we multiply by 0.7
        let single_letter_height = measure(gutter_label([m])).height * 0.7
        let label_height = measure(label).height
        let is_multiline = label_height > 2 * single_letter_height
        let hoffset = if is_multiline {
          label_height / 2.1 + single_letter_height / 3.5
        } else {
          single_letter_height / 1.3
        }

        place(dx: -gutter_width, dy: -hoffset, label)
      }
      box(baseline: 0%, block(
        width: 100%,
        fill: opts.colors.primary,
        height: 2pt,
      ))
    })
  }),

  fields: (
    e.field("title", e.types.option(content), doc: "The text of the section divider", named: false),
  ),
)
