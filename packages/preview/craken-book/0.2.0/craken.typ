// ─────────────────────────────────────────────────────────────────────────────
//  Captain Craken — book template for Typst
//  One source, three editions:
//    • pdf (default): A4 pages made for reading on a screen
//    • print: a ready-to-print book, 189 × 246 mm, two-sided
//    • web: a static site, one page per chapter, styled by web/craken.css,
//      which carries the design system's tokens and ck-* components
//
//    typst init @preview/craken-book:0.2.0 my-book
//    typst compile book.typ                           (A4 PDF)
//    typst compile --input edition=print book.typ book-print.pdf
//    typst compile --input theme=lantern book.typ     (dark PDF)
//    typst compile --features bundle,html --format bundle book.typ site
// ─────────────────────────────────────────────────────────────────────────────

// ── Colours ──────────────────────────────────────────────────────────────────

#let palettes = (
  paper: (
    paper: rgb("#fbf7f0"),
    paper-warm: rgb("#f4eadc"),
    rule: rgb("#e3d5c1"),
    ink: rgb("#2e221b"),
    ink-soft: rgb("#6c5849"),
    rust: rgb("#a63f29"),
    amber: rgb("#8f5e0e"),
    moss: rgb("#55602e"),
    coral: rgb("#e9664e"),
    peach: rgb("#f8c597"),
  ),
  lantern: (
    paper: rgb("#1c1612"),
    paper-warm: rgb("#282019"),
    rule: rgb("#3b3029"),
    ink: rgb("#f0e6d8"),
    ink-soft: rgb("#b9a695"),
    rust: rgb("#f08b6e"),
    amber: rgb("#deac55"),
    moss: rgb("#adba7a"),
    coral: rgb("#e8735b"),
    peach: rgb("#6e4632"),
  ),
)

#let theme = sys.inputs.at("theme", default: "paper")
#let palette = palettes.at(theme)

// ── Type ─────────────────────────────────────────────────────────────────────

#let fonts = (
  display: ("Fraunces Soft Display", "Libertinus Serif"), // chapter & section titles
  label: ("Fraunces Soft Text", "Libertinus Serif"), // labels, subsections, folios
  text: ("Newsreader Text", "Libertinus Serif"), // everything you read
  mono: ("DM Mono", "DejaVu Sans Mono"), // code
  math: ("STIX Two Math", "New Computer Modern Math"),
)

// The PDF edition: "pdf" (A4, read on a screen) or "print" (the printed book).
#let edition = sys.inputs.at("edition", default: "pdf")
#let _print = edition == "print"

// Print sizes are the design system's screen px × 0.583. The A4 edition is a
// step larger, since a page on a screen is read smaller than paper in the hand.
#let type-size = if _print {
  (
    chapter-numeral: 64pt,
    chapter-title: 30pt,
    section: 17.5pt,
    subsection: 12.25pt,
    label: 8.75pt,
    lede: 13pt,
    body: 10.5pt,
    caption: 8.75pt,
    note: 8.25pt,
    code: 8.75pt,
  )
} else {
  (
    chapter-numeral: 72pt,
    chapter-title: 33pt,
    section: 19pt,
    subsection: 13.5pt,
    label: 9.5pt,
    lede: 14pt,
    body: 11.5pt,
    caption: 9.5pt,
    note: 9pt,
    code: 9.5pt,
  )
}

// Baseline-to-baseline distances (text boxes are exactly 1em tall, see book()).
#let line-height = if _print {
  (
    chapter-title: 34pt,
    section: 22pt,
    body: 17.5pt,
    lede: 20pt,
    caption: 13.5pt,
    note: 12.25pt,
    code: 14pt,
  )
} else {
  (
    chapter-title: 37pt,
    section: 24pt,
    body: 19pt,
    lede: 22pt,
    caption: 14.5pt,
    note: 13.5pt,
    code: 15pt,
  )
}

// ── Space, radius, page grid ─────────────────────────────────────────────────

#let spacing = if _print {
  (s1: 2.5pt, s2: 4.5pt, s4: 8.75pt, s6: 14pt, s8: 17.5pt, s12: 26.25pt, s24: 52.5pt)
} else {
  (s1: 2.75pt, s2: 5pt, s4: 9.5pt, s6: 15pt, s8: 19pt, s12: 28.5pt, s24: 57pt)
}
#let radii = (s: 2pt, m: 5pt)

// Text column ≈ 66 characters in both; the margin column holds notes.
//   print: crown quarto, 189 × 246 mm, margin column on the outer side
//   pdf:   A4, one-sided, margin column always on the right
#let page-grid = if _print {
  (
    width: 189mm,
    height: 246mm,
    inside: 18mm,
    top: 22mm,
    bottom: 24mm,
    measure: 112mm,
    gutter: 6mm,
    margin-column: 40mm,
    edge: 13mm,
  )
} else {
  (
    width: 210mm,
    height: 297mm,
    inside: 22mm,
    top: 24mm,
    bottom: 26mm,
    measure: 125mm,
    gutter: 7mm,
    margin-column: 44mm,
    edge: 12mm,
  )
}
#let outside = page-grid.gutter + page-grid.margin-column + page-grid.edge

// ── Edition switches ─────────────────────────────────────────────────────────
// Call these inside `context`. "paged" = PDF; "html" = a web page; "bundle" =
// the top level of a multi-page site (only documents and assets live there).

#let _web() = target() == "html"
#let _site() = target() == "bundle"

/// An HTML element with an optional class.
#let _el(tag, class: none, attrs: (:), ..body) = html.elem(
  tag,
  attrs: (if class != none { (class: class) } else { (:) }) + attrs,
  ..body,
)

// ── Small helpers ────────────────────────────────────────────────────────────

#let _lead(size, height) = height - size   // par leading for a 1em-tall line box

#let label-text(fill: palette.ink-soft, body) = text(
  font: fonts.label,
  weight: 600,
  size: type-size.label,
  fill: fill,
  body,
)

