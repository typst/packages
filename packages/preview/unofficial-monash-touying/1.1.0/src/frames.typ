// Theorem-like environments built on frame-it, and the proof environment.

#import "@preview/frame-it:2.1.0": frame, frame-style
#import "@preview/touying:0.8.0": config-common, touying-set-config, utils
#import "design.typ": *
#import "backlinks.typ": back-link-here, backref-marker, current-target, link-style
#import "labels.typ": label-keys, label-text, with-labels

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
  (name: "exercise", color: exercise-purple, numbered: true, shared: false),
  (name: "remark", color: monash-slate, numbered: false, shared: false),
  (name: "note", color: monash-blue-dark, numbered: false, shared: false),
  (name: "warning", color: warning-red, numbered: false, shared: false),
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
      text(size: .68em, fill: white, weight: "bold", back-link-here(line))
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

// The light style: a rule at the left and the label in colour at the start
// of the text, without a header bar or a fill.
#let _plain-frame-style(title, tags, body, supplement, number, accent-color) = block(
  width: 100%,
  stroke: (left: (paint: accent-color, thickness: frame-rule)),
  inset: (left: space-md, y: .3em),
  {
    set text(size: .84em, fill: monash-charcoal)
    set par(leading: .55em, spacing: .8em)
    set block(spacing: .8em)
    let label = if number == none { supplement } else { [#supplement #number] }
    let name = text(fill: accent-color, weight: "bold", back-link-here(label))
    let lead = if _has-title(title) { [#name (#title).] } else { [#name.] }
    [#lead #body]
  },
)

#let _styles = (filled: monash-frame-style, plain: _plain-frame-style)

// An environment function. `numbered: false` on a call leaves that frame
// without a number and does not advance the counter. Called with
// `monash-env: true` it returns its description, which is how
// `show-monash-frames(extra: ..)` recognises a custom environment.
#let _make(env, supplement) = {
  let base = frame(kind: env.kind, supplement, env.color)
  (..args, numbered: true, monash-env: false) => {
    if monash-env { return env }
    base(..args, ..if not numbered { (numbering: none) })
  }
}

/// Creates your own environment in the Monash style. List it in
/// `show-monash-frames(extra: ..)` to activate it.
///
/// ```typst
/// #let claim = monash-frame("Claim", color: monash-teal)
/// #show: show-monash-frames.with(extra: (claim,))
///
/// #claim[Every bounded sequence has a convergent subsequence.]
/// ```
#let monash-frame(
  /// Name shown in the frame, such as "Claim".
  name,
  /// Accent colour.
  color: monash-blue,
  /// Whether the environment is numbered. It has its own counter.
  numbered: true,
) = {
  assert(
    type(name) == str and name != "",
    message: "unofficial-monash-touying: `monash-frame` needs a name such as \"Claim\".",
  )
  assert(type(color) == std.color, message: "unofficial-monash-touying: `color` must be a color.")
  let env = (
    name: name,
    color: color,
    numbered: numbered,
    shared: false,
    kind: "monash-custom-" + lower(name).replace(" ", "-"),
  )
  _make(env, name)
}

// Install the rules for one environment around `body`.
#let _install(env, numbering, shared-counter, style, body) = {
  let numbered = numbering and env.numbered
  let shared = numbered and shared-counter and env.shared
  let pattern = if not numbered { none } else if shared {
    (..) => context std.numbering("1", _shared-counter.get().first())
  } else { "1" }
  show figure.where(kind: env.kind): set align(left)
  show figure.where(kind: env.kind): set figure(numbering: pattern)
  show figure.where(kind: env.kind): it => {
    if shared and it.numbering != none { _shared-counter.step() }
    current-target.update(it.at("label", default: none))
    it
  }
  show: frame-style(kind: env.kind, style)
  body
}

// References to environments: the shared number when the shared counter is
// on, and the bare name when numbering is off.
#let _reference(environments, numbering, shared-counter, it) = {
  let el = it.element
  if el == none or el.func() != figure { return it }
  let env = environments.find(env => env.kind == el.kind)
  if env == none { return it }
  let numbered = numbering and env.numbered
  let shared = numbered and shared-counter and env.shared
  if it.form != "normal" { return it }
  // An untouched reference gets its marker from the theme's rule.
  if numbered and not shared { return it }
  let marker = backref-marker(it.target)
  let supplement = if it.supplement == auto { el.supplement } else if (
    type(it.supplement) == function
  ) { (it.supplement)(el) } else { it.supplement }
  let number = if shared {
    // The counter is stepped inside the frame, just after its location.
    str(_shared-counter.at(el.location()).first() + 1)
  }
  let parts = (supplement, number).filter(part => part not in (none, []))
  link(el.location(), link-style(parts.join([~]))) + marker
}

