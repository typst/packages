// Parts, chapters, sections and the margin table of contents.
#import "metrics.typ" as m
#import "state.typ": *
#import "theme.typ": make-theme
#import "page.typ": area-top
#import "@preview/marginalia:0.3.1" as marginalia

// Heading numbering limited to `depth` levels (kaobook secnumdepth).
#let numbering-with-depth(depth, pattern: "1.1") = (..nums) => {
  let n = nums.pos()
  if n.len() <= depth { numbering(pattern, ..n) }
}

#let has-number(h) = h.numbering != none and {
  let n = numbering(h.numbering, ..counter(heading).at(h.location()))
  n != none and n != "" and n != []
}

#let heading-number(h) = numbering(h.numbering, ..counter(heading).at(h.location()))

// Resets all counters that restart with every chapter.
#let reset-chapter-counters() = {
  for kind in float-kinds { counter(figure.where(kind: kind)).update(0) }
  counter(math.equation).update(0)
  sidenote-counter.update(0)
}

#let reset-section-counters() = {
  for kind in section-kinds { counter(figure.where(kind: kind)).update(0) }
}

// --- Margin table of contents (kaobook \margintoc) -------------------------------

#let toc-line(number, title, page, number-width, page-width, bold: false, leaders: true, target: none, number-color: black) = {
  set text(weight: if bold { "bold" } else { "regular" })
  let line = {
    box(width: number-width, text(fill: number-color, number))
    title
    if leaders {
      // kaobook: \leaders\hbox to 1.5ex{\hss.\hss}
      [ ]
      box(width: 1fr, repeat(gap: 0.55em, justify: false)[.])
      h(0.3em)
    } else {
      h(1fr)
    }
    box(width: 0pt, box(width: page-width, align(right, page)))
  }
  block(
    width: 100%,
    inset: (right: page-width),
    spacing: m.leading-for("small"),
    breakable: false,
    par(hanging-indent: number-width, justify: false, linebreaks: "optimized", if target != none { link(target, line) } else { line }),
  )
}

#let margin-toc(chapter, color: black) = {
  let next-chapters = query(selector(heading.where(level: 1)).after(chapter.location(), inclusive: false))
  let end = if next-chapters.len() > 0 { next-chapters.first().location() } else { none }
  let sel = selector(heading.where(level: 2)).or(heading.where(level: 3)).after(chapter.location())
  let entries = query(if end == none { sel } else { sel.before(end) }).filter(h => h.outlined)
  if entries.len() == 0 { return none }

  set text(size: m.size.small, top-edge: m.top-edge, bottom-edge: m.bottom-edge, hyphenate: true, costs: (hyphenation: 2000%))
  set par(leading: m.leading-for("small"), spacing: 0pt, justify: false)
  let numbers = entries.map(h => if has-number(h) { heading-number(h) } else { [] })
  let number-width = calc.max(..numbers.map(n => measure(text(size: m.size.small, weight: "bold", n)).width)) + 0.8mm
  let pages = entries.map(h => page-label(h.location()))
  let page-width = calc.max(8pt, ..pages.map(p => measure(text(size: m.size.small, weight: "bold", p)).width))
  for (i, h) in entries.enumerate() {
    if h.level == 2 and i > 0 { v(2.5pt) }
    toc-line(numbers.at(i), h.body, pages.at(i), number-width, page-width, bold: h.level == 2, target: h.location(), number-color: color)
  }
}

// Places the margin toc next to the chapter heading and tells marginalia
// to keep other notes clear of it.
#let place-margin-toc(chapter, dy, color: black) = context {
  let content = margin-toc(chapter, color: color)
  if content == none { return }
  let odd = calc.odd(here().page())
  let body = block(width: m.margin-width, breakable: false, content)
  let height = measure(body).height
  let side-state = if odd { marginalia._note_extends_right } else { marginalia._note_extends_left }
  let page-num = str(here().page())
  side-state.update(old => {
    let entries = old.at(page-num, default: ())
    entries.push((natural: area-top + dy, height: height, shift: false, keep-order: false))
    old.insert(page-num, entries)
    old
  })
  let dx = if odd { m.text-width + m.margin-sep } else { -m.margin-sep - m.margin-width }
  place(top + left, dx: dx, dy: dy, body)
}

// --- Chapter headings ----------------------------------------------------------

// kaobook \chapterstylekao: title flush against the text block, the number in
// the margin, separated by a vertical rule that runs off the top of the page.
#let kao-chapter(it, margin-toc: true, color: black) = context {
  let odd = calc.odd(here().page())
  let title-size = m.size.huge
  let number-size = title-size * m.chapter-number-scale
  let base = m.chapter-baseline - area-top
  let content-top = m.chapter-content-baseline - area-top - 0.75 * m.size.normalsize
  let number = if has-number(it) { heading-number(it) }

  let title = block(width: m.text-width, {
    set text(size: title-size, weight: "bold", hyphenate: false)
    set par(leading: m.leading-for("huge"), justify: false)
    set align(if odd { right } else { left })
    it.body
  })
  let title-height = measure(title).height

  block(width: 100%, height: content-top - m.par-spacing, above: 0pt, below: m.par-spacing, sticky: true, {
    place(top + left, dy: base + 0.25 * title-size - title-height, title)
    let rule-x = if odd { m.text-width + m.margin-sep / 2 } else { -m.margin-sep / 2 }
    let rule-length = 27.4mm + 20.74mm + 2mm
    place(
      top + left,
      dx: rule-x,
      dy: base + 2mm - rule-length,
      line(angle: 90deg, length: rule-length, stroke: m.chapter-rule-width + color),
    )
    if number != none {
      let n = text(size: number-size, weight: "bold", fill: color, number)
      if odd {
        place(top + left, dx: m.text-width + m.margin-sep, dy: base - 0.75 * number-size, n)
      } else {
        place(
          top + left,
          dx: -m.margin-sep - m.margin-width,
          dy: base - 0.75 * number-size,
          box(width: m.margin-width, align(right, n)),
        )
      }
    }
    if margin-toc {
      let first-baseline = m.chapter-content-baseline + 0.4pt - area-top
      place-margin-toc(it, first-baseline - 0.75 * m.size.small, color: color)
    }
  })
}

