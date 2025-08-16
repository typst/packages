#let pcite(label, ..args) = {
  set text(weight: "bold", size: 0.8em)
  show cite: it => {
    show "and": "et"
    it
  }

  // page number
  let p = args.pos()
  if (p == ()) {
    [(#cite(label, form: "author"), #cite(label, form: "year"))]
  } else {
    let p = args.pos().at(0)
    [(#cite(label, form: "author"), #cite(label, form: "year"):#p)]
  }
}

#let mcite(..args) = {
  set text(weight: "bold", size: 0.8em)
  show cite: it => {
    show "and": "et"
    it
  }

  context {
    let citations = args.pos()
    let result = []
    let lang = text.lang

    for i in range(citations.len()) {
      if i > 0 {
        if lang == "fr" { result += [ ; ] } else { result += [; ] }
      }

      let cit = citations.at(i)

      if type(cit) == array {
        let label = cit.at(0)
        let page = if cit.len() > 1 { cit.at(1) } else { none }

        if page == none {
          result += [#cite(label, form: "author"), #cite(label, form: "year")]
        } else {
          result += [#cite(label, form: "author"), #cite(label, form: "year"):#page]
        }
      } else {
        result += [#cite(cit, form: "author"), #cite(cit, form: "year")]
      }
    }

    [(#result)]
  }
}