#let _sucker-paged(color, d, filled, stroke) = box(
  width: d,
  height: d,
  baseline: 0.05em,
  {
    place(center + horizon, circle(radius: d / 2 - stroke / 2, stroke: stroke + color))
    if filled { place(center + horizon, circle(radius: d * 0.19, fill: color)) }
  },
)
#let _sucker-web(filled: true) = _el(
  "span",
  class: if filled { "ck-sucker" } else { "ck-sucker ck-sucker--open" },
  attrs: (aria-hidden: "true"),
)

/// The one ornament: a ring with a dot, from the kraken's tentacles.
#let sucker(color: palette.coral, d: 6.5pt, filled: true, stroke: 0.9pt) = context {
  if _web() { _sucker-web(filled: filled) } else { _sucker-paged(color, d, filled, stroke) }
}

/// A new term, introduced once.
#let dfn(body) = context {
  if _web() { _el("dfn", body) } else { text(style: "italic", weight: 600, body) }
}

/// The first paragraph of a chapter. The site's home page quotes it.
#let lede(body) = (
  [#metadata(body) <craken-lede>]
    + context {
      if _web() { _el("p", class: "lede", body) } else {
        block(below: spacing.s12, {
          set text(size: type-size.lede)
          set par(leading: _lead(type-size.lede, line-height.lede), justify: false)
          body
        })
      }
    }
)

/// Three suckers: a break inside a section.
#let sbreak() = context {
  if _web() {
    _el("div", class: "ck-break", attrs: (role: "separator"), _sucker-web() + _sucker-web() + _sucker-web())
  } else {
    let s = _sucker-paged(palette.coral, 6.5pt, true, 0.9pt)
    block(above: spacing.s12, below: spacing.s12, width: 100%, align(center, stack(
      dir: ltr,
      spacing: spacing.s4,
      s,
      s,
      s,
    )))
  }
}

// ── Callouts: Tip, Question, Try this ────────────────────────────────────────


// The answer under a question, set upside-down at the foot of the box (print).
#let _answer-flipped(answer) = {
  v(spacing.s6, weak: true)
  rotate(180deg, reflow: true, block(width: 100%, {
    set text(size: type-size.caption, fill: palette.ink-soft)
    set par(leading: _lead(type-size.caption, line-height.caption), justify: false)
    label-text(fill: palette.rust)[Answer]
    h(spacing.s2)
    answer
  }))
}

// Chapter range helpers: the part of the book from the last chapter heading
// before `loc` to the next one after it. Locations, not counters, so the
// answers and solutions settle in as few layout passes as possible.
#let _after-chapter-start(sel, loc) = {
  let prev = query(heading.where(level: 1).before(loc))
  if prev.len() > 0 { sel.after(prev.last().location()) } else { sel }
}
#let _before-chapter-end(sel, loc) = {
  let next = query(heading.where(level: 1).after(loc, inclusive: false))
  if next.len() > 0 { sel.before(next.first().location()) } else { sel }
}

// A4 edition: nobody turns a screen upside-down, so the answer moves to the
// chapter's solutions and the question links to it (and back).
#let _answer-linked(answer) = context {
  let me = here()
  // Record the answer whatever happens, so solutions() never waits on the
  // check below.
  [#metadata((kind: "answer", body: answer, question: me))<craken-solution>]
  let here-on = _before-chapter-end(selector(<craken-solutions-here>).after(me), me)
  let collected = query(here-on).len() > 0 or query(<craken-solutions-here>).any(m => m.value.all)
  if not collected { return _answer-flipped(answer) } // no solutions() for this chapter
  v(spacing.s4, weak: true)
  set text(size: type-size.caption, fill: palette.ink-soft)
  label-text(fill: palette.rust)[Answer]
  h(spacing.s2)
  // the answer's page is known from the second layout pass on
  let found = query(<craken-answer-here>).filter(m => m.value == me)
  if found.len() > 0 {
    let there = found.first().location()
    link(there)[on page #there.page()]
  } else [on page …]
}

#let _callout(body, kind, name, color, answer: none) = context {
  if _web() {
    _el("aside", class: "ck-callout ck-callout--" + kind, {
      _el("p", class: "ck-callout__label label", _sucker-web() + name)
      body
      if answer != none {
        _el(
          "details",
          class: "ck-reveal",
          _el("summary", class: "label")[Answer] + _el("div", class: "ck-reveal__body", answer),
        )
      }
    })
  } else {
    block(
      width: 100%,
      above: spacing.s8,
      below: spacing.s8,
      inset: spacing.s6,
      fill: palette.paper-warm,
      radius: radii.m,
      breakable: true,
      {
        label-text(fill: color)[#_sucker-paged(color, 6.5pt, true, 0.9pt) #h(spacing.s2) #name]
        v(spacing.s2, weak: true)
        // Code sits on paper-warm; inside a callout (paper-warm too) it moves
        // to paper. Show-set rules, not state: state costs layout passes.
        show <craken-code-box>: set block(fill: palette.paper)
        show raw.where(block: true): set block(fill: palette.paper)
        show raw.where(block: false): set box(fill: palette.paper)
        body
        if answer != none {
          if _print { _answer-flipped(answer) } else { _answer-linked(answer) }
        }
      },
    )
  }
}

#let tip(body, label: [Tip]) = _callout(body, "tip", label, palette.amber)
#let try-this(body, label: [Try this]) = _callout(body, "try", label, palette.moss)

/// A question for the reader. In print the answer is set upside-down at the
/// foot of the box; on the web it hides behind an "Answer" toggle.
#let question(body, answer: none, label: [Question]) = _callout(body, "question", label, palette.rust, answer: answer)

// ── Margin notes ─────────────────────────────────────────────────────────────

#let note-counter = counter("craken-note")
#let note-state = state("craken-note-bottom", (page: 0, y: 0pt))

/// A numbered note in the margin column, beside the line that calls it.
#let note(body) = {
  note-counter.step()
  context {
    let n = note-counter.get().first()
    if _web() {
      _el("sup", class: "ck-note-ref", str(n))
      _el("span", class: "ck-note margin-note", _el("span", class: "ck-note__num", str(n)) + body)
      return
    }
    let pos = here().position()
    let recto = not _print or calc.odd(pos.page)
    let x = if recto { page-grid.inside + page-grid.measure + page-grid.gutter } else { page-grid.edge }
    let content = block(width: page-grid.margin-column, {
      set text(size: type-size.note, fill: palette.ink-soft, hyphenate: false)
      set par(leading: _lead(type-size.note, line-height.note), justify: false)
      text(fill: palette.rust, weight: 600)[#n]
      h(spacing.s1)
      body
    })
    let height = measure(content).height
    // align the note's first baseline with the calling line, then push it down
    // if the previous note on this page is still in the way
    let y0 = pos.y - 0.8 * type-size.note
    let prev = note-state.get()
    if prev.page == pos.page and y0 < prev.y + spacing.s2 { y0 = prev.y + spacing.s2 }
    note-state.update((page: pos.page, y: y0 + height))
    text(fill: palette.rust, weight: 600, super(str(n)))
    box(width: 0pt, place(top + left, dx: x - pos.x, dy: y0 - pos.y, content))
  }
}

// ── Code ─────────────────────────────────────────────────────────────────────

#let _in-code = state("craken-in-code", false)

/// A titled, optionally numbered listing. Plain ```blocks``` get the same box.
#let code(body, title: none, lang: none, numbers: false) = context {
  if _web() {
    show raw.line: it => if numbers { _el("span", class: "ck-line", it) } else { it }
    _el(
      "figure",
      class: if numbers { "ck-code ck-code--numbered" } else { "ck-code" },
      {
        if title != none or lang != none {
          _el("figcaption", class: "ck-code__title code", _el("span", title) + _el("span", lang))
        }
        _in-code.update(true)
        body
        _in-code.update(false)
      },
    )
    return
  }
  show raw.line: it => {
    if numbers {
      box(width: 1.6em, align(right, text(fill: palette.ink-soft, str(it.number))))
      h(1.2em)
    }
    it
  }
  [#block(
    width: 100%,
    above: spacing.s8,
    below: spacing.s8,
    radius: radii.m,
    clip: true,
    breakable: true,
    {
      if title != none or lang != none {
        block(
          width: 100%,
          inset: (x: spacing.s6, top: spacing.s4, bottom: 0pt),
          spacing: 0pt,
          sticky: true,
          {
            set text(font: fonts.mono, size: 7.5pt, fill: palette.ink-soft)
            set align(start)
            title
            h(1fr)
            lang
          },
        )
      }
      block(width: 100%, inset: (x: spacing.s6, y: spacing.s4), spacing: 0pt, {
        set align(start)
        // the code box is drawn here, so the code block itself goes bare
        show raw.where(block: true): set block(fill: none, inset: 0pt, radius: 0pt, above: 0pt, below: 0pt)
        body
      })
    },
  )<craken-code-box>]
}

