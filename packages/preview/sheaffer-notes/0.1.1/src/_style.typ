/// Styles for paged documents

#import "_constants.typ": *
#import "@preview/wrap-it:0.1.1": wrap-content

/// Math element style
#let _style-math(body, fonts: FONTS) = {
  show math.equation: it => {
    set text(font: fonts.at("math"))
    it
  }

  show math.equation.where(block: true): it => {
    set block(breakable: true)
    it
  }

  show math.qed: sym.square.stroked.medium

  // Number every display equation. The counter keeps running through the
  // whole document, so formulas are numbered (1), (2), (3) and so on.
  // A formula can still opt out with `math.equation(numbering: none)`.
  set math.equation(numbering: "(1)")

  body
}

#let conditions(body) = {
  set enum(indent: INDENT / 2, numbering: "(ia*)", full: true)
  body
}

/// Place a compact note beside the paragraph that follows it.
///
/// The note takes the smaller of its natural text width and `width`, which
/// defaults to 60% of the line. `width` may be a ratio or an absolute length.
/// - body (content): Contents of the note.
/// - width (ratio | length): Allowed share of the line.
/// - color (color): Note text color.
/// - size (length): Size of the note text.
/// - inset (relative | dictionary): Padding around the note text.
/// - footnote-step (bool): Internal; `wrapnote` sets it to number the note
///   with the footnote counter.
/// -> content
#let wrappar(
  body,
  width: 60%,
  color: ACCENT,
  size: 0.8em,
  inset: (top: 0pt, right: 0.25em, bottom: 0.25em, left: 0.25em),
  footnote-step: false,
) = metadata((
  tag: "__sheaffer_wrappar",
  content: body,
  width: width,
  color: color,
  size: size,
  inset: inset,
  footnote-step: footnote-step,
))

/// A note in the outer margin, numbered with the footnote counter.
///
/// Behaves like `wrappar`: the note sits beside the paragraph that follows it
/// and takes the smaller of its natural width and `width`. The whole note is
/// `BLUE`. A superscript number appears in the text right where the note is
/// declared (leading the wrapped paragraph when the note stands before it)
/// and again at the head of the margin box; both come from the footnote
/// counter. The note lives only in the margin — no entry is added to
/// the footnote list at the bottom of the page — but its numbers keep running
/// together with real footnotes and reset with them at the start of a chapter.
/// The number is taken at the note's position in the text, so it follows the
/// source order regardless of where the margin box lands on the page. Label
/// the note and reference it with `#footnote(<label>)` to repeat its number
/// in `BLUE`.
///
/// An earlier `#wrapnotemark` in the flow claims the number: the note then
/// reuses it instead of taking the next counter value.
/// - body (content): Contents of the note.
/// - width (ratio | length): Allowed share of the line.
/// - size (length): Size of the note text.
/// - inset (relative | dictionary): Padding around the note text.
/// -> content
#let wrapnote(
  body,
  width: 60%,
  size: 0.8em,
  inset: (top: 0pt, right: 0.25em, bottom: 0.25em, left: 0.25em),
) = wrappar(
  body,
  width: width,
  color: BLUE,
  size: size,
  inset: inset,
  footnote-step: true,
)

/// A superscript footnote-counter marker in the text, with no margin box.
///
/// Takes the next footnote-counter value and draws it as a blue superscript
/// at the call site, like the number `wrapnote` would print. The next
/// `#wrapnote[...]` that follows in the flow reuses this number instead of
/// stepping the counter again, so the pair stays on one number.
///
/// The invisible claim marker travels with the visible superscript, so
/// `_wrap-subsections` can pair the following note with it.
#let wrapnotemark() = {
  counter(footnote).step()
  [#metadata((tag: "__sheaffer_wrapnote_claim"))#context(text(fill: BLUE, super(counter(footnote).display())))]
}

