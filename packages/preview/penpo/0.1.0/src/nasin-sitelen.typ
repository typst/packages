#let Lasina(t) = {
  text(font: "libertinus serif")[#t]
}

#let seli-kiwen(t) = {
  text(font: "sitelen seli kiwen asuki", hyphenate: false)[#t]
}

#let Nimi(spelling) = {
  seli-kiwen[
    [#{spelling.join([ ])}]
  ]
}


