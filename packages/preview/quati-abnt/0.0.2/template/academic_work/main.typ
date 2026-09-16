// # Academic Work. Trabalho Acadêmico.
// NBR 14724:2024

#import "./data/glossary.typ": abbreviations_entries, glossary_entries, symbols_entries
#import "./packages.typ": glossarium, quati-abnt

// ## Glossary. Glossário.
#show: glossarium.make-glossary
#glossarium.register-glossary(abbreviations_entries)
#glossarium.register-glossary(symbols_entries)
#glossarium.register-glossary(glossary_entries)

// ## Template. Modelo.
#show: it => quati-abnt.academic_work.template(
  it,

  // Define the color of links and cross-references.
  // Defina a cor dos links e das referências cruzadas.
  color_of_links: oklch(25%, 0.17, 264.05deg),

  // Define whether to format for electronic file only (true), or to print (false).
  // Defina se deve usar a formatação para apenas arquivos eletrônicos (true), ou para a impressão (false).
  consider_only_odd_pages: true,

  // Define whether to count pages and place its numbers at the headers.
  // Defina se deve contar as páginas e exibir seus números nos cabeçalhos.
  should_number_pages: true,

  // Define whether to display editor notes.
  // Defina se deve exibir as notas de editor.
  should_display_editor_notes: true,
)

// ## External elements. Elementos externos.
#include "./content/external.typ"

// ## Pre-textual elements. Elementos pré-textuais.
#include "./content/pre_textual.typ"

// ## Textual elements. Elementos textuais.
#include "./content/textual/main.typ"

// ## Bibliography. Referências.
#bibliography("./data/bibliography.bib")

// # Post-textual elements. Elementos pós-textuais.
#include "./content/post_textual.typ"
