#import "@preview/presentate:0.2.4" as p
#import p.store: states
#import "@preview/navigator:0.1.3" as nav

// État pour la configuration du thème
#let config-state = state("uni-pres-config", none)
#let last-main-page = state("last-main-page", none)
#let logical-slide-counter = counter("uni-pres-logical-slide")
#let appendix-state = state("uni-pres-appendix", false)

// --- Composants ---

#let progress-bar-line() = context {
  let conf = config-state.get()
  if conf == none or conf.progress-bar == "none" { return none }
  
  let current = logical-slide-counter.get().at(0)
  let is-annex = appendix-state.get()
  
  let total = if is-annex {
    logical-slide-counter.final().at(0)
  } else {
    let appendix-marker = query(<uni-pres-appendix-before-reset>)
    if appendix-marker.len() > 0 {
      logical-slide-counter.at(appendix-marker.first().location()).at(0)
    } else {
      logical-slide-counter.final().at(0)
    }
  }
  
  if total <= 0 or current <= 0 { return none }
  
  let ratio = calc.min(1.0, current / total)
  
  block(width: 100% * ratio, height: 2pt, fill: conf.primary-color)
}

#let empty-slide(fill: none, count: true, body) = {
  set page(margin: 0pt, fill: fill, header: none, footer: none, foreground: none)
  [
    #if count { logical-slide-counter.step() }
    #p.slide(logical-slide: true, {
      [#metadata((title: none, subtitle: none, allow-slide-breaks: false, is-special: true)) <uni-pres-slide-start>]
      body
    })
  ]
}

#let breadcrumb() = context {
  let conf = config-state.get()
  if conf == none { return none }
  
  let fg-color = if conf.dark-mode { 
    if conf.at("dark-text-secondary", default: none) != none { conf.dark-text-secondary } else { white.darken(20%) }
  } else { 
    gray.darken(20%) 
  }
  let sep-color = if conf.dark-mode { 
    if conf.at("dark-sep-color", default: none) != none { conf.dark-sep-color } else { gray.darken(40%) }
  } else { 
    gray.lighten(50%) 
  }
  
  set text(size: 0.8em, fill: fg-color)
  
  let mapping = conf.mapping
  let level-modes = (:)
  for role in ("part", "section", "subsection") {
    let lvl = mapping.at(role, default: none)
    if lvl != none { level-modes.insert("level-" + str(lvl) + "-mode", "current") }
  }

  nav.progressive-outline(
    ..level-modes,
    layout: "horizontal",
    separator: text(fill: sep-color, "  /  "),
    clickable: false,
    max-length: conf.max-length,
  )
}

#let set-logo(logo, ..args) = {
  if type(logo) == str {
    image(logo, ..args)
  } else if type(logo) == content {
    // If it's already an image or content
    if logo.func() == image {
      let w = args.named().at("width", default: auto)
      let h = args.named().at("height", default: auto)
      box(width: w, height: h, logo)
    } else {
      logo
    }
  } else {
    logo
  }
}

#let base-header(conf, logo-content: none, title-block: none) = context {
  if conf == none { return none }
  
  let markers = query(<uni-pres-slide-start>)
  if markers.len() == 0 { return none }
  
  let current-page = here().page()
  let marker = markers.filter(m => m.location().page() <= current-page).last()
  let meta = marker.value
  
  // On ne dessine pas l'en-tête si c'est une slide spéciale (titre, transition, etc.)
  let is-special = if type(meta) == dictionary { meta.at("is-special", default: false) } else { false }
  if is-special { return none }

  let top-inset = conf.at("header-inset-top", default: 0.8em)

  block(width: 100%, height: conf.at("margin-top", default: 4.5em), inset: (x: 2em, top: top-inset, bottom: 0.2em), {
    if conf.at("header-layout", default: "grid") == "stack" {
      stack(dir: ttb, spacing: 0.5em,
        logo-content,
        title-block
      )
    } else {
      grid(
        columns: (auto, 1fr),
        column-gutter: 1.5em,
        align: horizon,
        logo-content,
        title-block
      )
    }
  })
}

