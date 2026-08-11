// Linguistic example environment with automatic numbering
// Similar to linguex's \ex. command in LaTeX
//
// Create a numbered linguistic example
//
// Generates numbered examples (1), (2), etc. similar to linguex in LaTeX.
// Use with tables and subex-label() for aligned, labelable sub-examples.
//
// Arguments:
// - body (content): The example content (typically a table)
// - number-dy (length): Vertical offset for the number (optional; default: 0.4em)
// - caption (string): Caption for outline (hidden in document; optional)
// - title (content): Optional title shown on the same line as the number
//
// Returns: Numbered example that can be labeled and referenced
//
// With title (title aligns with number):
//   #ex(caption: "A phonology example", title: [An example:])[
//     #table(columns: 2, stroke: none, align: (left + bottom, left + top), ...)
//   ] <ex-phon1>
//
// Without title (put ex-num-label() in the first column of the inner table):
//   #ex(caption: "A phonology example")[
//     #table(
//       columns: 3,
//       stroke: none,
//       align: (left + bottom, left + bottom, left + top),
//       [#ex-num-label()<ex-phon1>], [#subex-label()<ex-a>], [sentence a],
//       [],                          [#subex-label()<ex-b>], [sentence b],
//     )
//   ]
//
//   See @ex-phon1, @ex-a.

// Counters
#let example-counter = counter("linguistic-example")
#let subex-counter = counter("linguistic-subexample")

// Alphabet for sub-example lettering (a, b, c...)
#let letters = "abcdefghijklmnopqrstuvwxyz"

// Main example function
#let ex(
  number-dy: 0.4em,
  caption: none,
  title: none,
  body,
) = {
  let content = if title != none {
    // Title case: outer 2-row grid — (num | title) / ([] | body)
    // Counter step happens inside num (first row), aligning number with title text.
    let num = context {
      subex-counter.update(0)
      example-counter.step()
      [(#(example-counter.get().first() + 1))]
    }
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.75em,
      row-gutter: 0.3em,
      align: (left + top, left + top),
      num, title,
      [], body,
    )
  } else {
    // No-title case: counter step fires silently; number is displayed via
    // ex-num-label() in the body table's first column.
    // The outer grid (with an invisible 0-width first column) forces full-width
    // left-aligned layout, matching the title case.
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
