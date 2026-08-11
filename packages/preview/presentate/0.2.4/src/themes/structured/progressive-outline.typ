#import "../../presentate.typ" as p
#import "../../store.typ": *
#import "../../components/components.typ": progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title

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
  body,
  ..options,
) = {
  
  let trans-opts = (enabled: true, level: 2)
  if type(transitions) == dictionary { trans-opts = p.utils.merge-dicts(base: trans-opts, transitions) }

  structure-config.update(conf => (
    mapping: mapping,
    auto-title: auto-title,
    text-size: text-size,
    text-font: text-font,
    show-heading-numbering: show-heading-numbering,
    numbering-format: numbering-format,
  ))

  config-state.update((
    text-size: text-size,
    text-font: text-font,
  ))

  if header == auto {
    header = context {
      let mapping = structure-config.get().mapping
      let level-modes = (level-1-mode: "none", level-2-mode: "none", level-3-mode: "none")
      let styles = (:)
      
      for role in ("part", "section", "subsection") {
        let lvl = mapping.at(role, default: none)
        if lvl != none {
          level-modes.insert("level-" + str(lvl) + "-mode", "current")
          let col = if role == "part" { gray.darken(20%) } else if role == "section" { gray } else { luma(150) }
          let weight = if role == "part" or role == "section" { "bold" } else { "regular" }
          styles.insert("level-" + str(lvl), (active: (fill: col, weight: weight)))
        }
      }

      set text(size: 0.8em)
      progressive-outline(
        ..level-modes,
        layout: "horizontal",
        separator: text(fill: gray, " / "),
        text-styles: styles,
        show-numbering: show-heading-numbering,
        numbering-format: numbering-format,
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
  
  // Wrap the document to ensure heading numbering is global
  show: doc => {
    if show-heading-numbering {
      if numbering-format != auto {
        set heading(outlined: true, numbering: (..nums) => {
          let lvl = nums.pos().len()
          if lvl in mapping.values() {
            numbering(numbering-format, ..nums)
          }
        })
        doc
      } else {
        set heading(outlined: true)
        doc
      }
    } else {
      set heading(numbering: none)
      doc
    }
  }
  
  // Unified Transition Rule
  show heading: h => {
    let hook = none
    if is-role(mapping, h.level, "part") { hook = on-part-change }
    else if is-role(mapping, h.level, "section") { hook = on-section-change }
    else if is-role(mapping, h.level, "subsection") { hook = on-subsection-change }

    if hook != none {
      hook(h)
    } else {
      let final-trans = transitions
      if show-all-sections-in-transition {
        let all-vis = (part: "all", section: "all", subsection: "all")
        let override = (parts: (visibility: all-vis), sections: (visibility: all-vis), subsections: (visibility: all-vis))
        if type(transitions) == dictionary {
          final-trans = p.utils.merge-dicts(base: final-trans, override)
        } else {
          final-trans = override
        }
      }

      render-transition(
        h,
        transitions: final-trans,
        mapping: mapping,
        show-heading-numbering: show-heading-numbering,
        numbering-format: numbering-format,
        theme-colors: (primary: eastern, accent: eastern),
        slide-func: empty-slide.with(text-size: text-size, text-font: text-font)
      )
    }
  }

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
