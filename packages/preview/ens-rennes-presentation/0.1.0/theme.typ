#import "@preview/touying:0.6.1": *
#import "custom-blocks.typ": *

#let alt-cell = block.with(
  width: 100%,
  height: 2.5em,
  above: 0pt,
  below: 0pt,
  breakable: false,
)

#let list-font = ("Univers", "New Computer Modern Sans", "CMU Sans Serif")

#let dpt-cols = (
  info: rgb("#49bfe0"),
  maths: rgb("3fb4a6"),
  mktro: rgb("98bf0c"),
  dem: rgb("93117e"),
  "2sep": rgb("f29500"),
  spen: rgb("#339963"),
)

#let section-styles = ("named subsection", "subsection", "compact section only")

#let section-link(section, body) = {
  link((page: section.location().page(), x: 0pt, y: 0pt), body)
}

#let is-active-section(section, active-section: none) = {
  active-section = if  active-section == none  {
    utils.current-heading(level: section.level)
  } else {
    active-section
  }
  active-section != none and section.location() == active-section.location()
}

#let get-sections(level, loc: auto) = {
  if (level > 2 or level < 1) {
    panic("`get-sections` only supports levels 1 and 2, got " + repr(level))
  }

  let main-active-section = utils.current-heading(level: 1)
  if loc == auto {
    // A bit of a hack, but it works.
    if level == 2 and main-active-section != none {
      loc = main-active-section.location()
    } else {
      loc = here()
    }
  }

  let parent-heading = heading.where(level: level - 1)
  let selector = heading.where(level: level, outlined: true)
  if (level == 1 and main-active-section != none) {
    selector = selector.or(main-active-section.location())
  }

  let previous-parents = query(parent-heading.before(loc))
  let next-parents = query(parent-heading.after(loc, inclusive: false))

  if previous-parents.len() != 0 {
    selector = selector.after(previous-parents.last().location())
  }
  if next-parents.len() != 0 {
    selector = selector.before(next-parents.first().location(), inclusive: false)
  }
  query(selector)
}

#let header(self, dpt-color: none) = {
  let row(level) = context {
    show: block.with(height: 1em)
    get-sections(level)
      .map(section => {
        set text(fill: self.colors.neutral-lightest) if is-active-section(section)
        section-link(section, section.body)
      })
      .join(h(1em))
  }
  let current-slide-title = {
    set align(horizon)
    set text(fill: self.colors.neutral-lightest)
    if self.store.title == auto {
      context {
        show heading: it => text(size: .8em, weight: "regular", it)
        utils.call-or-display(self, utils.current-heading(level: 2).body)
      }
    } else if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    }
  }
  set align(top)
  block(
    width: 100%,
    height: 2.5em,
    above: 0pt,
    below: 0pt,
    breakable: false,
    fill: self.colors.primary,
    inset: (left: 1em), {
      set text(fill: self.colors.neutral-light.transparentize(50%), size: 0.7em)
      show: it => grid(
        columns: (1fr, auto),
        align: (start + horizon, end + horizon),
        it, pad(10pt, image("src/images/ENSRennes_LOGOblanc_centre.svg")),
      )
      if self.ens-rennes.section-style == "named subsection" {
        stack(
          dir: ttb,
          spacing: 0.2em,
          row(1),
          text(size: 0.8em, row(2)),
        )
      } else if self.ens-rennes.section-style == "subsection" {
        context {
          let sections = get-sections(1)
          grid(
            columns: sections.len(),
            column-gutter: 1em,
            row-gutter: 0.2em,
            ..sections.map(section => {
              set text(fill: self.colors.neutral-lightest) if is-active-section(section)
              section-link(section, section.body)
            }),
            ..sections.map(section => {
              show: block.with(height: 1em)
              set text(fill: self.colors.neutral-lightest) if is-active-section(section)
              let subsections = get-sections(2, loc: section.location())
              for subsection in subsections {
                section-link(
                  subsection,
                  if is-active-section(subsection) {
                    sym.circle.filled
                  } else {
                    sym.circle.stroked
                  },
                )
              }
            })
          )
        }
      } else if self.ens-rennes.section-style == "compact section only" {
        grid(
          columns:1,
          rows:(1fr, 2fr),
          // spacing: 0.2em,
          text(size:.8em, row(1)),
          current-slide-title,
        )
      }
    }
  )

  if self.ens-rennes.section-style != "compact section only" {
    let subheader-col = rgb("#556fb2")
    if self.ens-rennes.department != none and self.ens-rennes.display-dpt {
      subheader-col = gradient.linear(
        dpt-cols.at(self.ens-rennes.department),
        dpt-cols.at(self.ens-rennes.department).lighten(60%),
      )
    }
    block(
      width: 100%,
      height: 2.5em,
      above: 0pt,
      below: 0pt,
      breakable: false,
      fill: subheader-col, inset: 1em, 
      current-slide-title
    )
  }
}

