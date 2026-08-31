// Endfield Document Theme
// A4 document template inspired by the visual style of @preview/touying-endfield
// Does NOT require Touying — suitable for regular flowing documents.

// ── Color palette (mirrors endfield theme defaults) ───────────────────────────
#let clr-darkest = rgb("#191919")
#let clr-dark = rgb("#5c5c5c")
#let clr-light = rgb("#D9D9D9")
#let clr-lightest = rgb("#E6E6E6")
#let clr-bg-light = rgb("#FCFCFC")
#let clr-bg-dark = rgb("#E7E7E7")
#let clr-codebg = rgb("#fdfde799")
#let clr-lightest-tr = rgb("#e6e6e699")
#let clr-pink = rgb("#E5007F")
#let clr-green = rgb("#00FF9A")
#let clr-bar = rgb("#777777")
#let clr-primary = rgb("#FFFA01")             // characteristic yellow accent
#let clr-link = rgb("#1a6fbf")             // hyperlink blue

// ── Internal helpers ─────────────────────────────────────────────────────────

// Best-effort flattening of content into a plain string, for use with
// `set document(..)` (PDF metadata accepts strings only).
// Footnotes are deliberately dropped so that author fields carrying affiliation
// footnotes still produce clean metadata.
#let _to-string(it) = {
  if it == none {
    ""
  } else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.func() == text {
    it.text
  } else if it.func() == footnote {
    ""
  } else if it.func() == smartquote {
    "\""
  } else if it.func() == linebreak or it.func() == parbreak {
    " "
  } else if it.has("children") {
    it.children.map(_to-string).join("")
  } else if it.has("body") {
    _to-string(it.body)
  } else {
    " "
  }
}

// Collapses runs of whitespace left behind by dropped elements (footnotes,
// linebreaks) and tidies up the resulting stray space before punctuation.
#let _clean-string(it) = _to-string(it)
.replace(regex("\\s+"), " ")
.replace(regex(" +([,;.])"), m => m.captures.at(0))
.trim()

// Splits a comma-separated author field into the list form that
// `set document(author: ..)` expects.
#let _author-list(author) = {
  if author == none { return () }
  _clean-string(author).split(",").map(a => a.trim()).filter(a => a != "")
}

// Renders the number of a heading, plus trailing gap. Returns `none` when the
// heading is unnumbered, so it can be added to `it.body` unconditionally.
#let _heading-number(it) = {
  if it.numbering == none { return none }
  [#counter(heading).display(it.numbering)#h(.6em)]
}

// Localized default title for the table of contents.
#let _outline-title(lang) = {
  if lang == "zh" { [目录 / Contents] } else if lang == "ja" { [目次 / Contents] } else { [Contents] }
}

// Renders the current page number using whatever numbering pattern is active,
// so that `page-numbering` (roman, "1 / 1", …) is honoured instead of hardcoded.
#let _page-label() = context {
  let pattern = here().page-numbering()
  if pattern != none { counter(page).display(pattern) }
}

// Shared decorative background, used by both the cover and the body pages.
#let _page-bg = place(bottom, image("contour_map.svg", width: 100%))

// ── UI Components ────────────────────────────────────────────────────────────

// The characteristic multi-color accent bar that adapts to content height.
// The bar is inset from the top of the container and spans 80% of its height,
// split pink / green / yellow. Fractions are named so the proportions can be
// tuned without decoding magic numbers.
#let _bar-top-inset = 0.1
#let _bar-pink-frac = 0.2
#let _bar-green-frac = 0.2
#let _bar-main-frac = 0.4

#let _accent-bar(
  bar-width: .5em,
  container-height: 4em,
) = {
  let bar = stack(
    dir: ttb,
    spacing: 0pt,
    rect(width: bar-width, height: container-height * _bar-pink-frac, fill: clr-pink),
    rect(width: bar-width, height: container-height * _bar-green-frac, fill: clr-green),
    rect(width: bar-width, height: container-height * _bar-main-frac, fill: clr-primary),
  )

  stack(
    dir: ttb,
    v(container-height * _bar-top-inset),
    bar,
  )
}