/// A numbered listing ("Listing 1.2") with a caption: code() inside a figure.
#let listing(body, caption: none, title: none, lang: none, numbers: false) = figure(
  code(body, title: title, lang: lang, numbers: numbers),
  kind: raw,
  supplement: [Listing],
  caption: caption,
)

// ── Exercises and solutions ──────────────────────────────────────────────────

#let exercise-counter = counter(figure.where(kind: "exercise"))

#let pips(n) = context {
  if _web() {
    _el(
      "span",
      class: "ck-exercise__difficulty",
      attrs: (role: "img", aria-label: "Difficulty " + str(n) + " of 3"),
      range(3).map(i => _sucker-web(filled: i < n)).join(),
    )
  } else {
    box(baseline: 0.05em, stack(
      dir: ltr,
      spacing: spacing.s1,
      ..range(3).map(i => _sucker-paged(palette.ink-soft, 6pt, i < n, 0.75pt)),
    ))
  }
}

/// A numbered exercise, rated 1–3. Label it to refer to it (@ex:name).
/// Print: its solution waits for solutions(). Web: it hides under the exercise.
#let exercise(body, difficulty: 1, solution: none) = figure(
  kind: "exercise",
  supplement: [Exercise],
  outlined: false,
  context {
    let chapter = counter(heading).get().first()
    let num = str(chapter) + "." + str(exercise-counter.get().first())
    if _web() {
      _el("section", class: "ck-exercise", {
        _el(
          "p",
          class: "ck-exercise__head",
          _el("span", class: "ck-exercise__number label")[Exercise #num] + [ ] + pips(difficulty),
        )
        _el("div", class: "ck-exercise__body", body)
        if solution != none {
          _el(
            "details",
            class: "ck-reveal ck-solution",
            _el("summary", class: "label")[Solution] + _el("div", class: "ck-reveal__body", solution),
          )
        }
      })
      return
    }
    block(
      width: 100%,
      above: 0pt,
      below: 0pt,
      inset: (y: spacing.s4),
      breakable: true,
      {
        set align(start)
        label-text(fill: palette.rust)[Exercise #num]
        h(spacing.s4)
        pips(difficulty)
        v(spacing.s2, weak: true)
        body
      },
    )
    if solution != none {
      [#metadata((kind: "exercise", num: num, body: solution))<craken-solution>]
    }
  },
)

/// Wraps a run of exercises.
#let exercises(body) = context {
  if _web() { _el("div", class: "ck-exercises", body) } else {
    block(width: 100%, above: spacing.s8, below: spacing.s8, body)
  }
}

/// Print: a "Solutions" section with this chapter's solutions (all: true for
/// every chapter). Web: nothing, as solutions sit under their exercises.
#let solutions(all: false, title: [Solutions]) = context {
  if _web() { return }
  let me = here()
  [#metadata((all: all))<craken-solutions-here>]
  let sel = selector(<craken-solution>).before(me)
  if not all { sel = _after-chapter-start(sel, me) }
  let items = query(sel).map(m => m.value)
  if title != none and items.len() > 0 { heading(level: 2, numbering: none, title) }
  for s in items {
    if s.kind == "answer" {
      [#metadata(s.question)<craken-answer-here>]
      block(above: spacing.s6, below: spacing.s6, breakable: true, {
          label-text(fill: palette.rust)[Answer]
          h(spacing.s2)
          text(size: type-size.caption, fill: palette.ink-soft, link(s.question)[to the question on page #s.question.page()])
          v(spacing.s2, weak: true)
          s.body
        })
    } else {
      block(above: spacing.s6, below: spacing.s6, breakable: true, {
        label-text(fill: palette.moss)[Solution #s.num]
        v(spacing.s2, weak: true)
        s.body
      })
    }
  }
}

// ── Figures drawn in Typst ───────────────────────────────────────────────────

#let ink-line = 1.2pt + palette.ink

// ── Chapters and the site ────────────────────────────────────────────────────

#let _meta = state("craken-meta", (:))
#let _chapter-counter = counter("craken-chapter")

#let _topbar(wide: false) = context {
  let meta = _meta.get()
  _el(
    "header",
    class: if wide { "ck-topbar ck-topbar--wide" } else { "ck-topbar" },
    {
      _el("a", class: "ck-topbar__title label", attrs: (href: "index.html"), {
        if meta.at("logo-src", default: none) != none {
          _el("img", attrs: (src: meta.logo-src, alt: ""))
        }
        meta.at("title", default: [])
      })
      if meta.at("pdf", default: none) != none {
        _el("nav", class: "ck-topbar__nav label", _el("a", attrs: (href: meta.pdf))[PDF])
      }
      _el("button", class: "ck-theme-toggle label", attrs: (type: "button"), _sucker-web() + _el("span")[Lantern])
    },
  )
}

#let _chapter-label(ch) = {
  if ch.numbering != none [Chapter #counter(heading).at(ch.location()).first()] else [ ]
}

#let _pager() = context {
  let chapters = query(heading.where(level: 1))
  let k = _chapter-counter.get().first()
  _el("nav", class: "ck-pager", attrs: (aria-label: "Chapters"), {
    if k >= 2 {
      let prev = chapters.at(k - 2)
      link(
        prev.location(),
        _el("span", class: "label")[Previous chapter] + _el("span", class: "ck-pager__title", prev.body),
      )
    }
    if k < chapters.len() {
      let next = chapters.at(k)
      _el("span", class: "ck-pager__next", link(
        next.location(),
        _el("span", class: "label")[Next chapter] + _el("span", class: "ck-pager__title", next.body),
      ))
    }
  })
}

#let _plural(n, one, many) = str(n) + " " + if n == 1 { one } else { many }

/// A small coloured label used inside running text: the sucker and a word.
#let _mark(kind, name) = _el("span", class: "ck-mark ck-mark--" + kind, _sucker-web() + name)

/// The letter on the home page when book(note: auto): what the book is, how it
/// talks to you, signed by the author.
#let _default-note(meta) = {
  // a div, so a one-paragraph description (no <p> of its own) keeps its spacing
  if meta.description != none { _el("div", class: "ck-letter__description", meta.description) }
  par[
    The book talks to you in a few ways. A #_mark("tip", [Tip]) is a trick worth keeping.
    A #_mark("question", [Question]) asks you to stop and answer before you read on; the answer waits behind a toggle.
    #_mark("try", [Try this]) is something small to do with your hands: run it, draw it, change one thing.
    Each chapter ends with exercises, rated from
    #_el(
      "span",
      class: "ck-exercise__difficulty",
      _sucker-web() + _sucker-web(filled: false) + _sucker-web(filled: false),
    )
    to #_el("span", class: "ck-exercise__difficulty", _sucker-web() + _sucker-web() + _sucker-web()),
    and every solution hides under its exercise.
  ]
  par[Take your time, and come back to anything that didn't land the first time.]
}

#let _home(meta) = context {
  let chapters = query(heading.where(level: 1))
  let between(sel, i) = {
    let from = sel.after(chapters.at(i).location())
    if i + 1 < chapters.len() { query(from.before(chapters.at(i + 1).location())) } else { query(from) }
  }

  // 1. The open book: frontispiece on the left page, title page on the right,
  //    with index tabs on the right page's top edge as the two ways in.
  _el("div", class: "ck-desk", _el("section", class: "ck-spread", {
    _el("div", class: "ck-spread__verso", {
      if meta.cover-src != none {
        _el("figure", class: "ck-frontis", {
          _el("div", class: "ck-frontis__plate", _el("img", attrs: (
            src: meta.cover-src,
            alt: meta.cover-alt,
          )))
          if meta.frontispiece != none { _el("figcaption", class: "ck-frontis__caption caption", meta.frontispiece) }
        })
      }
    })
    _el("div", class: "ck-spread__recto", {
      _el("nav", class: "ck-tabs", attrs: (aria-label: "Start reading"), {
        if chapters.len() > 0 {
          _el("span", class: "ck-tab ck-tab--read label", link(chapters.first().location())[Read online])
        }
        if meta.pdf != none {
          _el("span", class: "ck-tab label", _el("a", attrs: (href: meta.pdf))[Download the PDF])
        }
      })
      _el("div", class: "ck-titlepage", {
        if meta.series != none { _el("p", class: "ck-titlepage__series label", meta.series) }
        _el("h1", class: "ck-titlepage__title", meta.title)
        if meta.subtitle != none { _el("p", class: "ck-titlepage__subtitle", meta.subtitle) }
        _el("p", class: "ck-titlepage__fleuron", _sucker-web())
        if meta.author != none { _el("p", class: "ck-titlepage__author", meta.author) }
      })
      _el("p", class: "ck-titlepage__imprint label", {
        if meta.homepage != none { meta.homepage.trim("https://", at: start).trim("/", at: end) + " · " }
        str(datetime.today().year())
      })
    })
  }))

  // 2. A letter to the reader: what the book is and how it talks to you.
  if meta.note != none {
    _el("section", class: "ck-letter", {
      _el("p", class: "ck-letter__salutation")[To the reader,]
      _el("div", class: "ck-letter__body", if meta.note == auto { _default-note(meta) } else { meta.note })
      if meta.author != none { _el("p", class: "ck-letter__sign", meta.author) }
    })
  }

  // 3. Contents, set like a book's contents page.
  if meta.contents and chapters.len() > 0 {
    _el("div", class: "ck-break", attrs: (role: "separator"), _sucker-web() + _sucker-web() + _sucker-web())
    _el("section", class: "ck-contents", {
      _el("h2", class: "ck-contents__title")[Contents]
      _el("ol", class: "ck-contents__list", {
        let parts = query(<craken-part>)
        let shown = 0
        for (i, ch) in chapters.enumerate() {
          // the parts that open before this chapter, each listed once
          let k = query(selector(<craken-part>).before(ch.location())).len()
          for j in range(shown, k) {
            let p = parts.at(j)
            _el("li", class: "ck-contents__part", {
              _el("span", class: "ck-contents__part-num label")[Part #numbering("I", j + 1)]
              _el("h3", class: "ck-contents__part-name", link(chapters.at(i).location(), p.value.title))
            })
          }
          shown = calc.max(shown, k)
          let sections = between(heading.where(level: 2), i)
          let exercises = between(figure.where(kind: "exercise"), i).len()
          let ledes = between(selector(<craken-lede>), i)
          _el("li", class: "ck-contents__chapter", {
            _el("span", class: "ck-contents__num", if ch.numbering != none {
              str(counter(heading).at(ch.location()).first())
            } else { "" })
            _el("div", {
              _el("h3", class: "ck-contents__name", link(ch.location(), ch.body))
              if ledes.len() > 0 { _el("p", class: "ck-contents__lede", ledes.first().value) }
              if sections.len() > 0 or exercises > 0 {
                _el("p", class: "ck-contents__sections", {
                  sections
                    .map(s => link(s.location(), {
                      if s.numbering != none {
                        _el("span", class: "ck-section-num", numbering("1.1", ..counter(heading).at(s.location())))
                      }
                      s.body
                    }))
                    .join(_el("span", class: "ck-contents__dot", " · "))
                  if exercises > 0 {
                    if sections.len() > 0 { _el("span", class: "ck-contents__dot", " · ") }
                    _el("span", class: "ck-contents__count", _plural(exercises, "exercise", "exercises"))
                  }
                })
              }
            })
          })
        }
      })
    })
  }
}

#let _footer(wide: false) = context {
  let meta = _meta.get()
  _el(
    "footer",
    class: if wide { "ck-footer ck-footer--wide" } else { "ck-footer" },
    {
      _el("p", {
        [© #datetime.today().year()]
        if meta.at("author", default: none) != none [ #meta.author]
        if meta.at("homepage", default: none) != none {
          [ · ]
          _el("a", attrs: (href: meta.homepage), meta.homepage.trim("https://", at: start).trim("/", at: end))
        }
      })
      _el("p", class: "ck-footer__colophon")[Set in Fraunces, Newsreader and DM Mono. Made with Typst.]
    },
  )
}

/// The footnotes of a web page, listed at the end of its text.
#let _footnotes(notes) = if notes.len() > 0 {
  _el("section", class: "ck-footnotes caption", attrs: (role: "doc-endnotes"), _el("ol", {
    for f in notes {
      let k = str(counter(footnote).at(f.location()).first())
      _el("li", attrs: (id: "fn-" + k), {
        _el("a", class: "ck-footnotes__num", attrs: (href: "#fnref-" + k, role: "doc-backlink"), numbering(
          f.numbering,
          ..counter(footnote).at(f.location()),
        ))
        f.body
      })
    }
  }))
}

/// Opens a part: a group of chapters. Chapters keep their numbers across parts.
/// PDF: a part title page (on a right-hand page in print), listed in the
/// contents. Web: a heading in the home page's contents, and a banner on the
/// part's first chapter. Put it between chapters in book.typ:
///   #part[Foundations]
///   #chapter("recursion", include "chapters/recursion.typ")
#let part(title, intro: none) = {
  [#metadata((title: title, intro: intro))<craken-part>]
  context {
    if _web() or _site() { return }
    [#metadata("part")<craken-chapter-end>]
    pagebreak(weak: true, to: if _print { "odd" } else { none })
    v(1fr)
    figure(
      kind: "craken-part",
      supplement: [Part],
      numbering: "I",
      caption: title,
      outlined: true,
      intro,
    )
    v(2fr)
    [#metadata("part")<craken-chapter-end>]
    pagebreak(weak: true)
  }
}

/// Marks one chapter. In print it does nothing; in the site it becomes its own
/// page, `<slug>.html`.
#let chapter(slug, body) = context {
  if not _site() { return body }
  let meta = _meta.get()
  _chapter-counter.step()
  document(slug + ".html", title: meta.at("title", default: none), {
    _el("script", attrs: (src: "craken.js"))
    html.link(rel: "stylesheet", href: "craken.css")
    _topbar()
    _el("main", class: "ck-page ck-book body", {
      body
      context {
        let k = _chapter-counter.get()
        _footnotes(query(footnote).filter(f => _chapter-counter.at(f.location()) == k))
      }
    })
    _pager()
    _footer()
  })
}

// ── Web rules (HTML pages) ───────────────────────────────────────────────────

#let _web-rules(body) = {
  set heading(numbering: "1.1")
  set raw(theme: "themes/craken-web.tmTheme")

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "exercise")).update(0)
    note-counter.update(0)
    // The first chapter of a part opens with the part's banner.
    context {
      let parts = query(selector(<craken-part>).before(here()))
      if parts.len() == 0 { return }
      let p = parts.last()
      let between = query(heading.where(level: 1).after(p.location()).before(it.location(), inclusive: false))
      if between.len() > 0 { return }
      _el("section", class: "ck-part", {
        _el("p", class: "ck-part__kicker", _el("span", class: "label")[Part] + [ ] + _el(
          "span",
          class: "ck-part__numeral",
          numbering("I", parts.len()),
        ))
        _el("h2", class: "ck-part__title", p.value.title)
        if p.value.intro != none { _el("div", class: "ck-part__intro lede", p.value.intro) }
      })
    }
    _el("header", class: "ck-chapter", {
      if it.numbering != none {
        _el(
          "p",
          class: "ck-chapter__kicker",
          _el("span", class: "label")[Chapter]
            + [ ]
            + _el("span", class: "ck-chapter__numeral", context counter(heading).display("1")),
        )
      }
      _el("h1", class: "chapter-title", it.body)
    })
  }
  show heading.where(level: 2): it => _el("h2", class: "section-title", {
    if it.numbering != none { _el("span", class: "ck-section-num", context counter(heading).display()) }
    it.body
  })
  show heading.where(level: 3): it => _el("h3", class: "subsection-title", it.body)

  set math.equation(
    numbering: (..n) => {
      let chapter = counter(heading).get().first()
      numbering("(1.1)", chapter, ..n)
    },
    supplement: [Equation],
  )
  show math.equation.where(block: true): it => {
    if it.numbering == none {
      it
    } else if not it.has("label") {
      counter(math.equation).update(v => v - 1)
      _el("div", class: "ck-equation", math.equation(it.body, block: true, numbering: none))
    } else {
      _el(
        "div",
        class: "ck-equation",
        it + _el("div", class: "ck-equation__number", context counter(math.equation).display(it.numbering)),
      )
    }
  }

  show raw.where(block: true): it => context {
    if _in-code.get() { it } else { _el("figure", class: "ck-code", it) }
  }

  // Block quotes: the attribution set flush right, as in the PDF.
  show quote.where(block: true): it => _el("blockquote", class: "ck-quote", {
    _el("p", it.body)
    if it.attribution != none {
      let who = if type(it.attribution) == label { cite(it.attribution) } else { it.attribution }
      _el("p", class: "ck-quote__attribution")[— #who]
    }
  })

  // Footnotes: a numbered link here; the notes are listed at the end of the
  // chapter (see chapter()), not after the page footer.
  show footnote: it => context {
    let n = counter(footnote).display(it.numbering)
    let k = str(counter(footnote).get().first())
    _el("sup", class: "ck-fn-ref", attrs: (id: "fnref-" + k), _el("a", attrs: (href: "#fn-" + k), n))
  }
  // Typst still writes its own (now empty) endnotes after the page; the
  // stylesheet hides them.
  show footnote.entry: none

  // Tables: natural width unless a column is fractional; cells keep the
  // alignment given in Typst (the stylesheet's default otherwise).
  show table: it => {
    let cols = if type(it.columns) == array { it.columns } else { () }
    let full = cols.any(c => type(c) == fraction)
    _el("div", class: if full { "ck-table ck-table--full" } else { "ck-table" }, it)
  }
  show table.cell: it => {
    let a = it.align
    let x = if type(a) == alignment {
      if a.axis() == "horizontal" { a } else if a.axis() == none { a.x } else { none }
    } else { none }
    let name = if x == left or x == start { "left" } else if x == right or x == end { "right" } else if x == center {
      "center"
    } else { none }
    if name == none { it.body } else { _el("span", class: "ck-align ck-align--" + name, it.body) }
  }

  set figure(numbering: (..n) => {
    let chapter = counter(heading).get().first()
    numbering("1.1", chapter, ..n)
  })
  show figure: it => {
    if it.kind == "exercise" { return it.body }
    let art = if it.kind == image and it.body.func() != image {
      _el("div", class: "ck-figure__art ck-figure__art--drawn", html.frame(it.body))
    } else {
      _el("div", class: "ck-figure__art", it.body)
    }
    _el("figure", class: "ck-figure", {
      art
      if it.caption != none {
        _el("figcaption", class: "caption", {
          _el("span", class: "ck-figure__label label")[#it.supplement #context it.counter.display(it.numbering)]
          [ ]
          it.caption.body
        })
      }
    })
  }

  body
}

// ── Print rules (PDF) ────────────────────────────────────────────────────────

// Pages left empty by `pagebreak(to: "odd")` before a chapter or a part get no
// header or folio. Chapters and parts drop a <craken-chapter-end> marker where
// the text before them ends; a page is blank if it falls after the last such
// marker and before the next opener. A marker at the very top of a page marks
// nothing (the page was already empty), so it doesn't count.
#let _is-blank(p) = {
  let openers = (
    query(heading.where(level: 1)).map(it => it.location().page())
      + query(figure.where(kind: "craken-part")).map(it => it.location().page())
  )
  if p in query(figure.where(kind: "craken-part")).map(it => it.location().page()) { return true }
  let next = openers.filter(s => s > p)
  if next.len() == 0 { return false }
  let s = calc.min(..next)
  let ends = query(<craken-chapter-end>)
    .map(it => it.location().position())
    .filter(pos => pos.page < s and pos.y > page-grid.top + 1pt)
    .map(pos => pos.page)
  let e = if ends.len() > 0 { calc.max(..ends) } else { 0 }
  e < p
}

