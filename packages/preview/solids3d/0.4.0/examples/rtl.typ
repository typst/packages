// Exemple arabe / RTL.
// Le texte suit la direction RTL ; la géométrie conserve ses coordonnées.
#import "@preview/solids3d:0.4.0": *
#set page(width: 15cm, height: auto, margin: 1cm)
#set text(font: "DejaVu Sans", lang: "ar", dir: rtl)

= مجسّمات هندسية

هذا مثال على استعمال الحزمة مع النص العربي من اليمين إلى اليسار.
تظلّ الإحداثيات، الأسهم، الأبعاد والإسقاطات الهندسية مستقلة عن اتجاه الكتابة.

#let A = (0, 0, 0)
#let B = (4, 0, 0)
#let C = (4, 2, 0)
#let D = (0, 2, 0)
#let E = (0, 0, 2.5)
#let F = (4, 0, 2.5)
#let G = (4, 2, 2.5)
#let H = (0, 2, 2.5)

#align(center)[
  #picture(width: 10cm, projection: orthographic(7, 6, 5),
    draw(cuboid(length: 4, width: 2, height: 2.5), withopacity(paleblue, 0.62)),
    draw(box3(A, G), pen(black, 0.6pt)),
    // La ligne de rappel ne dessine pas la diagonale : celle-ci est explicite.
    draw(line3(A, G), pen(gray(0.35), 0.5pt, dashed)),
    point3([A], A, align: SW, pen: black),
    point3([B], B, align: S, pen: black),
    point3([C], C, align: SE, pen: black),
    point3([D], D, align: W, pen: black),
    point3([E], E, align: NW, pen: black),
    point3([F], F, align: N, pen: black),
    point3([G], G, align: NE, pen: black),
    point3([H], H, align: W, pen: black),
    dimension3([الطول = 4 cm], A, B, offset: (0, -0.65, 0), align: S, pen: blue),
    dimension3([العرض = 2 cm], B, C, offset: (0, 0, -0.55), align: SE, pen: blue),
    dimension3([الارتفاع = 2.5 cm], A, E, offset: (-0.75, 0, 0), align: W, pen: blue),
    callout3([رأس], G, (5, 2, 3.1), align: W, pen: red),
    callout3([القطر AG], (2, 1, 1.25), (-1.5, 1.5, 2.6), align: E, pen: orange),
  )
]

#v(8pt)
#align(center)[#text(dir: ltr)[RTL is supported by Typst's text engine; use an Arabic-capable font.]]
