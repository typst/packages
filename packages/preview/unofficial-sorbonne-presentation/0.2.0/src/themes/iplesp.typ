#import "../core.typ": *

#let iplesp-red = rgb("#EA4328")
#let iplesp-blue = rgb("#262C66")
#let iplesp-lightblue = rgb("#B0B0C5")
#let iplesp-yellow = rgb("#F7B618")
#let iplesp-green = rgb("#2E7D32")
#let iplesp-teal = rgb("#00796B")
#let iplesp-purple = rgb("#6A1B9A")
#let iplesp-orange = rgb("#EF6C00")
#let iplesp-slate = rgb("#455A64")
#let iplesp-text = rgb("#262C66")

#let iplesp-darkbg = rgb("#1d1d1d")
#let iplesp-darktext = rgb("#eeeeee")

#let iplesp-logos-bar(conf) = {
  if conf.logo-slide != none {
    align(center + horizon, set-logo(conf.logo-slide, height: 2.5em))
  } else {
    let suffix = if conf.dark-mode { "-white" } else { "" }
    
    let get-logo(key, def-path) = {
      let trans-key = key + "-transition"
      if conf.dark-mode {
        if conf.at(trans-key, default: none) != none { conf.at(trans-key) }
        else if conf.at(key, default: none) != none { conf.at(key) }
        else { image("../../assets/iplesp/" + def-path + "-white.png", height: 2.2em) }
      } else {
        if conf.at(key, default: none) != none { conf.at(key) }
        else { image("../../assets/iplesp/" + def-path + ".png", height: 2.2em) }
      }
    }

    grid(
      columns: (1fr, 1fr, 1fr),
      align: horizon,
      align(left, set-logo(get-logo("logo-left", "inserm"), height: 2.2em)),
      align(center, set-logo(get-logo("logo-center", "iplesp"), height: 2.2em)),
      align(right, set-logo(get-logo("logo-right", "iplesp-sante"), height: 2.2em))
    )
  }
}

#let iplesp-header(conf) = context {
  let markers = query(<uni-pres-slide-start>)
  if markers.len() == 0 { return none }
  
  let current-page = here().page()
  let marker = markers.filter(m => m.location().page() <= current-page).last()
  let h = marker.value
  
  let allow-breaks = if type(h) == dictionary { h.at("allow-slide-breaks", default: false) } else { false }
  let is-continuation = current-page > marker.location().page() and allow-breaks
  let resolved-title = if type(h) == dictionary and h.title != none { h.title } else { nav.resolve-slide-title(none) }
  
  let text-color = if conf.dark-mode { iplesp-darktext } else { iplesp-text }
  let title-display = if is-continuation and resolved-title != none {
    resolved-title + text(size: 0.8em, weight: "regular", fill: text-color.lighten(40%), conf.slide-break-suffix)
  } else {
    resolved-title
  }

  let title-block = if resolved-title != none or h.subtitle != none {
    // v(-0.5em)
    stack(dir: ttb, spacing: 0.4em,
      if resolved-title != none {
        text(size: 1.25em, weight: "bold", fill: text-color, smallcaps(title-display))
      },
      if h.subtitle != none {
        text(size: 0.95em, style: "italic", fill: text-color.lighten(20%), h.subtitle)
      }
    )
  }

  base-header(conf, logo-content: iplesp-logos-bar(conf), title-block: title-block)
}

#let iplesp-title-slide(conf) = {
  base-title-slide(conf, {
    let title-text-color = if conf.dark-mode { iplesp-darktext } else { iplesp-text }
    align(horizon, pad(x: 3em, stack(
      spacing: 1.5em,
      line(length: 15%, stroke: 5pt + (if conf.dark-mode { iplesp-darktext } else { conf.primary-color })),
      text(size: 2.8em, weight: "bold", fill: if conf.dark-mode { iplesp-darktext } else { conf.primary-color }, smallcaps(conf.title)),
      if conf.subtitle != none { text(size: 1.4em, style: "italic", fill: title-text-color.transparentize(20%), conf.subtitle) },
      v(1.5em),
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        stack(spacing: 0.6em,
          text(size: 1.2em, weight: "bold", conf.author, fill: title-text-color),
          text(size: 1em, fill: title-text-color.transparentize(20%), conf.affiliation),
        ),
        align(bottom + right, text(size: 0.9em, fill: title-text-color.transparentize(20%), conf.date))
      )
    )))
  })
}

