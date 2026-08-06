#set page(
  paper: "a4",
  margin: (top: 3cm, left: 3cm, right: 3cm, bottom: 3cm),
)

#set text(weight: "bold", font: "TeX Gyre Heros", size: 20pt, lang: "de", hyphenate: false)
#set par(justify: false)

#place(top + center, text(size: 1.3em, [Your Title]))
#v(1.1fr)

#align(center + horizon, [
  #text([Bachelorarbeit der Mathematisch-Naturwissenschaftlichen Fakultät])
  #v(0.1em)
  der #smallcaps[Eberhard Karls Universität Tübingen] //kapitälchen
  #v(0.1em)
  #text([im Fach X])

#v(1fr)

vorgelegt von #str("\n\n") Surname, Name #str("\n") Tübingen, November 2025])

#pagebreak()