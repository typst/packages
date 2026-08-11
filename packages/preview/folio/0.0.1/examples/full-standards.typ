#import "@preview/folio:0.0.1": project-doc
#import "data.typ": project-data

#show: project-doc(
  // * Project data based on the PMBOK guide
  data: project-data,
  // * Project configuration
  config: (
    // cover: false,
    audit: true,
    // toc: false,
  ),
  // * Branding and styling
  brand: (
    preset: "corporate",
    // preset: "academic",
    primary: rgb("#0d47a1"),
  ),
)

#pagebreak()

= Custom Appendix
This section demonstrates that folio allows appending custom content after the automated PMBOK pipeline.
