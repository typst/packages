#import "@preview/min-manual:0.3.0": *

#show: manual.with(
  title: "Package Name",
  description: "Short description, no longer than two lines.",
  authors: "Author <@author>",
  package: "pkg-name:0.4.2",
  license: "MIT",
  logo: image("assets/logo.png")
)


#v(1fr)
#outline()
#v(1.2fr)
#pagebreak()


= Code Extraction

/* Example simulating a snippet in another file or location.
#let feature(
  title: none,
  date: datetime.today(),
  color: luma(250),
  size: auto,
) = {}
*/
#extract(
  "feature",
  from: read("manual.typ")
)


= Arguments

#arg("name: <- type | type | type <required>")[
  Required argument.
]
#arg("name: <- type | type | type")[
  Optional argument.
]
#arg("name: -> type | type | type")[
  Possible output types.
]
#arg("name: <- type | type | type -> type | type <required>")[
  Possible input and output types.
]
#arg("```typ #feature(name)``` -> type | type | type")[
  Syntax highlight.
]
#arg("```typ #set feature(name)```")[
  No input nor output types.
]
#arg("name: <- type | type | type | type | type | type | type | type | type | type | type | type | type | type | type | type <required>")[
  Long list of input types.
]
#arg("name: -> type | type | type | type | type | type | type | type | type | type | type | type | type | type | type | type <required>")[
  Long list of output types.
]
#arg("name: <- type | type | type | type | type | type | type | type -> type | type | type | type | type | type | type | type <required>")[
  Long list of input and output types.
]

#pagebreak()


= Paper-friendly Links

#url("https://typst.app")[This link is clickable on screens and generates a
footnote for print visibility.]


= Package URLs

#grid(
  columns: (auto, auto),
  gutter: 1em,
  [*LuaRocks:      *], pkg("https://luarocks.org/modules/alerque/decasify"),
  [*Typst Universe:*], univ("decasify"),
  [*Python PyPi:   *], pip("decasify"),
  [*Rust crate:    *], crate("decasify"),
  [*GitHub repo:   *], gh("alerque/decasify"),
)


= Terminal Simulation

```term
user@host:~$ cd projects/
user@host:~/projects$ sudo su
Password:
root@host:~/projects# rm foo
rm: cannot remove 'foo': No such file or directory
```


= Code Example

```eg
A #emph[Typst] code *example*
```


= Level 1
== Level 2
=== Level 3
==== Level 4
===== Level 5
====== Level 6


= Heading References <ref>

This is tye @ref section, and the next one is the @callout section.


= Callout <callout>

#callout[Simple default callout.]

#callout(title: "Title")[Callout with title]

// More icon names in https://heroicons.com/
#callout(background: blue, text: white, icon: "exclamation-triangle")[
  Blue callout with white text and custom icon.]

#callout(
  title: "Note",
  text: ( title: (fill: blue) ),
  background: (
    fill: none,
    stroke: (left: 3pt + blue),
    outset: (left: 1em, bottom: 0.45em),
    inset: (left: 0pt),
  ),
  [GitHub-ish customized callout.]
)

#pagebreak()


= Page Space

#lorem(50)

#lorem(70)

#lorem(50)

#lorem(70)

#lorem(50)

#lorem(70)

#lorem(24)
