#import "palettes.typ" : palette, style

// To know which palette is applied anywhere we use the metadata
// Every chapter (the function) will add a metadata to associate a palette with a page
// Every call to next-palette (function too) will do the same but with calculation for the next page
// So every components who needs to know which palette it has to use will compare his own page to the metadata, which is a list of (page, palette)


// use a constant to avoid typing errors
#let page-palette-meta-name = "page-palette"

// ------------------ States and counters --------------------------------------

// this state will get the style of the ingredients block "flat" or "gradient"
#let style-state = state("style", style.flat)

// this function just save the style in the state
#let set-style(style) = {
  style-state.update(style)
}


// --------------------- Colors for ingredients functions ----------------------

// color to fill the ingredients block
#let fill-ingredients(style, palette) = {
  if style == "gradient" {
    gradient.linear(palette.medium,palette.light, angle: 90deg)
  } else {
    palette.light
  }
}


// color for the group text of the ingredients block
#let ingredient-group-color(style, palette) = {
  if style == "gradient" {
    palette.dark.darken(30%)
  } else {
    palette.dark
  }
}

// ------------------- Palette functions -------------------------------------

// the current palette for the page
#let page-palette(page) = {
  let events = query(selector(metadata))
    .filter(it => it.value.kind == page-palette-meta-name)
    .sorted(key: it => it.value.page)

  // keep the event before page
  let before = events.filter(ev => {
    ev.value.page <= page
  })

  // if not found → fallback
  if before.len() == 0 {
    return palette.slate
  }

  // We keep the last event
  let last = before.last()

  last.value.palette
}

// this function is used in chapter, recipe or in the cover page to set the palette. it's not for the users
#let set-palette(palette, from-recipe: false) = context {
  metadata((
    kind: page-palette-meta-name,
    palette: palette,
    page: here().position().page,
  ))
}

#let set-all-palettes(settings) = {
  if type(settings) == array and settings.len() > 0 {

    for setting in settings {
      metadata((kind: page-palette-meta-name, palette: setting.palette, page: setting.page))
    }
  } 
}


