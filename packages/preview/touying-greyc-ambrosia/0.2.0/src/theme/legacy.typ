#import "../core.typ": utils, config-page, extensions
#import "../assets.typ"
#import "../core.typ": palettes
#let fit-title = extensions.fit-title
#let touying-slide = extensions.render-slide
#let watermark-layer = extensions.watermark-layer
#let presentation-people = extensions.presentation-people
#let authors-grid = extensions.authors-grid
#let institutions-list = extensions.institutions-list
#let emails-grid = extensions.emails-grid

#let render-legacy-title-slide(self: none, config: (:), fit: auto, min-scale: auto, watermark: auto, ..args) = {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 2em, right: 30%, top: 1em, bottom: 20%),
      header: none,
      footer: none,
    ),
    config,
  )
  // Keep the historical composition while following the resolved palette/accent.
  self.colors.cover = self.colors.primary
  self.colors.on-cover = palettes.on-color(self.colors.cover)
  self.page.fill = self.colors.cover
  self.colors.foreground = self.colors.on-cover
  self.colors.muted = self.colors.on-cover
  self.colors.primary = self.colors.on-cover
  self.store.title = none
  let watermark = if watermark == auto { "title" in self.store.watermark-slides } else { watermark }
  assert(type(watermark) == bool, message: "Slide watermark must be true, false, or auto.")
  self.store.logo-background = self.colors.cover
  let info = self.info + args.named()
  let people = presentation-people(info)
  let decoration = context {
    layout(size => {
      let ml
      let mt
      if type(page.margin) == dictionary and "top" in page.margin and "left" in page.margin {
        ml = page.margin.left
        mt = page.margin.top
      } else if page.margin == auto {
        ml = (page.width - size.width) / 2
        mt = (page.height - size.height) / 2
      } else {
        ml = page.margin
        mt = page.margin
      }
      // cover
      place(top + left, dx: -ml, dy: -mt, float: false, block(width: page.width, height: page.height)[
        #place(right + horizon, dx: 22%, dy: -1%)[
          #image(assets.read-asset(assets.asset-paths.cover-image), height: 140%, fit: "cover")
        ]
        #place(left + horizon)[
          #box(
            fill: gradient.linear(
              ..((self.colors.cover,) * 15),
              self.colors.cover.transparentize(50%),
              self.colors.cover.transparentize(100%),
            ),
            width: 80%,
            height: 100%,
          )
        ]
        #place(right + top, dx: 5%, dy: -7.5%)[
          #image(assets.read-asset(assets.asset-paths.cover-traits), height: 35%, fit: "cover")
        ]
        #if watermark {
          place(top + left, watermark-layer(self, self.colors.cover, page.width, page.height,
            size: self.store.watermark-height))
        }
        // Optional identity decoration never changes the palette roles.
        #if self.store.at("greyc-team-accent", default: false) {
          place(top + left, block(width: 0.3em, height: 100%, fill: self.store.greyc-team-color, {
            [#metadata((color: self.store.greyc-team-color.to-hex()))<greyc-team-accent>]
          }))
        }
      ])

      // logos
      place(dy: page.height - mt - 3.25em, float: false, block(width: size.width, height: auto, {
        show: std.align.with(horizon)
        [#metadata((background: page.fill.to-hex(),
          team-color: if self.store.at("greyc-team-color", default: none) == none { none } else { self.store.greyc-team-color.to-hex() },
          team-accent: self.store.at("greyc-team-accent", default: false),
          width: size.width.pt()))<greyc-legacy-cover>]
        let logo-info = info
        if self.store.primary-logos == auto and "logo-light" in info and palettes.prefer-light(self.colors.cover) { logo-info.logo = info.logo-light }
        let groups = extensions.title-logo-groups(self, info: logo-info, logos: args.named().at("logos", default: auto))
        extensions.grouped-logo-row(self, groups.primary, groups.partners, 2.25em, gap: 0.6em)
      }))
    })
  }
  let body = fit-title({
    show: std.align.with(left + horizon)
    set par(
      leading: 0.65em,
      spacing: 0.7em,
    )
    set text(fill: self.colors.on-cover)
    // title and subtitle
    text(size: 1.4em, fill: self.colors.on-cover, weight: "extrabold", upper(info.title))
    if info.subtitle != none {
      parbreak()
      text(size: 1.0em, fill: self.colors.on-cover, weight: "semibold", info.subtitle)
    }
    // Names, affiliations, and contact details stay inside the fitted cover unit.
    v(1.2em)
    authors-grid(people, self.store.mono-font, self.colors.on-cover, compact: true, columns: self.store.author-columns)
    if people.institutions.len() > 0 {
      v(0.4em)
      institutions-list(people, self.colors.on-cover)
    }
    if people.emails.len() > 0 {
      v(0.4em)
      emails-grid(people, self.store.mono-font, self.colors.on-cover)
    }
    // date
    if info.date != none {
      v(0.5em)
      text(size: 0.7em, utils.display-info-date(self + (info: info)))
    }
  }, fit: if fit == auto { self.store.title-fit } else { fit },
  min-scale: if min-scale == auto { self.store.title-min-scale } else { min-scale },
  alignment: left + horizon, decoration: decoration)
  touying-slide(self: self, body)
}
