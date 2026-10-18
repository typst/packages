#import "@preview/touying:0.7.4": *

// Theme colours mirrored into plain states so that inline helpers like `button`
// and `small-cite` can read them from a `context` -- and therefore be used
// inside `#only`/`#uncover`/`context`, where touying's `touying-fn-wrapper`
// marks are unsupported. The states are seeded by `clean-theme`'s `init`.
#let _clean-primary = state("touying-quarto-clean-primary", rgb("107895"))
#let _clean-foreground = state("touying-quarto-clean-foreground", rgb("131516"))

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(left + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", font: self.store.font-family-heading)
    utils.display-current-heading(level: 1)
  }
  self = utils.merge-dicts(self, config-page(margin: (left: 2em, top: -0.25em)))
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
    if not self.store.at("hide-slide-numbers", default: false) {
      h(1fr)
      context utils.slide-counter.display() + " / " + utils.last-slide-number
    }
  }

  // Set the slide
  let self = utils.merge-dicts(self, config-page(
    header: header,
    footer: footer,
  ))
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


#let clean-theme(
  aspect-ratio: "16-9",
  handout: false,
  header: utils.display-current-heading(level: 2),
  footer: [],
  hide-slide-numbers: false,
  font-size: 20pt,
  font-family-heading: "Roboto",
  font-family-body: "Roboto",
  font-family-mono: "Fira Code",
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
  set text(size: font-size, font: font-family-body, fill: color-jet, weight: font-weight-body)
  show raw: set text(font: font-family-mono)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio, margin: (top: 4em, bottom: 1.5em, x: 2em)),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      handout: handout,
      enable-frozen-states-and-counters: false, // https://github.com/touying-typ/touying/issues/72
      show-hide-set-list-marker-none: true,
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        // Seed the colour states (read by `button` / `small-cite`).
        _clean-primary.update(self.colors.primary)
        _clean-foreground.update(self.colors.neutral-darkest)
        show link: set text(fill: self.colors.primary)
        // Unordered List
        // Markers are drawn as vector polygons (not font glyphs) so they render
        // identically regardless of which fonts the Typst fallback picks up.
        set list(indent: 1em, marker: (
          // Level 1: filled right-pointing triangle
          box(baseline: 0.05em, polygon(
            fill: self.colors.primary,
            (0em, 0em), (0.42em, 0.24em), (0em, 0.48em),
          )),
          // Level 2+: thin right arrow glyph (New Computer Modern ships with
          // Typst, so it is always available -- slim, like the original theme)
          text(fill: self.colors.primary, font: "New Computer Modern")[#sym.arrow],
        ))
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
          },
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
      hide-slide-numbers: hide-slide-numbers,
      font-family-heading: font-family-heading,
      font-family-body: font-family-body,
      font-size-title: font-size-title,
      font-size-subtitle: font-size-subtitle,
      font-weight-heading: font-weight-heading,
      font-weight-title: font-weight-title,
      font-weight-subtitle: font-weight-subtitle,
      ..args.named(),
    ),
    // Forward positional config-* args (e.g. a `config-info` handed in by a
    // bridge dispatcher), so info like title/authors reaches `self.info`.
    ..args.pos(),
  )

  body
}

// ORCID iD icon, bundled inline as SVG (no fontawesome / font download needed).
#let orcid-svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 256 256\"><path fill=\"#A6CE39\" d=\"M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z\"/><path fill=\"#FFFFFF\" d=\"M86.3,186.2H70.9V79.1h15.4v48.4V186.2z\"/><path fill=\"#FFFFFF\" d=\"M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z\"/><path fill=\"#FFFFFF\" d=\"M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,46.7,88.7,51.3,88.7,56.8z\"/></svg>"
#let orcid-icon = box(baseline: 0.15em, image(bytes(orcid-svg), format: "svg", height: 0.95em))

#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  // Resolve the title-slide fields tolerantly so the theme works both
  // standalone (fields passed straight to `title-slide`) and through a Quarto
  // bridge (fields arrive via `config-info`). Structured authors are read from
  // `authors-data` first (the Quarto convention) and fall back to `authors`.
  let title = info.at("title", default: none)
  let subtitle = info.at("subtitle", default: none)
  let authors = info.at("authors-data", default: info.at("authors", default: none))
  let date = info.at("date", default: none)
  let body = {
    set align(left + horizon)
    block(inset: (y: 1em), [#text(
        size: self.store.font-size-title,
        fill: self.colors.neutral-darkest,
        weight: self.store.font-weight-title,
        font: self.store.font-family-heading,
        title,
      )
      #if subtitle != none {
        linebreak()
        v(-0.3em)
        text(
          size: self.store.font-size-subtitle,
          style: "italic",
          fill: self.colors.primary,
          weight: self.store.font-weight-subtitle,
          font: self.store.font-family-body,
          subtitle,
        )
      }])

    set text(fill: self.colors.neutral-darkest)

    if authors != none {
      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 1.5em,
        ..authors.map(author => align(left)[
          #text(size: 1em, weight: "regular")[#author.name]
          #if author.orcid != [] {
            link("https://orcid.org/" + author.orcid.text)[#orcid-icon]
          } \
          #text(size: 0.7em, style: "italic")[
            #show link: set text(size: 0.9em, fill: self.colors.neutral-darkest)
            #link("mailto:" + author.email.children.map(email => email.text).join())[#author.email]
          ] \
          #text(size: 0.8em, style: "italic")[#author.affiliation]
        ])
      )
    }

    if date != none {
      block(if type(date) == datetime { date.display(self.datetime-format) } else { date })
    }
  }
  self = utils.merge-dicts(self, config-common(freeze-slide-counter: true))
  touying-slide(self: self, body)
})



// Custom Functions
// `.fg` / `.bg` colour the text / its background.
#let fg = (fill: rgb("e64173"), it) => text(fill: fill, it)
#let bg = (fill: rgb("e64173"), it) => highlight(
  fill: fill,
  radius: 2pt,
  extent: 0.2em,
  it,
)

// Beamer-style goto button (like `\beamergotobutton`). Reads the theme's
// primary colour from a `context`, so it works anywhere -- including inside
// `#only` / `#uncover` / `context`, unlike a `touying-fn-wrapper`.
#let button(it) = context {
  box(
    fill: _clean-primary.get(),
    inset: (x: 0.35em, y: 0.2em),
    radius: 0.5em,
    baseline: 0.05em,
  )[
    #set text(
      size: 0.55em,
      fill: white,
      weight: "regular",
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )
    // Vector triangle (font-independent), matching the white button text.
    #box(baseline: 0em, polygon(
      fill: white,
      (0em, 0em), (0.5em, 0.3em), (0em, 0.6em),
    ))~#it
  ]
}

// `.small-cite` -- small, muted inline text for citations / sources. Also
// `context`-based so it can be used inside animations.
#let small-cite(it) = context text(
  size: 0.7em,
  fill: _clean-foreground.get().lighten(30%),
  it,
)
