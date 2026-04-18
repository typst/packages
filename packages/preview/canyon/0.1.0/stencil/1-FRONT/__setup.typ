#import "../SETUP/ELEMENTS.typ": ELEM

#set heading(numbering: none)
#set page(..ELEM.page.blanket)

#include "half-title.typ"

#pagebreak(to: "odd")
#set page(..ELEM.page.roman)

#include "title.typ"

#include "credits.typ"
#include "outline.typ"
#include "lists.typ"
#include "preface.typ"

#pagebreak(to: "odd")
