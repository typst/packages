#import "base.typ" : setup, style-content
#import "../cover/cover1.typ": cover
#import "../header.typ": header-current-chapter-and-name

// Collect all style definitions in one dictionary to use in the template.
#let style(components: (:)) = (
  font: "Arial",
  fontsize: 12pt,
  setup: setup,
  header: header-current-chapter-and-name,
  cover: cover,
  style-content: style-content,
  chapters: (
    components.declaration,
    components.abstract,
    components.toc,
    components.nomenclature,
    components.body,
    components.bibliography,
    components.figures,
    components.tables,
    components.listings,
    components.appendix,
  ),
)
