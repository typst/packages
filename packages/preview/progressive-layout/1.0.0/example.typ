#import "@preview/progressive-layout:1.0.0": progressive-outline
// #import "lib.typ": progressive-outline

#progressive-outline(
  h1-style: "all",
  h2-style: "all",
  h3-style: "all",
  show-numbering: false
)

= Title 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

#progressive-outline(
  h1-style: "current-and-grayed",
  h2-style: "none",
  h3-style: "none",
  show-numbering: false
)

== Subtitle 1.1

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#progressive-outline(
  h1-style: "none",
  h2-style: "current-and-grayed",
  h3-style: "none",
  show-numbering: false
)

=== Sub-subtitle 1.1.1

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#progressive-outline(
  h1-style: "none",
  h2-style: "none", 
  h3-style: "current-and-grayed",
  show-numbering: false
)

=== Sub-subtitle 1.1.2

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

#progressive-outline(
  h1-style: "none",
  h2-style: "current", 
  h3-style: "current-and-grayed",
  show-numbering: false
)

== Subtitle 1.2

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

= Title 2

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

#progressive-outline(
  h1-style: "current-and-grayed",
  h2-style: "none",
  h3-style: "none",
  show-numbering: false
)

== Subtitle 2.1

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#progressive-outline(
  h1-style: "current",
  h2-style: "current-and-grayed",
  h3-style: "none",
  show-numbering: false
)

== Subtitle 2.2

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

= Title 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

== Subtitle 3.1

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

== Subtitle 3.2

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
