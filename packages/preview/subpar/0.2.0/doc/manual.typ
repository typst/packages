#import "@local/mantys:0.1.4" as mantys
#import "@preview/hydra:0.4.0": hydra

#import "/src/lib.typ" as subpar

#let package = toml("/typst.toml").package

#let issue(n) = text(
  eastern,
  link("https://github.com/tingerrr/subpar/issues/" + str(n))[subpar\##n],
)

#show: mantys.mantys.with(
  ..package,
  title: [subpar],
  date: datetime.today().display(),
  abstract: [
    SUBPAR provides easy to use sub figures with sensible default numbering and an easy-to-use
    no-setup API.
  ],
  examples-scope: (subpar: subpar),
)

#show raw: it => {
  show "{{VERSION}}": package.version
  it
}

= Manifest
SUBPAR aims to be:
- simple to use
  - importing a function and using it should be all that is needed
  - setup required to make the package work should be avoided
- unsurprising
  - parameters should have sensible names and behave as one would expect
  - deviations from this must be documented and easily accesible to Typst novices
- interoperable
  - SUBPAR should be easy to use with other packages by default or provide sufficient configuration to allow this in other ways
- minimal
  - it should only provide features which are specifically used for sub figures

If you think its behvior is surprising, you believe you found a bug or think its defaults or parameters are not sufficient for your use case, please open an issue at #text(eastern, link("https://github.com/tingerrr/subpar")[GitHub:tingerrr/subpar]).
Contributions are also welcome!

= Guide
== Labeling
Currently to refer to a super figure the label must be explicitly passed to `super` using `label: <...>`.

== Grid Layout
The default `super` function provides only the style rules to make sub figures correctly behave with respect to numbering.
To arrange them in a specific layout, you can use any other Typst function, a common choice would be `grid`.

#mantys.example[```typst
#subpar.super(
  grid(
    [#figure([a], caption: [An image]) <fig1a>],
    [#figure([b], caption: [Another image]) <fig1b>],
    figure([c], caption: [A third unlabeled image]),
    columns: (1fr,) * 3,
  ),
  caption: [A figure composed of three sub figures.],
  label: <fig1>,
)

We can refer to @fig1, @fig1a and @fig1b.
```]

Because this quickly gets cumbersome, SUBPAR provides a default grid layout wrapper called `grid`.
It provides good defaults like `gutter: 1em` and hides options which are undesireable for sub figure layouts like `fill` and `stroke`.
To label sub figures simply add a label after a figure like below.

#mantys.example[```typst
#subpar.grid(
  figure([a], caption: [An image]), <fig2a>,
  figure([b], caption: [Another image]), <fig2b>,
  figure([c], caption: [A third unlabeled image]),
  columns: (1fr,) * 3,
  caption: [A figure composed of three sub figures.],
  label: <fig2>,
)

We can refer to @fig2, @fig2a and @fig2b.
```]

== Numbering
`subpar` and `grid` take three different numberings:
/ `numbering`: The numbering used for the sub figures when displayed or referenced.
/ `numbering-sub`: The numbering used for the sub figures when displayed.
/ `numbering-sub-ref`: The numbering used for the sub figures when referenced.

Similarly to a normal figure, these can be functions or string patterns. The `numbering-sub` and `numbering-sub-ref` patterns will receive both the super figure an sub figure number.

== Supplements
Currently, supplements for super figures propagate down to super figures, this ensures that the supplement in a reference will not confuse a reader, but it will cause reference issues in multilingual documents (see #issue(4)).

#mantys.example[````typst
#subpar.grid(
  figure(```typst Hello Typst!```, caption: [Typst Code]), <sup-ex-code1>,
  figure(lorem(10), caption: [Lorem]),
  columns: (1fr, 1fr),
  caption: [A figure containing two super figures.],
  label: <sup-ex-super1>,
)
````]

When refering the the super figure we see "@sup-ex-super1", when refering to the sub figure of a different kind, we still see the same supplement "@sup-ex-code1".

To turn this behavior off, set `propagate-supplement` to `false`, this will also resolve the issues from #issue(4).

#mantys.example[````typst
#subpar.grid(
  figure(```typst Hello Typst!```, caption: [Typst Code]), <sup-ex-code2>,
  figure(lorem(10), caption: [Lorem]),
  columns: (1fr, 1fr),
  propagate-supplement: false,
  caption: [A figure containing two super figures.],
  label: <sup-ex-super2>,
)
````]

Now when refering the the super figure we see still see "@sup-ex-super2", but when refering to the sub figure of a different kind, we the inferred supplement "@sup-ex-code2".

== Appearance
The `super` and `grid` functions come with a few arguments to control how super or sub figures are rendered.
These work similar to show rules, i.e. they receive the element they apply to and display them.
/ `show-sub`: Apply a show rule to all sub figures.
/ `show-sub-caption`: Apply a show rule to all sub figures' captions.

#mantys.example[```typst
#subpar.grid(
  figure(lorem(2), caption: [An Image of ...]),
  figure(lorem(2), caption: [Another Image of ...]),
  numbering-sub: "1a",
  show-sub-caption: (num, it) => {
    it.supplement
    [ ]
    num
    [: ]
    it.body
  },
  columns: 2,
  caption: [Two Figures],
)
```]

Unfortunately, to change how a super figure is shown without changing how a sub figure is shown you must use a regular show rule and reconstruct the normal appearance in the sub figures using `show-sub`.
Subpar provides a default implementation for this: `subpar.default.show-figure`, it can be passed directly to `show-sub`.

= Reference
== Subpar
The package entry point.
#mantys.tidy-module(read("/src/lib.typ"), name: "subpar")

== Default
Contains default implementations for show rules to easily reverse show rules in a scope.
#mantys.tidy-module(read("/src/default.typ"), name: "default")
