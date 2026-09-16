// zebra-notes.typ
// A collaborative note-taking and task marking module for Typst.

#let _zebra-state = state("zebra-notes-state", ())
#let _zebra-counters = state("zebra-notes-counters", (:))
#let _zebra-draft = state("zebra-notes-draft", true)

// ─────────────────────────────────────────────────────────────────────────────
// Draft/Final Mode Control
// ─────────────────────────────────────────────────────────────────────────────

#let zebra-draft() = _zebra-draft.update(true)
#let zebra-final() = _zebra-draft.update(false)

// ─────────────────────────────────────────────────────────────────────────────
// Summary Table
// ─────────────────────────────────────────────────────────────────────────────

#let zebra-summary() = context {
  if not _zebra-draft.get() { return }

  let notes = _zebra-state.get()
  let counts = _zebra-counters.get()

  if notes.len() == 0 { return }

  // Render summary section header
  heading(level: 1, numbering: none, outlined: false)[Zebra Notes]

  // Render a clean horizontal-ruled table with a light gray background
  align(center, block(inset: 1em, {
    table(
      columns: (12em, 4em),
      inset: 8pt,
      stroke: (x, y) => if y == 0 or y == 1 or y == counts.len() + 1 { (top: 0.6pt + black) } else { none },
      fill: (x, y) => if y > 0 { luma(95%) } else { none },
      align: (left, center),
      table.header([*Note type*], [*Count*]),
      ..for (t, c) in counts.pairs() {
        (
          text(weight: "regular")[#lower(t)],
          [#c],
        )
      }
    )
  }))
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal Rendering Logic
// ─────────────────────────────────────────────────────────────────────────────

#let _zebra-render(note-type, content, assignee, color, visible-override) = context {
  let is-draft = _zebra-draft.get()
  let visible = if visible-override == auto { is-draft } else { visible-override }

  // Block 1: Counter logic (must always step if visible to keep numbering consistent)
  if visible {
    _zebra-counters.update(c => {
      let val = c.at(note-type, default: 0) + 1
      c.insert(note-type, val)
      c
    })
    _zebra-state.update(s => {
      s.push((type: note-type, content: content))
      s
    })
  }

  // Block 2: Visual rendering
  context {
    if not visible { return }

    let counts = _zebra-counters.get()
    let num = counts.at(note-type, default: 0)
    let num-str = str(num)

    let label-color = color.darken(30%)

    // Render the note type label with a SmallCaps effect.
    // The first letter is slightly larger for visual emphasis.
    let type-str = lower(note-type)
    let type-sc = text(fill: label-color, weight: "bold", size: 0.82em)[
      #text(size: 1.1em)[#upper(type-str.at(0))]#text(size: 0.9em)[#upper(type-str.slice(1))]
    ]

    // Number: space before it
    let num-part = text(fill: label-color, weight: "bold", size: 0.82em)[ #num-str]

    // @assignee: NO space before @
    let asgn-str = if assignee != none and assignee != "" { "@" + assignee } else { "" }
    let asgn-part = if asgn-str != "" {
      text(fill: label-color, weight: "bold", size: 0.82em, asgn-str)
    } else { "" }

    let colon-part = text(fill: label-color, weight: "bold", size: 0.82em)[:]

    let label-box = box(
      fill:   luma(247),
      inset:  (x: 2.5pt, y: 1.5pt),
      radius: 0.5pt,
      [#type-sc#num-part#asgn-part#colon-part]
    )

    /*
    // Optional: Render a margin mark alongside the note.
    let margin-mark = place(
      left,
      dx: -2.5em,
      dy: 0.15em,
      text(fill: color, weight: "bold", size: 0.8em)[#num-str],
    )
    */

    // ── Full inline note
    [#text(fill: color)[[#h(0.1em)#label-box #content#h(0.1em)]]]
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public Note Factory
// ─────────────────────────────────────────────────────────────────────────────

#let zebranewnote(note-type, color) = {
  (content, assignee: none, visible: auto) => {
    _zebra-render(note-type, content, assignee, color, visible)
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in Notes
// ─────────────────────────────────────────────────────────────────────────────

#let zebra-colors = (
  zebrablue:   rgb("#1e40af"),
  zebrared:    rgb("#b91c1c"),
  zebragreen:  rgb("#15803d"),
  zebrapurple: rgb("#6b21a8"),
  zebrayellow: rgb("#b45309"),
)

#let todo = zebranewnote("todo", rgb("#800080")) // Purple
#let note = zebranewnote("note", rgb("#8A2BE2")) // BlueViolet
#let zebracomment = zebranewnote("comment", rgb("#0000FF")) // Blue
#let fixed = zebranewnote("fixed", rgb("#00FFFF")) // Cyan
#let placeholder = zebranewnote("placeholder", rgb("#808080")) // Gray
