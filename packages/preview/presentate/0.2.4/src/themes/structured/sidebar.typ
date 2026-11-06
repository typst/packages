#import "../../presentate.typ" as p
#import "../../components/components.typ": progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title

// State to share configuration
#let config-state = state("sidebar-config", none)

/// Standard slide with sidebar
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
    {
      slide-title(resolve-slide-title(manual-title))
      body
    }
  )
}

/// A sidebar-based template inspired by Beamer's Hannover/Marburg themes.
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
  side: "left",
  width: 22%,
  sidebar-color: rgb("#2c3e50"),
  main-color: white,
  text-color: white,
  active-color: rgb("#f39c12"),
  completed-color: rgb("#95a5a6"),
  title-color: rgb("#2c3e50"),
  logo: none,
  logo-position: "top",
  outline-options: (:),
  body,
  ..options
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

  // Default text styles for the sidebar
  let default-text-styles = (
    level-1: (
      active: (weight: "bold", fill: active-color),
      completed: (fill: completed-color),
      inactive: (fill: text-color)
    ),
    level-2: (
      active: (weight: "bold", fill: active-color, size: 0.9em),
      completed: (fill: completed-color, size: 0.9em),
      inactive: (fill: text-color.darken(10%), size: 0.9em)
    ),
    level-3: (
      active: (weight: "bold", fill: active-color, size: 0.8em),
      completed: (fill: completed-color, size: 0.8em),
      inactive: (fill: text-color.darken(20%), size: 0.8em)
    )
  )

  // Mapping-aware outline options
  let mapped-levels = mapping.values()
  let final-outline-opts = (
    level-1-mode: if 1 in mapped-levels { "all" } else { "none" },
    level-2-mode: if 2 in mapped-levels { "all" } else { "none" },
    level-3-mode: if 3 in mapped-levels { "all" } else { "none" },
    match-page-only: true,
    text-styles: default-text-styles,
    show-numbering: show-heading-numbering,
    numbering-format: numbering-format,
    spacing: (
      indent-2: 1.2em,
      indent-3: 2.4em,
      v-between-1-1: 1.2em, 
      v-between-1-2: 0.8em,
      v-between-2-1: 1.2em, 
      v-between-2-2: 0.6em,
      v-between-2-3: 0.4em,
      v-between-3-3: 0.3em,
    )
  ) + outline-options

  // The content of the sidebar
  let sidebar-content = context {
    set text(font: text-font, size: 0.7em)
    
    place(
      if side == "left" { left } else { right },
      rect(width: width, height: 100%, fill: sidebar-color, stroke: none)
    )
    
    place(
      if side == "left" { left } else { right },
      block(
        width: width, height: 100%, inset: (x: 1em, y: 2em),
        if logo != none and logo-position == "bottom" {
          stack(
            dir: ttb, spacing: 1em,
            block(inset: (bottom: 0.5em), text(size: 1.2em, weight: "bold", fill: white, title)),
            progressive-outline(..final-outline-opts),
            v(1fr),
            align(center, logo)
          )
        } else {
          stack(
            dir: ttb, spacing: 2em,
            if logo != none { align(center, logo) },
            block(inset: (bottom: 0.5em), text(size: 1.2em, weight: "bold", fill: white, title)),
            progressive-outline(..final-outline-opts)
          )
        }
      )
    )
  }

  let layout-margins = if side == "left" {
    (left: width + 1cm, right: 1cm, top: 1cm, bottom: 1cm)
  } else {
    (left: 1cm, right: width + 1cm, top: 1cm, bottom: 1cm)
  }

  set page(
    paper: "presentation-" + aspect-ratio,
    margin: layout-margins,
    fill: main-color,
    background: sidebar-content,
    footer: context {
      set text(fill: gray.darken(30%), size: 0.8em)
      align(if side == "left" { right } else { left })[
        #counter(page).display("1 / 1", both: true)
      ]
    }
  )

  set text(size: text-size, font: text-font, fill: black)
  
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
          final-trans = p.utils.merge-dicts(base: transitions, override)
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
        theme-colors: (primary: sidebar-color, accent: active-color),
        slide-func: empty-slide.with(text-size: text-size, text-font: text-font)
      )
    }
  }

  // --- Title Slide ---
  empty-slide(fill: sidebar-color, text-size: text-size, text-font: text-font, {
    set align(center + horizon)
    set text(fill: white)
    block(
      text(size: 2.5em, weight: "bold", title),
      inset: (bottom: 1em),
      stroke: (bottom: 2pt + white.transparentize(50%))
    )
    if subtitle != none { 
      text(size: 1.2em, emph(subtitle))
      v(1em) 
    }
    
    let info = ()
    if author != none { info.push(author) }
    if date != none { info.push(date) }
    
    if info.len() > 0 {
      grid(columns: info.len() * 2 - 1, ..info.intersperse(grid.vline(stroke: 0.5pt + white.transparentize(50%))), inset: 0.7em)
    }
  })

  if show-outline {
    p.slide([
      #block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 2pt + sidebar-color))[
        #text(weight: "bold", size: 1.2em, outline-title)
      ]
      #v(1em)
      #set text(size: 0.9em)
      #outline(title: none, indent: 2em, depth: outline-depth)
    ])
  }

  body
}