#let _paged-rules(body, justify: true) = {
  // Page: two-sided, margin column on the outside.
  set page(
    width: page-grid.width,
    height: page-grid.height,
    margin: if _print {
      (inside: page-grid.inside, outside: outside, top: page-grid.top, bottom: page-grid.bottom)
    } else {
      (left: page-grid.inside, right: outside, top: page-grid.top, bottom: page-grid.bottom)
    },
    binding: if _print { left } else { auto },
    fill: palette.paper,
    header: context {
      let p = here().page()
      if _is-blank(p) { return }
      let chapters = query(heading.where(level: 1))
      if chapters.any(ch => ch.location().page() == p) { return }
      let before = chapters.filter(ch => ch.location().page() < p)
      if before.len() == 0 { return }
      let ch = before.last()
      let head = label-text({
        if ch.numbering != none {
          str(counter(heading).at(ch.location()).first())
          h(0.6em)
        }
        ch.body
      })
      align(if not _print or calc.odd(p) { right } else { left }, head)
    },
    footer: context {
      let p = here().page()
      if counter(page).get().first() > 1 and not _is-blank(p) {
        align(if not _print or calc.odd(p) { right } else { left }, label-text(counter(page).display()))
      }
    },
  )

  // Text: Newsreader, 1em line boxes so leading sets an exact baseline grid.
  set text(
    font: fonts.text,
    size: type-size.body,
    fill: palette.ink,
    lang: "en",
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    hyphenate: justify,
  )
  set par(leading: _lead(type-size.body, line-height.body), spacing: spacing.s4, justify: justify)
  show strong: set text(weight: 600)
  set footnote.entry(separator: none, clearance: spacing.s8)
  show link: set text(fill: palette.rust)
  show ref: it => if _print { it } else { text(fill: palette.rust, it) }
  // Lists: a plain coral dot (no ring, so it can't be mistaken for the
  // sucker on callouts), then a short dash, then a small dot, both ink-soft;
  // label-face numerals in rust for numbered lists.
  let dot(r, fill) = box(width: 2 * r, height: 0.5em, baseline: 0pt, place(left + horizon, circle(radius: r, fill: fill)))
  set list(
    marker: (
      dot(2.1pt, palette.coral),
      box(width: 5pt, height: 0.5em, place(left + horizon, line(length: 5pt, stroke: 0.9pt + palette.ink-soft))),
      dot(1.3pt, palette.ink-soft),
    ),
    indent: 0pt,
    body-indent: spacing.s4,
  )
  set enum(
    numbering: n => text(font: fonts.label, weight: 600, fill: palette.rust, number-type: "lining", str(n) + "."),
    indent: 0pt,
    body-indent: spacing.s4,
  )

  // Headings: chapters (level 1), sections (2), subsections (3).
  set heading(numbering: "1.1")
  show heading: set text(fill: palette.ink, hyphenate: false)
  show heading: set par(justify: false)

  show heading.where(level: 1): it => {
    [#metadata("chapter-end") <craken-chapter-end>]
    pagebreak(to: if _print { "odd" } else { none }, weak: true)
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "exercise")).update(0)
    note-counter.update(0)
    block(above: 0pt, below: spacing.s6, width: 100%, {
      v(spacing.s24)
      if it.numbering != none {
        label-text[Chapter]
        v(spacing.s2, weak: true)
        text(
          font: fonts.display,
          weight: 500,
          size: type-size.chapter-numeral,
          fill: palette.coral,
          top-edge: "cap-height",
          bottom-edge: "baseline",
          context counter(heading).display("1"),
        )
        v(spacing.s8, weak: true)
      }
      block(width: 88%, {
        set text(font: fonts.display, weight: 600, size: type-size.chapter-title)
        set par(leading: _lead(type-size.chapter-title, line-height.chapter-title))
        it.body
      })
    })
  }

  show heading.where(level: 2): it => block(above: spacing.s12, below: spacing.s4, sticky: true, {
    set text(font: fonts.display, weight: 600, size: type-size.section)
    set par(leading: _lead(type-size.section, line-height.section))
    if it.numbering != none {
      context counter(heading).display()
      h(0.5em)
    }
    it.body
  })

  show heading.where(level: 3): it => block(above: spacing.s8, below: spacing.s2, sticky: true, {
    set text(font: fonts.label, weight: 600, size: type-size.subsection)
    it.body
  })

  // Math: STIX Two Math, a step above the text. Only labelled equations get a
  // number, as (chapter.n).
  show math.equation: set text(font: fonts.math, size: 1.06em)
  set math.equation(
    numbering: (..n) => {
      let chapter = counter(heading).get().first()
      numbering("(1.1)", chapter, ..n)
    },
    supplement: [Equation],
  )
  show math.equation.where(block: true): it => {
    if it.numbering != none and not it.has("label") {
      counter(math.equation).update(v => v - 1)
      math.equation(it.body, block: true, numbering: none)
    } else { it }
  }
  show math.equation.where(block: true): set block(above: spacing.s6, below: spacing.s6)

  // Code: DM Mono on paper-warm, four colour roles.
  set raw(theme: "themes/craken-" + theme + ".tmTheme")
  show raw: set text(font: fonts.mono, size: type-size.code, fill: palette.ink, hyphenate: false)
  show raw.where(block: true): set par(leading: _lead(type-size.code, line-height.code), justify: false)
  show raw.where(block: true): set block(
    width: 100%,
    above: spacing.s8,
    below: spacing.s8,
    inset: (x: spacing.s6, y: spacing.s4),
    fill: palette.paper-warm,
    radius: radii.m,
  )
  show <craken-code-box>: set block(fill: palette.paper-warm)
  show raw.where(block: false): set text(size: 0.86 * type-size.body)
  show raw.where(block: false): set box(fill: palette.paper-warm)
  show raw.where(block: false): it => box(
    radius: radii.s,
    inset: (x: 1.5pt),
    outset: (y: 2pt),
    it,
  )

  // Figures, listings and tables: numbered per chapter, caption below,
  // label in rust, text in ink-soft.
  set figure(numbering: (..n) => {
    let chapter = counter(heading).get().first()
    numbering("1.1", chapter, ..n)
  })
  show figure: set block(above: spacing.s8, below: spacing.s8)
  show figure.where(kind: "exercise"): set block(above: 0pt, below: 0pt, breakable: true)
  show figure.where(kind: "exercise"): it => it.body
  show figure.where(kind: "craken-part"): it => block(width: 100%, {
    set align(start)
    label-text(it.supplement)
    v(spacing.s2, weak: true)
    text(
      font: fonts.display,
      weight: 500,
      size: type-size.chapter-numeral,
      fill: palette.coral,
      top-edge: "cap-height",
      bottom-edge: "baseline",
      it.counter.display(it.numbering),
    )
    v(spacing.s8, weak: true)
    block(width: 88%, {
      set text(font: fonts.display, weight: 600, size: type-size.chapter-title, hyphenate: false)
      set par(leading: _lead(type-size.chapter-title, line-height.chapter-title), justify: false)
      it.caption.body
    })
    if it.body != none and it.body != [] {
      v(spacing.s8, weak: true)
      block(width: 88%, {
        set text(size: type-size.lede)
        set par(leading: _lead(type-size.lede, line-height.lede), justify: false)
        it.body
      })
    }
  })
  show figure.caption: it => block(width: 100%, above: spacing.s4, {
    set align(start)
    set text(size: type-size.caption, fill: palette.ink-soft)
    set par(leading: _lead(type-size.caption, line-height.caption), justify: false)
    label-text(fill: palette.rust)[#it.supplement #context it.counter.display(it.numbering)]
    h(0.6em)
    it.body
  })

  // Tables: hairlines, no boxes, tabular figures.
  set table(
    align: (x, _) => if x == 0 { start } else { end },
    stroke: (_, y) => if y == 0 { (bottom: 0.5pt + palette.ink-soft) } else { none },
    inset: (x: spacing.s4, y: spacing.s2 + 1pt),
  )
  show table: set text(number-type: "lining", number-width: "tabular")
  show table.cell.where(y: 0): set text(font: fonts.label, weight: 600, size: type-size.label, fill: palette.ink-soft)

  // Table of contents.
  show outline.entry: it => {
    let el = it.element
    if el.func() != figure or el.kind != "craken-part" { return it }
    block(above: spacing.s12, below: spacing.s4, link(el.location(), {
      set text(fill: palette.ink)
      label-text(fill: palette.rust)[#el.supplement #numbering(el.numbering, ..el.counter.at(el.location()))]
      h(0.6em)
      text(font: fonts.display, weight: 600, size: type-size.subsection, el.caption.body)
      h(0.4em)
      box(width: 1fr, repeat(gap: 0.25em)[.])
      h(0.4em)
      text(font: fonts.label, weight: 600, it.page())
    }))
  }
  show outline.entry.where(level: 1): set text(font: fonts.label, weight: 600)
  show outline.entry.where(level: 1): set block(above: spacing.s6)

  body
}

#let _paged-titlepage(title, subtitle, author, cover, cover-width, is-logo) = page(header: none, footer: none, {
  set par(justify: false)
  set text(hyphenate: false)
  v(1fr)
  if cover != none {
    let width = if cover-width != auto { cover-width } else if _print { 44mm } else { 54mm }
    let mark = box(width: width, image(cover, width: 100%))
    // On Lantern the picture keeps its paper ground: a disc for the round
    // logo, a card for any other cover.
    if theme == "lantern" {
      mark = if is-logo {
        circle(radius: 28mm, fill: palettes.paper.paper, inset: 0pt, align(center + horizon, mark))
      } else {
        box(fill: palettes.paper.paper, inset: 4mm, radius: radii.m, mark)
      }
    }
    mark
    v(spacing.s12)
  }
  text(font: fonts.display, weight: 600, size: if _print { 34pt } else { 40pt }, title)
  if subtitle != none {
    v(spacing.s4)
    text(size: type-size.lede, fill: palette.ink-soft, subtitle)
  }
  v(2fr)
  if author != none { label-text(fill: palette.ink, author) }
})

