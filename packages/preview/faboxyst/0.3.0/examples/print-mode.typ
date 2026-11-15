// Blockst-inspired monochrome output, with a normal-theme comparison.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 15cm, height: auto, margin: 1cm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.55em)
#show: faboxyst.with(theme: "normal")

= Mode d'impression / Print mode

*Thème normal — conservé sans changement.*

#garnet-box[La bannière conserve son grenat et son relief natifs.]

#print-group[
  *Mode print — surfaces blanches, traits noirs, ombres en gris.*

  #numbered-header-box(
    title: [Concept essentiel],
    number: 12,
    direction: rtl,
  )[
    يجمع هذا المثال بين نمط الطباعة واتجاه RTL؛ يبقى الرقم والعنوان
    في موضعيهما المنطقيين، من دون تغيير هندسة الصندوق.
  ]

  #v(0.35cm)
  #fabox(title: [Ombre conservée], colour: blue, shadow: "large")[
    L’ombre reste présente, rendue dans une nuance de gris.
  ]
  #v(0.35cm)
  #postit(title: [À retenir])[La note devient blanche, avec un contour noir et une ombre grise.]
  #v(0.35cm)
  #sketch-box(fill: rgb("#F3C832"), stroke-colour: red)[
    Les couleurs personnalisées sont neutralisées pendant le groupe print.
  ]
]

*Après le groupe — le thème normal revient.*

#garnet-box[Le grenat, le relief et les ombres sont de nouveau visibles.]