// Top page margin, shared with `set page(..)` below and with the running
// header's "is this heading at the top of the page" heuristic.
#let _page-margin-top = 6em

// ── Page header ───────────────────────────────────────────────────────────────
#let _doc-header(doc-title) = context {
  let current-page = here().page()

  // NOTE: page numbers alone aren't enough here. The header is laid out
  // *above* the page body, so `here()` inside the header precedes all of this
  // page's own content in document order — `.before(here())` would therefore
  // always report the *previous* section, even on a page that starts with a
  // brand-new heading. Comparing `location().page() <= current-page` fixes
  // that case, but overcorrects when `heading-pagebreak` is disabled and more
  // than one level-1 heading lands on the same page: it then picks the last
  // heading on the page, even if that heading only appears partway down and
  // the page actually opens with the *previous* section's tail content.
  //
  // So: only trust a heading that starts on the current page if it is the
  // first one on that page *and* sits within a small margin of the page's top
  // edge (i.e. nothing else was rendered above it there). Otherwise fall back
  // to the last heading carried over from an earlier page. The margin check
  // is a heuristic — a very short orphan line left over from the previous
  // section could in rare cases still push a heading past the threshold — but
  // it resolves the common case of two headings sharing a page.
  // `.position().y` is already resolved to an absolute length, whereas the
  // margin/threshold below is expressed in `em` — they must both be resolved
  // to the same (absolute) unit before they can be compared.
  let top-threshold = (_page-margin-top + 3em).to-absolute()
  let headings = query(heading.where(level: 1))
  let carried = headings.filter(h => h.location().page() < current-page).at(-1, default: none)
  let on-this-page = headings.filter(h => h.location().page() == current-page)
  let starts-page = (
    on-this-page.len() > 0
      and on-this-page.first().location().position().y < top-threshold
  )
  let section = if starts-page { on-this-page.first() } else { carried }
  let section = if section == none { [] } else { section.body }

  block(
    width: 100%,
    fill: clr-bar,
    inset: (x: 1.2em, y: .6em),
    stack(
      dir: ltr,
      spacing: 1em,
      text(fill: clr-primary, weight: "bold", size: .85em, doc-title),
      h(1fr),
      text(fill: clr-light, weight: "medium", size: .85em, section),
    ),
  )
}

// ── Page footer ───────────────────────────────────────────────────────────────
// Tri-color accent stripe + dark bar with custom text (left) and page number
// (right).
#let _doc-footer(doc-footer) = context {
  stack(
    dir: ttb,
    stack(
      dir: ltr,
      line(stroke: .28em + clr-pink, length: 2em),
      line(stroke: .28em + clr-green, length: 2em),
      line(stroke: .28em + clr-primary, length: 100% - 4em),
    ),
    block(
      width: 100%,
      fill: clr-bar,
      inset: (x: 1.2em, y: .45em),
      grid(
        columns: (auto, 1fr, auto),
        align: horizon,
        text(fill: clr-light, weight: "bold", size: .78em, doc-footer),
        [],
        box(
          fill: clr-dark,
          inset: (x: .6em, y: .3em),
          text(fill: clr-primary, weight: "bold", size: .78em, _page-label()),
        ),
      ),
    ),
  )
}

