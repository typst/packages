// japanese localizations
#let strings = (
  abstract: [概要],
  contents: [目次],
  chapter: n => [第#(n)章],
  // Japanese technical documents usually number sections/subsections
  // ("1.1 導入") without a "Section" word at all - a good reminder that
  // localizing isn't always a 1:1 word swap, sometimes a label just
  // disappears in another language.
  section: n => [#n],
  table: [表],
  figure: [図],
  appendix: n => [付録#n],
  references: [参考文献],
)
