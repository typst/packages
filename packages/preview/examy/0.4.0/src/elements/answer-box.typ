#import "../prelude.typ": *
#import "../config.typ": solution_colors
#import "../widen.typ": widen_par_solutions

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name). Kept next to the
/// signature — update both together.
#let DOCS = (
  "answer-box": (
    desc: "A box for students to write answers in.",
    args: (
    (
      name: "body",
      type: "content",
      required: true,
      doc: "Content shown inside the box (a prompt, `#solution[..]`, or nothing).",
    ),
    (
      name: "solution",
      type: "content | none",
      default: "none",
      doc: "Solution content that fills the bottom of the box when solutions are enabled.",
    ),
    (
      name: "width",
      type: "auto | length | ratio | relative",
      default: "auto",
      doc: "The width of the box; `auto` falls back to `default_width`.",
    ),
    (
      name: "height",
      type: "length | fraction | none",
      default: "none",
      doc: "A fixed height gives a box of that size (`none` falls back to `default_height`); a fraction (`1fr`) makes the box grow to fill the remaining space on the page, shared proportionally with the other `fr` boxes there.",
    ),
    (
      name: "baseline",
      type: "length | ratio | relative",
      default: "50% - .33em",
      doc: "Baseline shift for small boxes sitting inline in a sentence; ignored for block-mode and full-width boxes. The default centers the box on the center line of a capital letter, the same line `bubble` is centered on, so a bubble and a box side by side line up.",
    ),
    (
      name: "default_height",
      type: "length",
      default: "2cm",
      doc: "The height used when `height` is `none`.",
    ),
    (
      name: "default_width",
      type: "length",
      default: "2cm",
      doc: "The width used when `width` is `auto` (inline boxes only).",
    ),
    ),
  ),
)

/// Display a box where students can write answers
#let answer_box(
  body,
  solution: none,
  width: auto,
  height: none,
  // `.33em` is half the cap height of a typical serif face: the box is
  // centered on the center line of a capital letter, which is what `bubble`
  // centers on too, so the two line up side by side. `bubble` measures that
  // line from the font instead of approximating it, but it can afford a
  // `context` to do so and this cannot — one here would make the box opaque
  // to the exam pipeline's content scans (see the note on block spacing
  // below). tests/unit/bubble.typ holds the two to within .01em of each
  // other.
  baseline: 50% - .33em,
  default_height: 2cm,
  default_width: 2cm,
) = {
  let it = (
    body: body,
    solution: solution,
    width: width,
    height: height,
    baseline: baseline,
    default_height: default_height,
    default_width: default_width,
  )

  // Since Typst 0.15, the `show` chain below is applied eagerly, so the
  // resulting block/box (and its height) is directly visible to the exam
  // pipeline's content scans — no height hint needed (emitting one would
  // double-count the fr height).
  let is_block = type(it.height) == fraction
  let height = it.height
  // The height of a box cannot be a fraction, so we change it to 100% if it is
  let box_height = if is_block { 100% } else if height == none { auto } else { height }
  if box_height == auto {
    box_height = it.default_height
  }

  let width = if is_block and it.width == auto {
    // The default width for block elements is 100%
    100%
  } else {
    it.width
  }
  if width == auto {
    width = it.default_width
  }

  // A centering baseline only makes sense for a small box sitting inline in
  // a sentence. For block-mode boxes and full-width boxes on their own line
  // there is none: since Typst 0.14/0.15 the line's ascent honors the
  // baseline shift literally, so `50% - .33em` on a tall box pushes it half
  // its height down the page.
  let is_standalone = is_block or type(width) in (ratio, relative)

  // If our height is given as a fraction, we must be a block element
  show: it_ => {
    if is_block {
      block(
        width: width,
        height: height,
        // Match the gap a fixed-height (inline) answer box gets from line
        // leading, instead of the much larger default block spacing —
        // otherwise `height: 1fr` boxes sit noticeably lower below their
        // question text than `height: 2in` ones. 0.65em is Typst's default
        // `par.leading`. (Not read via `context` because that would make the
        // box opaque to the exam pipeline's content scans.)
        above: 0.65em,
        it_,
      )
    } else {
      it_
    }
  }
  // The baseline shift goes on an *outer* wrapper rather than on the drawn
  // box itself: a box inherits the baseline of its contents' last line, so a
  // box holding anything at all (a prompt, a solution) would be positioned
  // by that line instead of by its own bottom edge, and the shift would then
  // drop the whole box below the surrounding text. A `stack` discards the
  // baseline of what it holds, so the wrapper's baseline is reliably its
  // bottom edge — which is what `50% - .33em` is measured from. Wrapping the
  // finished box (instead of its contents) also leaves the contents' own
  // region alone, so `place(bottom)` and `height: 1fr` inside still see the
  // full box. The wrapper repeats the box's height so that it still reads as
  // a sized box to the exam pipeline's scans (`starts_inline` keeps a gutter
  // label off the baseline of a tall box only when it can see its height).
  show: it_ => if is_standalone { it_ } else {
    box(height: box_height, baseline: it.baseline, stack(dir: ttb, it_))
  }
  show: box.with(
    stroke: .5pt,
    width: width,
    height: box_height,
    inset: 5pt,
  )

  // A solution standing alone in a paragraph fills the box, so the highlight
  // reads as the box's answer rather than a stray label; one used
  // mid-sentence stays inline and leaves its line intact.
  widen_par_solutions(it.body)
  set block(spacing: 8pt)
  if it.solution != none {
    e.get(get => {
      let colors = solution_colors(get)
      show: it_ => {
        set text(fill: colors.color)
        show: pad.with(-3pt)
        block(
          width: 100%,
          height: 1fr,
          fill: colors.background,
          inset: 3pt,
          it_,
        )
      }
      it.solution
    })
  }
}
