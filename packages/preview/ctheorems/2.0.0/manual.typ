#import "@preview/tidy:0.4.2"
#import "manual-template.typ": *

#show: thm-rules
#show: project.with(
  title: "cTheorems",
  author: "sahasatvik",
  url: "https://github.com/sahasatvik/typst-theorems",
)


#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
)[
  #outline(indent: 2em, target: heading.where(numbering: "1."))
  #v(0.7em)
  #outline(indent: 2em, target: heading.where(numbering: "A.1."), title: none)
][
  This package provides functions that help create numbered theorem
  environments, taking heavy inspiration from the #LATEX packages `amsthm`,
  `thmtools`, `apxproof`.

  A _theorem environment_ combines content with automatically updated
  _numbering_ information.
  Theorem environments can
  - share the same counter (_Theorems_ and _Lemmas_ often do so)
  - have their counters attached to headings or other environments
    (_Corollaries_ are often numbered based upon the parent _Theorem_)
  - be ```typ <label>```-ed and ```typ @reference```-d
  - be restated or deferred to appear later in the document.

  This package also introduces a few miscellaneous features related to
  mathematical writing.
  - Proof environments, with _QED_ symbols.
  - Equation tags.
  - Predefined sets of commonly used theorem environments, and a few themes.
]



= Setup

#example-code(
```typst
#import "@preview/ctheorems:2.0.0": *
#show: thm-rules    // Must include!
```
)
_Applying the #fn("thm-rules") show rule --- in the same `.typ` file where
`ctheorems` functions have been used --- is *essential* for displaying theorem
environments, references, and equations correctly!_

A standard set of theorem environments in the AMS style is available using
#example-code(
```typst
#import thm-themes.ams: *
```
)
This lets you immediately use `theorem`, `proof`, `proposition`, `lemma`,
`corollary`, `definition`, `example`, `remark`, `claim`.
See @thm-themes-ams for more details.


#pagebreak()

= Demonstration

#example(
dir: ltr,
```
<<<#import "@preview/ctheorems:2.0.0": *
#import thm-themes.ams: *
#show: thm-rules.with(
  qed-symbol: $square$
)

#definition[Expectation][
  The expectation of a random variable $X$ on a probability space $(Omega, cal(E), PP)$ is $
    EE[X] = integral X dif PP,
  $ whenever well-defined.
] <expectation>

#remark[
  We require at least one of $EE[X^+], EE[X^-]$ to be finite.
]

#proposition[
  For any $A in cal(E)$, $
    PP(X in A) = EE[bold(1)_A (X)].
  $
] <prob-exp>

#theorem[Markov][
  Let $X >= 0$. For all $a > 0$, $
    PP(X > a) <= EE[X] / a.
  $
] <markov>

#corollary[Chebyshev][
  Let $EE[X] = mu$, $"var"[X] = sigma^2$. Then, $
    PP(|X - mu| >= k sigma) <= 1 / k^2.
  $
] <chebyshev>

#proof[of @markov][
  $
    PP(X thin&> a) \
      &= EE[bold(1)_((a, oo))(X)]
        #tag[(@prob-exp[Prop.])] \
      &<= EE[(X / a) bold(1)_((a, oo))(X)] \
      &<= EE[X] / a. #qedhere
  $
]
```
)



// #pagebreak()

= Features

== Numbered theorems

#example(
```
#let theorem = thm.with(
  supplement: "Theorem",
  base-level: 1
)

#theorem[Euclid][
  There are infinitely many primes.
] <euclid>
```
)

Note that `theorem` inherits its numbering from the current heading (the
default #var("thm.base")).
By setting #var("thm.base-level") to ```typc 1```, this theorem only uses the
first level count from its base.


== References

Since our theorem has been labeled ```typ <euclid>```, we can reference it
elsewhere in the document via ```typ @euclid```.

#example(
```
We will supply a proof of @euclid later.
```
)

References can be fully customized through #var("thm.ref-fmt").
The special supplement `[!]` exposes the `name` of the theorem environment.

#example(
```
Item @euclid[] is named '@euclid[!]'.
```
)

== Chained numbering <chained-numbering>

Theorem environments can be attached together by setting the child's
#var("thm.base") to the parent's #var("thm.counter").

