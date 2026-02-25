// Visual Styles Gallery - exercise-bank
// All 9 badge styles with attractive colors

#import "@preview/exercise-bank:0.4.0": *

#set page(margin: 1.5cm)
#set text(font: "New Computer Modern", size: 11pt)

= Visual Styles

#exo-setup(badge-style: "box")
#exo(exercise: [*Box* (default) - Solve $x + 2 = 5$])

#exo-setup(badge-style: "circled")
#exo(exercise: [*Circled* - Clean and minimal])

#exo-setup(badge-style: "filled-circle", badge-color: rgb("#2563eb"))
#exo(exercise: [*Filled Circle* - High visibility])

#exo-setup(badge-style: "pill", badge-color: rgb("#059669"))
#exo(exercise: [*Pill* - Modern and friendly])

#exo-setup(badge-style: "tag", badge-color: rgb("#7c3aed"))
#exo(exercise: [*Tag* - Callout style])

#exo-setup(badge-style: "border-accent", badge-color: rgb("#d97706"))
#exo(exercise: [*Border Accent* - Document sections])

#exo-setup(badge-style: "underline", badge-color: rgb("#dc2626"))
#exo(exercise: [*Underline* - Classic textbook])

#exo-setup(badge-style: "rounded-box", badge-color: rgb("#0891b2"))
#exo(exercise: [*Rounded Box* - Clean worksheets])

#exo-setup(badge-style: "header-card", badge-color: rgb("#4f46e5"))
#exo(exercise: [*Header Card* - Standalone exercises])