/// Inline enumeration declared with Typst's `+` syntax.
#let inline-enum(
  body,
  numbering-style: "(a)",
  separator: [;],
  conjunction: [and],
) = {
  let children = body.children
  let has-trailing-space = (
    children.len() > 0 and children.at(children.len() - 1).func() == space
  )
  let inline-body = if has-trailing-space {
    children.slice(0, children.len() - 1).join()
  } else {
    body
  }

  show enum: it => {
    let items = it.children
    for (index, item) in items.enumerate() {
      if index > 0 {
        if index == items.len() - 1 {
          separator
          [ ]
          conjunction
        } else {
          separator
        }
        [ ]
      }
      numbering(numbering-style, index + 1)
      [ ]
      item.body
    }
  }

  inline-body
}

/// Paragraph & body text style
#let _style-body(body, fonts: FONTS) = {
  set text(font: fonts.at("body"))
  set par(
    first-line-indent: (amount: 1.4em, all: false),
    justify: true,
    spacing: SPACING,
    leading: LEADING,
  )

  // Lists
  set terms(hanging-indent: INDENT)
  set enum(indent: INDENT / 2, numbering: "1.a.i.", full: true)
  set list(indent: INDENT, marker: ([#sym.bullet.stroked], [--]))

  // make non-tight spacing work (list blocks get double leading around them)
  let non-tight-style = it => {
    set par(spacing: LEADING * 2)
    v(LEADING * 2, weak: true)
    it
    v(LEADING * 2, weak: true)
  }

  show enum.where(tight: false): non-tight-style
  show list.where(tight: false): non-tight-style
  show terms.where(tight: false): non-tight-style

  let f(it) = {
    // Preserve list indentation so nested lists remain visibly nested.
    set block(breakable: true)
    v(weak: true, LEADING)
    it
    v(weak: true, LEADING * 2)
  }

  show list: f
  show enum: f
  show terms: f

  body
}

/// Syntax highlighting theme derived from the package palette (`BLUE`,
/// `ORANGE`, `CYAN`, `VERMILION`, `GRAY` from `_constants.typ`), built as a
/// tmTheme for `raw(theme: ..)`.
#let _code-theme = {
  let rule(scope, color) = (
    "<dict>\n"
      + "  <key>scope</key>\n  <string>"
      + scope
      + "</string>\n"
      + "  <key>settings</key>\n  <dict>\n"
      + "    <key>foreground</key>\n    <string>"
      + color.to-hex()
      + "</string>\n"
      + "  </dict>\n</dict>\n"
  )

  (
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      + "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
      + "<plist version=\"1.0\">\n<dict>\n"
      + "  <key>name</key>\n  <string>Sheaffer palette</string>\n"
      + "  <key>settings</key>\n  <array>\n"
      + "    <dict>\n      <key>settings</key>\n      <dict>\n"
      + "        <key>background</key>\n        <string>"
      + GRAY.to-hex()
      + "</string>\n"
      + "        <key>foreground</key>\n        <string>#222222</string>\n"
      + "      </dict>\n    </dict>\n"
      + rule("keyword, storage", BLUE)
      + rule("string", VERMILION)
      + rule("entity.name.function, support.function, meta.function-call", ORANGE)
      + rule("constant.numeric, constant.language, constant.character", CYAN.darken(25%))
      + rule("comment", GRAY.darken(45%))
      + "  </array>\n</dict>\n</plist>\n"
  )
}

/// Code block / raw text style
#let _style-code(body, fonts: FONTS) = {
  set raw(theme: bytes(_code-theme))
  show raw: set block(
    fill: GRAY,
    inset: (left: 1em, top: 1em, bottom: 1em),
    above: 1em,
    below: 1em,
    width: 100%,
    radius: 4pt,
  )
  show raw: set text(font: fonts.at("code"))
  body
}