#example(
```
>>>#let theorem = thm.with(supplement: "Theorem", base-level: 1)
#let corollary = thm.with(
  supplement: "Corollary",
  base: "Theorem"
)

#corollary(restate: true)[
  There is no largest prime number.
] <largest-prime>

#proof([of @largest-prime], defer: true)[
  The existence of a largest prime would imply the finitude of the set of primes.
]
```
)

We have set #var("thm.restate") and #var("thm.defer") --- go to @defer-restate
to find out more!

// Setting #var("thm.base") to ```typc none``` produces an unattached, global
// numbering.

== Shared numbering

Theorem environments can share the same numbering by setting a common
#var("thm.counter").
#example(
```
>>>#let theorem = thm.with(supplement: "Theorem", base-level: 1)
#let proposition = thm.with(
  supplement: "Proposition",
  counter: "Theorem",
  base-level: 1
)

#proposition[
  If a natural number divides $a$ and $b$, it also divides $a - b$.
]
```
)

For directly  manipulating theorem counters, see #fn("thm-counter-get"),
#fn("thm-counter-step"), #fn("thm-counter-update").

== Proofs

Theorems go hand in hand with proofs, which are available using #fn("proof").
#example(
```
>>>#let theorem = thm.with(supplement: "Theorem", base-level: 1)
#proof[of @euclid][
  Suppose to the contrary that $p_1, p_2,
  dots, p_n$ is a finite enumeration of
  all primes. Set $P = p_1 p_2 dots p_n$.
  Since $P + 1$ is not in our list, it cannot
  be prime. Thus, some prime factor $p_j$
  divides $P + 1$. Since $p_j$ also divides
  $P$, it must divide the difference $(P + 1)
  - P = 1$, a contradiction.
]
```
)

Proof environments will float a _QED_ symbol ($qed$) at the bottom right by
default.
The symbol can be customized by setting #var("thm-rules.qed-symbol").
If your proof ends in a block equation, or a list/enum, you can place
#var("qedhere") to correctly position the _QED_ symbol.
#example(
```
>>>#let theorem = thm.with(supplement: "Theorem", base-level: 1)
#show: thm-rules.with(qed-symbol: $square$)

#theorem[Prime gaps][
  There are arbitrarily long stretches of composite numbers.
]
#proof[
  For any $n > 2$, consider $
    n! + 2, quad
    n! + 3, quad ..., quad
    n! + n. #qedhere
  $
]
```
)

*Caution*: #var("qedhere") does not play well with numbered equations!


== Equation tags

Tags can be inserted into equations using #fn("tag").
These float to the right, mimicking `\tag` in #LATEX.
#example(
```
$
  (a + b)^2
    &= a^2 + 2 a b + b^2 \
    &<= 2a^2 + 2b^2 #tag[(AM-GM)] \
    &<= 2 thin max{a, b}^2.
$
```
)

// _Remark._ This is essentially how the _QED_ symbol is placed inside equations
// by #var("qedhere").

== Defer, restate, and display <defer-restate>

Theorem environments can be restated, or deferred to later in the document by
setting #var("thm.restate"), #var("thm.defer") as in the example in
@chained-numbering, then calling #fn("thm-restate").

#example(
```
#import thm-state: thm-restate, thm-display

#thm-restate()
```
)

This is often useful for pushing content to the appendix.
For finer control, consider using #var("thm.restate-keys").
#example(
```
>>>#import thm-state: thm-restate, thm-display
Euclid's Theorem states:
#thm-restate(
  [Euclid],
  all: true,
  fmt: thm => thm.body
)
```
)

The #fn("thm-display") function is the most powerful method for manipulating
theorem environments.
The following produces a crude outline of named theorem environments (so far),
excluding proofs; see #var("thm.fmt") for more information about the formatting
function `fmt`.
#example(
dir: ttb,
```
>>>#import thm-state: thm-restate, thm-display
#thm-display(
  thm => thm.name != none and thm.supplement != "Proof",    // Filter
  fmt: thm => {                                             // Format
    let head =[*#thm.supplement~#thm.number*]
    if thm.name != none { head = head + [~(#thm.name)] }
    let page = link(thm.loc, [#thm.loc.position().page])    // Get page number
    [#head~#box(width: 1fr, repeat[.])~#page\ ]
  }
)
```
)
Setting #var("thm-display.final") to ```typc true``` would extend this search
to the entire document.

== Formatting

