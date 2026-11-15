#import "@preview/touying:0.8.0": *
#import "helpers.typ": print-date, pick-logo, place-institute-logo, umit-lang
#import "options.typ": options

// Own slide of the option `name` (title-slide, outline-slide) of slides(),
// handled like section-slide: auto returns auto (the slide of the template),
// none returns no slide, a slide function (touying-slide-wrapper) is called
// with `args` and rendered with `self`.
#let custom-slide(self, name, args) = {
  let custom = self.store.at(name, default: auto)
  if custom == auto { return auto }
  if custom == none { return [] }
  // unwrap the touying-slide-wrapper, as touying does for section-slide
  let wrapper = custom(..args)
  let wrapper = if type(wrapper) == content and wrapper.func() == block { wrapper.body } else { wrapper }
  assert(
    type(wrapper) == content and wrapper.func() == metadata
      and type(wrapper.value) == dictionary
      and wrapper.value.at("kind", default: none) == "touying-slide-wrapper",
    message: "Option '" + name + "' must return a touying-slide-wrapper",
  )
  (wrapper.value.fn)(self)
}

// Size and margins of one slide. With speaker notes on a second screen
// (option notes), touying doubles the page and adds the notes half to a margin,
// so page.width and page.margin no longer describe the slide.
#let slide-geometry(self) = {
  let (width, height) = utils.get-page-dimensions(self)
  let margin = self.page.at("margin", default: 0pt)
  let side(names) = if type(margin) != dictionary { margin } else {
    let hit = names.find(name => name in margin)
    if hit != none { margin.at(hit) } else { 0pt }
  }
  (
    width: width,
    height: height,
    left: side(("left", "x", "rest")),
    right: side(("right", "x", "rest")),
    top: side(("top", "y", "rest")),
    bottom: side(("bottom", "y", "rest")),
  )
}

// Background of the title and section slides: the photo, lightened in the
// primary color
#let slide-background(self) = place(
  center+bottom,
  image(height: 100%, "./../assets/background_bettelwurf.jpg")
) + box(fill: self.colors.primary.transparentize(65%).lighten(50%), height:100%, width: 100%)

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  // not shown in article mode, the report variant has its own title block
  if self.at("article-mode", default: false) { return touying-slide(self: self, []) }
  let custom = custom-slide(self, "title-slide", args)
  if custom != auto { return custom }
  let opts = options.final()
  let new-config = utils.merge-dicts(
    config-page(
      header: none,
      footer: none,
      background: slide-background(self),
    ),
    config-common(freeze-slide-counter:true),
  )

  self = utils.merge-dicts(self, new-config)

  let logo-left = pick-logo(opts.logo, "title-left")
  let logo-right = pick-logo(opts.logo, "title-right")

  let authors = (self.info.authors,).flatten()
  let title = (self.info.title,).flatten()
  let subtitle = self.info.subtitle
  let institution = self.info.institution
  let conference = self.info.conference
  let location = self.info.location
  let date = self.info.date

  let bold(size, body) = strong(text(size: size, body))

  let body = {
    // restore defaults
    set par(justify: false, spacing: 0.65em)
    set text(fill: self.colors.background, spacing: 100%)

    // settings
    let left-margin = 28pt

    // body
    // the margin of the slide, page.margin also holds the notes (option notes)
    place(
      bottom+left,
      dy: slide-geometry(self).bottom,
    block(
      inset: left-margin,
      fill: gradient.linear(
        self.colors.primary.transparentize(30%),
        self.colors.primary.transparentize(0%).darken(100%),
        angle: 90deg
      ),
      radius: 2pt,
      {
      // authors and institutions
      block(
        width: 100%,
        align(left,
        text(
          size: 14pt)[#authors.join[, ]] + if institution != none [
          #line(length: 30%, stroke: self.colors.background)
          #text(size: 10pt)[#institution.join[\ ]]
        ])
      )
      v(0.5em)
      // title
      block(
        width: 100%,
        {
            set par(leading: .4em)
            set text(
              fill: self.colors.background,
              font: opts.fonts.serif,
              weight: "bold",
              size: 34pt
            )
            [
              #title.at(0, default:none)
              #if subtitle != none {
                parbreak()
                text(
                  size: 12pt,
                  font: opts.fonts.serif,
                  weight: "regular",
                  subtitle
                )
              }
            ]
        },
      )
      // flush the rest to the bottom
      v(2em)
      grid(
        columns: (1fr, 1fr),
        gutter: 7pt,
        grid.cell(
          align(left+top,{
            let loc-str = ""
            if location != none {
              loc-str = [, #location]
            }
            [
            // conference
            #if conference != none {
              parbreak()
              text(size: 14pt, conference)
              linebreak()
            }
            // date
            #if date != none {
              if conference == none {
                parbreak()
              }
              text(size: 14pt)[#print-date(date)#loc-str]
            }
            ]
          })
        ),
        grid.cell(
          align(center+top,
            grid(
              columns: (1fr, 1fr),
              gutter: 0pt,
              grid.cell(
                if logo-left == auto {
                  pad(
                    top: 0pt,
                    // without an institute the height of its logo is kept
                    // for the placed UMIT TIROL logo on the right
                    if opts.institute == none { box(height: 40pt) } else {
                      place-institute-logo(opts, "title-slide", height: 40pt)
                    }
                  )
                } else {
                  logo-left
                }
              ),
              grid.cell(
                if logo-right == auto {
                  place(
                    dy: 10pt,
                    image("./../assets/logo_umit_white_" + umit-lang(opts) + ".svg", height: 36pt)
                  )
                } else {
                  logo-right
                }
              ),
            )
          )
        )
      )
    }
    ))
  }
  touying-slide(self: self, body)
})

#let outline-slide(
  cover-lvl: 1,
  ..args,
) = touying-slide-wrapper(self => {
  // not shown in article mode, the report variant has its own outline
  if self.at("article-mode", default: false) { return touying-slide(self: self, []) }
  let custom = custom-slide(self, "outline-slide", arguments(cover-lvl: cover-lvl, ..args))
  if custom != auto { return custom }

  let cnt-outline = counter("bmim-outline")
  cnt-outline.update(1)

  let body = {
    show: align.with(horizon)
    show heading: none
    show outline.entry.where(level: 1): it => {
      cnt-outline.step()
      let style(entry) = block(
          fill: gradient.linear(
            if cnt-outline.get().at(0) == cover-lvl {
              self.colors.primary.lighten(50%)
            } else {
              self.colors.primary.lighten(5%)
            },
            self.colors.primary.lighten(5%).transparentize(100%),
            relative: "parent",
          ),
          width: 100%,
          inset: 6pt,
          strong(text( fill: white, cnt-outline.display() + h(1em) + entry ))
        )
      link(it.element.location(), style( it.body() ))
      []
      v(1em)
    }

    pad(x: 2.5em, outline(depth: 1, ..args))
  }

  touying-slide(self: self, body)
})

#let new-section-slide(
  level: 1,
  numbered: true,
  ..args,
) = touying-slide-wrapper(self => {
  let new-config = utils.merge-dicts(
    config-page(
      margin: 0pt,
      header: none,
      footer: none,
      background: slide-background(self),
    ),
  )

  self = utils.merge-dicts(self, new-config)

  let body = {
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    v(-4em)
    block(
      width: 100%,
      fill: gradient.linear(
        self.colors.primary.lighten(5%),
        self.colors.primary.lighten(5%).transparentize(100%),
        relative: "parent",
      ),
      inset: (x: 2em, y: .8em),
      utils.display-current-heading(level: level, numbered: numbered)
    )
  }

  touying-slide(self: self, body)
})