#let base-footer(conf) = context {
  if conf == none { return none }
  
  let markers = query(<uni-pres-slide-start>)
  if markers.len() == 0 { return none }
  let current-page = here().page()
  let marker = markers.filter(m => m.location().page() <= current-page).last()
  let meta = marker.value
  let is-special = if type(meta) == dictionary { meta.at("is-special", default: false) } else { false }
  if is-special { return none }

  let fg-color = if conf.dark-mode { 
    if conf.at("dark-text-secondary", default: none) != none { conf.dark-text-secondary } else { white.darken(20%) }
  } else { 
    gray.darken(20%) 
  }
  let line-color = if conf.dark-mode { 
    if conf.at("dark-line-color", default: none) != none { conf.dark-line-color } else { gray.darken(60%) }
  } else { 
    gray.lighten(80%) 
  }

  block(width: 100%, height: 3.0em, inset: (x: 2.5em, bottom: 0.8em, top: 0.2em), {
    set text(size: 0.65em, fill: fg-color)
    line(length: 100%, stroke: 0.5pt + line-color)
    v(0.5em)

    let show-author = conf.footer-author
    let show-title = conf.footer-title
    
    let slide-num = context {
      let current = logical-slide-counter.get().at(0)
      let is-annex = appendix-state.get()
      let total = if is-annex {
        logical-slide-counter.final().at(0)
      } else {
        let appendix-marker = query(<uni-pres-appendix-before-reset>)
        if appendix-marker.len() > 0 {
          logical-slide-counter.at(appendix-marker.first().location()).at(0)
        } else {
          logical-slide-counter.final().at(0)
        }
      }
      if current > 0 {
        box(width: 3.5em, align(right, [#current / #total]))
      }
    }

    if not show-author and not show-title {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        breadcrumb(),
        slide-num
      )
    } else {
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        text(size: 0.9em, weight: "regular", {
          if show-author { conf.short-author }
          if show-author and show-title [ #h(0.5em) · #h(0.5em) ]
          if show-title { conf.short-title }
        }),
        breadcrumb(),
        slide-num
      )
    }
  })
}

#let apply-layout(breakable: true, body) = context {
  let config = config-state.get()
  let fg-color = if config.dark-mode { white } else { config.text-color }
  set text(font: config.text-font, size: config.text-size, fill: fg-color)
  
  if not breakable {
    grid(
      columns: 100%,
      rows: 1fr,
      inset: (x: 2.5em, top: 0.5em, bottom: 0pt),
      {
        metadata((t: "ContentSlide"))
        body
      }
    )
  } else {
    block(width: 100%, breakable: true, inset: (x: 2.5em, top: 0.5em, bottom: 0pt), {
      metadata((t: "ContentSlide"))
      body
    })
  }
}

#let base-focus-slide(body, subtitle: none, conf) = {
  let is-dark = conf.dark-mode
  let bg-fill = if is-dark { conf.at("focus-bg-dark", default: conf.primary-color.darken(40%)) } else { conf.at("focus-bg-light", default: conf.primary-color) }
  
  empty-slide(fill: bg-fill, {
    // Logo slot
    if conf.at("transition-logo-func", default: none) != none {
      (conf.transition-logo-func)(conf)
    }

    let text-color = if is-dark { white } else { conf.at("focus-text-color", default: white) }
    set text(fill: text-color)

    if conf.at("focus-layout", default: "centered") == "boxed" {
      let box-fill = if is-dark { conf.at("dark-bg", default: black) } else { white }
      align(center + horizon, block(
        width: 80%,
        inset: 2em,
        stroke: (left: 5pt + conf.primary-color),
        fill: box-fill,
        align(left, stack(dir: ttb, spacing: 1em,
          text(size: 2.5em, weight: "bold", fill: if is-dark { white } else { conf.primary-color }, body),
          if subtitle != none {
            text(size: 1.5em, weight: "regular", style: "italic", fill: text-color.transparentize(20%), subtitle)
          }
        ))
      ))
    } else {
      // Default centered layout (Example style)
      set text(weight: "bold")
      align(center + horizon, pad(x: 3em, stack(dir: ttb, spacing: 1em,
        text(size: 2.5em, body),
        if subtitle != none {
          text(size: 1.5em, weight: "regular", style: "italic", fill: text-color.transparentize(20%), subtitle)
        }
      )))
    }
  })
}

