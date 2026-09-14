
#import "../types.typ": *
#import "../settings.typ": *


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
        let items = (
          sans(text(size: 1.2em, {
            it.title
          })),
        )
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
        if body_height < annotation_height {
          // If the body is shorter than the annotation, we need to pad it to the height of the annotation
          place(annotation, dx: -opts.gutter_width)
          block(height: annotation_height, breakable: true, {
            body
          })
        } else {
          place(annotation, dx: -opts.gutter_width)
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
