#import "../../presentate.typ" as p
#import "../../store.typ": *
#import "../../components/components.typ": progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition, navigator-config
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title
#import "shared.typ": apply-heading-numbering, apply-transition-rule

#let config-state = state("progressive-outline-config", none)

#let slide(..args) = {
  let kwargs = args.named()
  let args = args.pos()
  let manual-title = none
  let body = none

  if args.len() == 1 {
    body = args.at(0)
  } else {
    manual-title = args.at(0)
    body = args.at(1)
  }

  p.slide(
    ..kwargs,
    [
      #slide-title(resolve-slide-title(manual-title))
      #body
    ],
  )
}

#let template(
  title: none,
  subtitle: none,
  author: none,
  date: datetime.today().display(),
  aspect-ratio: "16-9",
  text-font: "Lato",
  text-size: 20pt,
  mapping: (section: 1, subsection: 2),
  auto-title: false,
  show-heading-numbering: true,
  numbering-format: auto,
  show-outline: false,
  outline-title: [Outline],
  outline-depth: 2,
  transitions: (),
  show-all-sections-in-transition: false,
  on-part-change: none,
  on-section-change: none,
  on-subsection-change: none,
  // Thème spécifique
  header: auto,
  footer: auto,
  max-length: none,
  use-short-title: false,
  body,
  ..options,
) = {
  
  // Synchronisation avec navigator-config
  navigator-config.update(c => {
    c.mapping = mapping
    c.auto-title = auto-title
    c.show-heading-numbering = show-heading-numbering
    c.numbering-format = numbering-format
    c.slide-func = empty-slide.with(text-size: text-size, text-font: text-font)
    c.theme-colors = (primary: eastern, accent: eastern)
    c.transitions = transitions
    c.max-length = max-length
    c.use-short-title = use-short-title
    c.progressive-outline = p.utils.merge-dicts(
      (
        level-1-mode: "none",
        level-2-mode: "none",
        level-3-mode: "none",
        text-styles: (
          level-1: (active: (fill: gray.darken(20%), weight: "bold"), completed: (weight: "bold"), inactive: (weight: "bold")),
          level-2: (active: (fill: gray, weight: "bold"), completed: (weight: "bold"), inactive: (weight: "bold")),
          level-3: (active: (fill: gray.lighten(40%), weight: "regular"), completed: (weight: "regular"), inactive: (weight: "regular")),
        ),
      ),
      base: c.at("progressive-outline", default: (:))
    )
    c
  })

  if header == auto {
    header = context {
      let mapping = navigator-config.get().mapping
      let level-modes = (:)
      
      for role in ("part", "section", "subsection") {
        let lvl = mapping.at(role, default: none)
        if lvl != none {
          level-modes.insert("level-" + str(lvl) + "-mode", "current")
        }
      }

      set text(size: 0.8em)
      progressive-outline(
        ..level-modes,
        layout: "horizontal",
        separator: text(fill: gray, " / "),
      )
    }
  }

  if footer == auto {
    footer = {
      set text(fill: gray, size: 0.8em)
      author
      h(1fr)
      context counter(page).display("1")
    }
  }

  set page(paper: "presentation-" + aspect-ratio, header: header, footer: footer)
  set text(size: text-size, font: text-font)
  
  show heading: set text(size: 1em, weight: "regular")
  
  show: apply-heading-numbering.with(mapping, show-heading-numbering, numbering-format)
  show heading: apply-transition-rule.with(mapping, transitions, show-all-sections-in-transition, on-part-change, on-section-change, on-subsection-change)

  // --- Title Slide ---
  empty-slide(text-size: text-size, text-font: text-font, {
    set align(center + horizon)
    pad(x: 10%)[
      #block(text(size: 2em, weight: "bold", title), inset: (bottom: 1.2em), stroke: (bottom: 2pt + eastern))
      #emph(subtitle)
      #linebreak()
      #grid(columns: 2, author, grid.vline(), date, inset: (x: 0.5em))
    ]
  })

  if show-outline {
    p.slide([
      #block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 2pt + eastern))[
        #text(weight: "bold", size: 1.2em, outline-title)
      ]
      #v(1em)
      #set text(size: 0.9em)
      #outline(title: none, indent: 2em, depth: outline-depth)
    ])
  }

  show emph: set text(fill: eastern)
  set-options(..options)
  body
}