#let focus-slide(body, subtitle: none) = context {
  let conf = config-state.get()
  if conf.at("focus-slide-func", default: none) != none {
    return (conf.focus-slide-func)(body, subtitle: subtitle)
  }
  
  base-focus-slide(body, subtitle: subtitle, conf)
}

#let alert(body) = context {
  let conf = config-state.get()
  text(fill: conf.alert-color, weight: "bold", body)
}

#let muted(body) = context {
  let conf = config-state.get()
  let color = if conf.dark-mode { luma(70%) } else { gray }
  text(fill: color, body)
}

#let subtle(body) = context {
  let conf = config-state.get()
  let color = if conf.dark-mode { luma(50%) } else { gray.lighten(40%) }
  text(fill: color, body)
}

#let two-col(left, right, columns: (1fr, 1fr), gutter: 2em) = {
  grid(
    columns: columns,
    column-gutter: gutter,
    left,
    right
  )
}

#let three-col(left, center, right, columns: (1fr, 1fr, 1fr), gutter: 2em) = {
  grid(
    columns: columns,
    column-gutter: gutter,
    left,
    center,
    right
  )
}

#let grid-2x2(tl, tr, bl, br, columns: (1fr, 1fr), rows: (auto, auto), gutter: 2em) = {
  grid(
    columns: columns,
    rows: rows,
    column-gutter: gutter,
    row-gutter: gutter,
    tl,
    tr,
    bl,
    br
  )
}

// --- API ---

#let slide(..args) = {
  let pos = args.pos()
  let named = args.named()
  let manual-title = named.at("title", default: none)
  let subtitle = named.at("subtitle", default: none)
  let allow-slide-breaks = named.at("allow-slide-breaks", default: false)
  let background = named.at("background", default: none)
  let is-special = named.at("is-special", default: false)
  let count = named.at("count", default: true)
  let body = if pos.len() > 0 { pos.at(0) } else { none }
  
  let clean-named = named
  for key in ("title", "subtitle", "allow-slide-breaks", "background", "is-special", "count") {
    if key in clean-named { 
      let _ = clean-named.remove(key)
    }
  }
  
  [
    #if count { logical-slide-counter.step() }
    #p.slide(..clean-named, {
      if background != none {
        context {
          let conf = config-state.get()
          let m-top = conf.at("margin-top", default: 4.5em)
          let m-bottom = 3.0em
          place(top + left, dx: 0pt, dy: -m-top, block(width: 100%, height: 100% + m-top + m-bottom, background))
        }
      }
      [#metadata((title: manual-title, subtitle: subtitle, allow-slide-breaks: allow-slide-breaks, is-special: is-special)) <uni-pres-slide-start>]
      apply-layout(breakable: allow-slide-breaks, body)
    })
  ]
}

#let figure-slide(fig, title: none, subtitle: none, caption: none, ..args) = {
  slide(title: title, subtitle: subtitle, ..args, {
    set align(center + horizon)
    figure(fig, caption: caption)
  })
}

#let figure-slide-split(fig-left, fig-right, title: none, subtitle: none, caption-left: none, caption-right: none, ..args) = {
  slide(title: title, subtitle: subtitle, ..args, {
    set align(center + horizon)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 2em,
      figure(fig-left, caption: caption-left),
      figure(fig-right, caption: caption-right)
    )
  })
}

