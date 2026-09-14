#import "./template-individual.typ": template-individual
#import "../dependency/i-figured.typ"


#let main-outline(
  title: "Table of contents",
  titlelevel: 2,
  outlined: false,
  ..args,
) = {
  template-individual(outlined: outlined, titlelevel: titlelevel, title, outline(depth: 3, title: none, ..args))

}

#let figure-outline(
  title: "List of figures",
  titlelevel: 2,
  outlined: false,
  ..args,
) = {
  template-individual(
    outlined: outlined,
    titlelevel: titlelevel,
    title,
    i-figured.outline(depth: 3, title: none, target-kind: image, ..args),
  )
}

#let table-outline(
  title: "List of tables",
  titlelevel: 2,
  outlined: false,
  ..args,
) = {
  template-individual(
    outlined: outlined,
    titlelevel: titlelevel,
    title,
    i-figured.outline(depth: 3, title: none, target-kind: table, ..args),
  )
}
)
