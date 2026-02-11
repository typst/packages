#import "@preview/presentate:0.2.4" as p
#import p.store: states
// On importe la version locale modifiée de navigator
#import "@preview/navigator:0.1.3" as nav

// --- Configuration et Couleurs ---
#let sorbonne-red = rgb("#AC182E")
#let sorbonne-blue = rgb("#1D2769")
#let sorbonne-lightblue = rgb("#52B5E5")
#let sorbonne-yellow = rgb("#FFB700")
#let sorbonne-text = rgb("#263068")

// État pour la configuration du thème
#let config-state = state("sorbonne-config", none)
#let last-main-page = state("last-main-page", none)
#let logical-slide-counter = counter("sorbonne-logical-slide")

// --- Composants ---

#let progress-bar-line() = context {
  let conf = config-state.get()
  if conf == none or conf.progress-bar == "none" { return none }
  
  let current = logical-slide-counter.get().at(0)
  let appendix-marker = query(<sorbonne-appendix-marker>)
  let total = if appendix-marker.len() > 0 {
    logical-slide-counter.at(appendix-marker.first().location()).at(0) - 1
  } else {
    logical-slide-counter.final().at(0)
  }
  
  if total == 0 { return none }
  
  let is-annex = if appendix-marker.len() > 0 {
    appendix-marker.first().location().page() <= here().page()
  } else { false }

  let ratio = if is-annex { 1.0 } else { calc.min(1.0, current / total) }
  
  block(width: 100% * ratio, height: 2pt, fill: conf.primary-color)
}

#let empty-slide(fill: none, body) = {
  set page(margin: 0pt, fill: fill, header: none, footer: none, foreground: none)
  [
    #logical-slide-counter.step()
    #p.slide(logical-slide: true, {
      [#metadata((title: none, subtitle: none, allow-slide-breaks: false)) <sorbonne-slide-start>]
      body
    })
  ]
}

#let breadcrumb() = context {
  let conf = config-state.get()
  if conf == none { return none }
  set text(size: 0.8em, fill: gray.darken(20%))
  
  let mapping = conf.mapping
  let level-modes = (:)
  for role in ("part", "section", "subsection") {
    let lvl = mapping.at(role, default: none)
    if lvl != none { level-modes.insert("level-" + str(lvl) + "-mode", "current") }
  }

  nav.progressive-outline(
    ..level-modes,
    layout: "horizontal",
    separator: text(fill: gray.lighten(50%), "  /  "),
    clickable: false,
  )
}

#let sorbonne-header() = context {
  let conf = config-state.get()
  if conf == none { return none }
  
  let markers = query(<sorbonne-slide-start>)
  if markers.len() == 0 { return none }
  
  // On cherche le marqueur qui s'applique à cette page.
  // C'est soit un marqueur sur cette page, soit le dernier marqueur avant.
  let current-page = here().page()
  let marker = markers.filter(m => m.location().page() <= current-page).last()
  let h = marker.value
  
  // On n'affiche (suite) que si allow-slide-breaks est activé ET qu'on est sur une page physique suivante
  let allow-breaks = if type(h) == dictionary { h.at("allow-slide-breaks", default: false) } else { false }
  let is-continuation = current-page > marker.location().page() and allow-breaks
  
  let resolved-title = if type(h) == dictionary and h.title != none { h.title } else { nav.resolve-slide-title(none) }
  if resolved-title == none and h.subtitle == none { return none }

  let title-display = if is-continuation and resolved-title != none {
    resolved-title + text(size: 0.8em, weight: "regular", fill: sorbonne-text.lighten(40%), conf.slide-break-suffix)
  } else {
    resolved-title
  }

  block(width: 100%, inset: (x: 2em, top: 0.8em, bottom: 0.2em), {
    grid(
      columns: (4.5em, 1fr),
      column-gutter: 1.5em,
      align: horizon,
      image(conf.logo-slide, width: 4.5em),
      stack(dir: ttb, spacing: 0.3em,
        if resolved-title != none {
          text(size: 1.1em, weight: "bold", fill: sorbonne-text, smallcaps(title-display))
        },
        if h.subtitle != none {
          text(size: 0.85em, style: "italic", fill: sorbonne-text.lighten(20%), h.subtitle)
        }
      )
    )
  })
}