// KOMA default chapter heading, used in the front and back matter.
#let plain-chapter(it) = {
  let size = m.size.huge
  let top = m.plain-chapter-baseline - area-top - 0.75 * size
  let below = m.gap(m.plain-chapter-content-baseline - m.plain-chapter-baseline, above-size: size)
  block(width: 100%, above: 0pt, below: below, inset: (top: top), sticky: true, {
    set text(size: size, weight: "bold", hyphenate: false)
    set par(leading: m.leading-for("huge"), justify: false)
    if has-number(it) { heading-number(it); h(0.5em) }
    it.body
  })
}

// --- Parts ---------------------------------------------------------------------

// Starts a new part, e.g. `#part[Introduction and Foundations][A Process Perspective]`.
#let part(title, ..subtitle) = {
  let subtitle = subtitle.pos().at(0, default: subtitle.named().at("subtitle", default: none))
  if subtitle == [] or subtitle == "" { subtitle = none }
  [#heading(level: 1, numbering: none, outlined: true, bookmarked: true, title)<kao-part>]
  [#metadata(subtitle)<kao-part-subtitle>]
}

#let part-subtitle(h) = {
  let subs = query(selector(<kao-part-subtitle>).after(h.location()))
  if subs.len() > 0 { subs.first().value }
}

#let part-page(it, margin-layout: true, color: black) = context {
  let n = numbering("I", ..part-counter.get())
  let subtitle = part-subtitle(it)
  let size = m.size.Huge
  let odd = calc.odd(here().page())
  let area-left = if not margin-layout or odd { m.inner } else {
    m.page-width - m.inner - m.text-width
  }
  let body = block(width: m.wide-width, {
    set text(size: size, weight: "bold", hyphenate: false)
    set par(leading: m.leading-for("Huge"), justify: false)
    set align(center)
    smallcaps[#text(fill: color)[#n.] #it.body]
    if subtitle != none { linebreak(); smallcaps(subtitle) }
  })
  let lines = calc.round((measure(body).height - size) / m.baselineskip.Huge) + 1
  let first-baseline = 330.2pt - (lines - 1) * m.baselineskip.Huge / 3
  place(
    top + left,
    dx: m.page-width / 2 - area-left - m.wide-width / 2,
    dy: first-baseline - area-top - 0.75 * size,
    body,
  )
}

// --- Section headings ------------------------------------------------------------

#let section-heading(it, color: black) = {
  let metrics = m.heading-metrics.at(str(it.level), default: m.heading-metrics.at("4"))
  let size = m.size.at(metrics.key)
  block(
    width: 100%,
    above: m.gap(metrics.above, below-size: size),
    below: m.gap(metrics.below, above-size: size),
    sticky: true,
    breakable: false,
    context {
      set text(size: size, weight: "bold", hyphenate: false)
      set par(leading: m.leading-for(metrics.key), justify: false, first-line-indent: 0pt)
      if has-number(it) {
        let number = heading-number(it)
        let gap = 0.5 * m.size.normalsize
        par(hanging-indent: measure(text(size: size, weight: "bold", number)).width + gap)[#text(fill: color, number)#h(gap)#it.body]
      } else {
        par(it.body)
      }
    },
  )
}

// Run-in paragraph heading (KOMA \paragraph): `#paragraph[The Perceptron.] Text ...`
#let paragraph(title) = {
  parbreak()
  v(m.gap(33.7pt), weak: true)
  strong(title)
  h(1em)
}

// --- Show rules --------------------------------------------------------------------

// `style`: "kao" (main matter, 1.5-column layout) or "plain" (front/back matter).
// `strings`: the language table from i18n.typ.
#let heading-rules(
  style: "kao",
  strings: (:),
  numbering-depth: 3,
  numbering-pattern: "1.1",
  margin-toc: true,
  theme: make-theme(),
  body,
) = {
  let color = theme.primary
  set heading(numbering: numbering-with-depth(numbering-depth, pattern: numbering-pattern))
  show heading: set heading(supplement: strings.section)
  show heading.where(level: 1): set heading(supplement: strings.chapter)

  show heading.where(level: 1): it => {
    break-marker()
    pagebreak(weak: true, to: "odd")
    if is-part(it) {
      part-counter.step()
      start-marker("part")
      part-page(it, margin-layout: style == "kao", color: color)
    } else {
      reset-chapter-counters()
      reset-section-counters()
      start-marker("chapter")
      if style == "kao" { kao-chapter(it, margin-toc: margin-toc, color: color) } else { plain-chapter(it) }
    }
  }
  show heading.where(level: 2): it => {
    reset-section-counters()
    section-heading(it, color: color)
  }
  show heading: it => if it.level >= 3 { section-heading(it, color: color) } else { it }
  body
}
