// ===========================================================================
//  ticket — torn stub (original fancy.ticket)
//
//    typst compile pages/ticket.typ pages/ticket.pdf --root .
// ===========================================================================

#import "/lib.typ": *
#import "/pages/_preview.typ": titre

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= ticket — torn stub

A card with a half-disc bitten out of each short side and a dashed tear.
`stub:` paints the leading coupon. Direction-aware.

#titre[1. LTR — admit stub]

#ticket(stub: [12], width: 100%)[
  *ADMIT ONE* \
  Friday 23 Aug · Door 19:30
]

#titre[2. LTR — colours / no stub]

#grid(columns: (1fr, 1fr), gutter: 0.4cm,
  ticket(stub: [A4], colour: rgb("#1E5CB3"), width: 100%)[
    *GALLERY* \
    Row C · Seat 14
  ],
  ticket(colour: rgb("#2E7D32"), width: 100%)[
    * Cloakroom * \
    no stub
  ],
)

#titre[3. RTL — stub on the leading (right) edge]

#[
  #set text(lang: "ar", dir: rtl, font: ("DejaVu Sans",))
  #ticket(stub: [12], colour: rgb("#C0392B"), width: 100%)[
    *تذكرة دخول* \
    الجمعة 23 أوت · الباب 19:30
  ]
  #v(0.45em)
  #ticket(stub: [أ], colour: rgb("#6A1B9A"), width: 100%)[
    *المعرض* \
    الصف ج · المقعد 14
  ]
]
