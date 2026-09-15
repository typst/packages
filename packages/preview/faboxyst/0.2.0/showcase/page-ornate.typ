#import "@preview/faboxyst:0.2.0": *
#set text(font: "DejaVu Sans", size: 11pt, lang: "fr")
#show: ornate-pages.with(preset: ornatebox, margin: 1.6cm,
  title: none, colour: rgb("#1F3A68"), gold: rgb("#C9A24E"))

= Cadre ornate-pages

Cette page entière est dessinée par `ornate-pages` : double filet, coins, motifs de bord.

#khatambox(title: [À l’intérieur], badge: [1])[
  Le contenu flotte dans le cadre. En RTL la sash et les coins se mirent.
]

#pagebreak()
#set text(lang: "ar", dir: rtl)
= إطار صفحة كاملة

#mihrabbox(title: [محراب])[
  الصفحة الثانية، اتجاه من اليمين إلى اليسار، داخل نفس الإطار المزخرف.
]
