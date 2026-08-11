#import "@preview/touying:0.7.4": *
#import "utils.typ": *

#let black = rgb(0, 0, 0)
#let white = rgb(255, 255, 255)

/*
 * NOTE: For later version, I wish to implement a "variant" setting
 */
#let au-blue = rgb(0, 61, 115)
#let au-blue-dark = rgb(0, 37, 70)
#let au-purple = rgb(101, 90, 159)
#let au-purple-dark = rgb(40, 28, 65)
#let au-cyan = rgb(55, 160, 203)
#let ay-cyan-dark = rgb(0, 62, 92)
#let au-turquoise = rgb(0, 171, 164)
#let au-turquoise-dark = rgb(0, 69, 67)
#let au-green = rgb(139, 173, 63)
#let au-green-dark = rgb(66, 88, 33)
#let au-yellow = rgb(250, 187, 0)
#let au-yellow-dark = rgb(99, 75, 3)
#let au-orange = rgb(238, 127, 0)
#let au-orange-dark = rgb(95, 52, 8)
#let au-red = rgb(226, 0, 26)
#let au-red-dark = rgb(91, 12, 12)
#let au-magenta = rgb(226, 0, 122)
#let au-magenta-dark = rgb(95, 0, 48)
#let au-gray = rgb(135, 135, 135)
#let au-gray-dark = rgb(75, 75, 74)

// ######################
// # Slide config
// ######################

#let slide(
  title: auto,
  ..args,
) = touying-slide-wrapper(self => {
  // If a title is provided update the config-store
  if title != auto {
    self.store.title = title
  }

  // Import info
  let info = self.info + args.named()

  /*
   * Slide header
   */
  let header(self) = {
    set align(top)

    set text(weight: "bold")
    show text: it => upper(it)

    show: components.cell.with(inset: 1em)

    // If a title is provided use it, otherwise use subsection title
    set text(size: 1.5em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }

    v(-0.5em)
    line(length: 1.5cm, stroke: 4pt)
  }

  /*
   * Slide footer
   */
  let footer(self) = {
    set align(bottom)
    grid(
      inset: (x: 1em),
      columns: (1fr, 1fr),
      align: (left + bottom, right + bottom),

      au-logo(
        fill: self.colors.primary,
        department: info.department,
      ),

      text(
        fill: self.colors.primary,
        size: 9pt,
        (
          utils.display-info-date(self),
          context utils.slide-counter.display() + " of " + utils.last-slide-number,
        ).join(" | "),
      ),
    )
    v(1em)
  }

  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )

  touying-slide(self: self, ..args)
})

// ######################
// # Title slide
// ######################

#let title-slide(..args) = touying-slide-wrapper(self => {
  // Extract info
  let info = self.info + args.named()
  let body = {
    set align(horizon)
    set text(fill: white)

    block(text(
      size: 2em,
      weight: "bold",
      info.title,
    ))

    block(text(
      size: 1.2em,
      weight: "bold",
      info.subtitle,
    ))

    line(length: 1.5cm, stroke: 4pt + white)
    v(2em)


    set text(weight: "regular", size: 0.7em)
    if info.author != none {
      block(info.author)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }

    // Add seal to top right corner
    place(
      top + right,
      dy: -7.5cm,
      dx: 7.5cm,
      text(
        font: "AU Logo",
        size: 20cm,
        fill: luma(255, 15%),
        "1",
      ),
    )
  }

  /*
   * Slide footer
   */
  let footer(self) = {
    set align(bottom)
    grid(
      inset: (x: 1em),
      columns: (1fr, 1fr),
      align: (left + bottom, right + bottom),

      au-logo(
        fill: white,
        department: info.department,
      ),

      text(
        size: 1.5em,
        fill: white,
        font: "AU Logo",
        "1",
      ),
    )
    v(1em)
  }

  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary-dark,
      margin: (x: 1.5em, y: 2em),
      footer: footer,
    ),
  )

  touying-slide(self: self, body)
})

// ######################
// # End Slide
// ######################

#let end-slide(..args) = touying-slide-wrapper(self => {
  // Extract info
  let info = self.info + args.named()
  let body = {
    set align(horizon + center)
    set text(fill: white)

    scale(250%, au-logo(
      fill: white,
      department: info.department,
    ))

    // Add seal to the right
    place(
      right + horizon,
      dx: 11cm,
      text(
        font: "AU Logo",
        size: 20cm,
        fill: luma(255, 15%),
        "1",
      ),
    )

    // Add seal to the left
    place(
      left + horizon,
      dx: -11cm,
      text(
        font: "AU Logo",
        size: 20cm,
        fill: luma(255, 15%),
        "1",
      ),
    )
  }

  self = utils.merge-dicts(
    self,
    config-page(
      margin: 1.5em,
      fill: self.colors.primary-dark,
    ),
  )

  touying-slide(self: self, body)
})

// ######################
// # Global config
// ######################

#let touying-au-community(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 18pt, font: "AU Passata")

  // Quote configuration
  set quote(block: true, quotes: true)
  show quote: set align(center)
  show quote: set pad(x: 5em)

  // Enum configuration
  set enum(indent: 1em, spacing: 1em)

  // List configuration
  set list(indent: 1em, spacing: 1em)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 5em, bottom: 1.5em, x: 2em),
      footer-descent: -30%,
    ),

    config-common(
      slide-fn: slide,
      datetime-format: "[month repr:long] [day padding:none], [year]",
    ),

    config-colors(
      primary: au-blue,
      primary-dark: au-blue-dark,
      secondary: au-gray,
      secondary-dark: au-gray-dark,
    ),

    config-methods(
      alert: utils.alert-with-primary-color,
    ),

    config-store(
      title: none,
    ),

    ..args,
  )
  body
}

