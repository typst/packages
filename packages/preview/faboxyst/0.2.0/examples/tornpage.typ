// faboxyst — tornpage: a paper note with a fractal-torn bottom edge,
// after the tcolorbox `tcbnote` (TeX.SE 586474, CC BY-SA 4.0).
#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: (x: 1.6cm, y: 1.4cm), fill: white)
#set text(size: 10pt)
#show: faboxyst.with(theme: (lang: "fr", dir: ltr))

#tornpage(title: [Note Title])[
  Une feuille propre aux bords nets en haut et sur les côtés, dont le bas
  seul est déchiré à la main : la décoration fractale relève chaque
  segment d'un montant aléatoire, comme un flocon de Koch, et l'ombre
  floue décolle doucement le papier de la page.
]

#v(0.8cm)

#tornpage(title: [Carnet de terrain], width: 72%)[
  Les coins sont vifs, le filet presque invisible, et le titre en gras
  s'assoit au centre du haut de la feuille, comme sur l'original.
]

#v(0.8cm)

#tornpage[
  Sans titre, la note reste une simple page déchirée — le mottle
  papyrus donne au papier sa texture mate et usée.
]

#v(0.8cm)

#tornpage(title: [صفحة ممزقة], width: 70%, direction: rtl)[
  الاتجاه من اليمين إلى اليسار : الجسم يُحاذى إلى اليمين داخل الورقة.
]
