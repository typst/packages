// Entry function: a structured section with sidebar + content layout.

#import "theme.typ": colors, fonts, icons, checkbox

#let entry(
  name,
  items: (),
  content: [],
  items-header: none,
  content-header: none,
  notes-header: none,
  description: none,
  image: none,
  badge: none,
  notes: none,
) = {
  // 1. Header Section
  heading(level: 2, name)

  // Description & Meta row
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    align(left + horizon, {
      if description != none {
        text(font: fonts.body, style: "italic", fill: colors.muted, description)
      }
    }),
    align(right + horizon, {
      set text(font: fonts.header, size: 0.9em, fill: colors.muted)
      let meta = ()
      if badge != none { meta.push([#icons.badge #h(0.3em) #badge]) }
      if meta.len() > 0 {
        meta.join(h(1.5em))
      }
    })
  )

  v(0.8em)
  line(length: 100%, stroke: 0.5pt + colors.line)
  v(2em)

  // 2. Main Layout (Sidebar + Content)
  grid(
    columns: (35%, 1fr),
    gutter: 2.5em,

    // -- Left Column: Items --
    {
      if image != none {
        block(width: 100%, height: auto, clip: true, radius: 4pt, image)
        v(1.5em)
      }

      block(
        fill: colors.bg-panel,
        inset: 1.2em,
        radius: 4pt,
        width: 100%,
        stroke: 0.5pt + colors.line.darken(5%),
      )[
        #text(font: fonts.header, weight: "bold", size: 1.1em, fill: colors.text, items-header)
        #v(0.8em)
        #set text(size: 0.95em)

        #for item in items {
          grid(
            columns: (auto, 1fr),
            gutter: 0.6em,
            checkbox,
            {
              if type(item) == dictionary {
                [*#item.at("amount", default: "")* #item.at("name", default: "")]
              } else {
                item
              }
            }
          )
          v(0.6em)
        }
      ]

      if notes != none {
        v(1.5em)
        text(font: fonts.header, size: 0.9em, weight: "bold", fill: colors.accent, notes-header)
        v(0.3em)
        text(style: "italic", size: 0.9em, fill: colors.muted, notes)
      }
    },

    // -- Right Column: Content --
    {
      text(font: fonts.header, weight: "bold", size: 1.1em, fill: colors.text, content-header)
      v(1em)

      set enum(
        numbering: n => text(font: fonts.header, size: 1.2em, weight: "bold", fill: colors.accent, box(inset: (right: 0.5em), [#n]))
      )
      set par(leading: 1em, justify: true)

      // Just apply spacing to list items via a show rule on the item
      show enum.item: it => {
        pad(bottom: 0.8em, it)
      }

      content
    }
  )
}
