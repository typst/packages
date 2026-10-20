#import "@preview/frame-it:2.0.0": frame, frame-style
#import "design.typ": *

#let _has-title(title) = title not in (none, [], "")

#let _frame-fill(accent-color) = if accent-color == monash-charcoal {
  monash-grey-light
} else {
  accent-color.transparentize(93%)
}

/// Low-level styling function used by the Monash frame environments.
///
/// This is passed to `frame-it` through `show-monash-frames`. Most users should
/// call `#show: show-monash-frames` and then use `#definition`, `#theorem`, and
/// the other exported environments instead of calling this function directly.
#let monash-frame-style(title, tags, body, supplement, number, accent-color) = {
  let supplement-line = if number == none {
    supplement
  } else {
    [#supplement #number]
  }

  let title-line = if _has-title(title) {
    [#supplement-line: #title]
  } else {
    supplement-line
  }

  block(
    width: 100%,
    fill: _frame-fill(accent-color),
    stroke: (
      left: (paint: accent-color, thickness: monash-frame-rule),
      rest: (paint: monash-grey-soft, thickness: .55pt),
    ),
    radius: 2pt,
    inset: 0pt,
    [
      #block(
        width: 100%,
        fill: accent-color,
        inset: (x: monash-space-md, y: monash-space-xs),
        [
          #text(size: .68em, fill: white, weight: "bold", title-line)
          #if tags.len() > 0 {
            h(monash-space-sm)
            text(size: .52em, fill: white.transparentize(25%), tags.join([, ]))
          }
        ],
      )
      #if body != [] {
        block(
          width: 100%,
          inset: (x: monash-space-md, top: 0pt, bottom: .32em),
          [
            #set text(size: .84em, fill: monash-charcoal)
            #set par(leading: .72em, spacing: 0pt)
            #set block(above: 0pt, below: 0pt)
            #v(-.52em)
            #body
          ],
        )
      }
    ],
  )
}

/// Typesets a proof as a plain proof paragraph rather than a framed block.
///
/// The proof title is optional in meaning but required by the current call
/// shape. The body is followed by an automatically inserted open square.
///
/// ```typst
/// #proof[Sketch][
///   Apply the theorem and simplify.
/// ]
/// ```
#let proof(
  /// Proof title, usually something short like `Sketch` or `Proof`.
  title,
  /// Proof body.
  body,
) = block(
  width: 100%,
  inset: (x: monash-space-md, y: monash-space-xs),
  [
    #let proof-label = if _has-title(title) {
      [#text(weight: "bold")[Proof] (#title).]
    } else {
      [#text(weight: "bold")[Proof].]
    }
    #set text(size: .84em, fill: monash-charcoal)
    #set par(leading: .72em)
    #proof-label
    #h(.45em)
    #body
    #h(1fr)
    □
  ],
)

/// Activates the Monash frame styling rules.
///
/// Place this show rule in the preamble after `#show: monash-theme.with(...)`.
/// By default, theorem-like frames are numbered independently by environment
/// type. Set `numbering: false` to hide frame numbers.
///
/// ```typst
/// #show: show-monash-frames
/// #show: show-monash-frames.with(numbering: false)
/// ```
#let show-monash-frames(
  /// Whether numbered environments display their independent counters.
  numbering: true,
  /// Document body transformed by the show rule.
  body,
) = {
  let frame-numbering = if numbering { "1" } else { none }

  show figure.where(kind: "monash-definition"): set align(left)
  show figure.where(kind: "monash-definition"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-definition", monash-frame-style)

  show figure.where(kind: "monash-theorem"): set align(left)
  show figure.where(kind: "monash-theorem"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-theorem", monash-frame-style)

  show figure.where(kind: "monash-lemma"): set align(left)
  show figure.where(kind: "monash-lemma"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-lemma", monash-frame-style)

  show figure.where(kind: "monash-corollary"): set align(left)
  show figure.where(kind: "monash-corollary"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-corollary", monash-frame-style)

  show figure.where(kind: "monash-note"): set align(left)
  show figure.where(kind: "monash-note"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-note", monash-frame-style)

  show figure.where(kind: "monash-warning"): set align(left)
  show figure.where(kind: "monash-warning"): set figure(numbering: frame-numbering)
  show: frame-style(kind: "monash-warning", monash-frame-style)

  show figure.where(kind: "monash-remark"): set align(left)
  show figure.where(kind: "monash-remark"): set figure(numbering: none)
  show: frame-style(kind: "monash-remark", monash-frame-style)

  body
}

/// Numbered definition environment.
///
/// Definitions have their own independent counter by default.
///
/// ```typst
/// #definition[Loss Function][
///   A loss function maps predictions and targets to a scalar penalty.
/// ]
/// ```
#let definition = frame(kind: "monash-definition", "Definition", monash-blue)

/// Numbered theorem environment.
///
/// Theorems have their own independent counter by default.
///
/// ```typst
/// #theorem[Convergence][
///   Under the assumptions, the sequence converges.
/// ]
/// ```
#let theorem = frame(kind: "monash-theorem", "Theorem", monash-teal)

/// Numbered lemma environment.
///
/// Lemmas have their own independent counter by default.
///
/// ```typst
/// #lemma[Descent][
///   One optimization step decreases the objective.
/// ]
/// ```
#let lemma = frame(kind: "monash-lemma", "Lemma", monash-blue-grey)

/// Numbered corollary environment.
///
/// Corollaries have their own independent counter by default.
///
/// ```typst
/// #corollary[Rate][
///   The average regret is sublinear.
/// ]
/// ```
#let corollary = frame(kind: "monash-corollary", "Corollary", monash-green)

/// Unnumbered remark environment.
///
/// Remarks keep the Monash frame style but never display a counter.
///
/// ```typst
/// #remark[Design][
///   Use this for short interpretive comments.
/// ]
/// ```
#let remark = frame(kind: "monash-remark", "Remark", monash-slate)

/// Numbered note environment.
///
/// Notes have their own independent counter unless numbering is disabled in
/// `show-monash-frames`.
///
/// ```typst
/// #note[Usage][
///   Frame environments can be placed inside any Touying slide.
/// ]
/// ```
#let note = frame(kind: "monash-note", "Note", monash-blue-dark)

/// Numbered warning environment.
///
/// Warnings use the charcoal accent colour and have their own independent
/// counter unless numbering is disabled in `show-monash-frames`.
///
/// ```typst
/// #warning[Scope][
///   This template does not define an algorithm DSL.
/// ]
/// ```
#let warning = frame(kind: "monash-warning", "Warning", monash-charcoal)