/// Section heading style
#let _style-heading(body, fonts: FONTS) = {
  // Keep the built-in heading element for numbering, references, and outlines,
  // but replace its block layout with inline content.
  let runin-heading(it) = context {
    let number = if it.numbering != none and it.outlined {
      emph(text(size: 0.8em, counter(heading).display(it.numbering))) + [.] + h(0.5em)
    } else {
      []
    }
    number + emph(it.body) + [.] + h(0.35em)
  }

  // Generic section header function
  let heading-func = (body-fmt: emph, use-line: false, it) => {
    set text(weight: "regular")
    block(
      sticky: true,
      {
        if it.numbering != none and it.outlined {context {
          emph(text(size: 0.8em, counter(heading).display(it.numbering)))
          "."
          h(0.5em)
        }}
        body-fmt(it.body)
        if use-line {
          show: box.with(width: 1fr)
          show: align.with(right)
          line(
            length: 100% - 0.8em,
            start: (0%, -0.225em),
            stroke: (
              cap: "round",
              thickness: 0.75pt,
            ),
          )
        }
      },
    )
  }

  show heading.where(level: 1): set heading(supplement: "Chapter")
  // Chapter
  show heading.where(level: 1): it => {
    let is-outline-title = it.numbering == none and not it.outlined
    if not is-outline-title {
      pagebreak(weak: true, to: "odd")
    }
    set par(first-line-indent: 0.0em, justify: false)
    set text(hyphenate: false)
    block(
      inset: (left: -0.1em, top: 3cm),
      height: auto,
      {
        set text(size: 1.75em)
        (emph(it.body))
      }
        + if it.outlined {
          emph[
            #v(0.9em, weak: true)
            #if it.numbering != none and it.outlined {context [
              #h(0.125em)#text([#smallcaps[Chapter] #counter(heading).display(it.numbering)])
            ]}
          ]
        },
    )
    v(LEADING * 4, weak: true)
  }

  // Section
  show heading.where(level: 2): it => {
    set text(size: 1.2em)
    v(2em, weak: true)
    heading-func(use-line: true, it)
    v(0.75em, weak: true)
  }

  // Sub-section
  show heading.where(level: 3): it => {
    set text(size: 1.1em)
    v(1em, weak: true)
    heading-func(it)
  }

  // Sub-sub-section
  show heading.where(level: 4): it => {
    set text(size: 1.05em)
    runin-heading(it)
  }

  // Styles for all headings
  show heading: it => {
    set text(
      font: fonts.at("heading"),
      hyphenate: false,
      weight: "regular",
    )
    it
  }
  set heading(numbering: "1.1.1a")

  body
}

/// Hyperlink and internal reference style
#let _style-link(body, fonts: FONTS) = {
  show link: it => {
    if type(it.dest) != str {
      // local link
      set text(fill: VERMILION)
      it
    } else if (it.body == [#it.dest]) {
      // URL (no custom text)
      set text(fill: BLUE)
      set text(font: fonts.at("code"), size: 0.8em)
      box(it)
    } else {
      // URL (custom text)
      set text(fill: BLUE)
      box(it)
    }
  }

  body
}

#let _footer = context {
  let current-chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
  let is-chapter-heading = current-chapter != none and current-chapter.location().page() == here().page()

  if not is-chapter-heading {
    return
  }

  let page = counter(page).display()
  set text(size: 0.8em)
  place(center + horizon, text(page))
}

#let _header = context {
  let page_num = counter(page).get().at(0)
  let title-page = query(label("__sheaffer_title_page")).at(0, default: none)
  if title-page != none and title-page.location().page() == here().page() {
    return
  }

  let sec-right-after = query(selector(heading.where(level: 2)).after(here())).at(0, default: none)
  let sec-right-before = query(selector(heading.where(level: 2)).before(here())).at(-1, default: none)

  let current-chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
  let chapter-right-after = query(selector(heading.where(level: 1)).after(here())).at(0, default: none)

  let current-sec = if sec-right-after != none and sec-right-after.location().page() == here().page() {
    sec-right-after
  } else {
    sec-right-before
  }

  let is-chapter-heading = chapter-right-after != none and chapter-right-after.location().page() == here().page()

  if is-chapter-heading {
    return
  }

  let page = counter(page).display()
  let chap = if current-chapter != none {
    smallcaps(current-chapter.body)
  }
  let chap_num = if current-chapter != none and current-chapter.numbering != none [
    ch. #numbering(current-chapter.numbering, ..counter(heading).at(current-chapter.location()))
  ]

  let sec_num = if current-sec != none and current-sec.numbering != none [
    sec. #numbering(current-sec.numbering, ..counter(heading).at(current-sec.location()))
  ]

  set text(size: 0.8em)

  if calc.even(page_num) {
    place(left + horizon, dy: HEADER-DY, text(page))
    place(center + horizon, dy: HEADER-DY, smallcaps(document.title))
    if not is-chapter-heading {
      place(right + horizon, dy: HEADER-DY, smallcaps(chap_num))
    }
  } else {
    if not is-chapter-heading {
      place(left + horizon, dy: HEADER-DY, smallcaps(sec_num))
      place(center + horizon, dy: HEADER-DY, chap)
    }
    place(right + horizon, dy: HEADER-DY, text(page))
  }
}

