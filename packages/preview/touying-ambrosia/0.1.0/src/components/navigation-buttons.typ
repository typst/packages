#import "context.typ": component-wrapper
#import "../utils/metadata.typ": is-kind
#import "../palettes.typ": on-color
#import "../utils/headings.typ": appendix-filter

#let navigation-buttons-actions = ("first", "previous", "section", "outline", "next", "last")
#let _default-actions = ("previous", "section", "outline", "next")
#let _icons = (
  first: "M5 4V16 M16 4L9 10L16 16",
  previous: "M15 4L8 10L15 16",
  section: "M6 12L12 6L18 12 M6 16H18",
  outline: "M5 5H19 M5 10H19 M5 15H19",
  next: "M9 4L16 10L9 16",
  last: "M19 4V16 M8 4L15 10L8 16",
)
#let _titles = (first: "First Slide", previous: "Previous Slide", section: "Current Section",
  outline: "Presentation Outline", next: "Next Slide", last: "Last Slide")

#let _icon(action, ink) = image(bytes(
  "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 20\"><path d=\"" + _icons.at(action)
  + "\" fill=\"none\" stroke=\"" + ink.rgb().to-hex()
  + "\" stroke-width=\"1.7\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>"
), width: 1em, height: 0.83em, alt: _titles.at(action))

/// PDF links between logical slides. Animation frames remain one slide.
#let render-navigation-buttons(self: none, actions: _default-actions, opacity: 35%, fill: auto) = context {
  assert(type(actions) == array and actions.all(action => action in navigation-buttons-actions),
    message: "Navigator actions must be first, previous, section, outline, next, or last.")
  assert(type(opacity) == ratio and 0% <= opacity and opacity <= 100%,
    message: "Navigator opacity must be a percentage between 0% and 100%, such as 35%.")
  let slides = query(<touying-metadata>).filter(it => is-kind(it, "touying-new-slide"))
  if slides.len() == 0 or actions.len() == 0 { return }
  let current-page = here().page()
  let index = calc.max(0, slides.filter(it => it.location().page() <= current-page).len() - 1)
  let sections = query(appendix-filter(heading.where(level: 1, outlined: true))).filter(it => it.location().page() <= current-page)
  let outlines = query(metadata).filter(it => it.has("label") and str(it.label).starts-with("touying-outline:"))
  let previous-outline = outlines.filter(it => it.location().page() <= current-page)
  let outline = if previous-outline.len() > 0 { previous-outline.last() }
    else { outlines.at(0, default: none) }
  let background = self.store.at("logo-background", default: self.page.fill)
  let ink = if fill != auto { fill } else if type(background) == color { on-color(background) } else { self.colors.on-cover }
  assert(type(ink) == color, message: "Navigator fill must be a color or auto.")
  let targets = (
    first: if index > 0 { slides.first() } else { none },
    previous: if index > 0 { slides.at(index - 1) } else { none },
    section: sections.at(-1, default: none), outline: outline,
    next: slides.at(index + 1, default: none),
    last: if index < slides.len() - 1 { slides.last() } else { none },
  )
  box(grid(columns: (auto,) * actions.len(), gutter: 0.12em,
    ..actions.map(action => {
      let target = targets.at(action)
      let enabled = target != none and target.location().page() != current-page
      let icon = box(inset: 0.15em, _icon(action, ink.transparentize(100% - opacity * if enabled { 1 } else { 0.3 })))
      if enabled {
        [#metadata((action: action, target: target.location().page()))<ambrosia-navigation-target>#link(target.location(), icon)]
      } else { icon }
    }),
  ))
}

/// Place manually in content or a custom footer. The theme uses a compact footer row, with an overlay fallback for custom footers.
#let ambrosia-navigation-buttons(..args) = component-wrapper(render-navigation-buttons, ..args)
