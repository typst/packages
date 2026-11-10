#import "../components/glossary.typ": glossary-state
#import "../utils/translation.typ": translation
#import "../components/tables.typ": x-header

#let make-glossary(glossary: ()) = {
  // convert manual given entries to required (id, (term, description)) format
  let kwarg_items = for (term, description) in glossary { (str("glossary-" + term): (term, description)) }

  context {
    let items = glossary-state.final() + kwarg_items
    if items.len() > 0 {
      pagebreak(weak: true)
      heading(translation("Glossary"))
      let table_lines = ()
      for (id, (term, description)) in items.pairs() {
        table_lines.push((table.cell(colspan: 2)[#term #label(id)], table.cell(colspan: 2)[#description])) // see commect in the table below
      }
      // items
      x-header(
        table(
          columns: (auto, 0.0001fr, auto, 0.0001fr),
          // the columns should scale automatically. But when using (auto, auto), the table will not fit the full width, if space space is not needed. A fixed fraction solves this, but also takes away the dynamic sizing. Because of that, the solution is, to add columns with a near-zero fraction, that will take up all left over space. To make the data fit these extra columns, the inline function is used for mapping below.
          table.header(..(translation("Term"), translation("Description")).map(el => table.cell(colspan: 2, el))),
          ..table_lines.flatten(),
        ),
      )
    }
  }
}

