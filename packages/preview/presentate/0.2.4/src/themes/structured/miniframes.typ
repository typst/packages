#import "../../presentate.typ" as p
#import "../../store.typ": states, set-options
#import "../../components/components.typ": get-structure, get-current-logical-slide-number, render-miniframes, progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title

// États pour partager la config entre le template et les fonctions slide
#let structure-cache = state("miniframes-structure-cache", none)
#let config-state = state("miniframes-config", none)

// Layout standard avec barre et footer
#let apply-layout(title: none, body) = context {
  let config = config-state.get()
  if config == none { return body }
  
  let struct = structure-cache.get()
  let current = get-current-logical-slide-number()
  
  let nav-opts = config.nav-opts
  let margin-x = config.margin-x
  let gap-zone = config.gap-zone
  let footer-content = config.footer-content
  let show-num = config.show-heading-numbering
  let num-fmt = config.numbering-format
  
  let footer-size = 0.75em

  // Gestion du titre manuel / auto
  let st-inset = (bottom: 0.8em)
  if nav-opts.position == "bottom" { st-inset.insert("top", 1.5em) }
  let st = slide-title(resolve-slide-title(title), size: 1.2em, weight: "bold", inset: st-inset)

  let bar = if struct != none {
    render-miniframes(
      struct,
      current,
      fill: nav-opts.fill,
      text-color: nav-opts.text-color,
      text-size: nav-opts.text-size,
      font: nav-opts.font,
      active-color: nav-opts.active-color,
      inactive-color: nav-opts.inactive-color,
      marker-shape: nav-opts.marker-shape,
      marker-size: nav-opts.marker-size,
      style: nav-opts.style,
      align-mode: nav-opts.align-mode,
      dots-align: nav-opts.dots-align,
      show-level1-titles: nav-opts.show-level1-titles,
      show-level2-titles: nav-opts.show-level2-titles,
      show-numbering: show-num,
      numbering-format: num-fmt,
      gap: nav-opts.gap,
      line-spacing: nav-opts.line-spacing,
      inset: nav-opts.inset,
      width: nav-opts.width,
      outset-x: nav-opts.outset-x,
      radius: nav-opts.radius,
    )
  } else { 
    block(width: 100%, height: 3em, []) 
  }

  // Style global de la slide (on force la police/taille du thème)
  set text(weight: "regular", fill: black, size: config.text-size, font: config.text-font)

  block(width: 100%, height: 100%, fill: white, {
    // Marqueur pour indiquer que cette slide doit produire un dot
    metadata((t: "Miniframes_Normal"))
    stack(
      dir: ttb,
      // 1. Zone Haute: BARRE DE MINIFRAMES (TOUT EN HAUT)
      if nav-opts.position == "top" {
        stack(dir: ttb, block(width: 100%, { set text(weight: "regular"); bar }), v(gap-zone))
      } else { none },
      
      // 2. Zone Milieu: TITRE + CORPS
      block(width: 100%, inset: (x: margin-x), {
        st
        // On cache les titres éventuellement présents dans body pour éviter les doublons
        show heading: none
        body
      }),
      
      v(1fr),
      
      // 3. Zone Basse: FOOTER / BARRE BASSE
      {
        set text(size: footer-size, fill: gray, weight: "regular")
        let footer-block = block(width: 100%, inset: (x: margin-x, bottom: 1em), footer-content)
        if nav-opts.position == "bottom" {
          stack(dir: ttb, footer-block, v(gap-zone/2), bar)
        } else {
          footer-block
        }
      }
    )
  })
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
  color: rgb("#1a5fb4"),
  show-level1-titles: true,
  show-level2-titles: true,
  navigation: (),
  body,
  ..options,
) = {
  let nav-opts = (
    position: "top", fill: color, text-color: white, text-size: 0.6em,
    font: none, active-color: white, inactive-color: white.transparentize(60%),
    marker-shape: "circle", marker-size: 4pt, style: "compact",
    align-mode: "left", dots-align: "left", 
    show-level1-titles: show-level1-titles,
    show-level2-titles: show-level2-titles,
    gap: 2em, line-spacing: 0.8em,
    inset: (x: 1.5em, y: 1.2em), radius: 0pt, width: 100%, outset-x: 0pt,
  )
  if type(navigation) == dictionary { 
    // Handle both 'align' and 'align-mode' for convenience
    if "align" in navigation and "align-mode" not in navigation {
      navigation.insert("align-mode", navigation.align)
    }
    nav-opts = p.utils.merge-dicts(base: nav-opts, navigation) 
  }

  structure-config.update(conf => (
    mapping: mapping,
    auto-title: auto-title,
    text-size: text-size,
    text-font: text-font,
    show-heading-numbering: show-heading-numbering,
    numbering-format: numbering-format,
  ))

  config-state.update((
    nav-opts: nav-opts, margin-x: 2.5em, gap-zone: 1.5em,
    footer-content: context grid(
      columns: (1fr, 1fr, 1fr),
      align(left, if author != none { author }),
      align(center, if title != none { title }),
      align(right, counter(page).display("1 / 1", both: true))
    ), 
    color: color,
    text-size: text-size,
    text-font: text-font,
    show-heading-numbering: show-heading-numbering,
    numbering-format: numbering-format,
  ))

  set page(paper: "presentation-" + aspect-ratio, margin: 0pt, header: none, footer: none)
  set text(size: text-size, font: text-font)

  show heading: set text(size: 1em, weight: "regular")
  
  // Wrap the document to ensure heading numbering is global and increments counters
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
  
  show: doc => { context structure-cache.update(get-structure(filter-selector: metadata.where(value: (t: "Miniframes_Normal")))); doc }
  
  // Title slide
  p.slide[
    #set align(center + horizon)
    #pad(x: 10%)[
      #block(fill: color, inset: (x: 2em, y: 1.5em), radius: 15pt, width: 100%)[
        #set text(fill: white)
        #if title != none { text(size: 2.2em, weight: "bold", title) }
        #if subtitle != none { 
          v(0.6em)
          line(length: 30%, stroke: 1pt + white.transparentize(50%))
          v(0.6em)
          text(size: 1.3em, style: "italic", subtitle) 
        }
      ]
    ]
    #v(2em)
    #pad(x: 12%)[
      #grid(
        columns: (1fr, 1fr), 
        align(left, if author != none { 
          set text(size: 1.1em)
          strong(author)
        }), 
        align(right, if date != none {
          set text(fill: gray)
          date
        })
      )
    ]
  ]

  if show-outline {
    p.slide(pad(x: 2.5em, y: 2em)[
      #block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 2pt + color))[
        #text(weight: "bold", size: 1.2em, outline-title)
      ]
      #v(1em)
      #set text(size: 0.9em)
      #outline(title: none, indent: 2em, depth: outline-depth)
    ])
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
        theme-colors: (primary: color, accent: white),
        slide-func: empty-slide.with(text-size: text-size, text-font: text-font)
      )
    }
  }

  set-options(..options)
  body
}