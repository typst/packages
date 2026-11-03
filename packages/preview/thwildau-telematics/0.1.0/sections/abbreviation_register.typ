#import "../components/abbreviation.typ": abbr-state
#import "../components/tables.typ": x-header
#import "../utils/translation.typ": translation

#let make-abbreviation-register() = {
  context {
    let items = abbr-state.final()
    if items.len() > 0 {
      pagebreak(weak: true)
      heading(translation("List of abbreviations"))
      let table_lines = ()
      for (id, (abbreviation, description)) in items.pairs() {
        table_lines.push((table.cell(colspan: 2)[#abbreviation #label(id)], table.cell(colspan: 2)[#description]))
      }
      // items
      x-header(
        table(
          columns: (auto, 0.0001fr, auto, 0.0001fr),
          // the columns should scale automatically. But when using (auto, auto), the table will not fit the full width, if space space is not needed. A fixed fraction solves this, but also takes away the dynamic sizing. Because of that, the solution is, to add columns with a near-zero fraction, that will take up all left over space. To make the data fit these extra columns, the inline function is used for mapping below.
          table.header(..(translation("Abbreviation"), translation("Description")).map(el => table.cell(colspan: 2, el))),
          ..table_lines.flatten(),
        ),
      )
    }
  }
}
