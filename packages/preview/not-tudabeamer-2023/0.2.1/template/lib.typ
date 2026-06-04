#import "@preview/touying:0.6.1": *

#let margin = (
  left: 0.39in,
  right: 0.34in,
  top: 1.2in,
  bottom: 0.33in
)

#let show-copyright = state("show-copyright", false)

#let figure-with-copyright(copyright: none, caption: none, ..args) = {
  figure(caption: context [
    #if show-copyright.get() {
      copyright
    } else {
      caption
    }
  ], ..args)
}

#let header-font(..args) = {
  text(font: "roboto", fallback: false, weight: "black", tracking: 2pt, size: 10pt, ..args)
}

#let footer-font(..args) = {
  text(font: "roboto", fallback: false, fill: rgb("#898989"), size: 9pt, ..args)
}

#let title-font(..args) = {
  set par(leading: 0.1in)
  set text(font: "roboto", fallback: false, weight: "black", size: 42pt)
  text(..args)
}

#let subtitle-font(..args) = {
  text(font: "roboto", fallback: false, size: 22pt, ..args)
}

#let slide-title-font(..args) = {
  set par(leading: 0.1in)
  text(font: "roboto", fallback: false, weight: "black", bottom-edge: "descender", size: 42pt, ..args)
}

#let header = self => pad(left: margin.left, right: margin.right, align(top)[
  #if self.store.enable-header {
    v(0.39in)
    header-font(upper(self.info.short-title + " / " + self.info.short-author))
  }
  #place(top + right, dx: 0.34in, dy: 0.2in)[#block(height: 0.99in, self.info.logo)]
])

#let footer(self) = pad(left: margin.left, right: margin.right, grid(
  rows: 0.125in,
  columns: (15%, 1fr, 15%),
  align: (bottom + left, bottom + center, bottom + right),
  footer-font(utils.display-info-date(self)),
  footer-font(self.info.department + " | " + self.info.institute + " | " + self.info.short-author),
  footer-font(context utils.slide-counter.display() ),
))

#let slide(title: auto, config: (:), repeat: auto, setting: body => body, composer: auto, ..bodies) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-common(subslide-preamble: self => {
      block(
        height: 1.99in - margin.top,
        below: 0.24in,
        width: 100% - 2in,
        align(bottom)[
          #slide-title-font(upper(if title != auto { title } else { utils.display-current-heading(depth: self.slide-level) }))
        ]
      )
    }),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
 })

#let title-slide(..args) = touying-slide-wrapper(self => {
  self.store.enable-header = false
  let info = self.info + args.named()
  let body = {
    grid(
      columns: 100%,
      rows: (
        2.76in - margin.top,
        1.18in,
        1.6in
      ),
      gutter: (0in, 0.2in),
      grid.cell([]),
      grid.cell(align: bottom + center, title-font(upper(info.title))),
      grid.cell(align: top + center, subtitle-font(info.subtitle)),
    )
  }
  touying-slide(self: self, body)
})

#let new-section-slide(body) = touying-slide-wrapper(self => {
  let body = {
    grid(
      columns: 100%,
      rows: (
        4.32in - margin.top,
        1.18in,
        1.18in
      ),
      gutter: (0in, 0.05in),
      grid.cell([]),
      grid.cell(align: bottom, slide-title-font(upper(utils.display-current-heading(level: 1)))),
      grid.cell(align: top, subtitle-font([]))
    )
  }
  touying-slide(self: self, body)
})

#let d-outline() = context {
   let elems = query(
    heading.where(level: 1, outlined: true)
  )
  set enum(numbering: n => title-font[#n], spacing: 0.4in, body-indent: 0.25in)
  show enum: set align(horizon)
  v(2.91in-1.18in-margin.top)
  columns(2,
    for (i, section) in elems.enumerate() {
    {
        enum.item(i + 1, section.body)
      }
      parbreak()
  })
}

#let outline-slide() = slide(title: "Outline", d-outline())

#let not-tudabeamer-2023-theme(
  ..args,
  body,
) = {
  set text(font: "roboto", fallback: false, size: 20pt)
  show: touying-slides.with(
    config-store(
      enable-header: true,
    ),
    config-page(
      width: 13.33in,
      height: 7.5in,
      footer-descent: 0in,
      header-ascent: 0in,
      margin: margin,
      header: header,
      footer: footer,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      datetime-format: "[day].[month].[year]"
    ),
    config-methods(init: (self: none, body) => {
      set document(title: self.info.title + " " + self.info.subtitle, author: self.info.author, date: self.info.date)
      body
    }),
    ..args,
  )

  body
}