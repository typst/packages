#import "slydekit-defaults.typ": *
#import "slydekit-slide.typ": slide-parser

#let formatted-number(at: none, force: false, level: none) = context {
  let resolve(item) = if at != none { item.at(at) } else { item.get() }
  let loc = if at != none { at } else { here() }

  if resolve(sk-states.numbering-hidden) {
    none
  } else if force or resolve(sk-states.section-numbering) {
    let fmt = if resolve(sk-states.appendix) {
      sk-states.numbering-pattern.get().appendix
    } else {
      sk-states.numbering-pattern.get().section
    }

    let counter-values = resolve(counter(heading))
    let depth = if level != none {
      calc.min(level, counter-values.len())
    } else {
      counter-values.len()
    }

    // A hidden ancestor — a shallower level whose currently active heading carries <hide-toc> — hides this number too, since this slide/section lives inside a section that was itself excluded from the outline.
    let hidden-ancestor = range(1, depth).any(l => {
      let last = query(heading.where(level: l).before(loc, inclusive: true))
      last.len() > 0 and last.last().has("label") and last.last().label == <hide-toc>
    })

    if hidden-ancestor or depth == 0 {
      none
    } else {
      numbering(fmt, ..counter-values.slice(0, depth))
    }
  }
}

#let slide-subtitle(fill-number: none) = context {
  let title = sk-states.current-slide-title.get()

  let fill-num = if fill-number != none {
    text(fill: fill-number)[#formatted-number()]
  } else {
    formatted-number()
  }


  [#fill-num #title]
}

// Appendix
//
// #show: appendix transforms the rest of the document into a single opaque argument passed to this function (verified: body.children, viewed from outside appendix(), contains only one child of type sequence at this point). The appendix's == headings are therefore never visible to the slide-parser applied at the document level. We run the splitter again here, on the appendix's own body, where it finds the appendix headings as a flat list.
#let appendix(body) = context {
  pagebreak(weak: true)
  sk-states.appendix.update(true)
  counter(heading).update(0)

  // body
  slide-parser(slide-level: sk-states.slide-level.get(), body)

}

// Hide new section slide
#let hide-new-section-slide(body) = context{
  show heading.where(level: sk-states.slide-level.get() - 1): none
  body
}

// Row images
#let row-img(logos) = {
  let n = logos.len()
  grid(
    columns: (1fr,)*n,
    column-gutter: 1fr,
    ..logos.enumerate().map(((i, item)) => {
      if n == 1 {
        align(right + horizon)[#item]
      } else if i == 0 {
        align(left + horizon)[#item]
      } else if i == n - 1 {
        align(right + horizon)[#item]
      } else {
        align(center + horizon)[#item]
      }
    })
  )
}

// Cell
#let cell = block.with(
  width: 100%,
  height: 100%,
  above: 0pt,
  below: 0pt,
  outset: 0pt,
  breakable: false,
)

// Full-width block helper (page bleed)
#let full-width(fill: none, anchor: top, body) = context {
  let margin = page.margin
  let margin-left = if type(margin) == dictionary {
    margin.at("left", default: margin.at("x", default: 0pt))
  } else {
    margin
  }
  let margin-right = if type(margin) == dictionary {
    margin.at("right", default: margin.at("x", default: 0pt))
  } else {
    margin
  }

  place(
    anchor,
    dx: -margin-left,
    box(
      width: 100% + margin-left + margin-right,
      height: 100%,
      fill: fill,
      body,
    ),
  )
}

// Section progress bar
#let progress-bar(ratio, active-color, inactive-color, row-height: (), gutter: ()) = {
  grid(
    columns: (ratio*100%, 1fr),
    rows: row-height,
    gutter: gutter,
    cell(fill: active-color),
    cell(fill: inactive-color)
  )
}

