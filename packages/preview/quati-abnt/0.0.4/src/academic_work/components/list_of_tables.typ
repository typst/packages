// # List of tables. Lista de tabelas.
// NBR 14724:2024 4.2.1.10

#import "../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../components/entry_on_outline_lists.typ": format_outline_entry

#let include_list_of_tables() = context {
  set text(
    font: font_family_for_highlighted_text_state.get(),
  )

  show outline.entry: format_outline_entry

  outline(
    title: "Lista de tabelas",
    target: figure.where(kind: table),
  )
}
