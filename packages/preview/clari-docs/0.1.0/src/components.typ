// ============================================================
// clari-slides — Reusable Slide Components
// ============================================================
// All components are theme-responsive: they read the global
// state variables (cs-primary, cs-accent, …) inside `context`
// blocks so that color changes propagate automatically.

#import "state.typ": *

// ============================================================
// ── LAYOUT COMPONENTS ────────────────────────────────────────
// ============================================================

/// Multi-column layout with equal or custom column widths.
///
/// Parameters:
///   columns  — `none` for equal widths, or an array of `fr`/length values.
///   gutter   — Space between columns. Default: `1.2em`.
///   ..bodies — One content argument per column (named or positional).
///
/// Panics if the number of column definitions does not match the number of
/// body arguments.
#let cols(columns: none, gutter: 1.2em, ..bodies) = {
  let items = bodies.pos()
  let n     = items.len()
  assert(n > 0, message: "cols: at least one body is required")

  let col-spec = if columns == none {
    (1fr,) * n
  } else {
    assert(
      columns.len() == n,
      message: "cols: column count (" + str(columns.len()) +
               ") does not match body count (" + str(n) + ")",
    )
    columns
  }

  grid(
    columns:      col-spec,
    column-gutter: gutter,
    ..items,
  )
}

/// Two-column convenience wrapper around `cols`.
///
/// Parameters:
///   ratio  — Tuple of two column sizes. Default: `(1fr, 1fr)`.
///   gutter — Space between columns. Default: `1.2em`.
///   left   — Content for the left column.
///   right  — Content for the right column.
#let two-col(ratio: (1fr, 1fr), gutter: 1.2em, left, right) = {
  cols(columns: ratio, gutter: gutter, left, right)
}

/// Fills the entire slide area with an image.
///
/// Parameters:
///   src     — Image source path (string).
///   fit     — Sizing mode passed to `image`. Default: `"cover"`.
///   alt     — Alt-text for accessibility. Default: `none`.
///   caption — Optional caption displayed at the bottom. Default: `none`.
#let img-full(src, fit: "cover", alt: none, caption: none) = {
  place(top + left, image(src, width: 100%, height: 100%, fit: fit, alt: if alt != none { alt } else { "" }))
  if caption != none {
    place(
      bottom + left,
      block(
        width:   100%,
        inset:   (x: 0.8em, y: 0.4em),
        fill:    black.transparentize(35%),
        text(fill: white, size: 0.75em)[#caption],
      ),
    )
  }
}

