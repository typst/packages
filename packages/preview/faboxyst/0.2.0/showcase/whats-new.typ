#import "_helpers.typ": *

#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst 0.2.0 · what’s new],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 10pt)

#cmd-title[What’s new  ·  0.2.0]
#note-line[Classroom pictos after *customenvs*, meters, marks, RTL polish.]

#v(8pt)
#grid(columns: (1fr, 1fr), gutter: 12pt,
  fabox(title: [Pictos], colour: rgb("#1565C0"), width: 100%)[
    `meter` styles: battery (fill opposite the nub), speedo, chrono, wifi (classic arcs), cible (white dart, 2 pt black stem). `#pictochrono`. `#size` on every picto.
  ],
  fabox(title: [Banners], colour: rgb("#C62828"), width: 100%)[
    `#competence-crayon` (vertical pencil; RTL: pencil right, pill against it, text right-aligned). `#sale-poster` = AfficheSoldes (slanted SOLDES, Arabic in RTL). `#banner-tri` chevron left→ / RTL right←, text *not* slanted. `#bicolor-title`, `#highway-sign`, `#level-counter`.
  ],
)
#v(8pt)
#grid(columns: (1fr, 1fr), gutter: 12pt,
  fabox(title: [Marks], colour: rgb("#6A1B9A"), width: 100%)[
    `#mark` (highlight, wave, circle, box, strike, scribble, bracket, jagged, fan). `#highlight-formula` / `#highlight-text` (highlightx).
  ],
  fabox(title: [Removed], colour: luma(80), width: 100%)[
    Chili / piment meter style is gone. Use stars, hearts or flame for a row of icons.
  ],
)

#v(10pt)
#sig[
```typ
#import "@preview/faboxyst:0.2.0": *
#meter(3, style: "wifi", size: 1.3cm, max: 4)
#competence-crayon(title: [Chercher], body: [Comp. 1], direction: ltr)
#banner-tri(title: [01], direction: rtl)[فصل]
#sale-poster(old: [19,90 €], new: [9,90 €], reduction: [−50%], direction: rtl)
```
]
