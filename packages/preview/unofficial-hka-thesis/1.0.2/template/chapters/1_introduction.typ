
#import "@preview/unofficial-hka-thesis:1.0.2": todo, flex-caption
#import "@preview/glossarium:0.5.9": gls, glspl

= Introduction

#lorem(800)

== Motivation

#lorem(250)

#lorem(36)

#lorem(30)

=== Third Level

#lorem(550)

== Objective

#lorem(300)

This is an example citation @Smith.2020. #gls("oidc_custom") means @oidc_custom. @figure describes @table which is shown in @listing. Test a b c d.

#figure(
  image("/figures/tiger.png", width: 80%),
  caption: flex-caption(
    [This is my long caption text in the document. @a],
    [This is short],
  )
) <figure>

#figure(
  table(
    columns: (1fr, auto, auto),
    inset: 10pt,
    align: horizon,
    [], [*Area*], [*Parameters*],
    "Text",
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],
    "Text",
    $ sqrt(2) / 12 a^3 $,
    [$a$: edge length]
  ),
  caption: flex-caption(
    [This is my long caption text in the document. @b],
    [This is short],
  )
) <table>

#figure(
  ```rust
  fn main() {
      println!("Hello World!");
  }
  ```,
  caption: flex-caption(
    [This is my long caption text in the document. @c],
    [This is short],
  )
) <listing>