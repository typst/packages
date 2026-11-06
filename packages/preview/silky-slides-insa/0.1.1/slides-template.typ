#import "@preview/touying:0.5.2": *

// CONSTANTS:

#let heading-fonts = ("League Spartan", "Arial", "Liberation Sans")
#let normal-fonts = ("Source Serif", "Source Serif 4", "Georgia")

#let insa-colors = (
  primary: rgb("#e42618"),
  secondary: rgb("#f69f1d"),
  tertiary: rgb("#f5adaa"),
)

// UTILITIES:

#let _footer(self, color: black) = {
  utils.call-or-display(self, self.page.footer)

  place(right + bottom, box(width: 1.75cm, height: 1.75cm, align(center + horizon, text(font: normal-fonts, fill: color, weight: "bold", context utils.slide-counter.display()))))
}

// SLIDES:

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  let visual = info.title-visual != none

  self = utils.merge-dicts(
    self,
    config-page(
      background: image(if visual {"assets/slide-title-visual.svg"} else {"assets/slide-title.svg"}),
      margin: (left: 0pt, top: 0pt),
      footer: _footer(self)
    )
  )
  touying-slide(self: self, {
    let titles-width = 16cm

    if visual {
      titles-width = 11.8cm

      place(dx: 13.95cm, dy: 1.9cm, block(width: 12cm, height: 11cm, align(center + horizon, info.title-visual)))
    }

    place(dx: 2.02cm, dy: 1.89cm, block(width: 4.94cm, info.logo))
    
    place(dx: 2.02cm, dy: 4cm, block(width: titles-width, height: 5.81cm, align(bottom, text(font: heading-fonts, size: 40pt, fill: white, weight: "bold", info.title))))

    place(dx: 2.02cm, dy: 12.8cm, block(width: titles-width, height: 2.3cm, align(top, text(font: heading-fonts, size: 20pt, fill: black, info.subtitle))))
  })
})

#let _section-slide-internal(section, section-description: none, add-heading: false) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: image("assets/slide-section.svg"),
      margin: (left: 0pt, top: 0pt),
      footer: _footer(self)
    ),
  )
  touying-slide(self: self, {
    if add-heading {
      show heading: {}
      heading(level: 1, section)
    }

    place(dx: 2.02cm, dy: 4.1cm, block(width: 20cm, height: 6.8cm, align(bottom, text(font: heading-fonts, size: 40pt, weight: "bold", fill: black, section))))

    place(dx: 2.02cm, dy: 11.5cm, block(width: 17cm, height: 4cm, align(top, text(font: heading-fonts, size: 24pt, fill: black, section-description))))
  })
})

#let section-slide(section, section-description) = _section-slide-internal(section, section-description: section-description, add-heading: true)

#let slide(..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: {
        place(bottom + right, image("assets/footer.png", width: 3.5cm))
      },
      footer: _footer(self, color: white)
    )
  )
  touying-slide(self: self, ..args)
})

#let insa-slides(
  title: "Titre à définir",
  title-visual: none,
  subtitle: "Sous-titre à définir",
  insa: "rennes",
  ..args,
  body
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-16-9",
      //footer: _footer,
      margin: (x: 2.02cm, y: 1.71cm)
    ),
    config-common(
      slide-level: 1,
      new-section-slide-fn: _section-slide-internal,
      slide-fn: slide
    ),
    config-info(
      title: title,
      title-visual: title-visual,
      subtitle: subtitle,
      logo: image("assets/" + insa + "/logo-white.png"),
    ),
    config-colors(
      ..insa-colors
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: normal-fonts, size: 22pt)

        show heading: set text(font: heading-fonts)
        show heading.where(level: 2): it => {
          pagebreak()
          text(size: 30pt, it)
          v(.5em)
        }

        set list(marker: (sym.circle.filled.tiny, sym.plus))
        // TODO: change sublist color to primary (impossible for now)

        body
      }
    ),
    ..args
  )

  title-slide()

  body
}