#let sorbonne-footer() = context {
  let conf = config-state.get()
  if conf == none { return none }
  
  block(width: 100%, inset: (x: 2.5em, bottom: 0.8em, top: 0.2em), {
    set text(size: 0.65em, fill: gray.darken(20%))
    line(length: 100%, stroke: 0.5pt + gray.lighten(80%))
    v(0.5em)

    let show-author = conf.footer-author
    let show-title = conf.footer-title
    
    if not show-author and not show-title {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        breadcrumb(),
        context {
          let current = logical-slide-counter.get().at(0)
          let appendix-marker = query(<sorbonne-appendix-marker>)
          let total = if appendix-marker.len() > 0 {
            logical-slide-counter.at(appendix-marker.first().location()).at(0) - 1
          } else {
            logical-slide-counter.final().at(0)
          }
          [#current / #total]
        }
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
        context {
          let current = logical-slide-counter.get().at(0)
          let appendix-marker = query(<sorbonne-appendix-marker>)
          let total = if appendix-marker.len() > 0 {
            logical-slide-counter.at(appendix-marker.first().location()).at(0) - 1
          } else {
            logical-slide-counter.final().at(0)
          }
          [#current / #total]
        }
      )
    }
  })
}

#let apply-layout(breakable: true, body) = context {
  let config = config-state.get()
  set text(font: config.text-font, size: config.text-size, fill: sorbonne-text)
  
  if not breakable {
    // Le grid 1fr occupe tout l'espace disponible, permettant le centrage vertical (horizon)
    // tout en s'ajustant si des notes de bas de page sont présentes.
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

#let focus-slide(body, subtitle: none) = context {
  let conf = config-state.get()
  empty-slide(fill: conf.primary-color, {
    place(top + left, pad(top: 2em, left: 2em, image(conf.logo-transition, width: 5em)))
    set text(fill: white, weight: "bold")
    align(center + horizon, stack(dir: ttb, spacing: 1em,
      text(size: 2.5em, body),
      if subtitle != none {
        text(size: 1.5em, weight: "regular", style: "italic", fill: white.transparentize(20%), subtitle)
      }
    ))
  })
}

#let alert(body) = context {
  let conf = config-state.get()
  text(fill: conf.alert-color, weight: "bold", body)
}

#let muted(body) = text(fill: gray, body)

