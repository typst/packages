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

#let maths_block_no_stroke(type, title, content) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if(title == []){
  [
    *#type #n ---* #content
  ]
}else{
    [
      *#type #n --- #title*

      #content
    ]
  }
  
}

#let maths_block(type, title, content) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if(title == []){
  enclose[
    *#type #n*

    #content
  ]
}else{
    enclose[
      *#type #n --- #title*

      #content
    ]
  }
  
}

// French Shortcuts.... 
#let def(title, content)  = context maths_block("Définition", title, content)
#let prop(title, content) = context maths_block("Proposition", title, content)
#let remarque(title, content) = context maths_block_no_stroke("Remarque", title, content)
#let theorem(title, content) = context maths_block("Théorème", title, content)
#let corollaire(title, content) = context maths_block("Corollaire", title, content)
#let lemme(title, content) = context maths_block("Lemme", title, content)
#let exemple(title, content) = context maths_block_no_stroke("Exemple", title, content)

#let demo(content) = context {
  [*Démonstration*]

  block(stroke: (left: 0.5pt + text.fill, rest: 0pt), inset: (top: 2pt, bottom: 2pt,left: 10pt,), content)
}






