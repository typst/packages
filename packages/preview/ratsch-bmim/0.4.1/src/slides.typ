#import "@preview/touying:0.7.4": *
#import "colors.typ": *
#import "data.typ": *
#import "utils.typ": translatedMonth
#import "options.typ": options

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let opts = options.final()
  let new-config = utils.merge-dicts(
    opts,
    config-page(
      header: none,
      footer: none,
      background: place(
        center+bottom,
        image(height: 100%, "./../assets/background_bettelwurf.jpg")
      ) + box(fill: self.colors.primary.transparentize(65%).lighten(50%), height:100%, width: 100%)
    ),
    config-common(freeze-slide-counter:true),
  )

  let logo-left = if type(opts.logo) == dictionary {
    opts.logo.at("title-left", default: auto)
  } else {
    opts.logo
  }
  let logo-right = if type(opts.logo) == dictionary {
    opts.logo.at("title-right", default: auto)
  } else {
    opts.logo
  }

  self = utils.merge-dicts(self, new-config)

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
    let left_margin = 28pt
    let logo_pad = 20pt
    let logo_height = 40pt

    // body
    context place(
      bottom+left,
      dy: page.margin.bottom,
    block(
      inset: left_margin,
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
              font: "Source Serif 4",
              weight: "bold",
              size: 34pt
            )
            [
              #title.at(0, default:none)
              #if subtitle != none {
                parbreak()
                text(size: 16pt, subtitle)
              }
            ]
        },
      )
      // flush the rest to the bottom
      v(2em)
      grid(
        columns: (1fr, 1fr),
        gutter: 1pt,
        grid.cell(
          align(left+bottom,{
            let locStr = ""
            if location != none {
              locStr = [, #location]
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
              text(size: 14pt,
              if opts.lang == "de" {
                [#date.day(). #translatedMonth(date, opts.lang) #date.year()#locStr]
              } else {
                [#translatedMonth(date, opts.lang) #date.day(), #date.year()#locStr]
              })
            }
            ]
          })
        ),
        grid.cell(
          align(center+bottom,
            grid(
              columns: (1fr, 1fr),
              gutter: 0pt,
              grid.cell(
                if logo-left == auto {
                  pad(
                    top: 0pt,
                    image("./../assets/logo_iace_white.svg", height: 40pt)
                  )
                } else {
                  logo-left
                }
              ),
              grid.cell(
                if logo-right == auto {
                  place(
                    dy: 10pt,
                    if opts.lang == "de" {
                      image("./../assets/logo_umit_white_gr.svg", height: 36pt)
                    } else {
                      image("./../assets/logo_umit_white_en.svg", height: 36pt)
                    }
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
  coverLvl: 1,
  ..args,
) = touying-slide-wrapper(self => {
  let opts = options.final()
  let new-config = utils.merge-dicts(
    opts,
  )

  self = utils.merge-dicts(self, new-config)

  let cntOutline = counter("outline")
  cntOutline.update(1)

  let body = {
    show: align.with(horizon)
    show heading: none
    show outline.entry.where(level: 1): it => {
      cntOutline.step()
      let style(entry) = block(
          fill: gradient.linear(
            if cntOutline.get().at(0) == coverLvl {
              self.colors.primary.lighten(50%)
            } else {
              self.colors.primary.lighten(5%)
            },
            self.colors.primary.lighten(5%).transparentize(100%),
            relative: "parent",
          ),
          width: 100%,
          inset: 6pt,
          strong(text( fill: white, cntOutline.display() + h(1em) + entry ))
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
  let opts = options.final()

  let new-config = utils.merge-dicts(
    opts,
    config-page(
      margin: 0pt,
      header: none,
      footer: none,
      background: place(
        center+bottom,
        image(height: 100%, "./../assets/background_bettelwurf.jpg")
      ) + box(fill: self.colors.primary.transparentize(65%).lighten(50%), height:100%, width: 100%)
    ),
  )

  self = utils.merge-dicts(self, new-config)
  self.store.title = ""

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