The default theorem formatting function, #fn("thm-fmt-block") helps with basic
customization of the theorem title and body, along with the surrounding block.

#example(
```
>>>#let theorem = thm.with(supplement: "Theorem", base-level: 1)
#let theorem-standout = theorem.with(
  stroke: 1pt + green,
  fill: green.lighten(95%),
  outset: 0.7em,
  spacing: 1.5em
) // All four arguments are passed to `block`

#theorem-standout(
  title-fmt: x => smallcaps(strong(x))
)[
  There are infinitely many composite numbers.
]
```
)

See #var("thm.fmt") for more information on how to write your own custom
formatting function.


= Acknowledgements

Thanks to
- #link("https://github.com/MJHutchinson")[MJHutchinson] for suggesting and
  implementing the `base-level` and `base: none` features,
- #link("https://github.com/rmolinari")[rmolinari] for suggesting and
  implementing the `separator: ...` feature,
- #link("https://github.com/DVDTSB")[DVDTSB] for contributing
  - the idea of passing named arguments from the theorem directly to the `fmt`
    function.
  - the `number: ...` override feature.
  - the `title: ...` override feature in `thm-plain`.
- #link("https://github.com/PgBiel")[PgBiel] for fixing breaking changes in
  version updates.
- The authors of the  #LATEX packages `amsthm`, `thmtools`, `apxproof`.
- The awesome devs of #link("https://typst.app/")[typst.app] for their
  support.


#pagebreak()
#show: appendix
#set page(margin: 0.7in)


= Function documentation

#counter(heading).update((1, 0))
#set heading(numbering: none, outlined: false)

#heading(level: 2, outlined: true, numbering: "A.1.")[ctheorems]

#let ctheorems = tidy.parse-module(
  read("src/thm.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
  scope: (
    thm-rules-1: (..args, doc) => {
      counter(heading).update(0)
      thm-stored.update(())
      thm-counters.update((:))
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm-rules-2: (..args, doc) => {
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm: thm,
    thm-fmt-block: thm-fmt-block,
    proof: proof,
    proof-body-fmt: proof-body-fmt,
    tag: tag,
    qedhere: qedhere,
  ),
)


#tidy.show-module(
  ctheorems,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  sort-functions: f => {
    (
      "thm",
      "proof",
      "tag",
      "thm-rules",
      "thm-fmt-block",
      "proof-body-fmt",
    ).position(
      x => (f.name == x)
    )
  },
  show-outline: true,
  first-heading-level: 2,
  show-module-name: false,
  break-param-descriptions: true,
)


#counter(heading).update((1, 1))
#heading(level: 2, outlined: true, numbering: "A.1.")[thm-state]

Methods for restating, reformatting, filtering, and manipulating theorem
environments from elsewhere in the document.
Every call to #fn("thm") appends a `thm` data dictionary to the state
#var("thm-stored"), where the keys of `thm` are as described in #var("thm.fmt").

Import all functions using
#example-code(
```typ
#import thm-state: *
```
)


#let thm-state = tidy.parse-module(
  read("src/state.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
  scope: (
    thm-rules-1: (..args, doc) => {
      counter(heading).update(0)
      thm-stored.update(())
      thm-counters.update((:))
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm-rules-2: (..args, doc) => {
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm: thm,
    proof: proof,
    proof-body-fmt: proof-body-fmt,
    tag: tag,
    qedhere: qedhere,
    thm-display-1: thm-display,
    thm-restate: thm-restate,
  ),
)


#tidy.show-module(
  thm-state,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  sort-functions: f => {
    (
      "thm-restate",
      "thm-display",
    ).position(
      x => (f.name == x)
    )
  },
  show-outline: true,
  first-heading-level: 2,
  show-module-name: false,
  break-param-descriptions: true,
)


#counter(heading).update((1, 2))
#heading(level: 2, outlined: true, numbering: "A.1.")[thm-counter]

Exposes methods for manipulating counters used by theorem environments.
Import all functions using
#example-code(
```typ
#import thm-counter: *
```
)

#let thm-counter = tidy.parse-module(
  read("src/counter.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
)


#tidy.show-module(
  thm-counter,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  show-outline: true,
  first-heading-level: 2,
  show-module-name: false,
  break-param-descriptions: true,
)


#let ams = tidy.parse-module(
  read("themes/ams.typ"),
  name: "ams",
  enable-curried-functions: false,
)



