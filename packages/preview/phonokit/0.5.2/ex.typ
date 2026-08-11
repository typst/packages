// Linguistic example environment with automatic numbering
// Similar to linguex's \ex. command in LaTeX
//
// Create a numbered linguistic example
//
// Generates numbered examples (1), (2), etc. similar to linguex in LaTeX.
//
// Arguments:
// - body (content): The example content
// - number-dy (length): Vertical offset for the number (optional; default: 0.4em)
// - caption (string): Caption for outline (hidden in document; optional)
// - title (content): Optional title shown on the same line as the number
// - labels (array): Optional labels for sub-examples in list mode (e.g., (<s1a>, <s1b>))
// - columns (array): Optional column widths for tabular cells (data columns only)
//
// Returns: Numbered example that can be labeled and referenced
//
// Smart modes — detected automatically from body content:
//
// Single item (auto-numbered):
//   #ex[Some example content] <ex-1>
//
// Single item with tabular cells (& separator):
//   #ex[#ipa("/anba/") & #a-r & #ipa("[amba]")] <ex-1>
//
// Sub-examples with list syntax (auto-lettered):
//   #ex[
//     - First example
//     - Second example
//   ] <ex-1>
//
// Sub-examples with tabular cells (& separator):
//   #ex(labels: (<ex-a>, <ex-b>), columns: (5em, 2em, 5em))[
//     - #ipa("/anba/") & #a-r & #ipa("[amba]")
//     - #ipa("/anka/") & #a-r & #ipa("[aNka]")
//   ] <phon-ex>
//
// Legacy table mode (when body is a table — backward compatible):
//   #ex()[
//     #table(
//       columns: (2em, 2em, 5em, 2em, 5em),
//       stroke: none, align: left,
//       [#ex-num-label()], [#subex-label()<ex-a>], [#ipa("/anba/")], [#a-r], [#ipa("[amba]")],
//       [],                [#subex-label()<ex-b>], [#ipa("/anka/")], [#a-r], [#ipa("[aNka]")],
//     )
//   ]

// Counters
#let example-counter = counter("linguistic-example")
#let subex-counter = counter("linguistic-subexample")

// Alphabet for sub-example lettering (a, b, c...)
#let letters = "abcdefghijklmnopqrstuvwxyz"

// Split content at & characters into an array of cell contents.
// Walks the content tree, accumulating children into cells.
// Trims leading/trailing space nodes from each cell.
#let _split-cells(body) = {
  let children = if body.has("children") { body.children } else { (body,) }
  let cells = ()
  let current = ()
  for child in children {
    if child.has("text") and child.text.contains("&") {
      // Found separator — finalize current cell
      cells.push(current)
      current = ()
    } else {
      current.push(child)
    }
  }
  cells.push(current) // last cell
  // Trim leading/trailing spaces from each cell and join into content
  cells.map(cell => {
    let trimmed = cell
    // Trim leading spaces
    while trimmed.len() > 0 and trimmed.first().func() == [ ].func() and trimmed.first().has("text") and trimmed.first().text.trim() == "" {
      trimmed = trimmed.slice(1)
    }
    // Trim trailing spaces
    while trimmed.len() > 0 and trimmed.last().func() == [ ].func() and trimmed.last().has("text") and trimmed.last().text.trim() == "" {
      trimmed = trimmed.slice(0, trimmed.len() - 1)
    }
    trimmed.join()
  })
}

// Check if content contains an & text node
#let _has-ampersand(body) = {
  let children = if body.has("children") { body.children } else { (body,) }
  children.any(c => c.has("text") and c.text.contains("&"))
}

// Classify body content to determine rendering mode
// Typst's `- item` syntax creates list.item elements in a sequence (not wrapped in a list)
#let _classify-body(body) = {
  if body.func() == list.item { return "list" }
  if body.func() == table { return "legacy" }
  if body.has("children") {
    for child in body.children {
      if child.func() == list.item { return "list" }
      if child.func() == table { return "legacy" }
    }
  }
  "single"
}

// Extract list items from body (may be nested in a sequence)
#let _extract-items(body) = {
  if body.func() == list.item { return (body,) }
  if body.has("children") {
    return body.children.filter(c => c.func() == list.item)
  }
  ()
}

