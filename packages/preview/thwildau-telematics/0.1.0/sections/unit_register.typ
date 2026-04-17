#import "../components/unit.typ": units-state
#import "../components/tables.typ": x-header
#import "../utils/translation.typ": translation

#let make-unit-register() = {
  context {
    let items = units-state.final()
    if items.len() > 0 {
      pagebreak(weak: true)
      heading(translation("List of units"))
      let table_lines = (
        translation("Symbol"),
        translation("Formula"),
        translation("Description"),
        translation("Unit"),
      )
      for (id, (symbol, unit, name, description)) in items.pairs() {
        table_lines.push(([#symbol #label(id)], unit, name, description))
      }
      // items
      x-header(
        table(
          columns: (auto, auto, 1fr, auto),
          ..table_lines.flatten(),
        ),
      )
    }
  }
}
