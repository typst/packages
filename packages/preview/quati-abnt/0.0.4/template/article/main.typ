// # Article. Artigo.
// NBR 6022:2018

#import "./data/glossary.typ": glossaries_entries
#import "./packages.typ": glossarium, quati-abnt

// ## Glossary. Glossário.
#show: glossarium.make-glossary
#glossarium.register-glossary(glossaries_entries)

// ## Template. Modelo.
#show: it => quati-abnt.article.template(
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
