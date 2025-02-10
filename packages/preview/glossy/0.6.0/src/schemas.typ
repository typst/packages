#import "@preview/valkyrie:0.2.1" as z

#let dict-schema = z.either(
  z.string(),
  z.dictionary(
    (
      short: z.content(), // this is the only required field
      plural: z.content(optional: true),
      long: z.content(optional: true),
      longplural: z.content(optional: true),
      description: z.content(optional: true),
      group: z.content(optional: true),
    )
  )
)

#let theme-schema = z.dictionary(
  (
    section: z.function(),
    group: z.function(),
    entry: z.function(),
  )
)

#let groups-list-schema = z.array(pre-transform: z.coerce.array)