#let _check-labels(labels) = {
  assert(
    type(labels) == dictionary,
    message: "unofficial-monash-touying: `labels` must be a dictionary such as `(theorem: \"Thm\")`.",
  )
  for (key, value) in labels {
    assert(
      key in label-keys,
      message: "unofficial-monash-touying: `labels` has no key `" + key + "`. Valid keys are: " + label-keys.join(", ") + ".",
    )
    assert(
      type(value) in (str, content),
      message: "unofficial-monash-touying: `labels." + key + "` must be a string or content.",
    )
  }
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
/// #show: show-monash-frames.with(labels: (theorem: "Thm"))
/// ```
#let show-monash-frames(
  /// Whether numbered environments show numbers.
  numbering: true,
  /// Whether statement-like environments share one counter.
  shared-counter: false,
  /// Labels that replace the built-in ones, such as `(theorem: "Thm")`.
  /// The keys are the environment names, `proof`, and `thank-you`.
  labels: (:),
  /// Look of the frames: `"filled"` has a coloured header bar, `"plain"`
  /// has a rule at the left and the name in colour at the start of the text.
  style: "filled",
  /// Your own environments, made with `monash-frame`.
  extra: (),
  /// Document body transformed by the show rule.
  body,
) = {
  _check-labels(labels)
  assert(
    style in _styles,
    message: "unofficial-monash-touying: `style` must be \"filled\" or \"plain\", got " + repr(style) + ".",
  )
  assert(
    type(extra) == array and extra.all(item => type(item) == function),
    message: "unofficial-monash-touying: `extra` must be an array of environments made with `monash-frame`, such as `(claim,)`.",
  )
  let custom = extra.map(item => item(monash-env: true))
  let environments = _environments + custom
  show ref: _reference.with(environments, numbering, shared-counter)
  let body = with-labels(labels, body)
  let body = environments.fold(body, (acc, env) => {
    _install(env, numbering, shared-counter, _styles.at(style), acc)
  })
  // Touying must rewind the custom counters on every subslide too.
  if custom == () { body } else {
    touying-set-config(
      config-common(frozen-counters: custom.map(env => counter(figure.where(kind: env.kind)))),
      body,
    )
  }
}

/// Numbered definition. `#definition[Body]` or `#definition[Title][Body]`.
#let definition = _make(_environments.at(0), label-text(_environments.at(0).name))

/// Numbered theorem. `#theorem[Body]` or `#theorem[Title][Body]`; label it
/// with `<name>` and reference it with `@name`.
#let theorem = _make(_environments.at(1), label-text(_environments.at(1).name))

/// Numbered lemma. `#lemma[Body]` or `#lemma[Title][Body]`.
#let lemma = _make(_environments.at(2), label-text(_environments.at(2).name))

/// Numbered corollary. `#corollary[Body]` or `#corollary[Title][Body]`.
#let corollary = _make(_environments.at(3), label-text(_environments.at(3).name))

/// Numbered proposition. `#proposition[Body]` or `#proposition[Title][Body]`.
#let proposition = _make(_environments.at(4), label-text(_environments.at(4).name))

/// Numbered assumption. `#assumption[Body]` or `#assumption[Title][Body]`.
#let assumption = _make(_environments.at(5), label-text(_environments.at(5).name))

/// Numbered example with its own counter. `#example[Body]` or
/// `#example[Title][Body]`.
#let example = _make(_environments.at(6), label-text(_environments.at(6).name))

/// Numbered exercise with its own counter. `#exercise[Body]` or
/// `#exercise[Title][Body]`.
#let exercise = _make(_environments.at(7), label-text(_environments.at(7).name))

/// Unnumbered remark. `#remark[Body]` or `#remark[Title][Body]`.
#let remark = _make(_environments.at(8), label-text(_environments.at(8).name))

/// Unnumbered note. `#note[Body]` or `#note[Title][Body]`.
#let note = _make(_environments.at(9), label-text(_environments.at(9).name))

/// Unnumbered warning. `#warning[Body]` or `#warning[Title][Body]`.
#let warning = _make(_environments.at(10), label-text(_environments.at(10).name))

// Splits a body that ends with a display equation into what comes before
// and that equation; `(body, none)` otherwise.
#let _split-final-equation(body) = {
  if body.func() != [].func() and body.func() != [a b].func() { return (body, none) }
  let children = body.fields().at("children", default: ())
  let blank = ([ ], parbreak(), linebreak())
  while children.len() > 0 and children.last() in blank { let _ = children.pop() }
  if children.len() == 0 { return (body, none) }
  let last = children.last()
  if last.func() == math.equation and last.block {
    (children.slice(0, -1).join(), last)
  } else { (body, none) }
}

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
  let name = text(weight: "bold", label-text("proof"))
  let lead = if _has-title(title) { [#name (#title).] } else { [#name.] }
  // A grey rule in line with the frames ties the proof to its statement.
  block(
    width: 100%,
    above: .7em,
    stroke: (left: (paint: monash-grey, thickness: frame-rule)),
    inset: (left: space-md, right: space-md, y: space-xs),
    {
      set text(size: .84em, fill: monash-charcoal)
      set par(leading: .55em, spacing: .8em)
      set block(spacing: .8em)
      let (rest, equation) = _split-final-equation(body)
      if equation == none {
        [#lead #body#h(1fr)#sym.square.stroked]
      } else {
        // The end mark sits on the line of a closing display equation.
        [#lead #rest]
        block(width: 100%, {
          place(right + horizon, sym.square.stroked)
          equation
        })
      }
    },
  )
}
