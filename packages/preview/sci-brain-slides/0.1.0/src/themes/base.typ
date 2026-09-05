#import "@preview/touying:0.6.1": *
#import "../scale.typ": sizes as default-sizes

// Body pages share a fixed header and footer, independent of content height.
#let slide(title: auto, config: (:), ..args) = touying-slide-wrapper(self => {
  let pal = self.store.palette
  let sizes = self.store.sizes
  let header = {
    set text(size: sizes.large, weight: "bold", fill: pal.ink)
    block(width: 100%, inset: (bottom: 10pt), stroke: (bottom: 0.7pt + pal.hairline))[
      #if title == auto { utils.call-or-display(self, self.store.header) } else { title }
    ]
  }
  let footer = {
    set text(size: sizes.chrome, fill: pal.text_soft)
    components.left-and-right(
      utils.call-or-display(self, self.store.footer),
      context utils.slide-counter.display(),
    )
    if self.store.footer-progress {
      v(6pt)
      components.progress-bar(height: 1.5pt, pal.primary, pal.hairline)
    }
  }
  touying-slide(self: self,
    config: utils.merge-dicts(config-page(header: header, footer: footer), config),
    ..args,
  )
})

#let section-slide(self: none, body: none, ..args) = touying-slide-wrapper(self => {
  let pal = self.store.palette
  let sizes = self.store.sizes
  touying-slide(self: self, config: config-page(header: none, footer: none), {
    set align(left + horizon)
    rect(width: 36pt, height: 3pt, fill: pal.accent_deep, stroke: none)
    v(18pt)
    text(size: sizes.xlarge, weight: "bold", fill: pal.ink,
      utils.display-current-heading(level: 1))
    if body != none { v(12pt); text(fill: pal.text_soft, body) }
  })
})

#let theme(pal, font: "DejaVu Sans", lang: "en", footer: none,
  footer-progress: false, sizes: default-sizes, ..args, body) = {
  set text(font: font, size: sizes.normal, fill: pal.text, lang: lang)
  set par(leading: 0.65em)
  set list(indent: 0pt, body-indent: 0.7em, spacing: 0.65em)
  show math.equation: set text(font: "New Computer Modern Math")
  show: touying-slides.with(
    config-page(paper: "presentation-16-9", fill: pal.paper,
      margin: (top: 100pt, bottom: 46pt, x: 48pt),
      header-ascent: 20pt, footer-descent: 16pt),
    config-common(slide-fn: slide, new-section-slide-fn: section-slide,
      zero-margin-header: false, zero-margin-footer: false),
    config-colors(primary: pal.primary, primary-light: pal.primary_light,
      secondary: pal.secondary, neutral-lightest: pal.paper,
      neutral-dark: pal.text_soft, neutral-darkest: pal.text),
    config-store(palette: pal, sizes: sizes,
      header: self => utils.display-current-heading(depth: self.slide-level),
      footer: footer, footer-progress: footer-progress),
    ..args,
  )
  body
}
