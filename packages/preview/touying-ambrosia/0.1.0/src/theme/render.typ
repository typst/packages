#import "../touying.typ" as touying
#import "../citations.typ"
#import "navigation-buttons.typ": with-navigation-buttons
#import "chrome.typ": with-footer-space
#import "navigation.typ": with-navigation, normalize-margins

// Apply marker transformations after animation parsing. Footer entry formatting
// lives in theme initialization, where the entries inherit their own styles.
#let touying-slide(self: none, config: (:), setting: body => body, ..args) = {
  let merged = normalize-margins(touying.utils.merge-dicts(self, config))
  if merged.handout or merged.at("show-only-notes", default: false) or merged.at("article-mode", default: false) {
    merged.store.navigation = none
    merged.store.navigation-buttons = false
    merged.store.section-progress = false
  }
  let resolved = with-navigation(with-navigation-buttons(with-footer-space(merged)))
  touying.touying-slide(
    self: resolved,
    setting: body => {
      if resolved.at("appendix", default: false) {
        [#metadata((kind: "touying-appendix"))<touying-metadata>]
      }
      show: citations.apply-citation-links
      show: setting
      body
    },
    ..args,
  )
}
