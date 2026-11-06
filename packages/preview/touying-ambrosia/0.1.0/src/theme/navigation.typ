#import "../touying.typ": utils
#import "../navigation.typ": get-navigation, resolve-navigation, resolve-navigation-height, resolve-sidebar-style
#import "../components/structural-navigation.typ": render-sidebar
#import "chrome.typ": header, footer

// Touying's second-screen output requires explicit edges (or x/y), even when
// a special slide starts with a scalar margin. Normalize before reservations.
#let normalize-margins(self) = {
  let margin = self.page.margin
  if margin == auto { return self }
  if type(margin) != dictionary { margin = (x: margin, y: margin) }
  let edge(key, axis) = margin.at(key, default: margin.at(axis, default: margin.at("rest", default: 0em)))
  utils.merge-dicts(self, (page: (margin: (left: edge("left", "x"), right: edge("right", "x"),
    top: edge("top", "y"), bottom: edge("bottom", "y"))),))
}

// Compute the structural reservation once, after global and per-slide settings
// have merged. Header rows declare a budget; the sidebar owns a body column.
#let with-navigation(self) = {
  let definition = resolve-navigation(self)
  let hidden = self.handout or self.at("show-only-notes", default: false) or self.at("article-mode", default: false)
  if hidden { definition = get-navigation(none) }
  self.store.navigation-definition = definition
  self.store.navigation-body-insets = none
  let margin = self.page.margin
  if margin == auto { return self }
  if type(margin) != dictionary { margin = (rest: margin) }
  let edge(key, axis) = margin.at(key, default: margin.at(axis, default: margin.at("rest", default: 0em)))
  let sides = (left: edge("left", "x"), right: edge("right", "x"), top: edge("top", "y"), bottom: edge("bottom", "y"))
  if sides.values().any(value => value == auto) { return self }
  let baseline = resolve-navigation-height(self, get-navigation(self.store.flavor-definition.navigation))
  // Custom headers explicitly opt into structural layout by setting header-a.
  if self.store.at("navigation-header-managed", default: self.page.header == header) {
    let old-height = if baseline.placement == "header" { baseline.height } else { 0em }
    let new-height = if definition.placement == "header" { definition.height } else { 0em }
    // Typst places a page header immediately above the body. Reserve a small
    // gap as well as lifting the header, so neither its top position nor its
    // text can collide with the first body line (whose ascenders can protrude).
    let body-gap = if self.page.header == header { 0.5em } else { 0em }
    margin.insert("top", sides.top + new-height - old-height + body-gap)
    self.page.header-ascent += body-gap
  }
  if definition.placement == "footer" {
    assert(self.store.at("navigation-footer-managed", default: self.page.footer == footer),
      message: "Footer navigation needs the standard Ambrosia footer. Use a segments descriptor with placement: header, or let a custom footer render the rail and set navigation-footer-managed: true.")
    margin.insert("bottom", sides.bottom + definition.height)
  }
  if definition.placement != "sidebar" {
    return utils.merge-dicts(self, (page: (margin: margin),))
  }
  let reserve = definition.width + definition.gap
  margin.insert(definition.side, sides.at(definition.side) + reserve)
  let insets = sides + if definition.side == "right" { (right: sides.right + reserve) } else { (left: sides.left + reserve) }
  self.store.navigation-body-insets = insets
  let previous = self.page.at("foreground", default: none)
  utils.merge-dicts(self, (page: (margin: margin, foreground: context {
    if type(previous) == function { previous(self) } else { previous }
    let (width, height) = utils.get-page-dimensions(self)
    let x = if definition.side == "left" { sides.left } else { width - sides.right - definition.width }
    let y = margin.at("top", default: sides.top)
    let available = (height - y - sides.bottom).to-absolute()
    let style = resolve-sidebar-style(self)
    let background = style.background
    let padding = style.padding.to-absolute()
    assert(definition.width.to-absolute() > 0pt and definition.gap.to-absolute() >= 0pt and available > 0pt
      and (width - insets.left - insets.right).to-absolute() > (4em).to-absolute(),
      message: "Sidebar leaves too little room for slide content. Reduce navigation-width/gap or page margins.")
    place(top + left, dx: x, dy: y,
      block(width: definition.width, height: available, fill: background, clip: true, breakable: false, {
        // Keep the region's anchor at its outer edge, before panel padding.
        place(top + left, [#metadata((side: definition.side,
          width: definition.width.to-absolute().pt(), height: available.pt(),
          background: background, padding: padding.pt(),
          ink: style.ink, muted: style.muted,
          body-left: insets.left.to-absolute().pt(), body-right: (width - insets.right).to-absolute().pt()))<ambrosia-navigation-region>])
        block(width: 100%, height: 100%, inset: padding, {
          if definition.renderer != auto { (definition.renderer)(self) } else { render-sidebar(self) }
        })
      }))
  }),))
}
