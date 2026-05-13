// Recipe rendering: header, sidebar, and instruction layout.

#import "theme.typ": colors, fonts, icons
#import "i18n.typ": translate
#import "components.typ": checkbox, note-box, section-heading, tag-pill

#let recipe(
  name,
  ingredients: (),
  utensils: (),
  instructions: [],
  description: none,
  image: none,
  servings: none,
  prep-time: none,
  cook-time: none,
  cuisine: none,
  tags: (),
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
      if cuisine != none { meta.push([#icons.cuisine #h(0.3em) #cuisine]) }
      if servings != none { meta.push([#icons.yield #h(0.3em) #servings]) }
      if prep-time != none { meta.push([#icons.time #h(0.3em) #prep-time]) }
      if cook-time != none { meta.push([#icons.fire #h(0.3em) #cook-time]) }
      if meta.len() > 0 {
        meta.join(h(1.5em))
      }
    }),
  )

  // Tags
  if tags.len() > 0 {
    v(0.5em)
    set text(font: fonts.header, size: 0.9em, fill: colors.muted)
    icons.tag
    h(0.3em)
    tags.map(tag-pill).join(h(0.4em))
  }

  v(0.8em)
  line(length: 100%, stroke: 0.5pt + colors.line)
  v(2em)

  // 2. Main Layout (Sidebar + Content)
  grid(
    columns: (35%, 1fr),
    gutter: 2.5em,

    // -- Left Column: Ingredients, Utensils, Notes --
    {
      if image != none {
        block(width: 100%, height: auto, clip: true, radius: 4pt, image)
        v(1.5em)
      }

      block(
        fill: colors.bg-ing,
        inset: 1.2em,
        radius: 4pt,
        width: 100%,
        stroke: 0.5pt + colors.line.darken(5%),
      )[
        #text(
          font: fonts.header,
          weight: "bold",
          size: 1.1em,
          fill: colors.text,
          translate("ingredients"),
        )
        #v(0.8em)
        #set text(size: 0.95em)

        #for ing in ingredients {
          grid(
            columns: (auto, 1fr),
            gutter: 0.6em,
            checkbox,
            {
              if type(ing) == dictionary {
                [*#ing.at("amount", default: "")* #ing.at("name", default: "")]
              } else {
                ing
              }
            },
          )
          v(0.6em)
        }
      ]

      if utensils.len() > 0 {
        v(1.5em)
        block(
          inset: 1.2em,
          radius: 4pt,
          width: 100%,
          stroke: (
            left: 3pt + colors.accent,
            rest: 0.5pt + colors.line.darken(5%),
          ),
        )[
          #text(
            font: fonts.header,
            weight: "bold",
            size: 1.1em,
            fill: colors.text,
            translate("utensils"),
          )
          #v(0.8em)
          #set text(size: 0.95em)

          #for utensil in utensils {
            grid(
              columns: (auto, 1fr),
              gutter: 0.6em,
              text(fill: colors.accent)[#icons.utensils], utensil,
            )
            v(0.6em)
          }
        ]
      }

      if notes != none {
        v(1.5em)
        note-box(notes)
      }
    },

    // -- Right Column: Instructions --
    {
      text(
        font: fonts.header,
        weight: "bold",
        size: 1.1em,
        fill: colors.text,
        translate("preparations"),
      )
      v(1em)

      set enum(
        numbering: n => text(
          font: fonts.header,
          size: 1.2em,
          weight: "bold",
          fill: colors.accent,
          box(
            inset: (right: 0.5em),
            [#n],
          ),
        ),
        spacing: 0.8em,
      )
      set par(leading: 1em, justify: true)

      // Instructions can be plain content or a dictionary of named sections.
      // Plain:     [+ Step one ... + Step two ...]
      // Sectioned: ("Prep": [+ ...], "Cook": [+ ...])
      if type(instructions) == dictionary {
        for (heading, steps) in instructions {
          section-heading(heading)
          steps
        }
      } else {
        instructions
      }
    },
  )
}
