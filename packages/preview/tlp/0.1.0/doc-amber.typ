#import "lib.typ": *

// Apply TLP:AMBER markings to the header and footer of every page
#show: tlp-setup.with("amber")

#set page(paper: "a4", margin: (x: 2cm, y: 2cm))
#set text(font: "Libertinus Serif", size: 11pt)

= TLP:AMBER Document Example

This document demonstrates the automatic header and footer markings provided by the `tlp` package.

Notice the *TLP:AMBER* label in the top-right (Header) and bottom-right (Footer) of this page.

== Introduction
This content is restricted to the participants' organization and its clients.

#lorem(100)

== Details
#lorem(150)

#pagebreak()

== Second Page
The markings persist on every page automatically.

#lorem(100)
