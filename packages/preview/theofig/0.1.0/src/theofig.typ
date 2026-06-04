#import "translations.typ": theofig-translations

/// This is the core factory function which implements a theorem-like
/// environment on top of `figure`. Most user-facing environments (e.g.
/// `#theorem`, `#definition`, `#proof`) are created with `.with(...)`
/// specializations of this function:
///
/// #[
/// #show raw: set text(6pt)
///
/// ```typst
/// #let definition  = theofig.with(kind: "definition",  supplement: "Definition",  translate-supplement: true)
/// #let theorem     = theofig.with(kind: "theorem",     supplement: "Theorem",     translate-supplement: true)
/// #let proof       = theofig.with(kind: "proof",       supplement: "Proof",       translate-supplement: true, 
///                                                                                 numbering: none, qed: true)
///
/// #let lemma       = theofig.with(kind: "lemma",       supplement: "Lemma",       translate-supplement: true)
/// #let statement   = theofig.with(kind: "statement",   supplement: "Statement",   translate-supplement: true)
/// #let remark      = theofig.with(kind: "remark",      supplement: "Remark",      translate-supplement: true)
/// #let proposition = theofig.with(kind: "proposition", supplement: "Proposition", translate-supplement: true)
/// #let corollary   = theofig.with(kind: "corollary",   supplement: "Corollary",   translate-supplement: true, 
///                                                                                            numbering: none)
///
/// #let example     = theofig.with(kind: "example",     supplement: "Example",     translate-supplement: true)
/// #let algorithm   = theofig.with(kind: "algorithm",   supplement: "Algorithm",   translate-supplement: true)
/// #let problem     = theofig.with(kind: "problem",     supplement: "Problem",     translate-supplement: true)
/// #let solution    = theofig.with(kind: "solution",    supplement: "Solution",    translate-supplement: true, 
///                                                                                            numbering: none)
/// ```]
/// If you wish this list were extended, open an issue in repository, and it will probably added shortly.
/// 
/// - body (content): The contents of the environment.
///   === Example
///   #code-example-row(```typst
///   #theorem[One body]
///   #theorem[Another body]
///   ```)
///
/// - ..note (array with one element): Additional text in supplement, i.e. 
///   author, year, or source of the theorem, like in *Theorem 1 (Cauchy, 1831).*
///   === Example
///   #code-example-row(```typst
///   #theorem[1910][$1 + 1 = 2$.]<th-1>
///   #theorem[Newton–Leibniz][
///     $ integral_a^b f'(x) dif x = f(b) - f(a). $
///   ]
///   Note the absence of note in reference of @th-1.
///   ```)
///
/// - kind (auto, str): The internal `figure.kind` value. If
///   left `auto` and a string `supplement` is provided (not `auto` or
///   `content`), the function will set `kind = lower(supplement)` so the kind
///   can be inferred from the supplement like `"Theorem"` $->$ `"theorem"`.
///
///   === Example
///   #code-example-row(```typst
///   #let axiom = theofig.with(
///     supplement: "Axiom", kind: "definition"
///   )
///   #definition[]
///   #axiom[
///     Due to (`kind: "definition"`), numbering and 
///     show rules are shared with `#definition()`.
///   ]
///   #definition[]
///   ```)
/// 
/// - supplement (auto, str, content): The figure supplement (the
///   textual label that appears as the environment title, e.g. `"Theorem"`,
///   `"Definition"`). Behavior:
///   - `auto` — the function attempts to translate the `kind` using
///     `theofig-translations` keyed by `text.lang` (so environments adapt to
///     document language).
///   - If `supplement` explicitly provided as string and `translate-supplement
///     == true`, the code will try to translate the supplement using
///     `theofig-translations` dictionary using contextual `text.lang`. If
///     there is no match in dictionary or `translate-supplement == false`,
///     `supplement` is used as is.
///   - If `kind` is `auto` and `supplement`, `kind` is set to
///     `lower(supplement)` (automatic kind from supplement).
///
///   === Example 1: Automatic kind selection
///   #code-example-row(```typst
///   #let story = theofig.with(supplement: "Story")
///   #show figure.where(kind: "story"): text.with(
///     fill: gradient.linear(
///       red, orange, green, blue, fuchsia
///     ),
///   )
///   #story[#lorem(25)]
///   #story[#lorem(5)]
///   ```)
///
///   === Example 2: Content supplement
///   #code-example-row(```typst
///   #let dream = theofig.with(
///     supplement: [D#sub[R]#super[E]#sub[A]M],
///     kind: "dream",
///   )
///   #dream[I am in a @dream-2.]<dream-2>
///   ```)
///
///   Note that if `kind` was omitted in the example 2, numeration would be
///   shown, but counter would be 0 everywhere.
/// 
/// - number (auto, int, label, other): Allows overriding the environment
///   number. Behaviors:
///   - `auto` --- default tracking (no manual override).
///     `int` --- uses that integer as the numbering (wrapped into a numbering
///     function). If `numbering == none`, it produces an error.
///   - `label` --- uses the counter number  of an existing labeled figure; if
///     `numbering == auto` the code also sets up `numbering` to produce
///     the same numbering as the labeled figure's counter value.
///   - other values are used verbatim with `numbering = (..) => number`.
/// 
/// - numbering (auto, none, str, function): The formatting function/style
///   for the displayed number (e.g. Roman, alphabetic).
///   Setting `auto` makes the function use either `figure.numbering` (default),
///   otherwise this argument takes precedence over `figure.numbering`, which
///   can be set using show rules or `figure-options` argument.
///   #code-example-row(```typst
///   #definition[It is @def-r-1.]<def-r-1>
///
///   #show figure.where(kind: "definition"): set figure(numbering: "A")
///   #definition[It is @def-r-2.]<def-r-2>
///
///   #let definition = definition.with(
///     figure-options: (numbering: "I"),
///   )
///   #definition[It is @def-r-3.]<def-r-3>
///   
///   #let definition = definition.with(
///     numbering: "(i)",
///   )
///   #definition[It is @def-r-4.]<def-r-4>
///
///   #let definition = definition.with(
///     numbering: numbering.with("(i)"),
///   )
///   #definition[It is @def-r-5.]<def-r-5>
///   ```)
/// 
/// - block-options (dictionary): Options passed to the inner
///   `block(...)` call; use to control visual block styling (stroke, inset,
///   radius, breakable, width etc.) without affecting nested blocks (as show
///   rules do).
/// 
/// - figure-options (dictionary): Options passed to
///   `figure(...)`. If `numbering` is determined (not `auto`), `figure-options` is
///   augmented with `numbering: numbering`.
/// 
/// - format-caption (none, function, array of functions): Function(s) applied to
///   the `supplement` (the title part) before rendering. If `none`, no special
///   formatting is applied. Typical values: `emph`, `smallcaps`, `strong`, or
///   user-provided functions.
///
///   === Example
///   #code-example-row(```typst
///   #theorem[]
///   #theorem(format-caption: none)[]
///   #theorem(format-caption: emph)[]
///   #theorem(format-caption:(smallcaps,underline))[]
///   ```)
/// 
/// - format-body (none, function, array of functions): Function(s) applied to the
///   body content (the environment contents). If `none`, no additional formatting
///   is applied.
///
///   === Example
///   #code-example-row(```typst
///   #theorem[#lorem(5)]
///   #theorem(format-body: emph)[#lorem(5)]
///   #theorem(
///     format-body: (text.with(blue), smallcaps,)
///   )[#lorem(4)]
///   ```)
///
/// - format-note (none, function, array of functions): Function(s) applied to the
///   note content (additional info to the caption, like authorship, date, or
///   source). If `none`, no additional formatting is applied.
///   === Example
///   #code-example-row(```typst
///   #theorem[Note][#lorem(3)]
///   #theorem(format-note: none)[`{Note}`][#lorem(3)]
///   #theorem(format-note: 
///     it => strong(delta: -300, [[#it]])
///   )[Note][#lorem(3)]
///   #theorem(format-note: (raw, emph), "note")[#lorem(3)]
///   ```)
///
/// - separator (none, str, content): Text appended between caption 
///   (supplement + caption + numbering) and the body. Behavior:
///   - `auto` --- follows `figure.caption.separator`. If `figure.caption.separator` is also auto, separator becomes `"."`.
///   - Otherwise, this argument takes precedence over `figure.caption.separator`.
///
///   === Example
///   #code-example-row(```typst
///   #definition[Default separator.]
///
///   #show figure.where(
///     kind: "definition"
///   ): set figure.caption(separator: "?")
///   #definition[Separator from show rule.]
///
///   #let definition = definition.with(
///     separator: none
///   )
///   #definition[Separator from `.with()` specialization.]
///
///   #definition(separator: ":")[Separator from argument.]
///   ```)
/// 
/// - translate-supplement (bool): Whether a provided `supplement` should be
///   passed through `theofig-translations` dictionary to allow localized titles. 
///   If `true` and `supplement` provided, package will attempt to map the lowercased 
///   supplement through `theofig-translations` for
///   the current contextual `text.lang`. Note that if figure and a reference to it 
///   are in different languages, figure caption and reference supplement will have
///   different languages as well.
///
///   It is `false` by default but is set to `true` for all user-facing environments
///   #theofig-kinds.map(s => raw("#" + s + "()")).join(", ", last: ", and ").
/// 
/// - qed (bool): If `true`, a `math.qed` marker (rendered as a box `∎`) is
///   added after the body. This is used for `proof` to append the end-of-proof
///   marker. Note that `math.qed` symbol can be changed using 
///   `show math.qed: ...` rule.
#let theofig(
  ..note,
  body,
  kind: auto, 
  supplement: auto, 
  number: auto,
  numbering: auto, 
  block-options: (:),
  figure-options: (:),
  format-caption: strong,
  format-body: none,
  format-note: it => [(#it)],
  separator: auto,
  translate-supplement: false,
  qed: false,
) = {
  let note = note.pos().at(0, default: none)
  if (kind == auto and type(supplement) == str) { kind = lower(supplement) }
  let supplement = context { 
    if (supplement == auto) {
      theofig-translations.at(text.lang).at(kind, default: kind)
    } else if type(supplement) == str and translate-supplement {
      theofig-translations.at(text.lang).at(lower(supplement), default: supplement)
    } else {
      supplement
    }
  } 
  if (number != auto) {
      if type(number) == label {
        if numbering == auto {
          numbering = (..) => context {
            std.numbering(figure.numbering, 
                          counter(figure.where(kind: kind)).at(number).first())
          }
        } else {
          numbering = (..) => {
            std.numbering(numbering, 
                          counter(figure.where(kind: kind)).at(number).first())
          }
        }
      } else if type(number) == int {
        if numbering == auto {
          numbering = (..) => context std.numbering(figure.numbering, number)
        } else {
          numbering = (..) => std.numbering(numbering, number)
        }
      } else {
          numbering = (..) => number
      }
  }
  if numbering != auto {
    figure-options += (numbering: numbering)
  }
  figure(
    // placement: none, 
    kind: kind, 
    supplement: supplement, 
    ..figure-options,
    block(
      width: 100%,
      breakable: true,
      sticky: true,
      ..block-options,
      context {
        let body = body
        let note = note
        let supplement = supplement
        let numbering = numbering 
        let separator = separator
        
        if number != auto {
          counter(figure.where(kind: kind)).update(n => n - 1)
        }

        if numbering == auto {
          if "numbering" in figure-options {
            numbering = figure-options.numbering
          } else {
            numbering = figure.numbering
          }
        }

        if numbering != none {
          supplement += [ #counter(figure.where(kind: kind)).display(numbering)]
        }

        if note != none { 
          if format-note != none {
            if type(format-note) == array {
              for f in format-note {
                note = f(note)
              }
            } else {
              note = format-note(note)
            } 
          }
          supplement += [ #note] 
        }

        if separator == auto {
          if (figure.caption.separator != auto) {
            separator = figure.caption.separator
          } else {
            separator = "."
          }
        }
        supplement += separator

        if format-caption != none {
          if type(format-caption) == array {
            for f in format-caption {
              supplement = f(supplement)
            }
          } else {
            supplement = format-caption(supplement)
          } 
        }

        if format-body != none {
          if type(format-body) == array {
            for f in format-body {
              body = f(body)
            }
          } else {
            body = format-body(body)
          } 
        }

        set par(first-line-indent: par.first-line-indent + (all: false))

        set align(left)
        [#box(figure.caption(supplement)) #body #if (qed) { h(1fr); math.qed }]
      }
    )
  )
}