#let acknowledgement-slide(
  title: "Acknowledgements",
  subtitle: none,
  people: (),
  institutions: (),
  extra: none,
  ..args
) = {
  slide(title: title, subtitle: subtitle, ..args, {
    set align(center + horizon)
    stack(
      dir: ttb,
      spacing: 1.5em,
      
      if people.len() > 0 {
        align(center, grid(
          columns: (auto, auto),
          column-gutter: 2em,
          row-gutter: 1em,
          ..people.map(p => (
            align(right, text(weight: "bold", p.name)),
            align(left, p.role)
          )).flatten()
        ))
      },
      
      if institutions.len() > 0 {
        v(0.5em)
        align(center, institutions.join([ #h(2em) ]))
      },

      if extra != none {
        v(1em)
        extra
      }
    )
  })
}

#let cite-box(bib-key, display-label: none, position: "bottom-right", form: "normal") = context {
  let conf = config-state.get()
  
  let align-pos = if position == "top-right" { top + right }
    else if position == "bottom-left" { bottom + left }
    else { bottom + right }
  
  let dx = if "right" in position { 1em } else { -1em }
  let dy = if "top" in position { -0.3em } else { 0.3em }

  let keys = if type(bib-key) == array { bib-key } else if bib-key != none { (bib-key,) } else { () }
  let labels = keys.map(k => if type(k) == str { label(k) } else { k })

  let content = if display-label != none {
    if labels.len() > 0 { 
      place(hide(labels.map(l => cite(l, form: form)).join())) 
    }
    display-label
  } else if labels.len() > 0 {
    labels.map(l => cite(l, form: form)).join(", ")
  } else {
    none
  }

  if content != none {
    let (fill-color, text-color) = if conf.dark-mode {
      (conf.primary-color.darken(60%), white)
    } else {
      (conf.primary-color.lighten(95%), conf.primary-color)
    }
    place(align-pos, dx: dx, dy: dy, block(
      fill: fill-color,
      stroke: 0.5pt + conf.primary-color,
      radius: 3pt,
      inset: 0.4em, 
      text(size: 0.65em, fill: text-color, content)
    ))
  }
}

#let equation-slide(
  equation,
  title: "Equation",
  subtitle: none,
  definitions: none,
  citation: none,
  ..args
) = {
  slide(title: title, subtitle: subtitle, ..args, {
    set align(center + horizon)
    
    stack(
      dir: ttb,
      spacing: 2em,
      
      stack(
        dir: ttb,
        spacing: 0.8em,
        block(
          text(size: 2.5em, weight: "bold", equation)
        ),
        if citation != none {
          let key = if type(citation) == dictionary { citation.at("bib-key", default: none) } else { citation }
          let lbl = if type(citation) == dictionary { citation.at("label", default: none) } else { none }
          let keys = if type(key) == array { key } else if key != none { (key,) } else { () }
          let labels = keys.map(k => if type(k) == str { label(k) } else { k })
          
          if labels.len() > 0 { place(hide(labels.map(l => cite(l)).join())) }
          
          let cite-content = if lbl != none { lbl } else { labels.map(l => cite(l)).join(", ") }
          
          context {
            let conf = config-state.get()
            let sig-color = if conf.dark-mode { white.darken(20%) } else { gray.darken(20%) }
            align(right, pad(right: 15%, text(fill: sig-color, size: 0.9em, [--- #cite-content])))
          }
        }
      ),
      
      if definitions != none {
        context {
          let conf = config-state.get()
          let fill-color = if conf.dark-mode { conf.primary-color.darken(60%) } else { conf.primary-color.lighten(95%) }
          let stroke-color = if conf.dark-mode { conf.primary-color.lighten(20%) } else { conf.primary-color }

          block(
            width: 85%,
            fill: fill-color,
            stroke: (left: 3pt + stroke-color),
            inset: 1.5em,
            radius: (right: 4pt),
            align(left, {
              set par(leading: 0.8em)
              definitions
            })
          )
        }
      }
    )
  })
}

#let base-title-slide(conf, body) = {
  let is-dark = conf.dark-mode
  let bg-fill = if is-dark { conf.at("title-bg-dark", default: conf.primary-color.darken(40%)) } else { conf.at("title-bg-light", default: conf.primary-color) }
  
  empty-slide(fill: bg-fill, count: false, {
    // Logo slot
    if conf.at("title-logo-func", default: none) != none {
      (conf.title-logo-func)(conf)
    }
    body
  })
}

#let base-ending-slide(conf, body) = {
  let is-dark = conf.dark-mode
  let bg-fill = if is-dark { conf.at("focus-bg-dark", default: conf.primary-color.darken(40%)) } else { conf.at("focus-bg-light", default: conf.primary-color) }
  
  empty-slide(fill: bg-fill, {
    // Logo slot
    if conf.at("transition-logo-func", default: none) != none {
      (conf.transition-logo-func)(conf)
    }
    body
  })
}

#let ending-slide(
  title: [Thanks for watching!],
  subtitle: [Questions?],
  contact: ("email@example.com", "github.com/username")
) = context {
  let conf = config-state.get()
  if conf.at("ending-slide-func", default: none) != none {
    return (conf.ending-slide-func)(title: title, subtitle: subtitle, contact: contact)
  }
  
  base-ending-slide(conf, {
    set text(fill: white)
    align(center + horizon, pad(x: 3em, stack(
      spacing: 1.5em,
      text(size: 2.5em, weight: "bold", title),
      if subtitle != none { text(size: 1.5em, style: "italic", fill: white.transparentize(20%), subtitle) },
      if contact != none and contact != () {
        v(1em)
        set text(size: 1em, weight: "regular")
        if type(contact) == array {
          contact.join([ #h(2em) ])
        } else {
          contact
        }
      }
    )))
  })
}

// --- Boîtes et Blocs ---

#let _base-box(title: none, body, color: black, fill-mode: "outline") = context {
  let conf = config-state.get()
  let is-dark = if conf != none { conf.dark-mode } else { false }

  let (fill-body, stroke-box) = if fill-mode == "fill" {
    (if is-dark { color.darken(60%) } else { color.lighten(90%) }, 0.5pt + (if is-dark { color.lighten(20%) } else { color }))
  } else if fill-mode == "full" {
    (if is-dark { color.darken(40%) } else { color.lighten(80%) }, 0.5pt + (if is-dark { color.lighten(20%) } else { color }))
  } else if fill-mode == "transparent" {
    (none, none)
  } else {
    // outline
    (none, 0.5pt + (if is-dark { color.lighten(20%) } else { color }))
  }
  
  block(
    width: 100%,
    radius: 4pt,
    clip: true,
    stroke: stroke-box,
    stack(
      spacing: 0pt,
      if title != none {
        block(
          width: 100%,
          fill: color,
          inset: 0.6em,
          text(fill: white, weight: "bold", title)
        )
      },
      block(
        width: 100%,
        fill: fill-body,
        inset: 0.8em,
        body
      )
    )
  )
}

#let highlight-box(title: "Key Point", fill-mode: "outline", body, color: blue) = {
  _base-box(title: title, body, color: color, fill-mode: fill-mode)
}

#let alert-box(title: "Warning", fill-mode: "outline", body, color: red) = {
  _base-box(title: title, body, color: color, fill-mode: fill-mode)
}

#let example-box(title: "Example", fill-mode: "outline", body, color: rgb("#2E7D32")) = {
  _base-box(title: title, body, color: color, fill-mode: fill-mode)
}

