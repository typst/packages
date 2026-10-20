
#import "../types.typ": *
#import "../settings.typ": *
#import "../utils.typ": *


/// An item with an annotation that hangs in the left margin.
/// ```example
/// #set page(margin: (left: 1.5in), width: 4.5in, height: 2in)
/// #annotated_item(title: "Annotated Item", subtitle: "Subtitle of the item")[
///     The body of an item that is well annotated.
/// ]
/// ```
#let annotated_item = e.element.declare(
  "annotated_item",
  prefix: PREFIX,
  doc: "An item with an annotation that hangs in the left margin",
  display: it => e.get(get => {
    let opts = get(settings)
    let sans = opts.font_sans.font

    // The part that goes in the margin
    let annotation = block(
      width: opts.gutter_width,
      inset: (right: 4pt),

      {
        set align(right)
        set par(leading: 0.3em, justify: false)
        // Only emit the items that actually have content. Pushing the title
        // unconditionally would leave an empty 1.2em line above a subtitle-only
        // annotation, making it taller than it looks and putting its first
        // baseline out of step with the shift computed below.
        let items = ()
        if it.title != none {
          items.push(sans(text(size: 1.2em, {
            it.title
          })))
        }
        if it.subtitle != none {
          items.push(text(size: .85em, fill: gray.darken(10%), {
            it.subtitle
          }))
        }
        stack(spacing: .8em, ..items)
      },
    )

    layout(size => {
      let body = block(
        width: size.width,
        breakable: true,

        it.body,
      )

      // We need to measure the height of the annotation and body. If the
      // body is shorter than the annotation, it needs to be placed in a block with a forced height so
      // that subsequent items don't overlap with the annotation.
      block(context {
        v(.4em)
        let annotation_height = measure(annotation).height
        let body_height = measure(body).height
        //[#(annotation_height, body_height)]

        // The annotation is set larger than the body (and in a different font), so aligning
        // the two at their tops would leave their first baselines out of step. Shift the
        // annotation by the difference in first-baseline offsets so the baselines match.
        let annotation_style = if it.title != none {
          body => sans(text(size: 1.2em, body))
        } else {
          body => text(size: .85em, body)
        }
        let baseline_shift = (
          first_baseline_offset(body => body) - first_baseline_offset(annotation_style)
        )
        place(annotation, dx: -opts.gutter_width, dy: baseline_shift)

        if body_height < annotation_height {
          // If the body is shorter than the annotation, we need to pad it to the height of the annotation
          block(height: annotation_height, breakable: true, {
            body
          })
        } else {
          body
        }
      })
    })
  }),

  fields: (
    e.field("title", e.types.option(content), doc: "The title of the item"),
    e.field(
      "subtitle",
      e.types.option(content),
      doc: "Additional description appearing below the title",
    ),
    e.field(
      "body",
      content,
      doc: "The descriptive test that will be shown inline in the document",
      required: true,
    ),
  ),
)