// Build a grid from list items with auto numbering and lettering
// Supports & cell separator for tabular data
#let _build-subex-grid(items, labels, columns, numbered: true) = {
  // Check if any item has tabular cells
  let has-tabular = items.any(item => _has-ampersand(item.body))

  let cells = ()
  let n-data-cols = 1 // default: single content column

  for (i, item) in items.enumerate() {
    // Column 1: example number on first row only (skip when title handles numbering)
    if numbered {
      let num-cell = if i == 0 {
        context {
          subex-counter.update(0)
          example-counter.step()
          [(#(example-counter.get().first() + 1))]
        }
      } else { [] }
      cells.push(num-cell)
    }

    // Column 2: sub-example letter (a., b., c.)
    let letter-fig = figure(
      box(baseline: 0pt, context {
        set par(first-line-indent: 0em)
        subex-counter.step()
        let n = subex-counter.get().first()
        [#letters.at(n).]
      }),
      kind: "linguistic-subexample",
      supplement: none,
      numbering: none,
    )
    // Attach label if provided (label must immediately follow figure, no whitespace)
    let letter-cell = if labels != () and i < labels.len() {
      [#letter-fig#labels.at(i)]
    } else {
      letter-fig
    }

    cells.push(letter-cell)

    if has-tabular {
      let data-cells = _split-cells(item.body)
      n-data-cols = calc.max(n-data-cols, data-cells.len())
      for cell in data-cells {
        cells.push(cell)
      }
      // Pad with empty cells if this row has fewer columns
      let pad = n-data-cols - data-cells.len()
      for _ in range(pad) { cells.push([]) }
    } else {
      cells.push(item.body)
    }
  }

  // Build column spec
  let data-col-spec = if columns != () {
    columns
  } else if has-tabular {
    range(n-data-cols).map(_ => auto)
  } else {
    (1fr,)
  }

  let col-spec = if numbered {
    (2em, 2em, ..data-col-spec)
  } else {
    (2em, ..data-col-spec)
  }

  grid(
    columns: col-spec,
    row-gutter: 1em,
    column-gutter: 0.5em,
    align: left + bottom,
    ..cells,
  )
}

// Main example function
#let ex(
  number-dy: 0.4em,
  caption: none,
  title: none,
  labels: (),
  columns: (),
  body,
) = {
  // Build the smart body content (list, single, or legacy)
  // numbered: false when title branch handles the example number
  let _build-smart-body(body, labels, columns, numbered: true) = {
    let mode = _classify-body(body)
    if mode == "list" {
      let items = _extract-items(body)
      _build-subex-grid(items, labels, columns, numbered: numbered)
    } else if mode == "single" and _has-ampersand(body) {
      let data-cells = _split-cells(body)
      let data-col-spec = if columns != () { columns } else {
        range(data-cells.len()).map(_ => auto)
      }
      grid(
        columns: data-col-spec,
        column-gutter: 0.5em,
        align: left + bottom,
        ..data-cells,
      )
    } else {
      body
    }
  }

  let content = if title != none {
    // Title case: (num | title) / ([] | smart body)
    let num = context {
      subex-counter.update(0)
      example-counter.step()
      [(#(example-counter.get().first() + 1))]
    }
    let smart-body = _build-smart-body(body, labels, columns, numbered: false)
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.75em,
      row-gutter: 0.3em,
      align: (left + top, left + top),
      num, title,
      [], smart-body,
    )
  } else {
    let mode = _classify-body(body)
    if mode == "list" {
      // List mode: auto number + auto letter sub-examples (with optional & cells)
      let items = _extract-items(body)
      _build-subex-grid(items, labels, columns)
    } else if mode == "single" {
      // Single-item mode: auto number to the left
      let num = context {
        subex-counter.update(0)
        example-counter.step()
        [(#(example-counter.get().first() + 1))]
      }
      // Check for tabular cells in single-item mode
      if _has-ampersand(body) {
        let data-cells = _split-cells(body)
        let data-col-spec = if columns != () { columns } else {
          range(data-cells.len()).map(_ => auto)
        }
        grid(
          columns: (2em, ..data-col-spec),
          column-gutter: 0.5em,
          align: left + bottom,
          num, ..data-cells,
        )
      } else {
        grid(
          columns: (auto, 1fr),
          column-gutter: 0.75em,
          align: (left + bottom, left + bottom),
          num, body,
        )
      }
    } else {
      // Legacy table mode: user manages numbering via ex-num-label() / subex-label()
      let step = context {
        subex-counter.update(0)
        example-counter.step()
        []
      }
      grid(
        columns: (auto, 1fr),
        column-gutter: 0pt,
        align: (left + top, left + top),
        step, body,
      )
    }
  }
  figure(
    content,
    caption: if caption != none { caption } else { none },
    outlined: caption != none,
    kind: "linguistic-example",
    supplement: none,
    numbering: "(1)",
    placement: none,
    gap: 0pt,
  )
}

// Display the current example number inside an ex() body.
//
// Use as the first-column cell of a 3-column table (num | sub-label | content)
// when no title is provided. Because it lives in the same table, it can share
// bottom alignment with the sub-example labels and the sentence text.
//
// Example:
//   #ex(caption: "Example")[
//     #table(
//       columns: 3,
//       stroke: none,
//       align: (left + bottom, left + bottom, left + top),
//       [#ex-num-label()<ex-1>], [#subex-label()<ex-1a>], [sentence a],
//       [],                      [#subex-label()<ex-1b>], [sentence b],
//     )
//   ]
#let ex-num-label() = {
  // No figure wrapper — a plain box behaves consistently with subex-label()
  // in table cells without requiring explicit bottom alignment.
  box(baseline: 0pt, context {
    set par(first-line-indent: 0em)
    let n = example-counter.get().first()
    [(#n)]
  })
}

// Create a sub-example label for use in tables
//
// Generates automatic lettering (a., b., c., ...) for table rows.
// Place in the first column of each row and attach a label after it.
//
// Returns: Labelable letter marker (a., b., c., ...)
//
// Example:
//   #ex(caption: "A phonology example")[
//     #table(
//       columns: 4,
//       stroke: none,
//       align: left,
//       [#subex-label()<ex-anba>], [#ipa("/anba/")], [#a-r], [#ipa("[amba]")],
//       [#subex-label()<ex-anka>], [#ipa("/anka/")], [#a-r], [#ipa("[aNka]")],
//     )
//   ] <ex-phon2>
//
//   See @ex-phon2, @ex-anba, and @ex-anka.
#let subex-label() = {
  // Figure must be outermost so labels attach to it (not to context)
  // Box with baseline ensures proper vertical alignment in table cells
  // Reset first-line-indent to avoid misalignment in documents with paragraph indentation
  figure(
    box(baseline: 0pt, context {
      set par(first-line-indent: 0em)
      subex-counter.step()
      let n = subex-counter.get().first()
      // get() returns value BEFORE step, so n=0,1,2... gives a,b,c...
      [#letters.at(n).]
    }),
    kind: "linguistic-subexample",
    supplement: none,
    numbering: none,
  )
}

// Show rules for linguistic examples
//
// Apply this to enable proper reference formatting for ex() and subex-label().
// References render as (1), (1a), (1b), etc.
//
// Usage: #show: ex-rules
#let ex-rules(doc) = {
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      if el.kind == "linguistic-example" {
        // Reference to main example: (1)
        // at() returns value before step, so add 1
        link(el.location(), context {
          let loc = el.location()
          let num = example-counter.at(loc).first() + 1
          [(#num)]
        })
      } else if el.kind == "linguistic-subexample" {
        // Reference to sub-example: (1a)
        // Subex is inside parent ex, so example-counter already stepped (no +1)
        // Subex counter: at() returns value before step (0,1,2...)
        link(el.location(), context {
          let loc = el.location()
          let parent-num = example-counter.at(loc).first()
          let letter-num = subex-counter.at(loc).first()
          let letter = letters.at(letter-num)
          [(#parent-num#letter)]
        })
      } else {
        it
      }
    } else {
      it
    }
  }
  // Hide captions in document (they still appear in outline)
  show figure.where(kind: "linguistic-example"): it => it.body
  show figure.where(kind: "linguistic-subexample"): it => it.body
  doc
}
