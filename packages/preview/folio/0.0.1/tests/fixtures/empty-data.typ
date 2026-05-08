// Fixture: empty-data.typ
// All placeholders render. Zero crash guarantee test.
// This is the ultimate zero-crash test: folio renders even with nothing.
#import "@preview/folio:0.0.1": project-doc

#show: project-doc(
  data: (:),
  config: (
    audit: true,
    toc: true,
    cover: true,
  ),
)