#let algorithm-box(title: "Algorithm", fill-mode: "outline", body, color: rgb("#455A64"), font: ("Fira Code", "DejaVu Sans Mono")) = {
  let algorithm-body = {
    set text(font: font, size: 0.9em)
    show enum: it => {
      grid(
        columns: (1.5em, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.5em,
        ..it.children.enumerate().map(((i, child)) => (
          align(right, text(fill: gray, str(i + 1) + ":")),
          child.body
        )).flatten()
      )
    }
    body
  }
  _base-box(title: title, algorithm-body, color: color, fill-mode: fill-mode)
}

#let themed-block(title: none, fill-mode: "outline", body) = context {
  let conf = config-state.get()
  let color = conf.primary-color
  _base-box(title: title, body, color: color, fill-mode: fill-mode)
}

#let appendix() = {
  [#metadata(none) <uni-pres-appendix-before-reset>]
  logical-slide-counter.update(0)
  appendix-state.update(true)
  counter(heading).update(0)
  [#metadata((is-special: true)) <uni-pres-appendix-marker>]
  context {
    let conf = config-state.get()
    focus-slide(upper(conf.annex-main-title))
  }
}

#let slide-break() = colbreak(weak: true)

// --- Moteur de Template ---

#let base-render-transition(h, is-annex, conf) = {
  let mapping = conf.mapping
  
  nav.render-transition(
    h,
    top-padding: 0pt,
    use-short-title: false,
    content-wrapper: (roadmap, h, active) => {
      let is-dark = conf.dark-mode
      let text-color = if is-dark { conf.at("dark-text", default: white) } else { conf.at("transition-text-color", default: white) }
      set text(fill: text-color, font: conf.text-font) 
      
      // Slot pour les logos (configuré par le thème)
      if conf.at("transition-logo-func", default: none) != none {
        (conf.transition-logo-func)(conf)
      }

      let roadmap-visible = {
        let active-color = if is-dark { white } else { conf.at("transition-active-color", default: white) }
        show text.where(fill: conf.marker-color): set text(fill: active-color)
        roadmap
      }

      let role = none
      for (r, lvl) in mapping { if lvl == h.level { role = r; break } }
      
      // --- CASE 1: PART TRANSITION (or Appendix Section if no parts) ---
      if role == "part" or (is-annex and role == "section" and not mapping.keys().contains("part")) {
         let num = if is-annex {
           numbering(conf.annex-numbering-format, counter(heading).at(h.location()).at(0))
         } else {
           numbering(conf.part-numbering-format, counter(heading).at(h.location()).at(0))
         }
         
         let muted-text = text-color.transparentize(40%)
         let title-text = if is-dark { white } else { conf.at("transition-title-color", default: white) }

         if conf.at("transition-part-layout", default: "centered") == "grid" {
           align(center + horizon, block(width: 90%, grid(
             columns: (auto, 1fr),
             column-gutter: 3em,
             align: horizon,
             stack(dir: ttb, spacing: 0.5em,
               if conf.show-header-numbering {
                 text(size: 1.2em, weight: "bold", fill: muted-text, smallcaps(if is-annex { conf.annex-title } else { "Partie" }))
                 text(size: 6em, weight: "bold", fill: muted-text, num)
               }
             ),
             block(
               inset: (left: 2em, y: 0.5em),
               stroke: (left: 2pt + muted-text),
               text(size: 2.8em, weight: "bold", fill: title-text, upper(h.body))
             )
           )))
         } else {
           align(center + horizon, stack(
            spacing: 1.5em,
            if conf.show-header-numbering {
              let num-prefix = if is-annex { conf.annex-title + " " } else { "" }
              text(size: if is-annex { 4em } else { 6em }, weight: "bold", fill: muted-text, num-prefix + num)
            },
            text(size: 3em, weight: "bold", fill: title-text, upper(h.body))
          ))
         }
      
      } else {
        // --- CASE 2: SECTION TRANSITION (with Roadmap) ---
        let part-lvl = mapping.at("part", default: none)
        let active-part = if part-lvl != none { active.at("h" + str(part-lvl), default: none) } else { none }
        
        let section-lvl = mapping.at("section", default: 1)
        let section-head = active.at("h" + str(section-lvl), default: h)
        let count = counter(heading).at(section-head.location())
        let start-idx = if mapping.keys().contains("part") { 1 } else { 0 }
        let nums = count.slice(start-idx)
        let fmt-num = if is-annex {
          numbering(conf.annex-numbering-format, ..nums)
        } else {
          numbering(conf.numbering-format, ..nums)
        }

        let muted-text = text-color.transparentize(40%)
        let title-text = if is-dark { white } else { conf.at("transition-title-color", default: white) }

        if conf.at("transition-section-layout", default: "stack") == "grid" {
          pad(x: 3em, stack(
            dir: ttb,
            v(22%),
            if active-part != none {
              block(inset: (bottom: 2em), text(size: 1.2em, weight: "bold", fill: muted-text, upper(active-part.body)))
            },
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              if conf.show-header-numbering {
                text(size: conf.at("transition-num-size", default: 6em), weight: "bold", fill: muted-text, fmt-num)
              },
              block(
                inset: (left: 2em, y: 0.5em),
                stroke: (left: 2pt + muted-text),
                stack(spacing: 1em,
                  text(size: conf.at("transition-title-size", default: 2.5em), weight: "bold", fill: title-text, upper(section-head.body)),
                  block(width: 80%, align(left, roadmap-visible))
                )
              )
            )
          ))
        } else {
          if active-part != none {
            place(top + right, pad(top: 2.5em, right: 3em, text(size: 0.8em, fill: muted-text, weight: "bold", upper(active-part.body))))
          }
          pad(x: 2em, stack(
            dir: ttb,
            v(15%),
            align(center, stack(
              spacing: 0.8em, 
              if conf.show-header-numbering {
                let prefix = if is-annex { conf.annex-title + " " } else { "" }
                if is-annex {
                  text(size: conf.at("transition-title-size-annex", default: 3.5em), weight: "bold", fill: title-text, prefix + fmt-num + " " + smallcaps(section-head.body))
                } else {
                  text(size: conf.at("transition-num-size", default: 6em), weight: "bold", fill: muted-text, fmt-num)
                }
              },
              if not is-annex { text(size: conf.at("transition-title-size", default: 2.2em), weight: "bold", fill: title-text, smallcaps(section-head.body)) },
              v(1.2em),
              block(width: 60%, align(left, roadmap-visible))
            ))
          ))
        }
      }
    }
  )
}

