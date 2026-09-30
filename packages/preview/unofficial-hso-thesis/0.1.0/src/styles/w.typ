#import "base.typ" : setup, style-content
#import "../cover/cover1.typ": cover
#import "../header.typ": header-current-chapter

// W Style
#let style(components: (:)) = (
  font: "Arial",
  fontsize: 11pt,
  setup: setup,
  header: header-current-chapter,
  cover: cover,
  style-content: style-content,
  chapters: (
    components.declaration,
    components.abstract,
    components.toc,
    components.figures,
    components.tables,
    components.nomenclature,
    components.body,
    components.bibliography,
    components.appendix,
  ),
)
