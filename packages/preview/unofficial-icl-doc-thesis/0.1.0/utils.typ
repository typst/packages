// utils.typ - Imperial College Typst Helpers
// Brand colours (mirrored from template.typ — no import to avoid circular deps)
#let _ic-blue       = rgb("#003E74")
#let _ic-light-blue = rgb("#D4EFFC")
#let _ic-navy       = rgb("#002147")
#let _ic-orange     = rgb("#D24000")
#let _ic-green      = rgb("#02893B")
#let _ic-red        = rgb("#DD2501")
#let _ic-grey       = rgb("#9C9FA4")
#let _ic-teal       = rgb("#009CBC")
#let _ic-violet     = rgb("#653098")

// ── Abbreviation state ────────────────────────────────────────────────────────
#let _abbr-seen  = state("abbr-seen",  (:))   // term -> true once seen
#let _abbr-store = state("abbr-store", (:))   // term -> expansion (for list)

// ── Callout boxes ─────────────────────────────────────────────────────────────

#let _callout(icon, label-text, accent, body) = block(
  width: 100%,
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  below: 0.8em,
  above: 0.8em,
)[
  #block(
    width: 100%,
    fill: accent.lighten(85%),
    stroke: (left: 3pt + accent),
    inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
    radius: (right: 4pt),
  )[
    #text(weight: "bold", fill: accent)[#icon #label-text] \
    #body
  ]
]

/// A blue informational note box.
#let note(body, color: _ic-blue) = _callout("i", "Note", color, body)

/// An orange warning box.
#let warning(body, color: _ic-orange) = _callout("!", "Warning", color, body)

/// A green tip box.
#let tip(body, color: _ic-green) = _callout("*", "Tip", color, body)

/// A definition box with a term header.
#let definition(body, term: "", color: _ic-navy) = block(
  width: 100%,
  below: 0.8em,
  above: 0.8em,
)[
  #block(
    width: 100%,
    fill: color.lighten(92%),
    stroke: (left: 3pt + color),
    inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
    radius: (right: 4pt),
  )[
    #text(weight: "bold", fill: color)[Definition: #term] \
    #body
  ]
]

// ── Inline badges ─────────────────────────────────────────────────────────────

/// A small coloured pill badge rendered inline.
#let badge(label-text, color: _ic-blue) = box(
  fill: color,
  inset: (x: 5pt, y: 2pt),
  radius: 3pt,
  baseline: 2pt,
)[
  #text(fill: white, size: 8pt, weight: "bold", label-text)
]

/// A red "TODO" badge with accompanying text.
#let todo(msg, color: _ic-red) = badge("TODO", color: color) + h(4pt) + text(fill: color, style: "italic", msg)

// ── Code blocks with filename label ───────────────────────────────────────────

/// Styled raw block with an optional filename label.
#let code-block(body, lang: "", filename: none, color: _ic-light-blue, font: ("Courier New", "Courier", "monospace")) = {
  let label-content = if filename != none {
    block(
      fill: _ic-blue,
      inset: (x: 8pt, y: 3pt),
      radius: (top: 4pt),
      below: 0pt,
    )[
      #text(fill: white, size: 8pt, font: font, filename)
    ]
  } else { none }

  if label-content != none { label-content }
  block(
    fill: color,
    inset: 0.8em,
    radius: if filename != none { (bottom: 4pt, top-right: 4pt) } else { 4pt },
    width: 100%,
    above: if filename != none { 0pt } else { 0.8em },
    below: 0.8em,
  )[
    #set text(font: font, size: 0.9em)
    #body
  ]
}

// ── Imperial-styled table ─────────────────────────────────────────────────────

/// Table with Imperial Blue header row.
/// `headers` is a tuple of strings; `rows` is a tuple of tuples.
#let ic-table(headers: (), rows: (), header-color: _ic-blue) = {
  let col-count = headers.len()
  let all-cells = ()

  // Header cells
  for h in headers {
    all-cells.push(
      table.cell(fill: header-color)[
        #text(fill: white, weight: "bold", h)
      ]
    )
  }

  // Data cells
  let row-idx = 0
  for row in rows {
    let bg = if calc.even(row-idx) { white } else { _ic-light-blue.lighten(40%) }
    for cell in row {
      all-cells.push(table.cell(fill: bg)[#cell])
    }
    row-idx += 1
  }

  table(
    columns: col-count,
    stroke: 0.5pt + _ic-grey,
    inset: 8pt,
    ..all-cells,
  )
}

// ── Figure convenience wrapper ────────────────────────────────────────────────

/// Wrap content in a `figure` with caption and label.
#let ic-figure(content, caption: "", label: none) = {
  let fig = figure(content, caption: caption)
  if label != none {
    [#fig #label]
  } else {
    fig
  }
}

// ── Numbered equations ────────────────────────────────────────────────────────

/// Display a numbered equation and attach a label for cross-referencing.
#let eq(body, label: none) = {
  let e = math.equation(body, block: true, numbering: "(1)")
  if label != none {
    [#e #label]
  } else {
    e
  }
}

// ── Section summary box ───────────────────────────────────────────────────────

/// A grey summary / learning-objectives box, typically at chapter end.
#let summary(body, color: _ic-grey) = block(
  width: 100%,
  below: 0.8em,
  above: 0.8em,
)[
  #block(
    width: 100%,
    fill: color.lighten(80%),
    stroke: (left: 3pt + color),
    inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
    radius: (right: 4pt),
  )[
    #text(weight: "bold", fill: color)[Chapter Summary] \
    #body
  ]
]

// ── Abbreviations ─────────────────────────────────────────────────────────────

/// First-use expansion: renders "Expansion (ABBR)" on first call, "ABBR" thereafter.
/// Also registers the abbreviation for #abbr-list().
#let abbr(short, long) = {
  // Register for the list
  _abbr-store.update(d => {
    d.insert(short, long)
    d
  })
  // Conditionally expand
  context {
    let seen = _abbr-seen.get()
    if short not in seen {
      _abbr-seen.update(d => {
        d.insert(short, true)
        d
      })
      [#long (#short)]
    } else {
      [#short]
    }
  }
}

/// Render all registered abbreviations as a definition list.
#let abbr-list() = context {
  let store = _abbr-store.final()
  if store.len() == 0 { return }
  heading(level: 1, outlined: true, numbering: none)[List of Abbreviations]
  for (short, long) in store {
    grid(
      columns: (3cm, 1fr),
      gutter: 0.5em,
      text(weight: "bold")[#short],
      long,
    )
  }
}