/// Page header and footer style
#let _style-header-footer(it) = {
  set page(footer: _footer, header: _header)
  it
}

/// Check if an element is a theorem environment.
#let _is-thm-block(it) = {
  let marker = if (
    it != none
      and it.has("body")
      and type(it.body) == content
      and it.body.has("children")
      and it.body.children.len() > 0
  ) {
    it.body.children.first()
  } else {
    none
  }

  return (
    marker != none
      and marker.func() == metadata
      and "tag" in marker.value
      and marker.value.at("tag") == "__sheaffer_thmenv"
  )
}

#let _thm-ref-supplements = (
  "Theorem": "Thm.",
  "Proposition": "Prop.",
  "Lemma": "Lem.",
  "Corollary": "Cor.",
  "Definition": "Def.",
  "Proof": "Proof.",
  "Example": "Ex.",
  "Solution": "Sol.",
  "Remark": "Rem.",
  "Observation": "Obs.",
)

/// Return the type label and canonical label used for a reference target.
#let _reference-info(element, target-label) = {
  if element == none {
    return none
  }

  if _is-thm-block(element) {
    let marker = element.body.children.first()
    let kind = marker.value.at("kind", default: "")
    let dest-meta = query(selector(<__sheaffer_thm_figure_meta>).after(element.location())).at(0, default: none)
    if dest-meta == none {
      return none
    }
    return (
      group: "theorem:" + kind,
      supplement: _thm-ref-supplements.at(kind, default: kind),
      label: dest-meta.value.label,
      parenthesize-number: false,
    )
  }

  if element.func() == heading {
    let level = element.level
    let is-chapter = level == 1
    return (
      group: if is-chapter { "chapter" } else { "section" },
      supplement: if is-chapter { "Ch." } else { "Sec." },
      label: target-label,
      parenthesize-number: false,
    )
  }

  if element.func() == math.equation {
    return (
      group: "equation",
      supplement: "Eq.",
      label: target-label,
      parenthesize-number: false,
    )
  }

  if element.func() == figure {
    let is-table = element.kind == table
    return (
      group: if is-table { "table" } else { "figure" },
      supplement: if is-table { "Tab." } else { "Fig." },
      label: target-label,
      parenthesize-number: false,
    )
  }

  if element.func() == footnote {
    return (
      group: "footnote",
      supplement: "Footnote",
      label: target-label,
      parenthesize-number: false,
    )
  }

  none
}

