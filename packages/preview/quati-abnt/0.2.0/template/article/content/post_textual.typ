// # Post-textual elements. Elementos pós-textuais.
// NBR 6022:2018 5.3

#import "../components.typ": *
#import "../data/glossary.typ": glossaries_entries
#import "../packages.typ": (
  quati-abnt.article.components.include_acknowledgements, quati-abnt.common.components.include_annex,
  quati-abnt.common.components.include_appendix, quati-abnt.common.components.include_glossary,
)


// ====================
// ## Glossary. Glossário.
// NBR 6022:2018 5.3.2

#include_glossary(
  disable_back_references: true,
  glossaries_entries,
)

// ====================

// ====================
// ## Appendixes. Apêndices.

#counter(heading).update(0)

#include_appendix(
  title: [Quod idem licet transferre in voluptatem, ut],
  label: <anexo:quod>,
)[
  #lorem(50)
]

// ====================

// ====================
// ## Annexes. Anexos.

#counter(heading).update(0)

#include_annex(
  title: [Quod idem licet transferre in voluptatem, ut],
  label: <anexo:quod>,
)[
  #lorem(50)
]

// ====================

// ====================
// ## Acknowledgments. Agradecimentos.
// NBR 6022:2018 5.3.5

#include_acknowledgements[
  Agradecemos ao Grupo de Educação Tutorial em Sistemas de Informação (GetSi) da Universidade Federal de Juiz de Fora (UFJF) por prover bolsas de apoio na graduação que possibilitaram a realização deste trabalho.
]

// ====================
