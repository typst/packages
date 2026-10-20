#import "../types.typ": *
#import "../config.typ": config

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
      doc: "A fixed height gives a box of that size (`none` falls back to `default_height`); a fraction (`1fr`) makes the box grow to fill the remaining space on the page.",
    ),
    (
      name: "baseline",
      type: "length | ratio | relative",
      default: "50% - .3em",
      doc: "Baseline shift for small boxes sitting inline in a sentence; ignored for block-mode and full-width boxes.",
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
#let other-answer-box(
  body,
  solution: none,
  width: auto,
  height: none,
  baseline: 50% - .3em,
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
      // omni-box(
      //   width: width,
      //   height: height,
      //   {
      //     [#width #height]
      //     it_
      //   },
      // )
    } else {
      it_
    }
  }
  // A centering baseline only makes sense for a small box sitting inline in
  // a sentence. For block-mode boxes and full-width boxes on their own line
  // it must be 0pt: since Typst 0.14/0.15 the line's ascent honors the
  // baseline shift literally, so `50% - .3em` on a tall box pushes it half
  // its height down the page.
  let is_standalone = is_block or type(width) in (ratio, relative)
  show: box.with(
    stroke: .5pt,
    width: width,
    height: box_height,
    baseline: if is_standalone { 0pt } else { it.baseline },
    inset: 5pt,
  )

  it.body
  set block(spacing: 8pt)
  if it.solution != none {
    e.get(get => {
      show: it_ => {
        set text(fill: get(config).solution-text-color)
        show: pad.with(-3pt)
        block(
          width: 100%,
          height: 1fr,
          fill: get(config).solution-background-color,
          inset: 3pt,
          it_,
        )
      }
      it.solution
    })
  }
}
