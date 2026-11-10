#import "base.typ" : setup, style-content
#import "../cover/cover1.typ": cover
#import "../header.typ": header-current-chapter-and-name

// M+V Style
#let style(components: (:)) = (
  font: "Times New Roman",
  fontsize: 12pt,
  setup: setup,
  header: header-current-chapter-and-name,
  cover: cover,
  style-content: style-content,
  chapters: (
    components.abstract,
    components.declaration,
    components.toc,
    components.body,
    components.bibliography,
    components.nomenclature,
    components.figures,
    components.tables,
    components.listings,
    components.appendix,
  ),
)
