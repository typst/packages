#import "@preview/touying:0.6.1": *
#import "@preview/fontawesome:0.5.0": *

#let new-section-slide(self: none, body)  = touying-slide-wrapper(self => {
  let main-body = {
    set align(left + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(
    self,
    config-page(margin: (left: 1em, top: 0em)),
  ) 
  touying-slide(self: self, main-body)
})

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(inset: (x: 2em, top: 1.5em))
    set text(
      size: 1.4em,
      fill: self.colors.neutral-darkest,
      weight: self.store.font-weight-heading,
      font: self.store.font-family-heading,
    )
    utils.call-or-display(self, self.store.header)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }

  // Set the slide
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


#let clean-theme(
  aspect-ratio: "16-9",
  handout: false,
  header: utils.display-current-heading(level: 2),
  footer: [],
  font-size: 20pt,
  font-family-heading: ("Roboto"),
  font-family-body: ("Roboto"),
  font-weight-heading: "light",
  font-weight-body: "light",
  font-weight-title: "light",
  font-weight-subtitle: "light",
  font-size-title: 1.4em,
  font-size-subtitle: 1em,
  color-jet: rgb("131516"),
  color-accent: rgb("107895"),
  color-accent2: rgb("9a2515"),
  ..args,
  body,
) = {
  set text(size: font-size, font: font-family-body, fill: color-jet,
           weight: font-weight-body)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      handout: handout,
      enable-frozen-states-and-counters: false, // https://github.com/touying-typ/touying/issues/72
      show-hide-set-list-marker-none: true,
      show-strong-with-alert: false
    ),
    config-methods(
      init: (self: none, body) => {
        show link: set text(fill: self.colors.primary)
        // Unordered List
        set list(
          indent: 1em,
          marker: (text(fill: self.colors.primary)[ #sym.triangle.filled.r ],
                    text(fill: self.colors.primary)[ #sym.arrow]),
        )
        // Ordered List
        set enum(
          indent: 1em,
          full: true, // necessary to receive all numbers at once, so we can know which level we are at
          numbering: (..nums) => {
            let nums = nums.pos()
            let num = nums.last()
            let level = nums.len()

            // format for current level
            let format = ("1.", "i.", "a.").at(calc.min(2, level - 1))
            let result = numbering(format, num)
            text(fill: self.colors.primary, result)
          }
        ) 
        // Slide Subtitle
        show heading.where(level: 3): title => {
          set text(
            size: 1.1em,
            fill: self.colors.primary,
            font: font-family-body,
            weight: "light",
            style: "italic",
          )
          block(inset: (top: -0.5em, bottom: 0.25em))[#title]
        }

        set bibliography(title: none)

        body
      },
      alert: (self: none, it) => text(fill: self.colors.secondary, it),
    ),
    config-colors(
      primary: color-accent,
      secondary: color-accent2,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: color-jet,
    ),
    // save the variables for later use
    config-store(
      header: header,
      footer: footer,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      ..args,
    ),
  )

  body
}

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(left + horizon)
    block(
      inset: (y: 1em),
      [#text(size: self.store.font-size-title,
             fill: self.colors.neutral-darkest,
             weight: self.store.font-weight-title,
             font: self.store.font-family-heading,
             info.title)
       #if info.subtitle != none {
        linebreak()
        v(-0.3em)
        text(size: self.store.font-size-subtitle,
             style: "italic",
             fill: self.colors.primary,
             weight: self.store.font-weight-subtitle,
             font: self.store.font-family-body,
             info.subtitle)
      }]
    )

    set text(fill: self.colors.neutral-darkest)

    if info.authors != none {
      let count = info.authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 1.5em,
        ..info.authors.map(author =>
            align(left)[
              #text(size: 1em, weight: "regular")[#author.name]
              #if author.orcid != [] {
                show link: set text(size: 0.7em, fill: rgb("a6ce39"))
                link("https://orcid.org/" + author.orcid.text)[#fa-orcid()]
              } \
              #text(size: 0.7em, style: "italic")[
                #show link: set text(size: 0.9em, fill: self.colors.neutral-darkest)
                #link("mailto:" + author.email.children.map(email => email.text).join())[#author.email]
              ] \
              #text(size: 0.8em, style: "italic")[#author.affiliation]
            ]
        )
      )
    }

    if info.date != none {
      block(if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true)
  )
  touying-slide(self: self, body)
})



// Custom Functions
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(
    fill: fill,
    radius: 2pt,
    extent: 0.2em,
    it
  )
#let _button(self: none, it) = {
  box(inset: 5pt,
      radius: 3pt,
      fill: self.colors.primary)[
    #set text(size: 0.5em, fill: white)
    #sym.triangle.filled.r
    #it
  ]
}

#let button(it) = touying-fn-wrapper(_button.with(it))
