#import "@preview/touying:0.6.1": *
#import "@preview/touying-simpl-nudt:0.1.0": *

#let nudt-green = rgb("#005844")

#let compact-code(code, height: auto) = block(
  width: 100%,
  height: height,
  inset: (x: 0.8em, y: 0.8em),
  radius: 0.18em,
  stroke: (paint: rgb("#d7ddd9"), thickness: 0.6pt),
  fill: rgb("#f7f8f7"),
  {
    set text(font: "DejaVu Sans Mono", size: 0.8em)
    set par(leading: 0.8em)
    text(code)
  },
)

// Navigation helpers
#let last-heading-label(current-headings) = {
  if current-headings != () and current-headings.at(-1).has("label") {
    str(current-headings.at(-1).label)
  }
}

#let centered-mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  short-heading: true,
) = context {
  let headings = query(heading.where(level: 1).or(heading.where(level: 2)))
  let sections = headings.filter(it => it.level == 1 and it.outlined != false)
  let subsections = headings.filter(it => it.level == 2 and it.outlined != false)
  if sections == () {
    return
  }

  let first-page = sections.at(0).location().page()
  let slides = query(<touying-metadata>).filter(it => (
    utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
  ))
  let current-page = here().page()
  let current-index = sections.filter(it => it.location().page() <= current-page).len() - 1

  let cols = ()
  for (section, next-section) in sections.zip(sections.slice(1) + (none,)) {
    let section-page = section.location().page()
    let next-section-page = if next-section != none { next-section.location().page() } else { calc.inf }
    let section-subsections = subsections.filter(it => {
      let page = it.location().page()
      section-page <= page and page < next-section-page
    })
    let col = ()
    col.push({
      let body = if short-heading { utils.short-heading(self: self, section) } else { section.body }
      [#link(section.location(), body)<touying-link>]
      linebreak()
      if display-section {
        let section-slides = slides.filter(it => {
          let page = it.location().page()
          section-page <= page and page < next-section-page
        })
        for (slide, next-slide) in section-slides.zip(section-slides.slice(1) + (none,)) {
          let next-slide-page = if next-slide != none { next-slide.location().page() } else { next-section-page }
          if slide.location().page() <= current-page and current-page < next-slide-page {
            [#link(slide.location(), sym.circle.filled)<touying-link>]
          } else {
            [#link(slide.location(), sym.circle)<touying-link>]
          }
        }
      }
      if display-section and display-subsection and linebreaks and section-subsections != () {
        linebreak()
      }
    })

    for (subsection, next-subsection) in section-subsections.zip(section-subsections.slice(1) + (none,)) {
      let subsection-page = subsection.location().page()
      let next-subsection-page = if next-subsection != none {
        next-subsection.location().page()
      } else {
        next-section-page
      }
      col.push({
        if display-subsection {
          let subsection-slides = slides.filter(it => {
            let page = it.location().page()
            subsection-page <= page and page < next-subsection-page
          })
          for (slide, next-slide) in subsection-slides.zip(subsection-slides.slice(1) + (none,)) {
            let next-slide-page = if next-slide != none { next-slide.location().page() } else { next-subsection-page }
            if slide.location().page() <= current-page and current-page < next-slide-page {
              [#link(slide.location(), sym.circle.filled)<touying-link>]
            } else {
              [#link(slide.location(), sym.circle)<touying-link>]
            }
          }
        }
        if display-subsection and linebreaks {
          linebreak()
        }
      })
    }

    cols.push(align(left, col.sum()))
  }

  cols = cols
    .enumerate()
    .map(((idx, body)) => {
      let text-fill = if idx == current-index { fill } else { utils.update-alpha(fill, alpha) }
      text(fill: text-fill, body)
    })

  set align(top)
  show: block.with(inset: (top: .5em, x: 2em))
  show linebreak: it => it + v(-1em)
  set text(size: .7em)
  grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
}

// Header
#let subsection-header(self) = {
  let current-label = last-heading-label(self.headings)
  if self.store.navigation == "mini-slides" {
    centered-mini-slides(
      self: self,
      fill: self.colors.primary,
      alpha: self.store.alpha,
      display-section: self.store.mini-slides.at("display-section", default: false),
      display-subsection: self.store.mini-slides.at("display-subsection", default: true),
      linebreaks: self.store.mini-slides.at("linebreaks", default: true),
      short-heading: self.store.mini-slides.at("short-heading", default: true),
    )
  }
  grid(
    inset: (x: 1.9em, y: 0.15em),
    rows: (auto, auto),
    row-gutter: 12%,
    grid(
      columns: (72%, 28%),
      [
        #set text(size: 16pt)
        #align(left + horizon, utils.display-current-heading(
          level: 2,
          hierachical: false,
          depth: if current-label == "touying:hidden" { self.slide-level - 1 } else { self.slide-level },
          style: none,
        ))
      ],
      align(right + top, image("images/logo.png", height: 1.05cm)),
    ),
    align(center + top, line(length: 100%, stroke: (paint: self.colors.primary, thickness: 1.5pt))),
  )
}

// Standard slide wrapper
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let body-offset = self => {
    utils.call-or-display(self, self.store.subslide-preamble)
    v(0.25em)
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: subsection-header,
      footer: nudt-footer,
      margin: (x: 1.25cm, bottom: 0em),
    ),
    config-common(subslide-preamble: body-offset),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

#let section-card(title, active: true) = {
  let card-stroke = if active {
    (paint: nudt-green, thickness: 1.4pt)
  } else {
    (paint: rgb("#e3e9e6"), thickness: 0.8pt)
  }
  let card-fill = if active { rgb("#f7faf8") } else { rgb("#fbfcfb") }
  let title-fill = if active { nudt-green } else { rgb("#9aa8a2") }

  block(
  width: 11cm,
  height: 1.9cm,
  radius: 0.36cm,
  inset: (x: 0.55cm, y: 0.22cm),
  stroke: card-stroke,
  fill: card-fill,
  )[
    #align(center + horizon)[
      #text(size: 1.6em, fill: title-fill, weight: "bold")[#title]
    ]
  ]
}

