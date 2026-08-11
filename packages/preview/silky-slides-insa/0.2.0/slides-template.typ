#import "insa-common.typ": *
#import "@preview/touying:0.7.4": *

// UTILITIES:

#let _breadcrumb() = context {
  let dot(selected) = ellipse(
    width: 7pt,
    height: 7pt,
    fill: if selected { insa-colors.secondary } else { luma(80%) },
    stroke: none,
  )

  let current-slide = utils.slide-counter.get().at(0)
  let total-slides = utils.slide-counter.final().last()
  let dots = (dot(false),) * total-slides
  dots.at(current-slide - 1) = dot(true)
  stack(dir: ltr, spacing: 4pt, ..dots)
}

#let _footer(self, color: black) = {
  utils.call-or-display(self, self.page.footer)

  let show-total = self.info.total-numbering

  place(right + bottom, box(width: 1.75cm, height: 1.75cm, align(center + horizon, text(
    font: insa-body-fonts,
    fill: color,
    size: if show-total { .75em } else { 1em },
    weight: "bold",
    context {
      if show-total [
        #utils.slide-counter.get().at(0)/#utils.slide-counter.final().at(0)
      ] else [
        #utils.slide-counter.display()
      ]
    },
  ))))

  if (self.info.breadcrumbs) {
    place(
      bottom + center,
      dy: -0.5cm,
      _breadcrumb(),
    )
  }
}

// Hack for https://github.com/touying-typ/touying/issues/219
#let _size-slide-background(self, background) = {
  let notes-position = self.at("show-notes-on-second-screen", default: none)

  align(top + left, box(
    width: if notes-position == right { 50% } else { 100% },
    height: if notes-position == bottom { 50% } else { 100% },
    align(horizon + center, background),
  ))
}


// SLIDES:

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()

  let visual = info.title-visual != none

  self = utils.merge-dicts(
    self,
    config-page(
      background: _size-slide-background(self, image(if visual { "assets/slide-title-visual.svg" } else {
        "assets/slide-title.svg"
      })),
      margin: 0pt,
      footer: _footer(self),
    ),
  )
  touying-slide(self: self, {
    let titles-width = 16cm

    if visual {
      titles-width = 11.8cm

      place(dx: 13.95cm, dy: 1.9cm, block(width: 12cm, height: 13cm, align(
        center + horizon,
        info.title-visual,
      )))
    }

    place(dx: 2.02cm, dy: 1.89cm, block(width: 4.94cm, info.logo))

    place(dx: 2.02cm, dy: 4cm, block(width: titles-width, height: 5.81cm, align(bottom, text(
      font: insa-heading-fonts,
      size: 40pt,
      fill: white,
      weight: "bold",
      info.title,
    ))))

    place(dx: 2.02cm, dy: 12.8cm, block(width: titles-width, height: 2.3cm, align(top, text(
      font: insa-heading-fonts,
      size: 20pt,
      fill: black,
      info.subtitle,
    ))))
  })
})

#let section-slide(title, description: none, add-heading: true) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: _size-slide-background(self, image("assets/slide-section.svg")),
      margin: 0pt,
      footer: _footer(self),
    ),
  )
  touying-slide(self: self, {
    if add-heading {
      // so a manual call to section-slide adds an entry to the outline
      show heading: {}
      heading(level: 1, title)
    }

    place(dx: 2.02cm, dy: 4.1cm, block(width: 20cm, height: 6.8cm, align(bottom, text(
      font: insa-heading-fonts,
      size: 40pt,
      weight: "bold",
      fill: black,
      if title == none { utils.display-current-heading(level: 1, style: heading => heading.body) } else { title },
    ))))

    place(dx: 2.02cm, dy: 11.5cm, block(width: 17cm, height: 4cm, align(top, text(
      font: insa-heading-fonts,
      size: 24pt,
      fill: black,
      description,
    ))))
  })
})

#let slide(..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      background: _size-slide-background(self, place(bottom + right, image("assets/footer.png", width: 3.5cm))),
      footer: _footer(self, color: white),
    ),
    config-common(
      subslide-preamble: (..args) => {
        utils.display-current-heading(level: 2, style: none)
        v(0.5em)
      },
    ),
  )
  touying-slide(self: self, ..args)
})

/// A template for INSA presentations
///
/// - title (str | content): title of the presentation
/// - title-visual (content | none): content shown next to the title
/// - subtitle (content): content shown under the title
/// - insa (str): name of the school
/// - breadcrumbs (bool): whether or not to show the breadcrumbs (fil d'Ariane)
/// - total-numbering (bool): whether or not to show the total amount of slides in the bottom right counter
/// - text-size (length): size of the text in the slides bodies
/// - args (arguments): additional arguments to pass to touying
/// - body (content): rest of the document
/// -> content
#let insa-slides(
  title: "Titre à définir",
  title-visual: none,
  subtitle: "Sous-titre à définir",
  insa: "rennes",
  breadcrumbs: false,
  total-numbering: false,
  text-size: 22pt,
  ..args,
  body,
) = {
  _ = insa-school-name(insa) // checks that the INSA is supported

  show: touying-slides.with(
    config-page(
      paper: "presentation-16-9",
      //footer: _footer,
      margin: (x: 2.02cm, y: 1.71cm),
    ),
    config-common(
      slide-level: 2,
      new-section-slide-fn: section-slide.with(add-heading: false),
      slide-fn: slide,
    ),
    config-info(
      title: title,
      title-visual: title-visual,
      subtitle: subtitle,
      logo: image(insa-logo-path(insa, white: true)),
      breadcrumbs: breadcrumbs,
      total-numbering: total-numbering,
    ),
    config-colors(
      ..insa-colors,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: insa-body-fonts, size: text-size)
        show heading: set text(font: insa-heading-fonts)

        set list(marker: (sym.circle.filled.tiny, sym.plus))
        // TODO: change sublist color to primary (impossible for now)

        body
      },
    ),
    ..args,
  )

  title-slide()

  body
}
