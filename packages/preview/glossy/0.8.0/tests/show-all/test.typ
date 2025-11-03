#import "/lib.typ": *

#show: init-glossary.with((
  one: "this is term one",
  two: "term two also"
))

#set page(
  margin: 1em,
  width: 3.5in,
  height: auto,
)
#set text(size: 10pt)

In this document we don't reference our glossary items but expect them to be
shown anyway.

#glossary(show-all: true)

#glossary(
  theme: theme-chicago-index,
  show-all: true
)

#glossary(
  theme: theme-compact,
  show-all: true
)

#glossary(
  theme: theme-table,
  show-all: true
)