// ── Cover page ────────────────────────────────────────────────────────────────
#let _cover-page(
  title: [],
  subtitle: none,
  author: none,
  date: none,
  institution: none,
  paper: "a4",
) = {
  page(
    paper: paper,
    margin: (x: 4em, top: 4em, bottom: 4em),
    header: none,
    footer: none,
    fill: gradient.linear(
      angle: 135deg,
      clr-bg-light,
      clr-bg-dark,
    ),
    background: _page-bg,
  )[
    #set footnote.entry(
      separator: line(length: 30%, stroke: .5pt + clr-dark),
    )

    #v(1fr)

    #block(width: 100%)[
      // Rows are collected first and empty ones dropped, so that `stack`'s
      // `spacing` applies only between rows that actually render. Interleaving
      // bare `v()` spacers with `none` branches would otherwise make the gaps
      // depend on which optional fields happen to be set.
      #let meta-rows = (
        if author != none {
          text(size: 1.0em, fill: clr-darkest, weight: "bold", author)
        },
        if date != none {
          text(size: .95em, fill: clr-dark, date)
        },
        if institution != none {
          text(size: .95em, fill: clr-dark, institution)
        },
      ).filter(r => r != none)

      // Explicit gaps per row keep the rhythm stable no matter which optional
      // fields are present: subtitle sits close under the title, while the
      // metadata block is separated by a wider break.
      #let title-rows = (
        (gap: 0pt, body: text(size: 2.5em, weight: "black", fill: clr-darkest, title)),
        if subtitle != none {
          (gap: 1.2em, body: text(size: 1.5em, fill: clr-dark, subtitle))
        },
        if meta-rows.len() > 0 {
          (gap: 1.4em, body: stack(dir: ttb, spacing: .6em, ..meta-rows))
        },
      ).filter(r => r != none)

      #let title-stack = stack(
        dir: ttb,
        ..title-rows.map(r => stack(dir: ttb, v(r.gap), r.body)),
      )

      #context {
        let content-height = measure(title-stack).height

        grid(
          columns: (auto, 1fr),
          column-gutter: 1.2em,
          _accent-bar(bar-width: .6em, container-height: content-height), title-stack,
        )
      }
    ]

    // Larger spring at the bottom shifts the visual centre of gravity
    // slightly upward, matching the original endfield slide theme.
    #v(1.2fr)
  ]
}

