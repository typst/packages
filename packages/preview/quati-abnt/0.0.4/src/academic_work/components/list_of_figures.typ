// # List of figures. Lista de ilustrações.
// NBR 14724:2024 4.2.1.9

#import "../../common/util/font_family.typ": font_family_for_highlighted_text_state
#import "../components/entry_on_outline_lists.typ": format_outline_entry

#let include_list_of_figures() = context {
  set text(
    font: font_family_for_highlighted_text_state.get(),
  )

  show outline.entry: it => {
    let kind = it.element.kind
    if kind != table {
      format_outline_entry(it)
    }
  }

  outline(
    title: "Lista de ilustrações",
    target: figure,
  )
}