#let toc-cards(current-section: none) = context {
  let sections = query(heading.where(level: 1)).filter(it => it.outlined != false)
  align(center)[
    #grid(
      columns: (auto,),
      row-gutter: 0.5cm,
      ..sections.map(it => {
        let active = current-section == none or it.body == current-section
        section-card(it.body, active: active)
      }),
    )
  ]
}

#let toc-slide() = slide(
  config: config-page(header: none, margin: (x: 1.25cm, top: 0.52cm, bottom: 0.9cm)),
)[
  #set text(fill: nudt-green)
  #grid(
    columns: (1fr, auto),
    [
      #v(0.6cm)
      #text(size: 1.85em, weight: "bold")[目录]
    ],
    [
      #v(0.6cm)
      #image("images/logo.png", width: 3.4cm)
    ],
  )
  #v(-0.1cm)
  #line(length: 100%, stroke: (paint: nudt-green, thickness: 1.5pt))

  #v(1cm)
  #toc-cards()
]

#let section-toc-slide(config: (:), ..args, body) = touying-slide-wrapper(self => {
  let current-section = if self.headings != () {
    self.headings.at(-1).body
  }
  self = utils.merge-dicts(
    self,
    config-page(header: none, footer: nudt-footer, margin: (x: 1.25cm, top: 0.52cm, bottom: 0.9cm)),
  )
  touying-slide(self: self, config: config)[
    #set text(fill: nudt-green)
    #grid(
      columns: (1fr, auto),
      [
        #v(0.6cm)
        #text(size: 1.85em, weight: "bold")[目录]
      ],
      [
        #v(0.6cm)
        #image("images/logo.png", width: 3.4cm)
      ],
    )
    #v(-0.1cm)
    #line(length: 100%, stroke: (paint: nudt-green, thickness: 1.5pt))

    #v(1cm)
    #toc-cards(current-section: current-section)
  ]
})

// Theme activation
#let use-theme(
  body,
  title: none,
  subtitle: none,
  author: none,
  date: none,
  institution: none,
) = {
  show: nudt-theme.with(
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: section-toc-slide,
    ),
  )
  body
}

// Title slide
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config, config-common(freeze-slide-counter: true), config-page(
    margin: (top: 3.5em, bottom: 1.5em, x: 2em),
  ))
  let info = self.info + args.named()
  let body = {
    set par(leading: 1.6em)
    set align(center + horizon)
    set page(
      background: align(left + bottom, image(
        "images/nudt-vi-nudtbg.png",
        width: if self.show-notes-on-second-screen == right { 50% } else { 100% },
      )),
      foreground: align(right + top, pad(right: 0.45em, top: 0.45em, image("images/logo.png", width: 3.7cm))),
    )
    block(width: 100%, inset: 3em, {
      v(0.2fr)
      block(
        if info.subtitle == none {
          linebreak()
        }
          + text(
            size: if info.subtitle == none { 2.2em } else { 1.9em },
            fill: self.colors.primary,
            weight: "bold",
            info.title,
          )
          + (
            if info.subtitle != none {
              v(-2.5em)
              linebreak()
              text(
                size: 1.3em,
                fill: self.colors.primary,
                weight: "bold",
                info.subtitle,
              )
            }
          ),
      )
      v(1fr)
      set text(size: 1.1em, fill: self.colors.neutral-dark, weight: "bold")
      if info.author != none {
        block(spacing: 0.3em, info.author)
      }
      v(1em)
      if info.date != none {
        block(spacing: 1em, utils.display-info-date(self))
      }
      set text(size: .8em, weight: "bold")
      if info.institution != none {
        block(spacing: 1em, info.institution)
      }
      if extra != none {
        block(spacing: 1em, extra)
      }
      v(0.3fr)
    })
  }
  touying-slide(self: self, body)
})
