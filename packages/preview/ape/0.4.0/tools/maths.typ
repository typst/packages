#let cpt = counter("maths")


#let enclose(content) = context {
  block(
    width: 100%,
    stroke: text.fill.lighten(0%) + 0.5pt,
    inset: 10pt,
    radius: 3pt,
    content,
  )
}

#let maths_block_no_stroke(type, titre, contenu) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if(titre == []){
  [
    *#type #n ---* #contenu
  ]
}else{
    [
      *#type #n --- #titre*

      #contenu
    ]
  }
  
}

#let maths_block(type, titre, contenu) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if(titre == []){
  enclose[
    *#type #n*

    #contenu
  ]
}else{
    enclose[
      *#type #n --- #titre*

      #contenu
    ]
  }
  
}

// French Shortcuts.... 

#let def(titre, contenu)  = context maths_block("Définition", titre, contenu)
#let prop(titre, contenu) = context maths_block("Proposition", titre, contenu)
#let remarque(titre, contenu) = context maths_block_no_stroke("Remarque", titre, contenu)
#let theorem(titre, contenu) = context maths_block("Théorème", titre, contenu)
#let corollaire(titre, contenu) = context maths_block("Corollaire", titre, contenu)
#let exemple(titre, contenu) = context maths_block_no_stroke("Exemple", titre, contenu)

#let demo(contenu) = context {
  [*Démonstration*]

  block(stroke: (left: 0.5pt + text.fill, rest: 0pt), inset: (top: 2pt, bottom: 2pt,left: 10pt,), contenu)
}