#let footer(self) = {
  set text(fill: self.colors.neutral-lightest, size: 0.8em)
  show: block.with(
    fill: self.colors.primary,
    inset: 1em,
  )
  grid(
    columns: (5fr, 4fr, 1fr),
    column-gutter: 1em,
    align: (start + horizon, start + horizon, end + horizon),
    utils.call-or-display(self, self.info.at("mini-authors", default: self.info.author)),
    utils.call-or-display(self, self.info.at("mini-title", default: self.info.title)),
    [#context utils.slide-counter.display() / #utils.last-slide-number],
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  set text(font: list-font)
  set page(foreground: align(top + left)[ #image("src/images/circles.png")])
  set list(
    marker: (
      text(self.colors.primary, sym.triangle.r.filled),
      text(self.colors.primary, sym.bullet),
      text(self.colors.primary, sym.dash.en),
    ),
  )
  self.store.title = title
  let header-margin = if self.ens-rennes.section-style == "compact section only" {
    3em
  } else {
    6em
  }

  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin: (top: header-margin, bottom: 1.5em, x: 2em),
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(additional-content: none, ..args) = touying-slide-wrapper(self => {
  set text(font: list-font)
  set page(foreground: align(top + left)[ #image("src/images/circles.png")])
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      {
        text(size: 2em, fill: self.colors.neutral-lightest, info.title)
        linebreak()
        text(size: 1em, fill: self.colors.neutral-lightest, info.subtitle)
      },
    )
    set text(fill: self.colors.neutral-darkest)
    if info.authors != none {
      block(info.authors)
    }
    if info.institution != none {
      block(info.institution)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
    additional-content
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin: (top: 8em, bottom: 1.5em, x: 2em),
    ),
  )

  touying-slide(self: self, body)
})

#let focus-slide(config: (:), align: horizon + center, body) = touying-slide-wrapper(self => {
  set text(font: list-font)
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})

// ENS Rennes theme

#let ens-rennes-theme(
  aspect-ratio: "16-9",
  footer: none,
  info,
  ..args,
  department: none,
  display-dpt: false,
  section-style: "named subsection",
  body,
) = {
  set text(size: 20pt, font: list-font)

  assert(
    department in dpt-cols,
    message: "`department` must be one of " + dpt-cols.keys().map(repr).join(", ", last: ", or "),
  )

  assert(
    section-style in section-styles,
    message: "`section-style` must be one of " + section-styles.join(", ", last: ", or "),
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(
      primary: if display-dpt and department != none {
        dpt-cols.at(department)
      } else {
        rgb("324c98")
      },
      neutral-lightest: rgb("#ffffff"),
      neutral-lighter: rgb("#ffffff"),
      neutral-light: if display-dpt and department != none {
        rgb("#F0F0F0")
      } else {
        rgb("CADDE4")
      },
      neutral-darkest: rgb("#000000"),
      neutral-darerk: rgb("#000000"),
      neutral-dark: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    info,
    ..args,
    (
      ens-rennes: (
        department: department,
        display-dpt: display-dpt,
        section-style: section-style,
      ),
    ),
  )

  body
}
