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
  color_of_links: quati-abnt.common.style.color_of_links,

  // Define the font family to be used on each context.
  // Defina a família tipográfica a ser utilizada em cada contexto.
  font_family_for_common_text: quati-abnt.common.style.font_family_serif,
  font_family_for_highlighted_text: quati-abnt.common.style.font_family_sans,
  font_family_for_math_text: quati-abnt.common.style.font_family_math,
  font_family_for_monospaced_text: quati-abnt.common.style.font_family_mono,
  font_family_for_editor_notes: quati-abnt.common.style.font_family_sans,

  // Define whether to use larger text as typographic highlight.
  // Defina se deve ser utilizada uma fonte maior como destaque tipográfico.
  should_use_larger_text_to_highlight: false,

  // Define whether to format for electronic file only (true), or to print (false).
  // Defina se deve usar a formatação para apenas arquivos eletrônicos (true), ou para a impressão (false).
  should_consider_only_odd_pages: true,

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
