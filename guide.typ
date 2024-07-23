#import "polytechnique.typ"

#show:  polytechnique.apply

#outline(indent: 1em, depth: 2)

= Discovering Typst and the template

Typst is a user-friendlier alternative to LaTeX.

== Doing some math

== Cite an article

You can cite an article, a book or something like @example-turing. Just see the `#bibliography` command below - you need a `.bib` file containing the bibliography.

== Dummy text with lorem

You can generate dummy text with the `#lorem(n)` command. For example : #lower(lorem(10))

=== Small heading

The small heading above won't appear in the table of contents (because depth is set to 2).

#heading(level: 2, numbering: none)[Heading without numbering]
#lorem(25)

== And again

= Modify the template

== Contribute

Contributions are welcomed ! For now, the source repo is #link("https://github.com/remigerme/typst-polytechnique").

You can also learn more about Typst packages release pipeline : #link("https://github.com/typst/packages").

#bibliography("example.bib")