#let core-template(
  conf: (:),
  body
) = {
  config-state.update(c => conf)
  
  nav.navigator-config.update(c => {
    c.mapping = conf.mapping
    c.auto-title = conf.auto-title
    c.show-heading-numbering = conf.show-header-numbering
    c.slide-func = empty-slide.with(count: false)
    c.theme-colors = (primary: conf.transition-fill)
    c.use-short-title = conf.use-short-title
    c.transitions = (
      parts: (visibility: (part: "none", section: "none", subsection: "none")),
      sections: (visibility: (part: "none", section: "none", subsection: "current-parent")),
      subsections: (visibility: (part: "none", section: "none", subsection: "current-parent")),
      style: (active-weight: "bold", active-color: white, inactive-opacity: 0.6, completed-opacity: 0.6),
      marker: none,
    ) + conf.transitions
    c.progressive-outline = nav.merge-dicts(
      (
        level-1-mode: "none",
        level-2-mode: "none",
        level-3-mode: "none",
        text-styles: (
          level-1: (active: (weight: "bold", fill: conf.marker-color), completed: (weight: "bold"), inactive: (weight: "bold")),
          level-2: (active: (weight: "regular", fill: conf.marker-color), completed: (weight: "regular"), inactive: (weight: "regular")),
          level-3: (active: (weight: "regular", fill: conf.marker-color), completed: (weight: "regular"), inactive: (weight: "regular"))
        ),
      ),
      base: c.at("progressive-outline", default: (:))
    )
    c
  })

  set page(
    paper: "presentation-" + conf.aspect-ratio, 
    margin: (top: conf.at("margin-top", default: 4.5em), bottom: 3.0em, x: 0pt), 
    header: none, 
    footer: none,
    fill: if conf.dark-mode { conf.at("dark-bg", default: rgb("#21232c")) } else { white },
    foreground: context {
      let c = config-state.get()
      if c == none { return none }
      
      let header-func = c.at("header-func", default: none)
      let footer-func = c.at("footer-func", default: base-footer)

      if header-func != none { place(top + left, header-func(c)) }
      if footer-func != none { place(bottom + left, footer-func(c)) }

      if c.progress-bar != "none" {
        let line = progress-bar-line()
        if c.progress-bar == "top" {
          place(top + left, line)
        } else if c.progress-bar == "bottom" {
          place(bottom + left, line)
        }
      }
    }
  )

  set text(font: conf.text-font, size: conf.text-size, fill: if conf.dark-mode { white } else { conf.text-color })
  
  if conf.at("math-font", default: none) != none {
    show math.equation: set text(font: conf.math-font)
  }

  show raw.where(block: true): it => {
    let bg-color = if conf.dark-mode { rgb("#2d2d2d") } else { luma(245) }
    let stroke-color = if conf.dark-mode { gray.darken(40%) } else { gray.lighten(50%) }
    let text-color = if conf.dark-mode { white } else { conf.text-color }

    block(
      width: 100%,
      fill: bg-color,
      inset: 10pt,
      radius: 4pt,
      stroke: 0.5pt + stroke-color,
      {
        set text(fill: text-color)
        show block: set block(fill: none, inset: 0pt, radius: 0pt, stroke: none)
        it
      }
    )
  }

  set list(marker: ([•], [‣], [–]).map(m => text(fill: conf.marker-color, m)))
  set enum(numbering: (n) => text(fill: conf.marker-color, weight: "bold", str(n) + "."))
  
  set bibliography(style: conf.bib-style)

  show cite: it => context {
    let c = config-state.get()
    let (fill-color, text-color) = if c.dark-mode {
      (c.primary-color.darken(50%), white)
    } else {
      (c.primary-color.lighten(90%), c.primary-color)
    }
    box(
      inset: (x: 2pt),
      outset: (y: 2pt),
      radius: 2pt,
      fill: fill-color,
      text(fill: text-color, it)
    )
  }
        
  set heading(numbering: (..nums) => context {
    if not conf.show-header-numbering { return none }
    let n = nums.pos()
    
    let is-annex = appendix-state.get()

    if is-annex {
      let formats = (conf.annex-numbering-format, "A", "1")
      let parts = ()
      for i in range(n.len()) {
        parts.push(numbering(formats.at(i, default: "1"), n.at(i)))
      }
      return conf.annex-title + " " + parts.join("")
    }

    let role = none
    for (r, lvl) in conf.mapping { if lvl == n.len() { role = r; break } }
    
    if role == "part" { 
      numbering(conf.part-numbering-format, ..n) 
    } else if role == "section" or role == "subsection" {
      let start-idx = if conf.mapping.keys().contains("part") { 1 } else { 0 }
      if n.len() > start-idx { 
        numbering(conf.numbering-format, ..n.slice(start-idx)) 
      }
    } else {
      none
    }
  })

  // Page de Titre
  let title-slide-func = conf.at("title-slide-func", default: none)
  if title-slide-func != none {
    title-slide-func(conf)
  }

  if conf.show-outline {
    slide(title: conf.outline-title, {
      if conf.outline-columns > 1 {
        columns(conf.outline-columns, outline(title: none, depth: conf.outline-depth, indent: 2em))
      } else {
        outline(title: none, depth: conf.outline-depth, indent: 2em)
      }
    })
  }

  show heading: h => context {
    if h.level > 3 { return h }
    
    let is-annex = appendix-state.get()

    let top-level = if conf.mapping.len() > 0 { calc.min(..conf.mapping.values()) } else { 1 }
    if is-annex and h.level > top-level {
      return place(hide(h))
    }

    if conf.at("render-transition-func", default: none) != none {
      return (conf.render-transition-func)(h, is-annex)
    }

    base-render-transition(h, is-annex, conf)
  }
  
  body
}
