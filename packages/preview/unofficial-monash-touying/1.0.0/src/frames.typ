// Theorem-like environments built on frame-it, and the proof environment.

#import "@preview/frame-it:2.1.0": frame, frame-style
#import "design.typ": *
#import "labels.typ": labels

// Every framed environment: label key, accent colour, whether it is
// numbered, and whether it joins the shared counter. The frame-it kind is
// "monash-" followed by the name.
#let _environments = (
  (name: "definition", color: monash-blue, numbered: true, shared: true),
  (name: "theorem", color: monash-teal, numbered: true, shared: true),
  (name: "lemma", color: monash-blue-grey, numbered: true, shared: true),
  (name: "corollary", color: monash-green, numbered: true, shared: true),
  (name: "proposition", color: monash-teal, numbered: true, shared: true),
  (name: "assumption", color: monash-blue-dark, numbered: true, shared: true),
  (name: "example", color: monash-orange, numbered: true, shared: false),
  (name: "exercise", color: monash-orange, numbered: true, shared: false),
  (name: "remark", color: monash-slate, numbered: false, shared: false),
  (name: "note", color: monash-blue-dark, numbered: false, shared: false),
  (name: "warning", color: monash-charcoal, numbered: false, shared: false),
).map(env => env + (kind: "monash-" + env.name))

// The counter used by `shared-counter: true`.
#let _shared-counter = counter("monash-shared-statement")

// Counters Touying must rewind on every subslide so that a frame on a slide
// with `#pause` is counted once.
#let frame-counters = (
  _environments.map(env => counter(figure.where(kind: env.kind)))
    + (_shared-counter,)
)

#let _has-title(title) = title not in (none, [], "")

#let _frame-fill(accent-color) = if accent-color == monash-charcoal {
  monash-grey-light
} else {
  accent-color.transparentize(93%)
}

#let _frame-header(title, tags, supplement, number, accent-color) = {
  let label = if number == none { supplement } else { [#supplement #number] }
  let line = if _has-title(title) { [#label: #title] } else { label }
  block(
    width: 100%,
    fill: accent-color,
    inset: (x: space-md, y: space-xs),
    below: 0pt,
    {
      text(size: .68em, fill: white, weight: "bold", line)
      if tags.len() > 0 {
        h(space-sm)
        text(size: .52em, fill: white.transparentize(25%), tags.join([, ]))
      }
    },
  )
}

// The body uses ordinary flow spacing, so paragraphs, lists, equations, and
// code blocks are separated as they are outside a frame.
#let _frame-body(body) = if body not in (none, []) {
  block(width: 100%, inset: (x: space-md, top: .5em, bottom: .55em), {
    set text(size: .84em, fill: monash-charcoal)
    set par(leading: .55em, spacing: .8em)
    set block(spacing: .8em)
    body
  })
}

/// Styling function of the Monash environments, in frame-it's style
/// signature. `show-monash-frames` installs it; call it directly only to
/// style your own frame-it kinds the Monash way.
#let monash-frame-style(
  /// Frame title, or `none`.
  title,
  /// Extra tags shown after the title.
  tags,
  /// Frame body.
  body,
  /// Environment name, such as "Theorem".
  supplement,
  /// Formatted number, or `none` when unnumbered.
  number,
  /// Accent colour of the frame.
  accent-color,
) = block(
  width: 100%,
  fill: _frame-fill(accent-color),
  stroke: (
    left: (paint: accent-color, thickness: frame-rule),
    rest: (paint: monash-grey-soft, thickness: .55pt),
  ),
  radius: 2pt,
  inset: 0pt,
  {
    _frame-header(title, tags, supplement, number, accent-color)
    _frame-body(body)
  },
)

#let _make(env) = frame(kind: env.kind, labels.at(env.name), env.color)

// Install the rules for one environment around `body`.
#let _install(env, numbering, shared-counter, body) = {
  let numbered = numbering and env.numbered
  let shared = numbered and shared-counter and env.shared
  let pattern = if not numbered { none } else if shared {
    (..) => context std.numbering("1", _shared-counter.get().first())
  } else { "1" }
  show figure.where(kind: env.kind): set align(left)
  show figure.where(kind: env.kind): set figure(numbering: pattern)
  show figure.where(kind: env.kind): it => {
    if shared { _shared-counter.step() }
    it
  }
  show: frame-style(kind: env.kind, monash-frame-style)
  body
}

