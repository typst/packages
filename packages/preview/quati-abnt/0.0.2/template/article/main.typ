// # Article. Artigo.
// NBR 6022:2018

#import "./data/glossary.typ": glossary_entries
#import "./packages.typ": glossarium, quati-abnt

// ## Glossary. Glossário.
#show: glossarium.make-glossary
#glossarium.register-glossary(glossary_entries)

// ## Template. Modelo.
#show: it => quati-abnt.article.template(
  it,

  // Define the color of links and cross-references.
  // Defina a cor dos links e das referências cruzadas.
  color_of_links: oklch(25%, 0.17, 264.05deg),

  // Define whether to count pages and place its numbers at the headers.
  // Defina se deve contar as páginas e exibir seus números nos cabeçalhos.
  should_number_pages: true,

  // Define whether to display editor notes.
  // Defina se deve exibir as notas de editor.
  should_display_editor_notes: true,
)

#include "./content/pre_textual.typ"

#include "./content/textual/main.typ"

#bibliography("./data/bibliography.bib")

#include "./content/post_textual.typ"