#pagebreak()


#counter(heading).update((1, 0))
#heading(level: 1, outlined: true, numbering: "A.1.")[Themes]

#counter(heading).update((2, 0))
#heading(level: 2, outlined: true, numbering: "A.1.")[thm-themes.ams] <thm-themes-ams>

This theme defines the following versions of #fn("thm") in the AMS style.
  - `thm` in the `plain` style, intended for theorems, lemmas, corollaries,
    propositions, conjectures.
  - `thm-def` in the `definition` style, intended for definitions, conditions,
    problems, examples.
  - `thm-rem` in the `remark` style, intended for remarks, notes, annotations,
    claims, cases, acknowledgments, conclusions.

These styles have been used to provide the following environments.
  - `theorem`, `proposition`, `lemma`, `conjecture`, `definition` sharing the
    counter ```typc "Theorem"```, with the default `base` ```typc "heading"```.
  - `corollary`, `example` sharing the counter ```typc "Sub-Theorem"```, with
    `base` ```typc "Thoerem"```.
  - `problem` with its own counter ```typc "Problem"```, with the default
    `base`.
  - `remark`, `claim`, `proof` (un-numbered).


#example(
// dir: btt,
```
>>>#counter(heading).update(0)
>>>#thm-counter.thm-counters.update(x => (:))
<<<#import "@preview/ctheorems:2.0.0": *
#import thm-themes.ams: *
#show: thm-rules

#set heading(numbering: "1.")

= Convergence in Probability

#definition[
  We say that $\{X_n\}$ converges to $X$ in probability if for every $epsilon > 0$, $
    PP(|X_n - X| > epsilon) -> 0
  $ as $n -> oo$.
]
#remark[
  This is denoted $X_n ->^p X$.
]

#example[
  Let $EE[X_n] = 0$ and $EE[X_n^2] -> 0$.
  Then, $X_n ->^p 0$.
]

#theorem[Weak Law of Large Numbers][
  Let $\{X_n\}$ be i.i.d. with $EE[X_1] = mu$, $EE[X_1^2] < oo$. Then $
    1/n sum_(i = 1)^n X_i ->^p mu.
  $
]

#proof[
  #lorem(14)
]
```
)

#let ams = tidy.parse-module(
  read("themes/ams.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
)

#tidy.show-module(
  ams,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  show-outline: false,
  first-heading-level: 2,
  show-module-name: false,
  break-param-descriptions: true,
)



#pagebreak()

#counter(heading).update((2, 1))
#heading(level: 2, outlined: true, numbering: "A.1.")[thm-themes.stripe] <thm-themes-stripe>


This theme creates theorem styles and environments just like `thm-themes.ams`,
but with a formatting function #fn("thm-fmt-stripe") which produces colorful
stripes on the left sides of theorems.

#example(
// dir: btt,
```
>>>#counter(heading).update(0)
>>>#thm-counter.thm-counters.update(x => (:))
<<<#import "@preview/ctheorems:2.0.0": *
#import thm-themes.stripe: *
#show: thm-rules

#set heading(numbering: "1.")

= Convergence in Probability

#definition[
  We say that $\{X_n\}$ converges to $X$ in probability if for every $epsilon > 0$, $
    PP(|X_n - X| > epsilon) -> 0
  $ as $n -> oo$.
]
#remark[
  This is denoted $X_n ->^p X$.
]

#example[
  Let $EE[X_n] = 0$ and $EE[X_n^2] -> 0$.
  Then, $X_n ->^p 0$.
]

#theorem[Weak Law of Large Numbers][
  Let $\{X_n\}$ be i.i.d. with $EE[X_1] = mu$, $EE[X_1^2] < oo$. Then $
    1/n sum_(i = 1)^n X_i ->^p mu.
  $
]

#proof[
  #lorem(14)
]

// Customize stripe
#theorem(stripe: 2pt + red)[Strong Law of Large Numbers][
  Let $\{X_n\}$ be i.i.d. with finite $EE[X_1] = mu$. Then $
    1/n sum_(i = 1)^n X_i ->^"a.s." mu.
  $
]
```
)

#let stripe = tidy.parse-module(
  read("themes/stripe.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
)

#tidy.show-module(
  stripe,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  show-outline: false,
  first-heading-level: 2,
  show-module-name: false,
  break-param-descriptions: true,
)
