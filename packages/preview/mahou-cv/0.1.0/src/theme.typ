#import "@preview/valkyrie:0.2.2" as z

#let color-schema = z.dictionary(
  (
    accent: z.color(),
    body: z.color(),
  ),
  optional: true,
)

#let theme-schema = z.dictionary((
  margin: z.length(default: 22pt),
  font: z.either(
    z.string(),
    z.array(),
    z.dictionary((
      name: z.string(),
      covers: z.either(
        z.string(),
        z.regex(),
        optional: true,
      ),
    )),
    default: "libertinus serif",
  ),
  color: z.dictionary((
    accent: z.color(default: blue),
    body: z.color(default: black),
    header: color-schema,
    main: color-schema,
    aside: color-schema,
  )),
  main-width: z.fraction(default: 5fr),
  aside-width: z.fraction(default: 3fr),
))

#let default-theme = z.parse((:), theme-schema)
#let theme-state = state("theme", default-theme)

#let set-theme(theme-config) = {
  let parsed-theme = z.parse(theme-config, theme-schema)
  theme-state.update(parsed-theme)
}