// ── The template ─────────────────────────────────────────────────────────────

// Where the site's web fonts come from by default: this version's web/fonts
// folder in the GitHub repository, served by jsDelivr. (Packages on Typst
// Universe can't ship font files.)
#let _web-fonts-cdn = "https://cdn.jsdelivr.net/gh/TheCaptainCraken/craken-book@v0.2.0/web/fonts/"

#let book(
  title: none,
  subtitle: none,
  author: none,
  logo: none, // the image's bytes: read("assets/captain-craken.png", encoding: none); site: top bar
  cover: auto, // the title page's picture (bytes, like logo); auto: the logo; none: no picture
  cover-alt: "", // site: what the cover shows, for screen readers ("" if it is decoration)
  cover-width: auto, // PDF: the cover's width on the title page (auto: 54mm A4, 44mm print)
  contents: true, // table of contents after the title page / on the site's home page
  justify: true, // print: justified and hyphenated; false for ragged right
  pdf: none, // site only: link to a PDF you copy into the site, e.g. "book.pdf"
  description: none, // site only: what the book is, opening the letter on the home page
  note: auto, // site only: the letter "To the reader" (auto: the default; none: no letter)
  series: none, // site only: a line above the title, e.g. "A Captain Craken book"
  frontispiece: none, // site only: caption under the cover picture
  homepage: none, // site only: your website, linked in the footer
  web-fonts: auto, // site only: the folder URL the fonts load from; auto: a CDN; "fonts/": copy them into site/fonts/
  body,
) = {
  set document(title: title, author: if author != none { author } else { () })
  // The logo arrives as bytes (a package can't read your project's files);
  // its type is told by its first bytes, for its file name on the site.
  let ext(img) = if img.slice(0, 4) == bytes((0x89, 0x50, 0x4E, 0x47)) { "png" } else if img.at(0) == 0xFF {
    "jpg"
  } else if img.at(0) == 0x3C { "svg" } else if img.slice(0, 4) == bytes("GIF8") { "gif" } else if (
    img.slice(0, 4) == bytes("RIFF")
  ) { "webp" } else { "png" }
  let logo-src = if logo != none { "assets/logo." + ext(logo) }
  let is-logo = cover == auto
  let cover = if cover == auto { logo } else { cover }
  let cover-src = if cover == none { none } else if is-logo { logo-src } else { "assets/cover." + ext(cover) }
  let meta = (
    title: title,
    subtitle: subtitle,
    author: author,
    logo-src: logo-src,
    cover-src: cover-src,
    cover-alt: cover-alt,
    pdf: pdf,
    description: description,
    note: note,
    series: series,
    frontispiece: frontispiece,
    homepage: homepage,
    contents: contents,
  )

  context {
    if _site() {
      // A multi-page site: assets, a home page, one page per chapter().
      _meta.update(meta)
      let font-base = if web-fonts == auto { _web-fonts-cdn } else { web-fonts }
      asset("craken.css", read("web/craken.css").replace("url(\"fonts/", "url(\"" + font-base))
      asset("craken.js", read("web/craken.js"))
      if logo != none { asset(logo-src, logo) }
      if cover != none and not is-logo { asset(cover-src, cover) }
      document("index.html", title: title, _web-rules({
        _el("script", attrs: (src: "craken.js"))
        html.link(rel: "stylesheet", href: "craken.css")
        _topbar(wide: true)
        _el("main", class: "ck-home ck-book body", _home(meta))
        _footer(wide: true)
      }))
      _web-rules(body)
    } else if _web() {
      // One HTML page with the whole book (e.g. HTML export in the web app).
      // Keep it beside the web/ folder so the stylesheet and fonts load.
      _meta.update(meta)
      _web-rules({
        _el("script", attrs: (src: "web/craken.js"))
        html.link(rel: "stylesheet", href: "web/craken.css")
        _topbar()
        _el("main", class: "ck-home ck-book body", _home(meta))
        _el("main", class: "ck-page ck-book body", body + context _footnotes(query(footnote)))
        _footer()
      })
    } else {
      _paged-rules(justify: justify, {
        if title != none { _paged-titlepage(title, subtitle, author, cover, cover-width, is-logo) }
        if contents { outline(depth: 2, target: heading.where(outlined: true).or(figure.where(kind: "craken-part"))) }
        body
      })
    }
  }
}
