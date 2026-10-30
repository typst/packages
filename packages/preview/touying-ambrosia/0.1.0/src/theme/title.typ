#import "../touying.typ": *
#import "../components.typ" as ambrosia-components
#import "../utils.typ" as ambrosia-utils
#import "flavors.typ": current-flavor
#import "../title-layouts.typ": resolve-title-layout
#import "../palettes.typ": on-color
#import "../components/branding.typ": title-logo-groups, logo-columns, logo-grid
#import "bookends.typ": cover-decoration
#import "../navigation.typ": resolve-navigation
#import "render.typ": touying-slide
#import "fitting.typ": fit-title
#import "watermark.typ": with-watermark
#import "../utils/people.typ": presentation-people, authors-grid, institutions-list, emails-grid

#let _modern-title-slide(self: none, config: (:), fit: auto, min-scale: auto,
  watermark: auto, layout: auto, logos: auto, ..args) = {
  // Merge local stores before resolving composition and branding.
  self = utils.merge-dicts(self, config)
  let flavor = current-flavor(self)
  let definition = resolve-title-layout(self, layout: layout)
  if resolve-navigation(self).placement == "sidebar" { self.store.navigation = none }
  self.store.section-progress = false
  let info = self.info + args.named()
  let groups = title-logo-groups(self, info: info, logos: logos)
  let logos = groups.primary + groups.partners
  let logo-count = logos.len()
  let featured = if definition.featured-logo and definition.logos-placement != "none" { groups.primary } else { () }
  let primary-count = if featured.len() > 0 { 0 } else { groups.primary.len() }
  if featured.len() > 0 { logos = groups.partners }
  // Featured layouts keep a centered partner grid, including empty-primary cases.
  if definition.featured-logo { definition.logos-distribution = "equal" }
  let logo-height = if definition.logo-height == auto { self.store.title-logo-height } else { definition.logo-height }
  let people = presentation-people(info)
  let header-logos = definition.logos-placement == "header"
  let columns = logo-columns(logos, definition)
  let rows = if definition.logos-distribution == "grouped" { calc.min(1, logos.len()) } else { calc.ceil(logos.len() / columns) }
  let header-height = if rows == 0 { 0em } else { rows * logo-height + (rows - 1) * definition.logo-gap + 2 * definition.header-inset }
  self = utils.merge-dicts(self, config-page(margin: (
    left: 2em, right: 2em,
    top: if header-logos { header-height + 0.75em } else if flavor.navigation == "none" { 1em } else { 2.3em },
    bottom: 1.4em,
  )), config)
  if definition.page-background != auto {
    self.page.fill = ambrosia-utils.call-or-return(self, definition.page-background)
  }
  if definition.immersive {
    self.store.navigation = none
    self.store.navigation-buttons = false
    self.page.header = none
    self.page.footer = none
    self.page.margin = (left: 2em, right: 2em,
      top: if header-logos { header-height + 0.75em } else { 1.5em }, bottom: 1.5em)
  }
  if header-logos {
    self.store.navigation = none
    self.store.footer-logo = config.at("store", default: (:)).at("footer-logo", default: false)
    let fill = ambrosia-utils.call-or-return(self, definition.header-background)
    let header-self = self
    header-self.store.logo-background = if fill == none { self.page.fill } else { fill }
    // Only this slide receives the logo header; the next slide retains its
    // ordinary flavor chrome. Touying also confines it to second-screen slides.
    self.page.header = if logos.len() == 0 { none } else { self => std.align(top,
      block(width: 100%, height: header-height, fill: fill, above: 0em, below: 0em,
        inset: (x: 1em, y: definition.header-inset),
        logo-grid(header-self, logos, definition, logo-height, primary-count: primary-count))) }
  }
  self = utils.merge-dicts(self, config)
  self.store.title = none
  self.store.subtitle = none
  self = with-watermark(self, "title", enabled: watermark)
  self.store.logo-background = self.page.fill
  let foreground = if definition.foreground == auto { self.colors.foreground }
    else { ambrosia-utils.call-or-return(self, definition.foreground) }
  if definition.immersive {
    self.colors.foreground = foreground
    self.colors.muted = foreground
    self.colors.primary = foreground
  }
  let title-background = ambrosia-utils.call-or-return(self,
    if definition.title-background == auto { flavor.title-background } else { definition.title-background })
  let title-text = ambrosia-utils.call-or-return(self,
    if definition.title-text == auto {
      if definition.title-background != auto and type(title-background) == color { on-color(title-background) } else { flavor.title-text }
    } else { definition.title-text })
  let title-shadow = if definition.title-shadow == auto { flavor.title-shadow and title-background != none } else { definition.title-shadow }
  let title-width = if definition.title-width == auto { flavor.title-width } else { definition.title-width }
  let title-panel = block(width: title-width, fill: title-background,
    inset: definition.title-inset, radius: definition.title-radius, breakable: false, {
      set par(justify: false)
      text(size: definition.title-size, fill: title-text, weight: "bold", info.title)
      if info.subtitle != none {
        parbreak()
        text(size: definition.subtitle-size, fill: title-text, weight: "bold", info.subtitle)
      }
    })
  if title-shadow { title-panel = ambrosia-components.shadow(title-panel, blur: 0.4em, dx: 0.15em, dy: 0.15em) }
  let metadata-panel = {
    set par(justify: false)
    authors-grid(people, self.store.mono-font, foreground,
      compact: definition.alignment == left, alignment: definition.alignment, columns: self.store.author-columns)
    if people.institutions.len() > 0 { v(0.25em); institutions-list(people, foreground) }
    if people.emails.len() > 0 { v(0.25em); emails-grid(people, self.store.mono-font, foreground) }
    if info.date != none { v(0.25em); text(size: 0.7em, utils.display-info-date(self + (info: info))) }
  }
  let body = {
    set text(fill: foreground)
    set std.align(definition.alignment)
    let main = grid(columns: (1fr,), row-gutter: definition.gap, align: definition.alignment,
      ..if featured.len() > 0 {
        (logo-grid(self, featured, definition + (logos-distribution: "equal",), definition.featured-logo-height),)
      } else { () },
      ..if definition.logos-placement == "above" and logos.len() > 0 {
        (logo-grid(self, logos, definition, logo-height, primary-count: primary-count),)
      } else { () }, title-panel, metadata-panel,
      ..if definition.logos-placement == "below" and logos.len() > 0 {
        (logo-grid(self, logos, definition, logo-height, primary-count: primary-count),)
      } else { () })
    [#metadata((name: definition.name, placement: definition.logos-placement, logos: logo-count))<ambrosia-title-layout>]
    if definition.composition == "split" and definition.logos-placement == "side" and logos.len() > 0 {
      let side-self = self
      let fill = ambrosia-utils.call-or-return(self, definition.side-background)
      side-self.store.logo-background = if fill == none { self.page.fill } else { fill }
      grid(columns: (1fr, definition.side-width), column-gutter: 1.2em, align: horizon,
        main, block(width: 100%, inset: 0.8em, radius: definition.title-radius, fill: fill,
          logo-grid(side-self, logos, definition, logo-height)))
    } else { main }
  }
  touying-slide(self: self, fit-title(body,
    decoration: cover-decoration(self, definition),
    alignment: definition.alignment + horizon,
    fit: if fit == auto { self.store.title-fit } else { fit },
    min-scale: if min-scale == auto { self.store.title-min-scale } else { min-scale },
  ))
}


/// Modern title slide.
#let modern-title-slide(config: (:), ..args) = touying-slide-wrapper(_modern-title-slide.with(config: config, ..args))


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: ambrosia-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(self: none, config: (:), layout: auto, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  let definition = current-flavor(self)
  if resolve-navigation(self).placement == "sidebar" { self.store.navigation = none }
  self.store.section-progress = false
  let native = layout != auto or self.store.title-layout != auto or definition.title-renderer == auto
  let title-slide-impl = if native { _modern-title-slide } else { definition.title-renderer }
  if title-slide-impl == none { return touying-slide(self: self, config: config, []) }
  title-slide-impl(
    self: self,
    config: config,
    ..if native { (layout: layout) } else { (:) },
    ..args,
  )
})
