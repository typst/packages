#import "../touying.typ": utils
#import "../components/watermark.typ": watermark-layer

#let with-watermark(self, kind, enabled: auto) = {
  let enabled = if enabled == auto { kind in self.store.at("watermark-slides", default: ()) } else { enabled }
  assert(type(enabled) == bool, message: "Slide watermark must be true, false, or auto.")
  if not enabled or self.store.at("watermark-logo", default: none) == none { return self }
  let previous = self.page.at("background", default: none)
  utils.merge-dicts(self, (page: (background: context {
    if type(previous) == function { previous(self) } else { previous }
    watermark-layer(self, self.page.fill, page.width, page.height,
      size: self.store.at("watermark-height", default: 50%))
  }),))
}
