// # List of figures. Lista de ilustrações.
// NBR 14724:2024 4.2.1.9

#import "../../common/style/style.typ": font_family_sans
#import "../components/entry_on_outline_lists.typ": format_outline_entry

#let include_list_of_figures() = {
  set text(
    font: font_family_sans,
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
