#import "../../presentate.typ" as p
#import "../../store.typ": set-options
#import "../../components/components.typ": progressive-outline, get-active-headings, structure-config, resolve-slide-title, is-role, render-transition
#import "../../components/structure.typ": empty-slide
#import "../../components/title.typ": slide-title

// State to share configuration between template and slides
#let config-state = state("minimal-config", none)

/// Internal layout engine for minimal slides
#let apply-layout(title: none, body) = context {
  let config = config-state.get()
  if config == none { return body }
  
  let footer-content = config.footer-content
  
  block(width: 100%, height: 100%, {
    // Marker for miniframes dot production
    metadata((t: "Miniframes_Normal"))
    
    stack(
      dir: ttb,
      // 1. Title zone
      slide-title(resolve-slide-title(title), inset: (x: 5%, top: 1.5em, bottom: 1em)),
      
      // 2. Content zone
      pad(x: 5%, body),
      
      v(1fr),
      
      // 3. Footer zone
      if footer-content != none {
        set text(fill: gray, size: 0.8em)
        pad(x: 5%, bottom: 1em, footer-content)
      }
    )
  })
}

/// Standard slide for the minimal theme
#let slide(..args, align: top) = {
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
    apply-layout(title: manual-title, {
      set std.align(align)
      body
    }),
  )
}

/// Minimalist theme focused on content and roadmap transitions
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
  header: none,
  footer: auto,
  body,
  ..options,
) = {
  
  structure-config.update(conf => (
    mapping: mapping,
    auto-title: auto-title,
    text-size: text-size,
    text-font: text-font,
    show-heading-numbering: show-heading-numbering,
    numbering-format: numbering-format,
  ))

  let footer-content = if footer == auto {
    context grid(
      columns: (1fr, 1fr, 1fr),
      align(left, if author != none { author }),
      align(center, if title != none { title }),
      align(right, counter(page).display("1"))
    )
  } else {
    footer
  }

  config-state.update((
    footer-content: footer-content,
    text-size: text-size,
    text-font: text-font,
  ))

  set page(paper: "presentation-" + aspect-ratio, margin: 0pt, header: header, footer: none)
  set text(size: text-size, font: text-font)
  
  show heading: set text(size: 1em, weight: "regular")
  
  // Wrap the entire document to ensure heading numbering is global
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
        theme-colors: (primary: black, accent: blue),
        slide-func: empty-slide.with(text-size: text-size, text-font: text-font)
      )
    }
  }
  
  set-options(..options)

  // --- Title Slide ---
  empty-slide(text-size: text-size, text-font: text-font, {
    set align(center + horizon)
    pad(x: 10%)[
      #block(text(size: 2.5em, weight: "bold", title), inset: (bottom: 1em))
      #if subtitle != none { text(size: 1.2em, emph(subtitle)) }
      #v(2em)
      #grid(columns: 2, author, date, inset: (x: 1em))
    ]
  })

  if show-outline {
    p.slide(pad(x: 10%, y: 10%)[
      #block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 2pt + black))[
        #text(weight: "bold", size: 1.2em, outline-title)
      ]
      #v(1em)
      #set text(size: 0.9em)
      #outline(title: none, indent: 2em, depth: outline-depth)
    ])
  }

  body
}