#let section-progress-bar(active-color, inactive-color, slide-level: 2) = context {
  let section-level = slide-level - 1
  let parent-level = slide-level - 2
  let not-appendix(h) = not sk-states.appendix.at(h.location())

  let pos = here()

  // 1. Trouver le parent courant (Chapter 1)
  let parent-before = if parent-level >= 1 {
    query(heading.where(level: parent-level).before(pos))
      .filter(not-appendix)
      .at(-1, default: none)
  } else {
    none
  }

  // 2. Trouver le parent suivant (Chapter 2) s'il existe
  let parent-after = if parent-before != none {
    query(heading.where(level: parent-level))
      .filter(not-appendix)
      .filter(h => h.location().page() > parent-before.location().page())
      .at(0, default: none)
  } else {
    none
  }

  // 3. Isoler les sections entre le chapitre courant et le suivant.
  let scope-start-page = if parent-before != none {
    parent-before.location().page()
  } else {
    0
  }
  let scope-end-page = if parent-after != none {
    parent-after.location().page()
  } else {
    calc.inf
  }
  let scope-sections = query(heading.where(level: section-level))
    .filter(not-appendix)
    .filter(s => (
      s.location().page() >= scope-start-page
      and s.location().page() < scope-end-page
    ))
  let total-sec = scope-sections.len()

  let current-sec = scope-sections
    .filter(s => s.location().page() <= pos.page())
    .len()

  let ratio = if total-sec > 0 { current-sec / total-sec } else { 1 }
  progress-bar(ratio, active-color, inactive-color)
}

// #let section-progress-bar(active-color, inactive-color) = context {
//   let section-level = sk-states.slide-level.get() - 1

//   let current-sec = query(heading.where(level: section-level)
//     .before(here()))
//     .filter(h => not sk-states.appendix.at(h.location()))
//     .len()

//   let total-sec = query(heading.where(level: section-level))
//     .filter(h => not sk-states.appendix.at(h.location()))
//     .len()

//   let ratio = if total-sec > 0 { current-sec / total-sec } else { 1 }

//   progress-bar(ratio, active-color, inactive-color)
// }

#let slide-progress-bar(active-color, inactive-color, height: 2pt) = context {
  let current-page = sk-states.slide-number.get().first()
  let total-page = sk-states.slide-number.final().first()

  let ratio = if total-page > 0 { current-page / total-page } else { 1 }

  block(
    width: 100%,
    progress-bar(ratio, active-color, inactive-color, row-height: height, gutter: 0pt)
  )
}

// Boxes - Utility
#let box-title(a, b) = {
  grid(columns: 2, column-gutter: 0.5em, align: (horizon),
    a,
    b
  )
}

#let colorize(svg, color) = {
  let blk = black.to-hex();
  if svg.contains(blk) {
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\""+ color.to-hex() + "\" ")
  }
}

#let color-svg(
  path,
  color,
  ..args,
) = {
  let data = colorize(read(path), color)
  return image(bytes(data), ..args)
}

#let footcite(key, supplement: none) = context {
  let elems = query(bibliography)
  if elems.len() > 0 {
    super(cite(key, supplement: supplement))
    sk-states.is-footcite.update(true)
    hide(footnote(cite(key, form: "full", style: "resources/short_ref.csl")))
    sk-states.is-footcite.update(false)
  } else {
    panic("No bibliography found. Please add a bibliography to use notecite.")
  }
}

#let show-ref(slide-level: 2, it) = {
  let el = it.element
  // if el == none { return it }
  if el == none { return footcite(it.target) }

  // Detect slides created via #slide(..., label: <...>)
  let is-metadata-slide = (
    el.func() == metadata
    and type(el.value) == dictionary
    and el.value.at("kind", default: none) == "slide"
  )

  // Detect slides created via a heading at the configured slide-level
  let is-heading-slide = (
    el.func() == heading
    and el.has("level")
    and el.level == slide-level
  )

  if is-metadata-slide or is-heading-slide {
    let loc = el.location()
    let is-app = sk-states.appendix.at(loc)

    let base-num = if is-app {
      sk-states.app-slide-number.at(loc).first()
    } else {
      sk-states.slide-number.at(loc).first()
    }

    // A heading just before the .step(), we add +1. For a metadata, the .step() has already occurred, we keep base-num.
    let num = if is-heading-slide { base-num + 1 } else { base-num }
    let prefix = if is-app { "A." } else { "" }

    link(loc, [#prefix#num])
  } else {
    it
  }
}

#let set-text(lang: "en", fonts: (:), body) = {
  set text(font: fonts.at("body", default: default-fonts.body), size: fonts.at("size", default: default-fonts.size), lang: lang, region: lang)
  show math.equation: set text(font: fonts.at("math", default: default-fonts.math), size: fonts.at("size", default: default-fonts.size))
  show raw: set text(font: fonts.at("raw", default: default-fonts.raw), size: fonts.at("size", default: default-fonts.size))

  body
}

// Short or long title
#let short-or-long(short, long) = [#metadata((short: short, long: long)) <sk-title>]