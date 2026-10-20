// # Post-textual elements. Elementos pós-textuais.
// NBR 6022:2018 5.3

#import "../data/glossary.typ": glossary_entries
#import "../packages.typ": (
  quati-abnt.article.components.include_acknowledgements, quati-abnt.common.components.include_annex,
  quati-abnt.common.components.include_appendix, quati-abnt.common.components.include_glossary,
)

// ## Glossary. Glossário.
// NBR 6022:2018 5.3.2
#include_glossary(
  disable_back_references: true,
  glossary_entries,
)

#counter(heading).update(0)
#include_appendix(
  title: [Quod idem licet transferre in voluptatem, ut],
  label: <anexo:quod>,
)[
  #lorem(50)
]

#counter(heading).update(0)
#include_annex(
  title: [Quod idem licet transferre in voluptatem, ut],
  label: <anexo:quod>,
)[
  #lorem(50)
]

// # Acknowledgments. Agradecimentos.
// NBR 6022:2018 5.3.5
#include_acknowledgements[
  #lorem(10)
]
