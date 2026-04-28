#import "../components/unit.typ": units-state
#import "../components/tables.typ": x-header
#import "../utils/translation.typ": translation

#let make-unit-register() = {
  context {
    let items = units-state.final()
    if items.len() > 0 {
      pagebreak(weak: true)
      heading(translation("List of units"))
      let table_lines = ()
      for (id, (symbol, unit, name, description)) in items.pairs() {
        table_lines.push(([#symbol #label(id)], unit, table.cell(colspan: 2, name), description)) // see commect in the table below
      }
      // items
      x-header(
        table(
          columns: (auto, auto, auto, 0.0001fr, auto),
          // the columns should scale automatically. But when using (auto, auto), the table will not fit the full width, if space space is not needed. A fixed fraction solves this, but also takes away the dynamic sizing. Because of that, the solution is, to add columns with a near-zero fraction, that will take up all left over space. To make the data fit these extra columns, the inline function is used for mapping below.
          table.header(..(translation("Symbol"), translation("Formula"), table.cell(colspan: 2, translation("Description")), translation("Unit"))),
          ..table_lines.flatten(),
        ),
      )
    }
  }
}
