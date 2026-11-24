#import "../touying.typ": utils
#import "../components/navigation-buttons.typ": render-navigation-buttons
#import "../navigation.typ": resolve-navigation
#import "../components/branding.typ": render-primary-logos
#import "chrome.typ": footer-logo-enabled, footer, footer-buttons-enabled

#let with-navigation-buttons(self) = {
  if (not self.store.at("navigation-buttons", default: false) or self.handout
    or self.at("show-only-notes", default: false) or self.at("article-mode", default: false)) { return self }
  if self.store.navigation-buttons-actions.len() == 0 or footer-buttons-enabled(self) { return self }
  let previous = self.page.at("foreground", default: none)
  // Reserve a row above the footer; covers with proportional margins have room.
  let margin = self.page.margin
  if type(margin) == dictionary and not footer-logo-enabled(self) {
    let bottom = margin.at("bottom", default: margin.at("y", default: 0em))
    if type(bottom) == length { margin.insert("bottom", bottom + 1.25em) }
  }
  utils.merge-dicts(self, (page: (margin: margin, foreground: context {
    if type(previous) == function { previous(self) } else { previous }
    let logo-space = if footer-logo-enabled(self) {
      measure(render-primary-logos(self, self.store.footer-logo-height, page.width * 30%)).width + 0.5em
    } else { 0em }
    let progress-space = if self.store.section-progress and self.page.footer == footer { 0.8em } else { 0em }
    let navigation = resolve-navigation(self)
    let rail-space = if navigation.placement == "footer" and not footer-logo-enabled(self) { navigation.height } else { 0em }
    let controls = render-navigation-buttons(self: self, actions: self.store.navigation-buttons-actions,
      opacity: self.store.navigation-buttons-opacity)
    let dimensions = measure(controls)
    place(bottom + right, dx: -1.5em - logo-space, dy: -1em - progress-space - rail-space,
      box(width: dimensions.width, height: dimensions.height, {
        [#metadata((width: dimensions.width.pt(), height: dimensions.height.pt()))<ambrosia-navigation-buttons-region>]
        controls
      }))
  }),))
}
