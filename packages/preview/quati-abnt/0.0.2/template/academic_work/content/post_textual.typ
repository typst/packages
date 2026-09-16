// # Post-textual elements. Elementos pós-textuais.
// NBR 14724:2024 4.2.3

// ====================
// ## Glossary. Glossário.
// NBR 14724:2024 4.2.3.2

#import "../data/glossary.typ": glossary_entries
#import "../packages.typ": (
  quati-abnt.academic_work.pages.include_glossary_page, quati-abnt.common.components.include_annex,
  quati-abnt.common.components.include_appendix,
)

#include_glossary_page(
  disable_back_references: true,
  glossary_entries,
)

// ====================


// ====================
// ## Appendixes. Apêndices.
// NBR 14724:2024 4.2.3.3

#counter(heading).update(0)

#include_appendix(
  title: [#lorem(20)],
  label: <apendice:lorem>,
)[
  #lorem(50)
]

// ====================

// ====================
// ## Annexes. Anexos.
// NBR 14724:2024 4.2.3.4

#counter(heading).update(0)

#include_annex(
  title: [Quod idem licet transferre in voluptatem, ut],
  label: <anexo:quod>,
)[
  #lorem(50)
]

// ====================
