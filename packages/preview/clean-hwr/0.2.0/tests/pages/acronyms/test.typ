#import "@preview/acrostiche:0.7.0": init-acronyms

#import "/pages/acronyms.typ": _render-acronyms

#include "/tests/helper/set-l10n-db.typ"

#let acronyms = (
  title: "Custom Acronyms",
  entries: (
    "QPU": ("Quantum Processing Unit", "Quantum Processing Units"),
    "HTML": "Hypertext Markup Language",
    "CSS": ("Cascading Style Sheet", "Cascading Style Sheets"),
  )
)

#init-acronyms(acronyms.entries)
#_render-acronyms(acronyms: acronyms)
