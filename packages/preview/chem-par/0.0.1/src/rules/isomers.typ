#import "../stateful.typ": *

#let isomers(body) = {
  show regex("(((iso)|(sec)|(tert)|(cis)|(trans)|(syn)|(anti)|(endo)|(exo)|[iompnNO])-)|([N][,′'’])"): (it) => {
    if-state-enabled( it , {
      show "-": "–"
      emph(it)
    })
  }
  body
}
