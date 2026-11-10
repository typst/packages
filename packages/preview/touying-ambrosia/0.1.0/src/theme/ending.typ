#import "../touying.typ": *
#import "../utils.typ" as ambrosia-utils
#import "../components.typ" as ambrosia-components
#import "../components/branding.typ": logo-array, logo-grid, primary-logos
#import "../ending-layouts.typ": resolve-ending-layout
#import "../palettes.typ": on-color
#import "../utils/people.typ": presentation-people, emails-grid
#import "../navigation.typ": resolve-navigation
#import "flavors.typ": current-flavor
#import "render.typ": touying-slide
#import "bookends.typ": cover-decoration
#import "watermark.typ": with-watermark

#let render-ending-slide(self: none, config: (:), title: none, layout: auto,
  logos: auto, contacts: auto, watermark: auto, body) = {
  self = utils.merge-dicts(self, config)
  let flavor = current-flavor(self)
  let definition = resolve-ending-layout(self, layout: layout)
  if resolve-navigation(self).placement == "sidebar" { self.store.navigation = none }
  self.store.section-progress = false
  self.store.title = if flavor.ending-empty-header { "" } else { none }
  self.store.subtitle = none
  self.store.header-aa = none
  self.store.header-ab = none
  if definition.page-background != auto { self.page.fill = ambrosia-utils.call-or-return(self, definition.page-background) }
  if definition.immersive {
    self.store.navigation = none
    self.store.navigation-buttons = false
    self.page.header = none
    self.page.footer = none
    self.page.margin = (x: 2em, y: 1.5em)
  }
  self = utils.merge-dicts(self, config)
  self = with-watermark(self, "ending", enabled: watermark)
  self.store.logo-background = self.page.fill
  let logos = if logos != auto { logos } else { self.store.ending-logos }
  if logos == auto { logos = primary-logos(self) }
  logos = logo-array(logos)
  let people = presentation-people(self.info)
  let contacts = if contacts == auto {
    if people.emails.len() > 0 { people.emails } else { people.authors.map(it => it.emails).flatten() }
  } else if contacts == none { () }
  else if type(contacts) == array { contacts } else { (contacts,) }
  contacts = contacts.dedup()
  let foreground = if definition.foreground == auto { self.colors.foreground }
    else { ambrosia-utils.call-or-return(self, definition.foreground) }
  if definition.immersive {
    self.colors.foreground = foreground
    self.colors.muted = foreground
    self.colors.primary = foreground
  }
  let background = ambrosia-utils.call-or-return(self,
    if definition.title-background == auto { flavor.ending-background } else { definition.title-background })
  let ink = ambrosia-utils.call-or-return(self, if definition.title-text != auto { definition.title-text }
    else if definition.title-background != auto and type(background) == color { on-color(background) }
    else { flavor.ending-text })
  let shadowed = if definition.title-shadow == auto { flavor.ending-shadow and background != none } else { definition.title-shadow }
  let width = if definition.title-width == auto { flavor.ending-width } else { definition.title-width }
  let heading-panel = if title == none { none } else {
    let panel = block(width: width, fill: background, inset: definition.title-inset,
      radius: definition.title-radius, breakable: false,
      text(size: definition.title-size, fill: ink, ambrosia-utils.call-or-display(self, title)))
    if shadowed { ambrosia-components.shadow(panel) } else { panel }
  }
  // Keep the positional body in native flow after Touying parses each frame.
  // Footnotes and citations retain their own space, counters, and link targets.
  touying-slide(self: self, setting: body => {
    if title != none {
      { set heading(numbering: none); show heading: none
        std.heading(ambrosia-utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true) }
    }
    let content = {
      set text(fill: foreground)
      set std.align(definition.alignment)
      let items = ()
      if definition.logos-placement == "above" and logos.len() > 0 {
        items.push(logo-grid(self, logos, definition, definition.logo-height, kind: "ending"))
      }
      if heading-panel != none { items.push(heading-panel) }
      if body != none and body != [] { items.push(body) }
      let contact-panel = emails-grid((authors: (), emails: contacts), self.store.mono-font, foreground)
      let side = definition.composition == "split" and (contacts.len() > 0 or (definition.logos-placement == "side" and logos.len() > 0))
      if not side and contacts.len() > 0 { items.push(contact-panel) }
      if definition.logos-placement == "below" and logos.len() > 0 {
        items.push(logo-grid(self, logos, definition, definition.logo-height, kind: "ending"))
      }
      let main = grid(columns: (1fr,), row-gutter: definition.gap, align: definition.alignment, ..items)
      [#metadata((name: definition.name, contacts: contacts.len(), logos: logos.len(), side: side))<ambrosia-ending-layout>]
      if side {
        let fill = ambrosia-utils.call-or-return(self, definition.side-background)
        let side-self = self
        side-self.store.logo-background = if fill == none { self.page.fill } else { fill }
        let side-ink = if type(fill) == color { on-color(fill) } else { foreground }
        grid(columns: (1fr, definition.side-width), column-gutter: 1.2em, align: horizon,
          main, block(width: 100%, fill: fill, radius: definition.title-radius, inset: 0.8em,
            grid(columns: (1fr,), row-gutter: definition.gap, align: center,
              ..if definition.logos-placement == "side" and logos.len() > 0 {
                (logo-grid(side-self, logos, definition, definition.logo-height, kind: "ending"),)
              } else { () },
              ..if contacts.len() > 0 { (emails-grid((authors: (), emails: contacts), self.store.mono-font, side-ink),) } else { () })))
      } else { main }
    }
    cover-decoration(self, definition)
    std.align(definition.alignment + horizon, content)
  }, body)
}

#let ending-slide(config: (:), title: none, layout: auto, logos: auto, contacts: auto,
  watermark: auto, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  let renderer = current-flavor(self).ending-renderer
  let native = layout != auto or self.store.ending-layout != auto or renderer == auto
  if not native and renderer == none { return touying-slide(self: self, body) }
  if native {
    render-ending-slide(self: self, config: config, title: title, layout: layout,
      logos: logos, contacts: contacts, watermark: watermark, body)
  } else { renderer(self: self, config: config, title: title, body) }
})
