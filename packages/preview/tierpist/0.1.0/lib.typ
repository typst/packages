// See https://typst.app/universe/package/typpuccino
#import "@preview/typpuccino:0.1.0" as theme

// Rename `text` to use `text` as an argument name
#let old-text = text

// Rename `page` to use `page` as an argument name
#let old-page = page

#let tierlist(
  tiers: (
    [],
    [],
    [],
    [],
    [],
    [],
    [],
  ),
  theme: theme.macchiato,
  page: (),
  text: (),
  details
) = {
  set old-text(
    // Default text parameters
    fill: theme.text,

    // Provided text parameters
    ..text
  )

  let page-settings = arguments(
    // Default page parameters

    // Default page size is A4 in landscape orientation
    width: 29.7cm,
    height: 21cm,
    
    margin: 0cm,
    
    fill: theme.crust,

    // Provided page parameters
    ..page
  )
  
  let width = page-settings.at("width")
  let height = page-settings.at("height")
  
  set old-page(
    ..page-settings
  )

  assert(
    (tiers.len() >= 1) and (tiers.len() <= 7),
    message: "Tierpist 0.1.0 only supports 1 to 7 rows"
  )
  
  let labels = "SABCDEF"
    .codepoints()
    .slice(0, tiers.len())

  let colors = (
    theme.red,
    theme.peach,
    theme.yellow,
    theme.green,
    theme.sky,
    theme.blue,
    theme.mauve
  )

  let make-row(label-color-content) = {
    let (label, color, content) = label-color-content
    return (grid.cell(fill: color, old-text(theme.base, 20pt, label)), content)
  }
  
  let labels-colors-contents = labels.zip(colors, tiers)
  let rows = labels-colors-contents.map(make-row).flatten()

  // The actual tierlist
  grid(
    columns: (height / tiers.len(), 1fr),
    rows: (1fr,) * tiers.len(),
    row-gutter: 0cm,
    align: (center + horizon, horizon),
    ..rows
  )

  // Optional pages to detail your ranking
  pagebreak(weak: true)
  details
}
