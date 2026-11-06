#import "/src/lib.typ": anti-matter, fence, set-numbering

#set page("a4", height: auto)
#show heading.where(level: 1): it => pagebreak(weak: true) + it

#show: anti-matter

#set-numbering(none)
#align(center)[My Title Page]
#pagebreak()
#set-numbering("I")

#include "front-matter.typ"
#fence()

#include "chapters.typ"
#fence()

#include "back-matter.typ"