// ── Main document template ────────────────────────────────────────────────────
// Usage:
//   #show: endfield-doc.with(
//     title:       [My Document],
//     subtitle:    [A Subtitle],
//     author:      [Your Name],
//     date:        datetime.today().display("[year]-[month]-[day]"),
//     institution: [Your Org],
//     doc-footer:  [Your Org],   // left side of footer bar
//     lang:        "zh",
//     region:      "cn",
//     font-cjk:    ("HarmonyOS Sans SC",),
//     font-latin:  ("HarmonyOS Sans",),
//     font-code:   ("JetBrains Mono",),
//     cover:       true,           // render the cover page
//     outline:     true,           // render the table of contents
//   )
#let endfield-doc(
  title: [Document Title],
  subtitle: none,
  author: none,
  date: none,
  institution: none,
  paper: "a4",
  lang: "zh",
  region: "cn",
  font-cjk: ("HarmonyOS Sans SC", "HarmonyOS Sans"),
  font-latin: ("HarmonyOS Sans",),
  font-code: ("JetBrains Mono",),
  font-emoji: ("Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", "Noto Emoji"),
  font-size: 11pt,
  doc-footer: text("ENDFIELD", weight: "bold") + text(" INDUSTRIES", size: 0.8em),
  cover: true,
  outline: true,
  outline-title: auto,
  heading-pagebreak: true,
  page-numbering: "1",
  equation-numbering: none,
  body,
) = {
  // emoji fonts are excluded here; they are routed via a show rule below
  // to avoid adding them to the lookup chain for every non-emoji character.
  let main-font-stack = font-cjk + font-latin
  let code-font-stack = font-code + main-font-stack

  // `outline` is shadowed by the boolean parameter above, so keep a handle on
  // the built-in element function to call further down.
  let outline-fn = std.outline

  // PDF metadata, so viewers show a real title/author instead of the filename.
  set document(
    title: _clean-string(title),
    author: _author-list(author),
  )

  // CJK first: prevents Latin fonts that bundle CJK glyphs from overriding
  // the intended CJK typeface.
  set text(
    font: main-font-stack,
    size: font-size,
    fill: clr-darkest,
    lang: lang,
    region: region,
  )

  // Force emoji Unicode ranges to always use the emoji font, regardless of
  // what the CJK or Latin fonts might provide for those code points.
  // Ranges covered:
  //   U+1F000–U+1FAFF  — mahjong/cards/enclosed glyphs through most emoji
  //                      (faces, objects, symbols) incl. U+1F1E6–1F1FF flags
  //   U+2300–U+23FF    — miscellaneous technical (clocks, arrows …)
  //   U+2600–U+27BF    — miscellaneous symbols & dingbats
  //   U+2B00–U+2BFF    — arrows & geometric shapes (⬛ ⭐ …)
  //   U+FE0F / U+200D  — variation selector-16 and ZWJ; these must be part of
  //                      the match so that composite sequences (👨‍👩‍👧, ❤️)
  //                      stay in one run and are not split across fonts.
  show regex(
    "[\u{1F000}-\u{1FAFF}\u{2300}-\u{23FF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]+",
  ): set text(font: font-emoji + main-font-stack)

  // ── Link styles ─────────────────────────────────────────────────────────────
  show link: it => text(fill: clr-link, it)

  // ── Cover page ──────────────────────────────────────────────────────────────
  if cover {
    _cover-page(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
      paper: paper,
    )
  }

  // ── Document-wide page settings ─────────────────────────────────────────────
  set page(
    paper: paper,
    // bottom margin must be large enough for: footer height (~2em) + footnotes.
    // footer-descent is intentionally left at default so Typst can correctly
    // reserve space for footnotes above the footer.
    margin: (top: _page-margin-top, bottom: 6em, x: 3em),
    header: _doc-header(title),
    footer: _doc-footer(doc-footer),
    fill: gradient.linear(
      angle: 90deg,
      clr-bg-light,
      clr-bg-dark,
    ),
    background: _page-bg,
    // Drives the footer page label; restarts numbering after the cover.
    numbering: page-numbering,
  )
  counter(page).update(1)

  set par(justify: true, leading: .75em, spacing: 1.2em)
  set math.equation(numbering: equation-numbering)

  // Emphasis needs care with a CJK-first stack: "HarmonyOS Sans SC" also covers
  // Latin but ships no italic face, so Latin `_emph_` would silently render
  // upright. Inside emphasis the Latin face is therefore preferred, which
  // restores real italics. CJK faces have no italic at all and a synthesised
  // slant looks wrong for Han glyphs, so CJK runs are emphasised by weight.
  show emph: it => {
    set text(font: font-latin + font-cjk)
    show regex("[\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}]+"): c => text(
      style: "normal",
      weight: "bold",
      c,
    )
    it
  }

  // ── Code block styles ───────────────────────────────────────────────────────
  show raw: it => {
    if it.block {
      stack(
        dir: ttb,
        // Language label tab with accent dots (only shown when lang is set)
        if it.has("lang") {
          align(left, block(
            fill: clr-primary,
            inset: (x: .6em, y: .3em),
            radius: (top: 2pt),
            text(fill: clr-darkest, size: .7em, weight: "black", upper(it.lang)),
          ))
        },
        block(
          width: 100%,
          fill: clr-codebg,
          inset: (x: 1.2em, y: 1em),
          radius: (top: 2pt, bottom: 2pt),
          stroke: (left: .35em + clr-primary),
          {
            set text(font: code-font-stack, size: 1em, fill: clr-darkest)
            it
          },
        ),
      )
    } else {
      // Inline code
      box(
        fill: clr-lightest-tr,
        inset: (x: .3em, y: 0pt),
        outset: (y: .3em),
        radius: 2pt,
        stroke: 0.5pt + clr-lightest-tr,
        {
          show regex("[\x20-\x7E]+"): set text(font: code-font-stack)
          it
        },
      )
    }
  }

  // ── Heading styles ──────────────────────────────────────────────────────────
  set heading(numbering: "1.1")

  // Level 1: primary-color accent bar + rule, starts a new page
  show heading.where(level: 1): it => {
    if heading-pagebreak { pagebreak(weak: true) }
    v(1.0em)
    grid(
      columns: (auto, 1fr),
      column-gutter: .7em,
      align: horizon,
      rect(width: .38em, height: 1.2em, fill: clr-primary),
      text(size: 1.3em, weight: "black", fill: clr-darkest, _heading-number(it) + it.body),
    )
    v(.2em)
    line(stroke: .12em + clr-light, length: 100%)
    v(.2em)
  }

  // Level 2: smaller accent bar
  show heading.where(level: 2): it => {
    v(.2em)
    grid(
      columns: (auto, 1fr),
      column-gutter: .7em,
      align: horizon,
      rect(width: .3em, height: 1em, fill: clr-primary),
      text(size: 1.15em, weight: "bold", fill: clr-darkest, _heading-number(it) + it.body),
    )
    v(.2em)
  }

  // Level 3: plain text, muted color
  show heading.where(level: 3): it => {
    v(.2em)
    text(size: 1.1em, weight: "bold", fill: clr-dark, _heading-number(it) + it.body)
    v(.1em)
  }

  // Level 4 and deeper: keep the family consistent instead of falling back to
  // Typst's defaults, which would jump to a different size and colour.
  show heading.where(level: 4): it => {
    v(.1em)
    text(size: 1.0em, weight: "bold", fill: clr-dark, _heading-number(it) + it.body)
    v(.1em)
  }

  // ── Lists ───────────────────────────────────────────────────────────────────
  // Accent-coloured markers tie bullets into the yellow/black visual language.
  // set list(marker: (
  //   text(fill: clr-primary, weight: "black", sym.square.filled),
  //   text(fill: clr-bar, weight: "black", sym.square.filled),
  //   text(fill: clr-light, weight: "black", sym.square.filled),
  // ))
  // set enum(numbering: (..n) => text(
  //   fill: clr-darkest, weight: "bold", n.pos().map(str).join(".") + ".",
  // ))

  // ── Tables ──────────────────────────────────────────────────────────────────
  // Header row in the accent colour, hairline separators in the neutral grey.
  set table(
    stroke: (x, y) => (
      top: if y == 0 { .12em + clr-darkest } else { .04em + clr-light },
      bottom: .12em + clr-darkest,
    ),
    inset: (x: .7em, y: .5em),
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  // ── Figures ─────────────────────────────────────────────────────────────────
  // Built by concatenation rather than markup so no stray spaces appear around
  // the separator.
  show figure.caption: it => text(size: .85em, fill: clr-dark, {
    if it.numbering != none {
      text(weight: "bold", fill: clr-darkest, {
        it.supplement
        [ ]
        context it.counter.display(it.numbering)
      })
      it.separator
    }
    it.body
  })

  // ── Block quotes ────────────────────────────────────────────────────────────
  show quote.where(block: true): it => block(
    width: 100%,
    above: 1.2em,
    below: 1.2em,
    inset: (x: 1.2em, y: .6em),
    radius: (top: 2pt, bottom: 2pt),
    stroke: (left: .3em + clr-light),
    fill: clr-lightest-tr,
    {
      it.body
      // `attribution` must be rendered explicitly, otherwise overriding the
      // quote layout would silently discard it.
      if it.attribution != none {
        v(.4em)
        align(right, text(size: .9em, fill: clr-dark, [— #it.attribution]))
      }
    },
  )

  // ── Table of contents ───────────────────────────────────────────────────────
  if outline {
    outline-fn(
      title: if outline-title == auto { _outline-title(lang) } else { outline-title },
      indent: auto,
    )
    pagebreak(weak: true)
  }

  body
}
