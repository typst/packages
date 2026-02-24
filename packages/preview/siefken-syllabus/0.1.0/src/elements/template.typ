#import "../types.typ": *
#import "../settings.typ": *
#import "section-divider.typ": section_divider
#import "header.typ": basic_info_table, header_banner


/// The syllabus template. Use with `#show: template`
#let template = e.element.declare(
  "template",
  prefix: PREFIX,
  doc: "The syllabus template. Use with `#show: template`.",
  template: it => it,
  display: it => {
    e.get(get => {
      let opts = get(settings)
      let sans = opts.font_sans.font
      let mono = opts.font_mono.font

      set page(
        paper: "us-letter",
        margin: (left: opts.gutter_width + 0.6in, right: 0.6in, top: 1.1in),

        footer: pad(left: -opts.gutter_width, align(center, context { counter(page).display("1") })),
        header: pad(left: -opts.gutter_width, context {
          if here().page() == 1 {
            header_banner()
          } else {}
        }),
      ) if it.minipage == false
      set par(justify: true)

      set list(indent: 1em, marker: place(dx: -3pt, dy: 2pt, rect(
        width: 4pt,
        height: 4pt,
        fill: opts.colors.primary,
      )))
      show link: it => mono(text(
        fill: opts.colors.primary,
        size: 0.83em,
        it,
      ))
      show heading: set text(fill: opts.colors.primary)
      show heading.where(level: 2): it => {
        set text(weight: "regular")
        section_divider(it.body)
      }

      let basic_info = if opts.basic_info.len() > 0 {
        pad(left: -opts.gutter_width, {
          v(-1.3em)
          stack(basic_info_table(), line(length: 100%, stroke: .5pt + opts.colors.primary))
        })
      }

      if it.minipage {
        // If we are in a minipage, set ourselves into a block with a margin equivalent to the gutter width

        block(inset: (left: opts.gutter_width), breakable: true, {
          // Manually insert the header onto the "first page".
          v(1.2em)
          pad(left: -opts.gutter_width, context {
            header_banner()
          })
          v(1em)
          basic_info
          it.doc
        })
      } else {
        basic_info
        it.doc
      }
    })
  },
  fields: (
    e.field("doc", content, doc: "The content of the syllabus", required: true),
    e.field(
      "minipage",
      bool,
      doc: "If `minipage` is true, `set page(...)` will be avoided so that the syllabus content can be typeset in a box/block",
      default: false,
    ),
  ),
)
