#import "../SETUP/ELEMENTS.typ": ELEM

#set page(..ELEM.page.normal)
#set par(..ELEM.par.normal)
#set text(..ELEM.text.normal)
#counter(heading).update(0)
#set heading(numbering: "A.1.")

#include "appendix-a.typ"

#set page(..ELEM.page.roman)
#set par(..ELEM.par.bare)
#set heading(numbering: none)

#include "references.typ"

#set par(..ELEM.par.normal)

#include "glossary.typ"
#include "index.typ"

#set par(..ELEM.par.bare)

#include "disclaimers.typ"

