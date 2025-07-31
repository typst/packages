#import "@preview/valkyrie:0.2.1" as z

#import "themes.typ": get-theme, THEMES

/// Document meta information
#let meta-schema = z.dictionary((
  course-name: z.string(),
  serial-str: z.string(),
  author-info: z.content(),
  author-names: z.either(z.tuple(), z.string()),
))

#let font-schema = z.either(z.string(), z.tuple())

#let theme-schema = z.dictionary((
  title: z.dictionary((
    whole-page: z.function(),
    simple: z.function(),
  )),
  page-setting: z.dictionary((
    header: z.function(),
    footer: z.function(),
  )),
  fonts: z.dictionary((
    heading: font-schema,
    text: font-schema,
    equation: font-schema,
  )),
))

#let title-style = z.choice(("whole-page", "simple", "none"))

#let theme-name = z.choice(THEMES)


#let themes-validation(meta) = {
  let meta = z.parse(meta, meta-schema)
  for name in THEMES {
    let theme = get-theme(name)
    z.parse(theme(meta), theme-schema, scope: (name,))
  }
  return
}