/// Image on the left, content on the right.
///
/// Parameters:
///   src     — Image source path.
///   width   — Width of the image column. Default: `45%`.
///   fit     — Image fitting mode. Default: `"cover"`.
///   alt     — Alt-text. Default: `none`.
///   caption — Caption below the image. Default: `none`.
///   body    — Content for the right column.
#let img-left(src, width: 45%, fit: "cover", alt: none, caption: none, body) = {
  let img-col = stack(
    dir: ttb,
    spacing: 0.4em,
    image(src, width: 100%, fit: fit, alt: if alt != none { alt } else { "" }),
    if caption != none { text(size: 0.7em, style: "italic")[#caption] },
  )
  grid(
    columns:       (width, 1fr),
    column-gutter: 1.2em,
    align:         (top, top),
    img-col,
    body,
  )
}

/// Image on the right, content on the left.
///
/// Parameters:
///   src     — Image source path.
///   width   — Width of the image column. Default: `45%`.
///   fit     — Image fitting mode. Default: `"cover"`.
///   alt     — Alt-text. Default: `none`.
///   caption — Caption below the image. Default: `none`.
///   body    — Content for the left column.
#let img-right(src, width: 45%, fit: "cover", alt: none, caption: none, body) = {
  let img-col = stack(
    dir: ttb,
    spacing: 0.4em,
    image(src, width: 100%, fit: fit, alt: if alt != none { alt } else { "" }),
    if caption != none { text(size: 0.7em, style: "italic")[#caption] },
  )
  grid(
    columns:       (1fr, width),
    column-gutter: 1.2em,
    align:         (top, top),
    body,
    img-col,
  )
}

/// Image on the top, content below.
///
/// Parameters:
///   src     — Image source path.
///   height  — Height of the image row. Default: `45%`.
///   fit     — Image fitting mode. Default: `"cover"`.
///   alt     — Alt-text. Default: `none`.
///   caption — Caption below the image. Default: `none`.
///   body    — Content below the image.
#let img-top(src, height: 45%, fit: "cover", alt: none, caption: none, body) = {
  stack(
    dir: ttb,
    spacing: 0.8em,
    block(
      height: height,
      width:  100%,
      clip:   true,
      image(src, width: 100%, height: 100%, fit: fit, alt: if alt != none { alt } else { "" }),
    ),
    if caption != none { text(size: 0.7em, style: "italic")[#caption] },
    body,
  )
}

/// Content on the top, image below.
///
/// Parameters:
///   src     — Image source path.
///   height  — Height of the image row. Default: `45%`.
///   fit     — Image fitting mode. Default: `"cover"`.
///   alt     — Alt-text. Default: `none`.
///   caption — Caption below the image. Default: `none`.
///   body    — Content above the image.
#let img-bottom(src, height: 45%, fit: "cover", alt: none, caption: none, body) = {
  stack(
    dir: ttb,
    spacing: 0.8em,
    body,
    block(
      height: height,
      width:  100%,
      clip:   true,
      image(src, width: 100%, height: 100%, fit: fit, alt: if alt != none { alt } else { "" }),
    ),
    if caption != none { text(size: 0.7em, style: "italic")[#caption] },
  )
}


// ============================================================
// ── CONTENT COMPONENTS ───────────────────────────────────────
// ============================================================

/// Styled code block with an optional colored title bar.
///
/// Pass a raw Typst code block as the body:
/// ```
///   #code-block(title: "main.py", theme: "dark")[
///     ```python
///     print("hello")
///     ```
///   ]
/// ```
///
/// Parameters:
///   title        — Optional title shown in the header bar. Default: `none`.
///   theme        — `"dark"` or `"light"`. Default: `"dark"`.
///   body         — Content containing the raw code block (with ``` delimiters).
#let code-block(title: none, theme: "dark", body) = context {
  let primary    = cs-primary.get()
  let is-dark    = theme == "dark"
  let bg-color   = if is-dark { rgb("#2B2B2B") } else { rgb("#F5F5F5") }
  let text-color = if is-dark { rgb("#F8F8F2") } else { rgb("#333333") }

  block(
    width:  100%,
    radius: 0.25em,
    clip:   true,
    stroke: if is-dark { none } else { 0.5pt + luma(200) },
    stack(
      dir: ttb,
      // ── title bar ──────────────────────────────────────────
      if title != none {
        rect(
          fill:  primary,
          width: 100%,
          inset: (x: 0.75em, y: 0.35em),
          text(fill: white, size: 0.75em, weight: "semibold")[#title],
        )
      },
      // ── code area ──────────────────────────────────────────
      block(
        fill:  bg-color,
        width: 100%,
        inset: (x: 0.85em, y: 0.65em),
        // body is already content (typically a raw block the user placed inside)
        // We apply monospace font styling and display it directly.
        {
          set text(fill: text-color, size: 0.8em)
          body
        },
      ),
    ),
  )
}

/// Horizontal info box: icon + title sidebar on the left, content on the right.
///
/// Parameters:
///   title — Title string. Default: `none`.
///   icon  — Icon character/string displayed above the title. Default: `none`.
///   color — Accent color. Default: `none` (uses primary).
///   body  — Main content for the right panel.
#let info-h(title: none, icon: none, color: none, body) = context {
  let c   = if color != none { color } else { cs-primary.get() }
  let muted = c.lighten(88%)

  block(
    width:  100%,
    radius: 0.25em,
    clip:   true,
    stroke: 0.5pt + c.lighten(50%),
    grid(
      columns:      (auto, 1fr),
      // ── left sidebar ───────────────────────────────────────
      block(
        fill:  c,
        inset: (x: 0.7em, y: 0.65em),
        align(center + horizon,
          stack(
            dir: ttb,
            spacing: 0.25em,
            if icon != none { text(fill: white, size: 1.2em)[#icon] },
            if title != none {
              text(fill: white, weight: "semibold", size: 0.75em, style: "normal")[
                #rotate(-0deg)[#title]
              ]
            },
          ),
        ),
      ),
      // ── right content ──────────────────────────────────────
      block(
        fill:  muted,
        inset: (x: 0.9em, y: 0.65em),
        width: 100%,
        body,
      ),
    ),
  )
}

/// Vertical info box: colored title bar on top, content below.
///
/// Parameters:
///   title — Title string. Default: `none`.
///   icon  — Icon character/string. Default: `none`.
///   color — Accent color. Default: `none` (uses primary).
///   body  — Main content.
#let info-v(title: none, icon: none, color: none, body) = context {
  let c     = if color != none { color } else { cs-primary.get() }
  let muted = c.lighten(88%)

  block(
    width:  100%,
    radius: 0.25em,
    clip:   true,
    stroke: 0.5pt + c.lighten(50%),
    stack(
      dir: ttb,
      // ── header bar ─────────────────────────────────────────
      if title != none or icon != none {
        rect(
          fill:  c,
          width: 100%,
          inset: (x: 0.8em, y: 0.45em),
          grid(
            columns:      (auto, 1fr),
            column-gutter: 0.4em,
            align:        (left + horizon, left + horizon),
            if icon != none { text(fill: white, size: 1em)[#icon] } else { [] },
            if title != none {
              text(fill: white, weight: "semibold", size: 0.82em)[#title]
            } else { [] },
          ),
        )
      },
      // ── body ───────────────────────────────────────────────
      block(
        fill:  muted,
        width: 100%,
        inset: (x: 0.9em, y: 0.65em),
        body,
      ),
    ),
  )
}

// Internal callout color/icon table
#let _callout-presets = (
  note:      (color: rgb("#1565C0"), icon: none, label: "Note"),
  tip:       (color: rgb("#2E7D32"), icon: none, label: "Tip"),
  warning:   (color: rgb("#F57F17"), icon: none, label: "Warning"),
  important: (color: rgb("#6A1B9A"), icon: none, label: "Important"),
  danger:    (color: rgb("#B71C1C"), icon: none, label: "Danger"),
  success:   (color: rgb("#00695C"), icon: none, label: "Success"),
)

/// Callout box with a preset style based on `type`.
///
/// Parameters:
///   type  — One of: "note", "tip", "warning", "important", "danger",
///            "success".
///   title — Override the default title. Default: `none` (uses type name).
///   body  — Callout content.
#let callout(type: "note", title: none, body) = {
  let preset = _callout-presets.at(type, default: _callout-presets.note)
  let c      = preset.color
  let icon   = preset.icon
  let label  = if title != none { title } else { preset.label }
  let bg     = c.lighten(90%)

  block(
    width:  100%,
    radius: 0.25em,
    clip:   false,
    fill:   none,
    stroke: none,
    // Left accent bar via overlay
    stack(
      dir: ltr,
      // accent bar
      rect(width: 4pt, fill: c, radius: (left: 0.25em)),
      // content area
      block(
        fill:   bg,
        width:  100%,
        inset:  (x: 0.8em, y: 0.55em),
        radius: (right: 0.25em),
        stack(
          dir: ttb,
          spacing: 0.35em,
          // header row
          grid(
            columns:       (auto, 1fr),
            column-gutter: 0.35em,
            align:         (top, top),
            text(fill: c, size: 0.95em, weight: "bold")[#icon],
            text(fill: c, size: 0.85em, weight: "bold")[#label],
          ),
          // body
          text(size: 0.85em)[#body],
        ),
      ),
    ),
  )
}

/// Styled pull quote with a large decorative quotation mark.
///
/// Parameters:
///   author — Attribution name. Default: `none`.
///   source — Source work or context. Default: `none`.
///   body   — The quote text.
#let quote-block(author: none, source: none, body) = context {
  let primary = cs-primary.get()
  let muted   = primary.lighten(92%)

  block(
    width:  100%,
    fill:   muted,
    radius: 0.25em,
    inset:  (x: 1.2em, y: 0.8em),
    stroke: (left: 4pt + primary),
    stack(
      dir: ttb,
      spacing: 0.5em,
      // decorative quote mark
      align(left,
        text(fill: primary.lighten(30%), size: 3.5em, style: "normal")[\u{201C}]
      ),
      // quote body
      text(size: 0.95em, style: "italic")[#body],
      // attribution
      if author != none or source != none {
        align(right,
          text(size: 0.75em, weight: "semibold")[
            #if author != none { [— #author] }
            #if source  != none { [, #text(style: "italic")[#source]] }
          ]
        )
      },
    ),
  )
}

/// Simple highlighted box.
///
/// Parameters:
///   color — Background color. Default: `none` → muted tint from primary.
///   body  — Content inside the box.
#let highlight-box(color: none, body) = context {
  let bg = if color != none { color } else { cs-primary.get().lighten(88%) }

  block(
    fill:   bg,
    width:  100%,
    radius: 0.25em,
    inset:  (x: 0.9em, y: 0.65em),
    body,
  )
}

/// General-purpose frame with an optional colored title bar.
///
/// Parameters:
///   title      — Title string. Default: `none`.
///   back-color — Background color of the content area. Default: `none`
///                (uses a muted tint).
///   body       — Frame content.
#let framed(title: none, back-color: none, body) = context {
  let primary = cs-primary.get()
  let bg      = if back-color != none { back-color } else { primary.lighten(92%) }

  block(
    width:  100%,
    radius: 0.25em,
    clip:   true,
    stroke: 0.5pt + primary.lighten(40%),
    stack(
      dir: ttb,
      if title != none {
        rect(
          fill:  primary,
          width: 100%,
          inset: (x: 0.8em, y: 0.4em),
          text(fill: white, weight: "semibold", size: 0.82em)[#title],
        )
      },
      block(
        fill:  bg,
        width: 100%,
        inset: (x: 0.9em, y: 0.65em),
        body,
      ),
    ),
  )
}

/// Definition box with a left accent bar and bold term.
///
/// Parameters:
///   term — The term being defined.
///   body — The definition.
#let definition(term, body) = context {
  let primary = cs-primary.get()
  let muted   = primary.lighten(90%)

  stack(
    dir: ltr,
    rect(width: 4pt, fill: primary, radius: (left: 0.25em)),
    block(
      fill:   muted,
      width:  100%,
      inset:  (x: 0.85em, y: 0.6em),
      radius: (right: 0.25em),
      stack(
        dir: ttb,
        spacing: 0.3em,
        text(fill: primary, weight: "bold", size: 0.9em)[#term],
        text(size: 0.85em)[#body],
      ),
    ),
  )
}

// Internal helper: math-style box (theorem, lemma, …)
#let _math-box(kind, header-color, title: none, number: none, body) = context {
  let muted = header-color.lighten(90%)
  let label-parts = (kind,)
  if number != none { label-parts.push(" " + str(number)) }
  let header-text = label-parts.join()

  block(
    width:  100%,
    radius: 0.25em,
    clip:   true,
    stroke: 0.5pt + header-color.lighten(40%),
    stack(
      dir: ttb,
      // ── colored header ─────────────────────────────────────
      rect(
        fill:  header-color,
        width: 100%,
        inset: (x: 0.8em, y: 0.4em),
        grid(
          columns:       (auto, 1fr),
          column-gutter: 0.5em,
          align:         (left + horizon, left + horizon),
          text(fill: white, weight: "bold", size: 0.82em)[#header-text],
          if title != none {
            text(fill: white.transparentize(20%), size: 0.78em, style: "italic")[#title]
          } else { [] },
        ),
      ),
      // ── body ───────────────────────────────────────────────
      block(
        fill:  muted,
        width: 100%,
        inset: (x: 0.9em, y: 0.65em),
        text(size: 0.85em)[#body],
      ),
    ),
  )
}

/// Theorem box with colored header.
///
/// Parameters:
///   title  — Subtitle in the header. Default: `none`.
///   number — Theorem number. Default: `none`.
///   body   — Theorem statement.
#let theorem(title: none, number: none, body) = context {
  _math-box("Theorem", cs-primary.get(), title: title, number: number, body)
}

/// Lemma box (accent-colored header).
///
/// Parameters:
///   title  — Subtitle in the header. Default: `none`.
///   number — Lemma number. Default: `none`.
///   body   — Lemma statement.
#let lemma(title: none, number: none, body) = context {
  _math-box("Lemma", cs-accent.get(), title: title, number: number, body)
}

/// Corollary box.
///
/// Parameters:
///   title  — Subtitle. Default: `none`.
///   number — Number. Default: `none`.
///   body   — Corollary statement.
#let corollary(title: none, number: none, body) = context {
  let c = cs-primary.get().mix(cs-accent.get())
  _math-box("Corollary", c, title: title, number: number, body)
}

/// Proposition box.
///
/// Parameters:
///   title  — Subtitle. Default: `none`.
///   number — Number. Default: `none`.
///   body   — Proposition statement.
#let proposition(title: none, number: none, body) = context {
  _math-box("Proposition", cs-accent.get().darken(15%), title: title, number: number, body)
}

/// Proof box. Starts with "Proof." in italic and ends with ∎.
///
/// Parameters:
///   body — Proof content.
#let proof(body) = context {
  let primary = cs-primary.get()
  let muted   = primary.lighten(94%)

  block(
    fill:   muted,
    width:  100%,
    radius: 0.25em,
    inset:  (x: 0.9em, y: 0.65em),
    stroke: (left: 3pt + primary.lighten(50%)),
    stack(
      dir: ttb,
      spacing: 0.4em,
      text(style: "italic", weight: "semibold", size: 0.85em)[Proof.],
      text(size: 0.85em)[#body],
      align(right, text(fill: primary, size: 1em)[∎]),
    ),
  )
}

/// Example box using the accent color.
///
/// Parameters:
///   title — Optional title. Default: `none`.
///   body  — Example content.
#let example(title: none, body) = context {
  _math-box(
    if title != none { "Example: " + title } else { "Example" },
    cs-accent.get().darken(10%),
    body,
  )
}

/// Remark box with subtle styling.
///
/// Parameters:
///   body — Remark content.
#let remark(body) = context {
  let primary = cs-primary.get()

  stack(
    dir: ltr,
    rect(width: 3pt, fill: primary.lighten(40%), radius: (left: 0.25em)),
    block(
      fill:   primary.lighten(95%),
      width:  100%,
      inset:  (x: 0.85em, y: 0.55em),
      radius: (right: 0.25em),
      stack(
        dir: ttb,
        spacing: 0.3em,
        text(fill: primary.lighten(20%), weight: "semibold", size: 0.78em, style: "italic")[Remark.],
        text(size: 0.82em)[#body],
      ),
    ),
  )
}

/// Two-column comparison. Left column uses primary, right uses accent.
///
/// Parameters:
///   left-title  — Header for the left column.
///   right-title — Header for the right column.
///   left-body   — Content for the left column.
///   right-body  — Content for the right column.
///   ratio       — Column sizes. Default: `(1fr, 1fr)`.
#let comparison(
  left-title:  "Option A",
  right-title: "Option B",
  left-body,
  right-body,
  ratio: (1fr, 1fr),
) = context {
  let primary = cs-primary.get()
  let accent  = cs-accent.get()

  grid(
    columns:       ratio,
    column-gutter: 1em,
    // left column
    block(
      width:  100%,
      radius: 0.25em,
      clip:   true,
      stroke: 0.5pt + primary.lighten(40%),
      stack(
        dir: ttb,
        rect(
          fill:  primary,
          width: 100%,
          inset: (x: 0.8em, y: 0.4em),
          text(fill: white, weight: "semibold", size: 0.82em)[#left-title],
        ),
        block(
          fill:  primary.lighten(90%),
          width: 100%,
          inset: (x: 0.85em, y: 0.6em),
          left-body,
        ),
      ),
    ),
    // right column
    block(
      width:  100%,
      radius: 0.25em,
      clip:   true,
      stroke: 0.5pt + accent.lighten(30%),
      stack(
        dir: ttb,
        rect(
          fill:  accent,
          width: 100%,
          inset: (x: 0.8em, y: 0.4em),
          text(fill: white, weight: "semibold", size: 0.82em)[#right-title],
        ),
        block(
          fill:  accent.lighten(88%),
          width: 100%,
          inset: (x: 0.85em, y: 0.6em),
          right-body,
        ),
      ),
    ),
  )
}

/// Numbered step list with large circle numbers in primary color.
///
/// Parameters:
///   ..steps — Positional content arguments, one per step.
#let step-list(..steps) = context {
  let primary = cs-primary.get()
  let items   = steps.pos()

  stack(
    dir:     ttb,
    spacing: 0.6em,
    ..items.enumerate().map(((i, step)) => {
      grid(
        columns:       (2em, 1fr),
        column-gutter: 0.7em,
        align:         (top, top),
        // circle number
        box(
          width:  2em,
          height: 2em,
          radius: 1em,
          fill:   primary,
          align(center + horizon,
            text(fill: white, weight: "bold", size: 0.78em)[#(i + 1)],
          ),
        ),
        // step content
        block(
          inset: (top: 0.25em),
          step,
        ),
      )
    }),
  )
}

/// Small inline pill badge.
///
/// Parameters:
///   label      — Badge text.
///   color      — Badge background. Default: `none` → primary.
///   text-color — Text color inside the badge. Default: `white`.
#let badge(label, color: none, text-color: white) = context {
  let bg = if color != none { color } else { cs-primary.get() }

  box(
    fill:   bg,
    radius: 0.9em,
    inset:  (x: 0.55em, y: 0.2em),
    text(fill: text-color, size: 0.7em, weight: "semibold")[#label],
  )
}

/// Horizontal row of badges.
///
/// Parameters:
///   ..tags — Positional string or content arguments, one per tag.
///            Strings are rendered with default badge styling.
///            Pass `badge(…)` calls directly for custom styling.
#let tag-row(..tags) = {
  let items = tags.pos()
  stack(
    dir:     ltr,
    spacing: 0.4em,
    ..items.map(t => if type(t) == str { badge(t) } else { t }),
  )
}

/// Styled data table.
///
/// Parameters:
///   headers — Array of header strings.
///   rows    — Array of arrays (each inner array = one row of cells).
///   caption — Optional table caption. Default: `none`.
///   striped — Alternate row background. Default: `true`.
///   col-align — Column alignment value or array. Default: `left`.
#let data-table(headers, rows, caption: none, striped: true, col-align: left) = context {
  let primary = cs-primary.get()
  let muted   = primary.lighten(90%)
  let n-cols  = headers.len()

  // Build alignment array
  let col-align-arr = if type(col-align) == array { col-align } else { (col-align,) * n-cols }

  // Header cells
  let header-cells = headers.map(h =>
    table.cell(
      fill: primary,
      align: center + horizon,
      text(fill: white, weight: "bold", size: 0.8em)[#h],
    )
  )

  // Body cells with optional striping
  let body-cells = ()
  for (row-i, row) in rows.enumerate() {
    let row-fill = if striped and calc.odd(row-i) { muted } else { white }
    for (col-i, cell) in row.enumerate() {
      let a = if col-i < col-align-arr.len() { col-align-arr.at(col-i) } else { left }
      body-cells.push(
        table.cell(
          fill:  row-fill,
          align: a + horizon,
          text(size: 0.8em)[#cell],
        )
      )
    }
  }

  let tbl = table(
    columns:      (1fr,) * n-cols,
    stroke:       0.5pt + primary.lighten(50%),
    inset:        (x: 0.6em, y: 0.45em),
    ..header-cells,
    ..body-cells,
  )

  if caption != none {
    stack(
      dir:     ttb,
      spacing: 0.4em,
      tbl,
      align(center, text(size: 0.75em, style: "italic")[#caption]),
    )
  } else {
    tbl
  }
}

/// Vertical timeline.
///
/// Parameters:
///   events — Array of dictionaries with keys:
///            `time`  (string, required),
///            `title` (string, required),
///            `body`  (content, optional).
///            Up to 6 events are displayed cleanly.
#let timeline(events) = context {
  let primary  = cs-primary.get()
  let accent   = cs-accent.get()
  let capped   = if events.len() > 6 { events.slice(0, 6) } else { events }
  let n        = capped.len()

  stack(
    dir:     ttb,
    spacing: 0pt,
    ..capped.enumerate().map(((i, ev)) => {
      let is-last = i == n - 1
      grid(
        columns:       (1.8em, 3.5em, 1fr),
        column-gutter: 0pt,
        rows:          (auto,),
        // ── connector line ───────────────────────────────────
        align(center,
          stack(
            dir: ttb,
            // dot
            box(
              width:  0.75em,
              height: 0.75em,
              radius: 0.375em,
              fill:   if i == 0 { primary } else { primary.lighten(35%) },
            ),
            // line segment below dot (skip for last item)
            if not is-last {
              block(
                width:  2pt,
                height: 2.2em,
                fill:   primary.lighten(55%),
              )
            },
          )
        ),
        // ── time label ───────────────────────────────────────
        block(
          inset: (top: 0.05em, right: 0.4em),
          align(right,
            text(fill: primary, weight: "semibold", size: 0.72em)[#ev.time],
          ),
        ),
        // ── event content ────────────────────────────────────
        block(
          inset:        (bottom: if not is-last { 1em } else { 0pt }),
          width:        100%,
          stack(
            dir:     ttb,
            spacing: 0.2em,
            text(weight: "bold",   size: 0.82em)[#ev.title],
            if "body" in ev and ev.body != none {
              text(size: 0.75em)[#ev.body]
            },
          ),
        ),
      )
    }),
  )
}

/// Inline horizontal progress bar.
///
/// Parameters:
///   value — Current value (number).
///   max   — Maximum value. Default: `100`.
///   label — Optional label shown above the bar. Default: `none`.
///   color — Bar fill color. Default: `none` → primary.
#let progress-indicator(value, max: 100, label: none, color: none) = context {
  let c       = if color != none { color } else { cs-primary.get() }
  let ratio   = calc.min(1.0, calc.max(0.0, value / max))
  let pct     = str(calc.round(ratio * 100)) + "%"

  stack(
    dir:     ttb,
    spacing: 0.25em,
    if label != none {
      grid(
        columns:       (1fr, auto),
        align:         (left + horizon, right + horizon),
        text(size: 0.78em, weight: "semibold")[#label],
        text(size: 0.78em, fill: c)[#pct],
      )
    } else {
      align(right, text(size: 0.72em, fill: c)[#pct])
    },
    // track
    block(
      width:  100%,
      height: 0.45em,
      radius: 0.225em,
      clip:   true,
      fill:   c.lighten(75%),
      // filled portion
      place(left + horizon,
        rect(
          width:  ratio * 100%,
          height: 100%,
          fill:   c,
          radius: 0.225em,
        )
      ),
    ),
  )
}

/// Grid of icon+label items, 3 per row, centered.
///
/// Parameters:
///   items — Array of dictionaries with keys `icon` and `label`.
#let icon-grid(items) = context {
  let primary = cs-primary.get()
  let muted   = primary.lighten(90%)
  // pad to multiple of 3
  let padded  = items
  while calc.rem(padded.len(), 3) != 0 {
    padded.push((icon: "", label: ""))
  }
  let rows = padded.chunks(3)

  stack(
    dir:     ttb,
    spacing: 0.6em,
    ..rows.map(row => {
      grid(
        columns:       (1fr, 1fr, 1fr),
        column-gutter: 0.8em,
        ..row.map(item => {
          block(
            fill:   muted,
            radius: 0.25em,
            inset:  (x: 0.5em, y: 0.6em),
            width:  100%,
            align(center,
              stack(
                dir:     ttb,
                spacing: 0.3em,
                text(fill: primary, size: 1.4em)[#item.icon],
                text(size: 0.75em, weight: "semibold")[#item.label],
              ),
            ),
          )
        }),
      )
    }),
  )
}

/// Single key-value row.
///
/// Parameters:
///   key       — Key string (rendered bold).
///   value     — Value content.
///   separator — Separator string. Default: `":"`.
#let key-value(key, value, separator: ":") = {
  grid(
    columns:       (auto, auto, 1fr),
    column-gutter: 0.25em,
    align:         (left + top, left + top, left + top),
    text(weight: "bold")[#key],
    text[#separator],
    text[#value],
  )
}

/// Inline text styled as an alert (primary color, semibold, slightly larger).
///
/// Parameters:
///   body — Inline content to style.
#let alert-text(body) = context {
  text(
    fill:   cs-primary.get(),
    weight: "semibold",
    size:   1.08em,
  )[#body]
}

/// Inline text in muted gray.
///
/// Parameters:
///   body — Inline content to style.
#let muted-text(body) = {
  text(fill: luma(140))[#body]
}