#let _reference-number(target, parenthesize: false) = {
  let number = ref(target, supplement: none)
  if parenthesize {
    [(#number)]
  } else {
    number
  }
}

/// Group labeled references by type, e.g. tables followed by figures.
#let refs(..targets) = context {
  let groups = ()
  let current = none

  for target-label in targets.pos() {
    let target = query(target-label).at(0, default: none)
    let info = _reference-info(target, target-label)
    if info == none {
      continue
    }

    if current == none or current.group != info.group {
      if current != none {
        groups.push(current)
      }
      current = (
        group: info.group,
        supplement: info.supplement,
        parenthesize-number: info.at("parenthesize-number", default: false),
        labels: (info.label,),
      )
    } else {
      current.labels.push(info.label)
    }
  }

  if current != none {
    groups.push(current)
  }
  if groups.len() == 0 {
    return []
  }

  let output = ()
  for (index, group) in groups.enumerate() {
    if index > 0 {
      output.push(if index == groups.len() - 1 { [ and ] } else { [, ] })
    }
    let supplement = if index == 0 { group.supplement } else { lower(group.supplement) }
    let numbers = group.labels.map(target => text(fill: VERMILION)[#_reference-number(
      target,
      parenthesize: group.at("parenthesize-number", default: false),
    )]).join([, ])
    output.push([#supplement #numbers])
  }

  [(see #output.join())]
}

/// Figures style
#let _style-figures(body) = {
  show figure: it => {
    v(LEADING * 2)
    it
    v(LEADING * 2)
  }

  show figure.caption: it => context {
    set text(size: 0.9em)
    smallcaps[#it.supplement #it.counter.display()#it.separator]
    it.body
  }

  show figure.where(kind: table): it => {
    set table(
      align: left,
      stroke: (_, y) => (
        top: if y <= 1 { 1pt } else { 0pt },
        bottom: 1pt,
      ),
    )
    show table.cell.where(y: 0): it => {
      show text: emph
      it
    }
    set figure.caption(position: top)
    set figure(gap: 1em)
    it
  }

  body
}

/// Handle references to theorem environments.
///
/// Implementation trick from typst-marginalia v0.3.0.
/// https://github.com/nleanba/typst-marginalia/blob/382e640c38e7229d4303ba09c773b5d04a898f03/lib.typ
///
/// Details:
/// - Theorems are identified with a special `metadata()` tag at the beginning.
/// - Theorems know their index by counting how many theorems were before them.
/// - This index is used to uniquely label the `figure()` within the theorem.
/// - The labelling step is within an opaque `context` block. To expose the
///   label to outsiders, we use a `metadata` element.
/// - Whenever a `ref()` occurs, and its target contains the special metadata
///   tag, intercept the reference, and make it point to the `figure()` instead
///   of the `#theorem[]` sequence.
#let _style-ref(body) = {
  show ref: it => context {
    // Raw numbered references are used inside the formatter and must pass through.
    if it.supplement == none {
      return it
    }

    if it.form == "page" {
      if it.element == none {
        return it
      }
      let location = it.element.location()
      let page-number = counter(page).at(location).first()
      return [(see p. #link(location, text(fill: VERMILION)[#page-number]))]
    }

    let info = _reference-info(it.element, it.target)
    if info == none {
      return it
    }

    [(see #info.supplement #text(fill: VERMILION)[#_reference-number(
      info.label,
      parenthesize: info.at("parenthesize-number", default: false),
    )])]
  }

  body
}

#let _is-wrappar-marker(it) = {
  if it.func() != metadata {
    return false
  }
  let value = it.value
  return (
    type(value) == dictionary
      and "tag" in value
      and value.at("tag") == "__sheaffer_wrappar"
  )
}

/// The note's inset with the page-edge side removed: on odd pages the note
/// sits on the right, on even pages on the left.
#let _wrappar-inset(inset, outside-right) = {
  let sides = if type(inset) == dictionary {
    inset
  } else {
    (top: inset, right: inset, bottom: inset, left: inset)
  }
  let x = sides.at("x", default: 0pt)
  let y = sides.at("y", default: 0pt)
  (
    top: sides.at("top", default: y),
    right: if outside-right { 0pt } else { sides.at("right", default: x) },
    bottom: sides.at("bottom", default: y),
    left: if outside-right { sides.at("left", default: x) } else { 0pt },
  )
}

/// The note text: number prefix for `footnote-step` notes, then the body.
///
/// `note-number` is the resolved footnote-counter value for the note, so the
/// prefix does not depend on where the margin box ends up on the page.
#let _wrappar-note-content(marker, note-number: none) = {
  set par(justify: false)
  let value = marker.value
  let prefix = if note-number != none { super(note-number) } else { [] }
  text(
    fill: value.at("color"),
    size: value.at("size"),
    [#prefix#value.at("content")],
  )
}

#let _wrappar-box(marker, width: 100%, outside-right: true, note-number: none) = box(
  width: width,
  inset: _wrappar-inset(marker.value.at("inset"), outside-right),
  _wrappar-note-content(marker, note-number: note-number),
)

/// The note as it looks when it is not constrained by the column width.
#let _wrappar-natural-width(marker, outside-right: true, note-number: none) = measure(
  box(
    inset: _wrappar-inset(marker.value.at("inset"), outside-right),
    _wrappar-note-content(marker, note-number: note-number),
  ),
).width