#let subtle(body) = text(fill: gray.lighten(40%), body)

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
  let body = if pos.len() > 0 { pos.at(0) } else { none }
  
  let clean-named = named
  for key in ("title", "subtitle", "allow-slide-breaks", "background") {
    if key in clean-named { 
      let _ = clean-named.remove(key)
    }
  }
  
  [
    #logical-slide-counter.step()
    #p.slide(..clean-named, {
      if background != none {
        place(top + left, dx: 0pt, dy: -4.5em, block(width: 100%, height: 100% + 4.5em + 3.0em, background))
      }
      [#metadata((title: manual-title, subtitle: subtitle, allow-slide-breaks: allow-slide-breaks)) <sorbonne-slide-start>]
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
    // On "cite" de manière invisible pour forcer l'inclusion en bibliographie
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
    place(align-pos, dx: dx, dy: dy, block(
      fill: conf.primary-color.lighten(95%),
      stroke: 0.5pt + conf.primary-color,
      radius: 3pt,
      inset: 0.4em, 
      text(size: 0.65em, fill: conf.primary-color, content)
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
      
      // Bloc Equation + Signature
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
          
          // Style "Signature" : à droite, en gris, avec tiret
          align(right, pad(right: 15%, text(fill: gray.darken(20%), size: 0.9em, [--- #cite-content])))
        }
      ),
      
      // Boîte de définitions
      if definitions != none {
        context {
          let conf = config-state.get()
          block(
            width: 85%,
            fill: conf.primary-color.lighten(95%),
            stroke: (left: 3pt + conf.primary-color), // Bordure gauche élégante
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

#let ending-slide(
  title: [Thanks for watching!],
  subtitle: [Questions?],
  contact: ("email@example.com", "github.com/username")
) = context {
  let conf = config-state.get()
  empty-slide(fill: conf.primary-color, {
    place(top + left, pad(top: 2em, left: 2em, image(conf.logo-transition, width: 5em)))
    set text(fill: white)
    align(center + horizon, stack(
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
    ))
  })
}

// --- Boîtes et Blocs ---

#let _base-box(title: none, body, color: black, fill-mode: "outline") = {
  let (fill-body, stroke-box) = if fill-mode == "fill" {
    (color.lighten(90%), 0.5pt + color)
  } else if fill-mode == "full" {
    (color.lighten(80%), 0.5pt + color)
  } else if fill-mode == "transparent" {
    (none, none)
  } else {
    // outline
    (none, 0.5pt + color)
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

#let highlight-box(title: "Key Point", fill-mode: "outline", body) = {
  _base-box(title: title, body, color: sorbonne-blue, fill-mode: fill-mode)
}

#let alert-box(title: "Warning", fill-mode: "outline", body) = {
  _base-box(title: title, body, color: sorbonne-red, fill-mode: fill-mode)
}

#let example-box(title: "Example", fill-mode: "outline", body) = {
  _base-box(title: title, body, color: rgb("#2E7D32"), fill-mode: fill-mode)
}

#let algorithm-box(title: "Algorithm", fill-mode: "outline", body) = {
  let algorithm-body = {
    set text(font: ("Fira Code", "DejaVu Sans Mono"), size: 0.9em)
    // On formate les listes numérotées comme des lignes de code
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
  _base-box(title: title, algorithm-body, color: rgb("#455A64"), fill-mode: fill-mode)
}

#let themed-block(title: none, fill-mode: "outline", body) = context {
  let conf = config-state.get()
  let color = conf.primary-color
  _base-box(title: title, body, color: color, fill-mode: fill-mode)
}

#let appendix() = {
  counter(heading).update(0)
  [#metadata(none) <sorbonne-appendix-marker>]
  context {
    let conf = config-state.get()
    focus-slide(upper(conf.annex-main-title))
  }
}

#let slide-break() = colbreak(weak: true)

// --- Template ---

#let template(
  title: none,
  author: none,
  short-title: none,
  short-author: none,
  affiliation: none,
  subtitle: none,
  date: datetime.today().display(),
  aspect-ratio: "16-9",
  text-font: "Fira Sans",
  text-size: 20pt,
  faculty: "sante",
  // Surcharges optionnelles
  primary-color: none,
  alert-color: none,
  logo-slide: none,
  logo-transition: none,
  show-header-numbering: true,
  numbering-format: "1.1",
  part-numbering-format: "I",
  annex-title: [Annexe],
  annex-main-title: [Annexes],
  annex-numbering-format: "I",
  mapping: (section: 1, subsection: 2),
  bib-style: "apa",
  transitions: (:),
  show-outline: false,
  outline-title: [Sommaire],
  outline-depth: 2,
  outline-columns: 1,
  auto-title: true,
  progress-bar: "none", // "none", "top", "bottom"
  slide-break-suffix: [ (cont.)],
  footer-author: true,
  footer-title: true,
  max-length: none,
  use-short-title: false,
  body
) = {
  // 1. Détermination des valeurs par défaut basées sur faculty
  let (def-primary, def-alert, def-logo-transition, def-logo-slide) = if faculty == "sciences" {
    (sorbonne-lightblue, sorbonne-lightblue.darken(40%), "assets/logo/sorbonne-sciences-white.png", "assets/logo/sorbonne-sciences.png")
  } else if faculty == "lettres" {
    (sorbonne-yellow, sorbonne-yellow.darken(45%), "assets/logo/sorbonne-lettres-white.png", "assets/logo/sorbonne-lettres.png")
  } else if faculty == "univ" or faculty == none {
    (sorbonne-blue, sorbonne-blue.darken(20%), "assets/logo/sorbonne-univ-white.png", "assets/logo/sorbonne-univ.png")
  } else {
    // Default is sante
    (sorbonne-red, sorbonne-red.darken(15%), "assets/logo/sorbonne-sante-white.png", "assets/logo/sorbonne-sante.png")
  }

  // 2. Application des surcharges si fournies
  let final-primary = if primary-color != none { primary-color } else { def-primary }
  let final-alert = if alert-color != none { alert-color } else { def-alert }
  let final-logo-transition = if logo-transition != none { logo-transition } else { def-logo-transition }
  let final-logo-slide = if logo-slide != none { logo-slide } else { def-logo-slide }

  config-state.update(c => (
    title: title,
    author: author,
    short-title: if short-title != none { short-title } else { title },
    short-author: if short-author != none { short-author } else { author },
    affiliation: affiliation,
    show-header-numbering: show-header-numbering,
    numbering-format: numbering-format,
    part-numbering-format: part-numbering-format,
    annex-title: annex-title,
    annex-main-title: annex-main-title,
    annex-numbering-format: annex-numbering-format,
    mapping: mapping,
    primary-color: final-primary,
    alert-color: final-alert,
    logo-transition: final-logo-transition,
    logo-slide: final-logo-slide,
    text-font: text-font,
    text-size: text-size,
    progress-bar: progress-bar,
    slide-break-suffix: slide-break-suffix,
    footer-author: footer-author,
    footer-title: footer-title,
    max-length: max-length,
    use-short-title: use-short-title,
  ))
  
  nav.navigator-config.update(c => {
    c.mapping = mapping
    c.auto-title = auto-title
    c.show-heading-numbering = show-header-numbering
    c.slide-func = empty-slide
    c.theme-colors = (primary: final-primary)
    c.max-length = max-length
    c.use-short-title = use-short-title
    c.transitions = (
      parts: (visibility: (part: "none", section: "none", subsection: "none")),
      sections: (visibility: (part: "none", section: "none", subsection: "current-parent")),
      subsections: (visibility: (part: "none", section: "none", subsection: "current-parent")),
      style: (active-weight: "bold", active-color: white, inactive-opacity: 0.6, completed-opacity: 0.6),
      marker: none,
    ) + transitions
    c.progressive-outline = nav.merge-dicts(
      (
        level-1-mode: "none",
        level-2-mode: "none",
        level-3-mode: "none",
        text-styles: (
          level-1: (active: (weight: "bold", fill: final-primary), completed: (weight: "bold"), inactive: (weight: "bold")),
          level-2: (active: (weight: "regular", fill: final-primary), completed: (weight: "regular"), inactive: (weight: "regular")),
          level-3: (active: (weight: "regular", fill: final-primary), completed: (weight: "regular"), inactive: (weight: "regular"))
        ),
      ),
      base: c.at("progressive-outline", default: (:))
    )
    c
  })

  set page(
    paper: "presentation-" + aspect-ratio, 
    margin: (top: 4.5em, bottom: 3.0em, x: 0pt), 
    header: none, 
    footer: none,
    foreground: context {
      let conf = config-state.get()
      if conf == none { return none }
      
      // Header & Footer
      place(top + left, sorbonne-header())
      place(bottom + left, sorbonne-footer())

      // Progress bar
      if conf.progress-bar != "none" {
        let line = progress-bar-line()
        if conf.progress-bar == "top" {
          place(top + left, line)
        } else if conf.progress-bar == "bottom" {
          place(bottom + left, line)
        }
      }
    }
  )
  set text(font: text-font, size: text-size, fill: sorbonne-text)
  show math.equation: set text(font: "Fira Math")

  // Listes à puces et énumérations thématiques
  set list(marker: ([•], [‣], [–]).map(m => text(fill: final-primary, m)))
  set enum(numbering: (n) => text(fill: final-primary, weight: "bold", str(n) + "."))
  
  // Définit le style de bibliographie
  set bibliography(style: bib-style)

    // Style des citations
    show cite: it => context {
      let conf = config-state.get()
      box(
        inset: (x: 2pt),
        outset: (y: 2pt),
        radius: 2pt,
        fill: conf.primary-color.lighten(90%),
              text(fill: conf.primary-color, it)
            )
          }
        
          set heading(numbering: (..nums) => context {
        
    if not show-header-numbering { return none }
    let n = nums.pos()
    
    // Check if we are in appendix
    let appendix-marker = query(<sorbonne-appendix-marker>)
    let is-annex = if appendix-marker.len() > 0 {
      appendix-marker.first().location().page() < here().page() or (appendix-marker.first().location().page() == here().page() and appendix-marker.first().location().position().y < here().position().y)
    } else { false }

    if is-annex {
      let formats = (annex-numbering-format, "A", "1")
      let parts = ()
      for i in range(n.len()) {
        parts.push(numbering(formats.at(i, default: "1"), n.at(i)))
      }
      return annex-title + " " + parts.join("")
    }

    let role = none
    for (r, lvl) in mapping { if lvl == n.len() { role = r; break } }
    
    if role == "part" { 
      numbering(part-numbering-format, ..n) 
    } else if role == "section" or role == "subsection" {
      let start-idx = if mapping.keys().contains("part") { 1 } else { 0 }
      if n.len() > start-idx { 
        numbering(numbering-format, ..n.slice(start-idx)) 
      }
    } else {
      none
    }
  })

  // Page de Titre
  empty-slide(fill: final-primary, {
    set text(fill: white)
    place(bottom + right, pad(bottom: 2em, right: 2em, image(final-logo-transition, width: 6em)))
    align(horizon, pad(x: 3em, y: 2em, stack(
      spacing: 1.2em,
      text(size: 2.5em, weight: "bold", smallcaps(title)),
      if subtitle != none { text(size: 1.4em, style: "italic", subtitle) },
      v(1.5em),
      text(size: 1.2em, weight: "bold", author),
      text(size: 1em, affiliation),
      text(size: 0.9em, fill: white.transparentize(20%), date),
    )))
  })

  // Sommaire automatique
  if show-outline {
    slide(title: outline-title, {
      if outline-columns > 1 {
        columns(outline-columns, outline(title: none, depth: outline-depth, indent: 2em))
      } else {
        outline(title: none, depth: outline-depth, indent: 2em)
      }
    })
  }

  show heading: h => context {
    if h.level > 3 { return h }
    
    let conf = config-state.get()
    
    // Check if we are in appendix for this heading
    let appendix-marker = query(<sorbonne-appendix-marker>)
    let is-annex = if appendix-marker.len() > 0 {
      appendix-marker.first().location().page() < h.location().page() or (appendix-marker.first().location().page() == h.location().page() and appendix-marker.first().location().position().y < h.location().position().y)
    } else { false }

    // En annexe, on ne fait des transitions que pour le niveau le plus haut mappé
    let top-level = calc.min(..mapping.values())
    if is-annex and h.level > top-level {
      return place(hide(h))
    }

    nav.render-transition(
      h,
      top-padding: 0pt,
      use-short-title: false,
      content-wrapper: (roadmap, h, active) => {
        set text(fill: white, font: "Fira Sans") 
        place(top + left, pad(top: 2em, left: 2em, image(conf.logo-transition, width: 5em)))
        
        let role = none
        for (r, lvl) in mapping { if lvl == h.level { role = r; break } }
        
        // --- CASE 1: PART TRANSITION (Centered Title, No Roadmap) ---
        if role == "part" or (is-annex and role == "section" and not mapping.keys().contains("part")) {
           align(center + horizon, stack(
            spacing: 1.5em,
            if conf.show-header-numbering {
              let num = if is-annex {
                conf.annex-title + " " + numbering(conf.annex-numbering-format, counter(heading).at(h.location()).at(0))
              } else {
                numbering(conf.part-numbering-format, counter(heading).at(h.location()).at(0))
              }
              text(size: if is-annex { 4em } else { 6em }, weight: "bold", num)
            },
            text(size: 3em, weight: "bold", upper(h.body))
          ))
        
        // --- CASE 2: SECTION TRANSITION (Split Layout with Roadmap) ---
        } else {
          // 2.1. Active Part display (Top Right)
          let part-lvl = mapping.at("part", default: none)
          let active-part = if part-lvl != none { active.at("h" + str(part-lvl), default: none) } else { none }
          if active-part != none {
            place(top + right, pad(top: 2.5em, right: 3em, text(size: 0.8em, fill: white.transparentize(30%), weight: "bold", upper(active-part.body))))
          }
          
          // 2.2. Main Content
          let section-lvl = mapping.at("section", default: 1)
          let section-head = active.at("h" + str(section-lvl), default: h)
          let count = counter(heading).at(section-head.location())
          let start-idx = if mapping.keys().contains("part") { 1 } else { 0 }
          let nums = count.slice(start-idx)
          
          pad(x: 2em, stack(
            dir: ttb,
            v(15%),
            align(center, stack(
              spacing: 0.8em, 
              if conf.show-header-numbering {
                let fmt-num = if is-annex {
                  conf.annex-title + " " + numbering(conf.annex-numbering-format, ..nums)
                } else {
                  numbering(conf.numbering-format, ..nums)
                }
                if is-annex {
                  text(size: 3.5em, weight: "bold", fmt-num + " " + smallcaps(section-head.body))
                } else {
                  text(size: 6em, weight: "bold", fmt-num)
                }
              },
              if not is-annex { text(size: 2.2em, weight: "bold", smallcaps(section-head.body)) },
              v(1.2em),
              block(width: 60%, align(left, roadmap))
            ))
          ))
        }
      }
    )
  }
  
  body
}
