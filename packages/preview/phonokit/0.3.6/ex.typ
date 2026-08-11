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
//
// Returns: Numbered example that can be labeled and referenced
//
// Example:
//   #ex(caption: "A phonology example")[
//     #table(
//       columns: 3,
//       stroke: none,
//       align: left,
//       [#ipa("/anba/")], [#a-r], [#ipa("[amba]")],
//       [#ipa("/anka/")], [#a-r], [#ipa("[aNka]")],
//     )
//   ] <ex-phon1>
//
//   See @ex-phon1.

// Counters
#let example-counter = counter("linguistic-example")
#let subex-counter = counter("linguistic-subexample")

// Alphabet for sub-example lettering (a, b, c...)
#let letters = "abcdefghijklmnopqrstuvwxyz"

// Main example function
#let ex(
  number-dy: 0.4em,
  caption: none,
  body,
) = {
  let num = context {
    // Reset subexample counter at start of each example
    subex-counter.update(0)
    example-counter.step()
    [(#(example-counter.get().first() + 1))]
  }
  let adjusted-num = move(dy: number-dy, num)
  let content = grid(
    columns: (auto, 1fr),
    column-gutter: 0.75em,
    align: (left + top, left + top),
    adjusted-num, body,
  )
  figure(
    content,
    caption: if caption != none { caption } else { none },
    kind: "linguistic-example",
    supplement: none,
    numbering: "(1)",
    placement: none,
    gap: 0pt,
  )
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
  // Strip figure wrapper from sub-examples
  show figure.where(kind: "linguistic-subexample"): it => it.body
  doc
}
