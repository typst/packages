#import "../../presentate.typ" as p
#import "../../store.typ": states, set-options
#import "../../components/components.typ": progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title

// State to share configuration
#let config-state = state("split-config", none)

#let apply-layout(title: none, body) = context {
  let config = config-state.get()
  if config == none { return body }
  
  let primary = config.primary
  let secondary = config.secondary
  let nav-style = config.navigation-style
  let h-inset = config.header-inset
  let sec-align = config.section-align
  let subsec-align = config.subsection-align
  let show-num = config.show-heading-numbering
  let num-fmt = config.numbering-format
  
  let header-size = 0.45em
  let footer-size = 0.4em
  
  let mapping = structure-config.get().mapping
  let roles = ()
  if "part" in mapping and mapping.part != none { roles.push("part") }
  if "section" in mapping and mapping.section != none { roles.push("section") }
  if "subsection" in mapping and mapping.subsection != none { roles.push("subsection") }
  
  let header-cols = config.header-columns
  if header-cols == (1fr, 1fr) and roles.len() == 3 {
    header-cols = (1fr, 1fr, 1fr)
  }

  // Header Logic using table for equal height columns
  let header = block(width: 100%, table(
    columns: header-cols,
    inset: h-inset,
    stroke: none,
    fill: (x, y) => if calc.even(x) { primary } else { secondary },
    align: (col, row) => {
      if col == 0 { return sec-align + horizon }
      if col == roles.len() - 1 { return subsec-align + horizon }
      return center + horizon
    },
    ..roles.map(role => {
      let lvl = mapping.at(role)
      let mode = if nav-style == "all" {
        if role == "part" { "all" }
        else if role == "section" { if "part" in mapping { "current-parent" } else { "all" } }
        else if role == "subsection" { "current-parent" }
        else { "all" }
      } else { "current" }
      
      {
        set text(size: header-size, fill: white)
        progressive-outline(
          level-1-mode: if lvl == 1 { mode } else { "none" },
          level-2-mode: if lvl == 2 { mode } else { "none" },
          level-3-mode: if lvl == 3 { mode } else { "none" },
          show-numbering: show-num,
          numbering-format: num-fmt,
          text-styles: (
            ("level-" + str(lvl)): (
              active: (weight: "bold", fill: white),
              inactive: (weight: "regular", fill: white.transparentize(40%)),
              completed: (weight: "regular", fill: white.transparentize(40%))
            )
          ),
          spacing: (v-between-1-1: 0.4em, v-between-2-2: 0.4em, v-between-3-3: 0.4em)
        )
      }
    })
  ))

  // Footer Logic
  let footer = block(width: 100%, {
    set text(size: footer-size, fill: white)
    grid(
      columns: (1fr, 1fr, 1fr),
      block(fill: primary, width: 100%, inset: 0.6em, align(center, config.author)),
      block(fill: secondary, width: 100%, inset: 0.6em, align(center, config.title)),
      block(fill: primary, width: 100%, inset: 0.6em, align(center, counter(page).display("1 / 1", both: true)))
    )
  })

  // Title Logic
  let st = slide-title(resolve-slide-title(title), size: 1.2em, weight: "bold", inset: (x: 1.5em, top: 0.8em))

  // Assemble the slide
  stack(
    dir: ttb,
    header,
    st,
    block(width: 100%, inset: (x: 1.5em, y: 1em), {
      show heading: none
      body
    }),
    v(1fr),
    footer
  )
}

#let slide(..args) = {
  let pos = args.pos()
  let named = args.named()
  if pos.len() == 1 {
    p.slide(..named, apply-layout(pos.at(0)))
  } else {
    p.slide(..named, apply-layout(title: pos.at(0), pos.at(1)))
  }
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
  primary: rgb("#003366"),
  secondary: rgb("#336699"),
  navigation-style: "all", // "all" or "current"
  header-columns: (1fr, 1fr),
  header-inset: (x: 1.5em, y: 0.8em),
  section-align: right,
  subsection-align: left,
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
    primary: primary,
    secondary: secondary,
    navigation-style: navigation-style,
    header-columns: header-columns,
    header-inset: header-inset,
    section-align: section-align,
    subsection-align: subsection-align,
    show-heading-numbering: show-heading-numbering,
    numbering-format: numbering-format,
    title: title,
    author: author,
    text-size: text-size,
    text-font: text-font,
  ))

  set page(paper: "presentation-" + aspect-ratio, margin: 0pt, header: none, footer: none)
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
          theme-colors: (primary: primary, secondary: secondary, accent: white),
          slide-func: empty-slide.with(text-size: text-size, text-font: text-font)
        )
      }
    }

  // --- Title Slide ---
  empty-slide(fill: primary, text-size: text-size, text-font: text-font, {
    set std.align(center + horizon)
    set text(fill: white)
    block(text(size: 2em, weight: "bold", title), inset: (bottom: 1.2em), stroke: (bottom: 2pt + white.transparentize(50%)))
    emph(subtitle)
    linebreak()
    grid(columns: 2, author, grid.vline(), date, inset: (x: 0.5em))
  })

  if show-outline {
    p.slide(pad(x: 1.5em, y: 1.5em)[
      #block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 2pt + primary))[
        #text(weight: "bold", size: 1.2em, outline-title)
      ]
      #v(1em)
      #set text(size: 0.9em)
      #outline(title: none, indent: 2em, depth: outline-depth)
    ])
  }

  set-options(..options)
  body
}