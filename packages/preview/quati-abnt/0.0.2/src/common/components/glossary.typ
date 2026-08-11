// # Glossary. Glossário.
// NBR 14724:2024 4.2.1.11, 4.2.1.12, 4.2.3.2

#import "../packages.typ": glossarium

#let include_glossary(
  disable_back_references: true,
  invisible: false,
  print_gloss: none,
  outlined: true,
  title: "Glossário",
  entries,
) = {
  let arguments = (
    deduplicate-back-references: true,
    description-separator: ". ",
    disable-back-references: disable_back_references,
    invisible: invisible,
  )

  let print_glossary = if (print_gloss == none) {
    () => glossarium.print-glossary(
      ..arguments,
      entries,
    )
  } else {
    () => glossarium.print-glossary(
      ..arguments,
      user-print-gloss: print_gloss,
      entries,
    )
  }

  if (invisible == false) {
    set heading(
      numbering: none,
      outlined: outlined,
    )
    heading(level: 1, title)
    print_glossary()
  } else {
    print_glossary()
  }
}
