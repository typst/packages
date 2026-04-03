#import "../core.typ": *

#let sorbonne-red = rgb("#AC182E")
#let sorbonne-blue = rgb("#1D2769")
#let sorbonne-lightblue = rgb("#52B5E5")
#let sorbonne-yellow = rgb("#FFB700")
#let sorbonne-text = rgb("#263068")

#let sorbonne-header(conf) = context {
  let markers = query(<uni-pres-slide-start>)
  if markers.len() == 0 { return none }
  let current-page = here().page()
  let marker = markers.filter(m => m.location().page() <= current-page).last()
  let meta = marker.value

  let allow-breaks = if type(meta) == dictionary { meta.at("allow-slide-breaks", default: false) } else { false }
  let is-continuation = current-page > marker.location().page() and allow-breaks
  
  let fg-color = if conf.dark-mode { white } else { conf.text-color }
  let subtitle-color = if conf.dark-mode { white.transparentize(20%) } else { conf.text-color.lighten(20%) }
  let continuation-color = if conf.dark-mode { white.transparentize(40%) } else { conf.text-color.lighten(40%) }

  let resolved-title = if type(meta) == dictionary and meta.title != none { meta.title } else { nav.resolve-slide-title(none) }
  
  let title-display = if is-continuation and resolved-title != none {
    resolved-title + text(size: 0.8em, weight: "regular", fill: continuation-color, conf.slide-break-suffix)
  } else {
    resolved-title
  }

  let logo-content = set-logo(conf.logo-slide, width: 4.5em)
  
  let title-block = stack(dir: ttb, spacing: 0.3em,
    if resolved-title != none {
      text(size: 1.25em, weight: "bold", fill: fg-color, smallcaps(title-display))
    },
    if meta.subtitle != none {
      text(size: 0.95em, style: "italic", fill: subtitle-color, meta.subtitle)
    }
  )

  base-header(conf, logo-content: logo-content, title-block: title-block)
}

#let sorbonne-title-slide(conf) = {
  base-title-slide(conf, {
    set text(fill: white)
    align(horizon, pad(x: 3em, y: 2em, stack(
      spacing: 1.2em,
      text(size: 2.5em, weight: "bold", smallcaps(conf.title)),
      if conf.subtitle != none { text(size: 1.4em, style: "italic", conf.subtitle) },
      v(1.5em),
      text(size: 1.2em, weight: "bold", conf.author),
      text(size: 1em, conf.affiliation),
      text(size: 0.9em, fill: white.transparentize(20%), conf.date),
    )))
  })
}

#let sorbonne-ending-slide(
  title: [Thanks for watching!],
  subtitle: [Questions?],
  contact: ("email@example.com", "github.com/username")
) = context {
  let conf = config-state.get()
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

#let sorbonne-template(
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
  dark-mode: false,
  body
) = {
  // 1. Détermination des valeurs par défaut basées sur faculty
  let (def-primary, def-alert, def-logo-transition, def-logo-slide) = if faculty == "sciences" {
    (sorbonne-lightblue, sorbonne-lightblue.darken(40%), image("../../assets/sorbonne/sorbonne-sciences-white.png"), image("../../assets/sorbonne/sorbonne-sciences.png"))
  } else if faculty == "lettres" {
    (sorbonne-yellow, sorbonne-yellow.darken(45%), image("../../assets/sorbonne/sorbonne-lettres-white.png"), image("../../assets/sorbonne/sorbonne-lettres.png"))
  } else if faculty == "univ" or faculty == none {
    (sorbonne-blue, sorbonne-blue.darken(20%), image("../../assets/sorbonne/sorbonne-univ-white.png"), image("../../assets/sorbonne/sorbonne-univ.png"))
  } else {
    // Default is sante
    (sorbonne-red, sorbonne-red.darken(15%), image("../../assets/sorbonne/sorbonne-sante-white.png"), image("../../assets/sorbonne/sorbonne-sante.png"))
  }

  let final-primary = if primary-color != none { primary-color } else { def-primary }
  let final-logo-transition = if logo-transition != none { 
    if type(logo-transition) == str { image(logo-transition) } else { logo-transition }
  } else { def-logo-transition }

  let final-logo-slide = if logo-slide != none { 
    if type(logo-slide) == str { image(logo-slide) } else { logo-slide }
  } else { 
    if dark-mode { def-logo-transition } else { def-logo-slide }
  }
  
  let final-transition-fill = if dark-mode { final-primary.darken(40%) } else { final-primary }
  
  let final-marker-color = if dark-mode { 
    if faculty == "univ" { final-primary.lighten(60%) }
    else if faculty == "sante" { final-primary.lighten(50%) }
    else { final-primary.lighten(30%) }
  } else { final-primary }
  
  let final-alert = if alert-color != none { 
    alert-color 
  } else { 
    if dark-mode { final-marker-color } else { def-alert }
  }

  let resolved-max-length = if type(max-length) == dictionary {
    let new-dict = (:)
    for (key, val) in max-length {
      if key in mapping {
        new-dict.insert("level-" + str(mapping.at(key)), val)
      } else {
        new-dict.insert(key, val)
      }
    }
    new-dict
  } else {
    max-length
  }

  let conf = (
    title: title,
    author: author,
    short-title: if short-title != none { short-title } else { title },
    short-author: if short-author != none { short-author } else { author },
    affiliation: affiliation,
    subtitle: subtitle,
    date: date,
    aspect-ratio: aspect-ratio,
    text-font: text-font,
    text-size: text-size,
    text-color: sorbonne-text,
    math-font: "Fira Math",
    primary-color: final-primary,
    marker-color: final-marker-color,
    transition-fill: final-transition-fill,
    alert-color: final-alert,
    logo-transition: final-logo-transition,
    logo-slide: final-logo-slide,
    show-header-numbering: show-header-numbering,
    numbering-format: numbering-format,
    part-numbering-format: part-numbering-format,
    annex-title: annex-title,
    annex-main-title: annex-main-title,
    annex-numbering-format: annex-numbering-format,
    mapping: mapping,
    bib-style: bib-style,
    transitions: transitions,
    show-outline: show-outline,
    outline-title: outline-title,
    outline-depth: outline-depth,
    outline-columns: outline-columns,
    auto-title: auto-title,
    progress-bar: progress-bar,
    slide-break-suffix: slide-break-suffix,
    footer-author: footer-author,
    footer-title: footer-title,
    max-length: resolved-max-length,
    use-short-title: use-short-title,
    dark-mode: dark-mode,
    header-func: sorbonne-header,
    // Title and Ending slides
    title-slide-func: sorbonne-title-slide,
    ending-slide-func: sorbonne-ending-slide,
    title-bg-light: final-primary,
    title-bg-dark: final-primary.darken(40%),
    title-logo-func: (c) => place(bottom + right, pad(bottom: 2em, right: 2em, set-logo(c.logo-transition, width: 6em))),
    // Transitions defaults for Example
    transition-text-color: white,
    transition-active-color: white,
    transition-title-color: white,
    transition-part-layout: "centered",
    transition-section-layout: "stack",
    transition-logo-func: (c) => place(top + left, pad(top: 2em, left: 2em, set-logo(c.logo-transition, width: 5em))),
    focus-layout: "centered",
    focus-bg-light: final-primary,
    focus-bg-dark: final-primary.darken(40%),
    focus-text-color: white,
  )

  core-template(conf: conf, body)
}
