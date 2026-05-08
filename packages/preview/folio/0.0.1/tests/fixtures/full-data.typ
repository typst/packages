// Fixture: full-data.typ
// All 30 schema paths populated. All sections render. Complete cross-references.
// This is the comprehensive "everything works" test.
#import "@preview/folio:0.0.1": project-doc
#import "full-data-dict.typ": full-project-data

#show: project-doc(
  data: full-project-data,
  config: (
    audit: true,
    toc: true,
  ),
)
