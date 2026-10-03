// # Article. Artigo.
// NBR 6022:2018

#import "./components.typ": *
#import "./data/glossary.typ": glossaries_entries
#import "./packages.typ": *


// ## Glossary. Glossário.
#show: glossarium.make-glossary
#glossarium.register-glossary(glossaries_entries)


// ## Template. Modelo.
#show: it => quati-abnt.link.template(
  it,
  // Define the color of links and cross-references.
  // Defina a cor dos links e das referências cruzadas.
  color_of_links: quati-abnt.link.color_of_links,
)
#show: it => quati-abnt.bibliography.template(it)
#show: it => quati-abnt.note.template(
  it,
  // Define the font family.
  // Defina a família tipográfica.
  font_family_for_notes: quati-abnt.common.style.font_family_sans,
  // Define whether to display editor notes.
  // Defina se deve exibir as notas de editor.
  should_display_notes: true,
)
#show: it => quati-abnt.article.template(
  it,

  // Define the font size for common text.
  // Defina o tamanho de fonte para o texto comum.
  base_font_size: quati-abnt.common.style.base_font_size,

  // Define the font family to be used on each context.
  // Defina a família tipográfica a ser utilizada em cada contexto.
  font_family_for_common_text: quati-abnt.common.style.font_family_serif,
  font_family_for_highlighted_text: quati-abnt.common.style.font_family_sans,
  font_family_for_math_text: quati-abnt.common.style.font_family_math,
  font_family_for_monospaced_text: quati-abnt.common.style.font_family_mono,

  // Define whether to use larger text as typographic highlight instead of uppercase.
  // Defina se deve ser utilizada uma fonte maior como destaque tipográfico em vez de caixa-alta.
  should_use_larger_text_instead_of_uppercase_to_highlight: false,

  // Define whether to count pages and place its numbers at the headers.
  // Defina se deve contar as páginas e exibir seus números nos cabeçalhos.
  should_number_pages: true,
)
#show: it => quati-abnt.footnote.template(it)


// ## Content. Conteúdo.

// ### Pre-textual elements. Elementos pré-textuais.
#include "./content/pre_textual.typ"

// ### Textual elements. Elementos textuais.
#include "./content/textual/main.typ"

// ### Bibliography. Referências.
#bibliography("./data/bibliography.bib")

// ### Post-textual elements. Elementos pós-textuais.
#include "./content/post_textual.typ"
