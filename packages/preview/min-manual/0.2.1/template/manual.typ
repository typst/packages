#import "@preview/min-manual:0.2.1": *

#show: manual.with(
  title: "Package Name",
  description: "Short description, no longer than two lines.",
  authors: "Author <@author>",
  package: "pkg-name:0.4.2",
  license: "MIT",
  logo: image("assets/logo.png")
)


#v(1fr)#outline()#v(1.2fr)
#pagebreak()


= Quick Start

```typm
#import "@preview/pkg-name:0.4.2": feature
#show: feature.with(
  title: "Title",
  date: datetime.today(),
  color: luma(000),
)
```


= Code Extraction and Arguments

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

#v(5pt)
#arg("```typm #show: feature.with()``` -> content")[
  Explanation of what is this structure, what it does, and how to properly set it.
]
#arg("```typm #set feature()``` -> nothing")[
  Explanation of what is this structure, what it does, and how to properly set it.
]
#arg("```typm #feature()``` -> content")[
  Explanation of what is this structure, what it does, and how to properly set it.
]
#arg("title: <- string | content <required>")[
  Explanation of what is this argument, what it does, and how to properly set it.
]
#arg("date: <- string | content <required>")[
  Explanation of what is this argument, what it does, and how to properly set it.
]
#arg("color: <- luma | rgb")[
  Explanation of what is this argument, what it does, and how to properly set it.
]
#arg("size: <- length")[
  Explanation of what is this argument, what it does, and how to properly set it.
]
#v(5pt)

#pagebreak()


= Paper-friendly Links

#url("https://typst.app")[
  This link is accessible on screens (click) and visible on paper (footnote) at
  the same time.
]


= Package URLs

#grid(
  columns: (auto, auto),
  gutter: 1em,
  [*Typst Universe:      *], univ("pkg-typ"),
  [*Python PyPi:         *], pip("pkg-py"),
  [*Rust crate:          *], crate("pkg-rs"),
  [*Package (LaTeX CTAN):*], pkg("https://ctan.org/pkg/pkg-tex"),
  [*Package (Perl CPAN): *], pkg("https://metacpan.org/pod/PKG::PackagePL"),
  [*GitHub repo:         *], gh("user/pkg"),
)


= Terminal Emulation

```term
~$ cd projects/
projects$ sudo su
Password:
projects# echo "The command is red, and the output white."
The command is red, and the output white.
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

You can reference headings even if they are unnumbered, like this @ref section.

#pagebreak()


= Page Space

#lorem(50)

#lorem(70)

#lorem(50)

#lorem(70)

#lorem(50)

#lorem(70)

#lorem(24)