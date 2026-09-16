#import "@preview/touying:0.7.4": *
#import "utils.typ": *
#import "colors.typ": *

// ######################
// # Slide config
// ######################

#let slide(
  title: auto,
  section: auto,
  ..args,
) = touying-slide-wrapper(self => {
  // If a title is provided update the config-store
  if title != auto {
    self.store.title = title
  }

  // If a section is provided update the config-store
  if section != auto {
    self.store.section = section
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

    if self.store.include-sections == true {
      // If a section is provided, use it - otherwise use the section title
      set text(size: 0.8em, fill: self.colors.secondary)
      block(below: 0.5em, {
        if self.store.section != none {
          utils.call-or-display(self, self.store.section)
        } else {
          utils.display-current-heading(level: 1)
        }
      })
    }

    // If a title is provided, use it - otherwise use subsection title
    set text(size: 1.5em, fill: black)
    block(below: 0.5em, {
      if self.store.title != none {
        utils.call-or-display(self, self.store.title)
      } else {
        utils.display-current-heading(level: 2)
      }
    })

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
        fill: self.colors.primary-dark,
        department: info.department,
      ),

      text(
        fill: self.colors.primary-dark,
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
// # New section
// ######################
#let new-section-slide(..args) = touying-slide-wrapper(self => {
  // Extract info
  let info = self.info + args.named()

  let body = {
    // Add seal to top right corner
    place(
      top + right,
      dy: -7.5cm,
      dx: 7.5cm,
      text(
        font: "AU Logo",
        size: 20cm,
        fill: luma(0, 15%),
        "1",
      ),
    )

    set align(horizon)
    set text(size: 1.5em, fill: self.colors.primary-dark, weight: "bold")

    components.custom-progressive-outline(
      depth: 1,
      alpha: 40%,
      vspace: (-0.5em, 0em),
      title: none,
    )
  }

  let footer(self) = {
    set align(bottom)
    grid(
      inset: (x: 1em),
      columns: (1fr, 1fr),
      align: (left + bottom, right + bottom),

      au-logo(
        fill: self.colors.primary-dark,
        department: info.department,
      ),

      text(
        fill: self.colors.primary-dark,
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
      margin: (x: 1.5em, y: 2em),
      footer: footer,
    ),
  )

  touying-slide(self: self, body)
})

// ######################
// # Title slide
// ######################

#let title-slide(..args) = touying-slide-wrapper(self => {
  // Extract info
  let info = self.info + args.named()
  let body = {
    set align(horizon)
    set text(size: 18pt, fill: white)

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
  variant: "blue",
  include-sections: true,
  include-agenda: true,
  ..args,
  body,
) = {
  set text(size: 16pt, font: "AU Passata")

  // Quote configuration
  set quote(block: true, quotes: true)
  show quote: set align(center)
  show quote: set pad(x: 5em)

  // Enum configuration
  set enum(indent: 1em, spacing: 1em)

  // List configuration
  set list(indent: 1em, spacing: 1em)

  // Set figure caption size
  show figure.caption: set text(9pt)

  // Table configuration
  show table.cell.where(y: 0): strong
  show table.cell: set text(11pt)
  set table(
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 6em, bottom: 1.5em, x: 2em),
      footer-descent: -30%,
    ),

    config-common(
      slide-fn: slide,
      new-section-slide-fn: if include-agenda { new-section-slide } else { none },
      datetime-format: "[month repr:long] [day padding:none], [year]",
    ),

    config-colors(
      primary: color-dict.at(variant).at("primary"),
      primary-dark: color-dict.at(variant).at("primary-dark"),
      secondary: color-dict.at(variant).at("secondary"),
      secondary-dark: color-dict.at(variant).at("secondary-dark"),
    ),

    config-methods(
      alert: utils.alert-with-primary-color,
    ),

    config-store(
      title: none,
      section: none,
      include-sections: include-sections,
      include-agenda: include-agenda,
    ),

    ..args,
  )
  body
}

