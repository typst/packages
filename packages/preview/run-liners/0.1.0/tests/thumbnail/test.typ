#import "/lib.typ": *

#set page(margin: 1em, height: auto, width: 5in)

*`#run-in-enum()`* creates run-in numbered lists, like:
#run-in-enum(
  [one],
  [two],
  [three],
).

#line(length: 100%)

*`#run-in-list()`* creates run-in bullet points, like:
#run-in-list(
  [one],
  [two],
  [three],
).

#line(length: 100%)

*`#run-in-terms()`* creates run-in term lists, like:
#run-in-terms(
  ([enumerations], [numbered lists]),
  ([lists], [bulleted lists]),
  ([term lists], [definition lists]),
  ([verses], [poetry (or similar) lines])
).

#line(length: 100%)

*`#run-in-verse()`* creates run-in verses, like:
#run-in-verse(
  [Now is the time],
  [for all good men],
  [to come to the aid],
  [of their country]
).