// References to environments: the shared number when the shared counter is
// on, and the bare name when numbering is off.
#let _reference(numbering, shared-counter, it) = {
  let el = it.element
  if el == none or el.func() != figure { return it }
  let env = _environments.find(env => env.kind == el.kind)
  if env == none { return it }
  let numbered = numbering and env.numbered
  let shared = numbered and shared-counter and env.shared
  if it.form != "normal" or (numbered and not shared) { return it }
  let supplement = if it.supplement == auto { el.supplement } else if (
    type(it.supplement) == function
  ) { (it.supplement)(el) } else { it.supplement }
  let number = if shared {
    // The counter is stepped inside the frame, just after its location.
    str(_shared-counter.at(el.location()).first() + 1)
  }
  let parts = (supplement, number).filter(part => part not in (none, []))
  link(el.location(), parts.join([~]))
}

/// Activates the Monash environments. Place it after `monash-theme`.
///
/// By default each numbered environment counts on its own (Theorem 1,
/// Lemma 1). With `shared-counter: true`, definitions, theorems, lemmas,
/// corollaries, propositions, and assumptions share one counter (Theorem 1,
/// Lemma 2); examples and exercises keep their own.
///
/// ```typst
/// #show: show-monash-frames
/// #show: show-monash-frames.with(shared-counter: true)
/// #show: show-monash-frames.with(numbering: false)
/// ```
#let show-monash-frames(
  /// Whether numbered environments show numbers.
  numbering: true,
  /// Whether statement-like environments share one counter.
  shared-counter: false,
  /// Document body transformed by the show rule.
  body,
) = {
  show ref: _reference.with(numbering, shared-counter)
  _environments.fold(body, (acc, env) => _install(env, numbering, shared-counter, acc))
}

/// Numbered definition. `#definition[Body]` or `#definition[Title][Body]`.
#let definition = _make(_environments.at(0))

/// Numbered theorem. `#theorem[Body]` or `#theorem[Title][Body]`; label it
/// with `<name>` and reference it with `@name`.
#let theorem = _make(_environments.at(1))

/// Numbered lemma. `#lemma[Body]` or `#lemma[Title][Body]`.
#let lemma = _make(_environments.at(2))

/// Numbered corollary. `#corollary[Body]` or `#corollary[Title][Body]`.
#let corollary = _make(_environments.at(3))

/// Numbered proposition. `#proposition[Body]` or `#proposition[Title][Body]`.
#let proposition = _make(_environments.at(4))

/// Numbered assumption. `#assumption[Body]` or `#assumption[Title][Body]`.
#let assumption = _make(_environments.at(5))

/// Numbered example with its own counter. `#example[Body]` or
/// `#example[Title][Body]`.
#let example = _make(_environments.at(6))

/// Numbered exercise with its own counter. `#exercise[Body]` or
/// `#exercise[Title][Body]`.
#let exercise = _make(_environments.at(7))

/// Unnumbered remark. `#remark[Body]` or `#remark[Title][Body]`.
#let remark = _make(_environments.at(8))

/// Unnumbered note. `#note[Body]` or `#note[Title][Body]`.
#let note = _make(_environments.at(9))

/// Unnumbered warning. `#warning[Body]` or `#warning[Title][Body]`.
#let warning = _make(_environments.at(10))

/// Proof, typeset as a paragraph rather than a frame and closed with a
/// square at the right end of its last line.
///
/// ```typst
/// #proof[Apply the lemma and telescope.]
/// #proof[Sketch][Apply the lemma and telescope.]
/// ```
#let proof(
  /// `[Body]`, or `[Title][Body]`.
  ..args,
) = {
  let pos = args.pos()
  assert(
    pos.len() in (1, 2) and args.named().len() == 0,
    message: "unofficial-monash-touying: use #proof[Body] or #proof[Title][Body].",
  )
  let (title, body) = if pos.len() == 2 { pos } else { (none, pos.first()) }
  let name = text(weight: "bold", labels.proof)
  let lead = if _has-title(title) { [#name (#title).] } else { [#name.] }
  block(width: 100%, inset: (x: space-md, y: space-xs), {
    set text(size: .84em, fill: monash-charcoal)
    set par(leading: .55em, spacing: .8em)
    [#lead #body#h(1fr)#sym.square.stroked]
  })
}
