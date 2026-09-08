// # List of abbreviations. Lista de abreviaturas e siglas.
// NBR 14724:2024 4.2.1.11

#import "../../components/entry_on_simple_glossary_lists.typ": print_gloss
#import "../../components/page.typ": not_number_page
#import "../post_textual/glossary.typ": include_glossary_page

#let include_list_of_abbreviations_page(
  invisible: false,
  abbreviations_entries,
) = {
  not_number_page(
    include_glossary_page(
      disable_back_references: true,
      invisible: invisible,
      print_gloss: print_gloss,
      title: "Lista de abreviaturas e siglas",
      outlined: false,
      abbreviations_entries,
    ),
  )
}
