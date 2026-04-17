#import "../components/abbreviation.typ": abbr-state
#import "../components/tables.typ": x-header
#import "../utils/translation.typ": translation

#let make-abbreviation-register() = {
  context {
    let items = abbr-state.final()
    if items.len() > 0 {
      pagebreak(weak: true)
      heading(translation("List of abbreviations"))
      let table_lines = (
        translation("Abbreviation"),
        translation("Description"),
      )
      for (id, (abbreviation, description)) in items.pairs() {
        table_lines.push(([#abbreviation #label(id)], description))
      }
      // items
      x-header(
        table(
          columns: (auto, 1fr),
          ..table_lines.flatten(),
        ),
      )
    }
  }
}