/// The width the note occupies: the smaller of its natural width and the
/// allowed share of the line.
#let _wrappar-width(marker, available, outside-right: true, note-number: none) = {
  let limit = marker.value.at("width")
  let max-width = if type(limit) == ratio { limit * available } else { limit }
  calc.min(
    _wrappar-natural-width(marker, outside-right: outside-right, note-number: note-number),
    max-width,
  )
}

#let _wrappar-with-paragraph(marker, paragraph, note-number: none) = layout(size => context {
  let page-number = counter(page).get().at(0)
  let outside-right = not calc.even(page-number)
  let gutter = 0.75em

  let note-width = _wrappar-width(
    marker,
    size.width,
    outside-right: outside-right,
    note-number: note-number,
  )
  let paragraph-width = size.width - gutter - note-width

  wrap-content(
    _wrappar-box(marker, outside-right: outside-right, note-number: note-number),
    paragraph,
    align: if outside-right { top + right } else { top + left },
    columns: if outside-right {
      (paragraph-width, note-width)
    } else {
      (note-width, paragraph-width)
    },
    column-gutter: gutter,
    size: size,
  )
})

/// A note that is not followed by a paragraph stands on its own, at the
/// outside edge of the page.
#let _wrappar-alone(marker, note-number: none) = layout(size => context {
  let page-number = counter(page).get().at(0)
  let outside-right = not calc.even(page-number)
  let note-width = _wrappar-width(
    marker,
    size.width,
    outside-right: outside-right,
    note-number: note-number,
  )

  align(
    if outside-right { right } else { left },
    _wrappar-box(marker, width: note-width, outside-right: outside-right, note-number: note-number),
  )
})

