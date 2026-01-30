= Basics
== Cite, Glossary and Abbreviations
Why don't you take a look at the glossary, to see what @typst is? You can also read more about it in the @typst_paper.

Here are some examples of cursive and bold text:

== Normal
#lorem(25)

== *Bold*
*#lorem(25)*

(All headers are already extra bold)

== _Cursive_
_#lorem(25)_

== *_Bold & Cursive_*
*_#lorem(25)_*

== Tabels and Images
@example_table shows you how beautiful math can be and @example_image shows an example image.

=== Tables
// https://typst.app/docs/reference/model/table/
#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: (center+horizon),
    table.header(
      [], [*Volume*], [*Parameters*],
    ),

    image("../assets/cylinder.svg", fit: "contain", width: 30pt),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    image("../assets/tetrahedron.svg", fit: "contain", width: 30pt),
    $ sqrt(2) / 12 a^3 $,
    [$a$: edge length]
  ),
  caption: "Math is beautiful",
) <example_table>


=== Images
#figure(
  image("../assets/logo.svg"),
  caption: "Replace the logo as described in the README",
) <example_image>


