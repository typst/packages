#import "lib.typ": *

// You can uncomment this to test page-wide settings:
// #show: tlp-setup.with("green") 
// (We keep it commented out to show individual boxes clearly first, or we can use it for the whole doc)

#set page(paper: "a4", margin: (x: 2cm, y: 2cm))
#set text(font: "Libertinus Serif", size: 11pt)

= TLP Package Showcase (v2.0)

This document demonstrates the Traffic Light Protocol (TLP) package for Typst, following TLP 2.0 Standards.

== Labels (Black Background, Colored Text)

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  [TLP:RED #tlp-label("red")],
  [TLP:AMBER #tlp-label("amber")],
  [TLP:AMBER+STRICT #tlp-label("amber-strict")],
  [TLP:GREEN #tlp-label("green")],
  [TLP:CLEAR #tlp-label("clear")],
)

== Content Blocks

#tlp-red[
  This is a TLP:RED section.
  Information accessible only to the individual recipients.
]

#tlp-amber[
  This is a TLP:AMBER section.
  Limited disclosure, restricted to participants' organizations.
]

#tlp-amber-strict[
  This is a TLP:AMBER+STRICT section.
  Restricted to participants' organization only.
]

#tlp-green[
  This is a TLP:GREEN section.
  Limited disclosure, restricted to the community.
]

#tlp-clear[
  This is a TLP:CLEAR section.
  Unlimited disclosure.
]

== Page Setup Usage

To set the TLP level for the entire document (Header/Footer), use:

```typst
#show: tlp-setup.with("red")
```
