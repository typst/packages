// # Entry on simple glossary list. Entrada em lista simples de glossário.

#import "../../common/style/style.typ": spacing_for_common_text
#import "../../common/packages.typ": glossarium

#let print_title = entry => {
  (
    grid(
      columns: (1fr, 4fr),
      column-gutter: spacing_for_common_text,
      align: top,

      strong(entry.short), entry.long,
    )
  )
}

#let print_description = entry => {}

#let print_back_references = entry => {}

#let print_gloss = (
  deduplicate-back-references: true,
  description-separator: "",
  disable-back-references: false,
  minimum-refs: 1,
  show-all: false,
  user-print-back-references: print_back_references,
  user-print-description: print_description,
  user-print-title: print_title,
  entry,
) => context {
  if glossarium.count-refs(entry.key) != 0 {
    print_title(entry)
  }
}