// `wrapnotemark`'s counter step, claim marker and superscript collapse into
// a single `sequence`, so the claim is not a top-level sibling. Flatten
// those wrappers and hand the real children to the note scan.
#let _wrap-subsections(body) = {
  if not body.has("children") {
    return body
  }

  // `wrapnotemark`'s counter step, claim marker and superscript collapse into
  // a single `sequence`, so the claim is never a top-level child. Flatten one
  // level of sequences so the scan sees the claim (and any note marker) as a
  // sibling. Deeper recursion is avoided: it would reach note bodies and break
  // labels like `<wn1>`.
  let flat = ()
  for child in body.children {
    if repr(child.func()) == "sequence" {
      flat += child.children
    } else {
      flat.push(child)
    }
  }
  let source = flat
  let output = ()
  let idx = 0
  // Claims emitted by `wrapnotemark`. Notes consume them FIFO: the n-th note
  // that follows a mark reuses the n-th mark's number instead of stepping the
  // counter again, so each pair stays on one number — like LaTeX's
  // `\footnotemark` / `\footnotetext`.
  let claim-total = 0
  let claim-used = 0
  while idx < source.len() {
    let it = source.at(idx)
    if it.func() == metadata and type(it.value) == dictionary and it.value.at("tag", default: none) == "__sheaffer_wrapnote_claim" {
      claim-total += 1
      output.push(it)
      idx += 1
    } else if _is-wrappar-marker(it) {
      let body-start = idx + 1
      while body-start < source.len() and (
        source.at(body-start).func() == space or source.at(body-start).func() == parbreak
      ) {
        body-start += 1
      }

      let body-end = body-start
      let first-body = none
      while body-end < source.len() {
        let child = source.at(body-end)
        if child.func() == parbreak or child.func() == heading or _is-wrappar-marker(child) {
          break
        }
        if first-body == none and child.func() != space {
          first-body = child
        }
        body-end += 1
      }

      // The counter step and the marker itself stay in the text flow, so the
      // note's number follows the source order regardless of where the margin
      // box is laid out. The marker is re-emitted as well: it is invisible,
      // but keeps labels like `<wn1>` queryable.
      //
      // A numbered note also gets a visible inline superscript. In the middle
      // of a text line it goes right after the preceding text; when the note
      // stands at the start of its own block it leads the wrapped paragraph.
      let prev = idx - 1
      while prev >= 0 and source.at(prev).func() == space {
        prev -= 1
      }
      let in-text = (
        prev >= 0
          and source.at(prev).func() != parbreak
          and source.at(prev).func() != heading
      )

      let note-number = none
      let inline-number = none
      let paired = false
      if it.value.at("footnote-step", default: false) {
        if claim-used < claim-total {
          // Pair with the oldest unconsumed `wrapnotemark` and reuse its
          // number instead of stepping the counter again. Reading the value at
          // the claim's own location keeps later marks (and intervening
          // footnotes) from shifting it — the pair stays on one number, like
          // LaTeX's `\footnotemark` / `\footnotetext`.
          let claim-index = claim-used
          claim-used += 1
          paired = true
          note-number = context {
            let claim-loc = query(metadata)
              .filter(m => type(m.value) == dictionary and m.value.at("tag", default: none) == "__sheaffer_wrapnote_claim")
              .at(claim-index, default: none)
              .location()
            counter(footnote).display(at: claim-loc)
          }
        } else {
          output.push(counter(footnote).step())
          note-number = context counter(footnote).display()
        }

        // Keep the original marker in the flow: labels like `<wn1>` are
        // attached to it, so replacing it would break `#footnote(<wn1>)`.
        output.push(it)

        // A paired note already has its visible marker at the `wrapnotemark`
        // site, so it must not draw a second one here.
        if not paired {
          inline-number = text(
            fill: it.value.at("color"),
            super(note-number),
          )
          if in-text {
            output.push(inline-number)
            inline-number = none
          }
        }
      } else {
        output.push(it)
      }

      if (
        first-body != none
          and first-body.func() != figure
          and first-body.func() != list
          and first-body.func() != enum
          and first-body.func() != terms
      ) {
        let paragraph = source.slice(body-start, body-end).join()
        if inline-number != none {
          paragraph = [#inline-number#paragraph]
        }
        output.push(_wrappar-with-paragraph(it, paragraph, note-number: note-number))
        idx = body-end
      } else {
        if inline-number != none {
          output.push(inline-number)
        }
        output.push(it)
        idx += 1
      }
    } else if it.func() == heading and it.at("depth", default: none) == 3 {
      let body-start = idx + 1
      while body-start < source.len() and (
        source.at(body-start).func() == space or source.at(body-start).func() == parbreak
      ) {
        body-start += 1
      }
      let body-end = body-start
      let first-body = none

      while body-end < source.len() {
        let child = source.at(body-end)
        if child.func() == parbreak or child.func() == heading or _is-wrappar-marker(child) {
          break
        }
        if first-body == none and child.func() != space {
          first-body = child
        }
        body-end += 1
      }

      if (
        first-body != none
          and first-body.func() != figure
          and first-body.func() != list
          and first-body.func() != enum
          and first-body.func() != terms
      ) {
        let paragraph = source.slice(body-start, body-end).join()
        output.push(layout(size => {
          let title-inset = (top: 0.0em, bottom: 0.6em)
          let natural-width = measure(box(inset: title-inset)[#it]).width
          let title-width = calc.min(natural-width, size.width / 2)
          let title-block = box(
            width: title-width,
            inset: title-inset,
          )[#it]

          wrap-content(
            title-block,
            paragraph,
            align: top + left,
            columns: (title-width, 1fr),
            column-gutter: 1em,
          )
        }))
        idx = body-end
      } else {
        output.push(it)
        idx += 1
      }
    } else {
      output.push(it)
      idx += 1
    }
  }

  output.join()
}

// Handle spacing between blocks.
//
// Works around https://github.com/typst/typst/issues/3206.
// Also sets spacing around theorem environments.
//
// Must be the last show rule, because we can't recurse into `styled()` elements
#let _block-spacing(rest) = {
  if not rest.has("children") {
    return rest
  }

  for (idx, it) in rest.children.enumerate() {
    let is-block-math = it.func() == math.equation and it.block
    let is-figure = it.func() == figure
    let is-space = it.func() == space
    let is-thm-environment = _is-thm-block(it)
    let is-proof-environment = (
      is-thm-environment
        and it.body.children.first().value.at("kind", default: none) == "Proof"
    )

    // scan the previous elements
    let prev-element = none
    for i in (1, 2, 3) {
      if idx - i < 0 {
        break
      }
      let prev = rest.children.at(idx - i)
      if prev.func() == space or prev.func() == parbreak {
        continue
      }
      prev-element = prev
      break
    }

    // scan the next elements
    let next-element = none
    let before-parbreak = false
    for i in (1, 2, 3) {
      let next = rest.children.at(idx + i, default: none)
      if next == none {
        break
      }
      if next.func() == parbreak {
        before-parbreak = true
      }
      if (
        (next != none) and not (next.func() == space) and not (next.func() == parbreak)
      ) {
        next-element = next
        break
      }
    }

    let zero-width-space = "​"

    if (is-block-math or is-figure) {
      // separate the equation from the prior paragraph without breaking the
      // paragraph
      v(LEADING, weak: true)
      // prevent math block from breaking the paragraph
      box(width: 100%, it)
      linebreak()
    } else if is-thm-environment {
      // theorems can not be boxed because that prevents breaking across pages.
      // treat them specially here.

      // no extra space when a chapter or section heading is right above: it
      // already emits its own trailing space. a weak `v` is also dropped at
      // the top of a page or column.
      let after-heading = (
        prev-element != none
          and prev-element.func() == heading
          and prev-element.depth <= 2
      )
      if not after-heading {
        v(if is-proof-environment { SPACING } else { SPACING * 2.5 }, weak: true)
      }
      it
      // insert spacing if the next thing isn't another theorem
      if next-element != none and not _is-thm-block(next-element) {
        v(SPACING * 2.5, weak: true)

        // indent the next paragraph after a theorem if there is a paragraph break.
        // (work around typst issue 3206.)
        if before-parbreak {
          context {
            // insert an invisible character
            zero-width-space
            // cancel its height and the paragraph spacing height
            v(-(measure(zero-width-space).height + SPACING))
          }
        }
      }
    } else {
      it
    }
  }
}

/// Main style entry point
///
/// - body (content): Contents of the document.
/// - fonts (dictionary): Fonts to use. Keys are `body`, `heading`, `math` and
///   `code`; missing keys fall back to the package defaults.
/// -> content
#let style(body, fonts: FONTS) = {
  // let callers override only the fonts they care about
  let fonts = FONTS + fonts
  show: _style-body.with(fonts: fonts)
  show: _style-heading.with(fonts: fonts)
  show: _style-code.with(fonts: fonts)
  show: _style-figures
  show: _style-header-footer
  show: _style-link.with(fonts: fonts)
  show: _style-math.with(fonts: fonts)

  // Update counters on new chapter
  show heading.where(level: 1): it => {
    counter(footnote).update(0)
    counter("__sheafferthm-thmlike").update(0)
    counter("__sheafferthm-example").update(0)
    it
  }

  // Footnote markers and entry numbers are links; color only the number.
  // A footnote whose body is a label repeats its target's number: VERMILION
  // for a real footnote, BLUE when the label points at a wrapnote.
  show footnote: it => context {
    let body = it.body
    let color = VERMILION
    let loc = it.location()
    if type(body) == label {
      let declared = query(body).at(0, default: none)
      if declared != none and declared.func() == footnote {
        loc = declared.location()
      } else if declared != none and _is-wrappar-marker(declared) {
        loc = declared.location()
        color = BLUE
      }
    }
    let num = counter(footnote).display(at: loc, it.numbering)
    let entry = query(footnote.entry).find(e => e.note.location() == loc)
    h(0pt, weak: true)
    link(
      if entry != none { entry.location() } else { loc },
      super(text(fill: color)[#num]),
    )
  }

  show footnote.entry: it => context {
    let loc = it.note.location()
    let num = counter(footnote).display(at: loc, it.note.numbering)
    h(it.indent)
    super(link(loc, text(fill: VERMILION)[#num]))
    h(0.05em, weak: true)
    it.note.body
  }

  // DO NOT TOUCH ANYTHING BELOW (cursed workarounds)

  show: _style-ref
  // this needs to be the very last show rule
  show: _block-spacing

  _wrap-subsections(body)
}