#let iplesp-ending-slide(
  title: [Thank you for your attention!],
  subtitle: [Questions?],
  contact: ("email@example.com", "github.com/username")
) = context {
  let conf = config-state.get()
  base-ending-slide(conf, {
    let text-color = if conf.dark-mode { iplesp-darktext } else { iplesp-text }
    let sub-color = text-color.transparentize(20%)
    set text(fill: text-color)

    align(center + horizon, stack(
      spacing: 1.5em,
      text(size: 3em, weight: "bold", fill: if conf.dark-mode { iplesp-darktext } else { conf.primary-color }, title),
      if subtitle != none { text(size: 1.8em, style: "italic", fill: sub-color, subtitle) },
      if contact != none and contact != () {
        v(2em)
        set text(size: 1.1em, weight: "regular")
        if type(contact) == array {
          contact.join([ #h(2em) ])
        } else {
          contact
        }
      }
    ))
    place(bottom + center, pad(bottom: 2em, line(length: 40%, stroke: 2pt + (if conf.dark-mode { iplesp-darktext } else { conf.primary-color }))))
  })
}

#let iplesp-template(
  title: none,
  author: none,
  short-title: none,
  short-author: none,
  affiliation: none,
  subtitle: none,
  date: datetime.today().display(),
  aspect-ratio: "16-9",
  text-font: "Lato",
  text-size: 20pt,
  theme: "blue",
  primary-color: none,
  alert-color: none,
  logo-slide: none,
  logo-transition: none,
  logo-left: none,
  logo-center: none,
  logo-right: none,
  logo-left-transition: none,
  logo-center-transition: none,
  logo-right-transition: none,
  show-header-numbering: true,
  numbering-format: "1.1",
  part-title: [Partie],
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
  let (def-primary, def-alert) = if theme == "red" {
    (iplesp-red, iplesp-blue)
  } else if theme == "yellow" {
    (iplesp-yellow, iplesp-blue)
  } else if theme == "green" {
    (iplesp-green, iplesp-blue)
  } else if theme == "teal" {
    (iplesp-teal, iplesp-blue)
  } else if theme == "purple" {
    (iplesp-purple, iplesp-blue)
  } else if theme == "orange" {
    (iplesp-orange, iplesp-blue)
  } else if theme == "slate" {
    (iplesp-slate, iplesp-blue)
  } else {
    (iplesp-blue, iplesp-red)
  }

  let final-primary = if primary-color != none { primary-color } else { def-primary }
  let final-alert = if alert-color != none { alert-color } else { def-alert }

  let final-logo-transition = if logo-transition != none {
    if type(logo-transition) == str { image(logo-transition) } else { logo-transition }
  } else {
    image("../../assets/iplesp/iplesp-white.png")
  }

  let final-logo-slide = if logo-slide != none {
    if type(logo-slide) == str { image(logo-slide) } else { logo-slide }
  } else {
    none
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
    text-color: iplesp-text,
    primary-color: final-primary,
    marker-color: if dark-mode { white } else { final-primary },
    transition-fill: if dark-mode { final-primary.darken(60%) } else { final-primary.lighten(80%) },
    alert-color: final-alert,
    logo-transition: final-logo-transition,
    logo-slide: final-logo-slide,
    logo-left: if type(logo-left) == str { image(logo-left) } else { logo-left },
    logo-center: if type(logo-center) == str { image(logo-center) } else { logo-center },
    logo-right: if type(logo-right) == str { image(logo-right) } else { logo-right },
    logo-left-transition: if type(logo-left-transition) == str { image(logo-left-transition) } else { logo-left-transition },
    logo-center-transition: if type(logo-center-transition) == str { image(logo-center-transition) } else { logo-center-transition },
    logo-right-transition: if type(logo-right-transition) == str { image(logo-right-transition) } else { logo-right-transition },
    show-header-numbering: show-header-numbering,
    numbering-format: numbering-format,
    part-numbering-format: part-numbering-format,
    annex-title: annex-title,
    annex-main-title: annex-main-title,
    annex-numbering-format: annex-numbering-format,
    mapping: mapping,
    bib-style: bib-style,
    transitions: (
      style: (active-color: if dark-mode { iplesp-darktext } else { final-primary }, inactive-opacity: 0.4, completed-opacity: 0.4)
    ) + transitions,
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
    // Customization for Laboratory
    margin-top: 5.5em,
    header-inset-top: 0.2em,
    header-layout: "stack",
    header-func: iplesp-header,
    title-slide-func: iplesp-title-slide,
    title-bg-light: final-primary.lighten(80%),
    title-bg-dark: final-primary.darken(60%),
    title-logo-func: (c) => place(top + left, block(width: 100%, inset: (x: 2em, top: 0.2em), iplesp-logos-bar(c))),
    focus-slide-func: none, // uses base-focus-slide with conf params
    focus-layout: "boxed",
    focus-bg-light: final-primary.lighten(80%),
    focus-bg-dark: final-primary.darken(60%),
    focus-text-color: iplesp-text,
    ending-slide-func: iplesp-ending-slide,
    transition-logo-func: (c) => place(top + right, block(width: 100%, inset: (x: 2em, top: 0.2em), iplesp-logos-bar(c))),
    transition-text-color: final-primary,
    transition-active-color: final-primary,
    transition-title-color: final-primary,
    transition-title-size: 2.2em,
    transition-num-size: 5em,
    transition-part-layout: "grid",
    transition-section-layout: "grid",
    dark-bg: iplesp-darkbg,
    dark-text-secondary: iplesp-darktext.darken(40%),
    dark-sep-color: iplesp-darktext.darken(70%),
    dark-line-color: iplesp-darktext.darken(70%),
  )

  core-template(conf: conf, body)
}
