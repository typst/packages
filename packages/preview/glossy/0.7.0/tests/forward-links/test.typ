#import "/lib.typ": *
#import "@preview/glossarium:0.5.3": *

#set page(height: auto, width: 4.5in)
#show link: set text(fill: red)

// -----------------------------------------------------------------------------

= `glossy`:

#box(
  stroke: 1pt,
  inset: 1em,
  [
    #show: init-glossary.with((WWW: "World Wide Web"))

    This should be a link: @WWW

    This should be a link, too: @WWW

    #glossary()
  ]
)

// -----------------------------------------------------------------------------

= `glossarium`:

#box(
  stroke: 1pt,
  inset: 1em,
  [
    #show: make-glossary
    #let entry-list = (
      (key: "ML", short: "ML", long: "Machine Learning"),
    )
    #register-glossary(entry-list)

    This should be a link: @ML

    This should be a link, too: @ML

    #print-glossary(entry-list)
  ]
)
