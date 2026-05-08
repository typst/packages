// Fixture: minimal-data.typ
// Bare-minimum valid project: just project name and description.
// Sections with data auto-render; everything else is skipped.
#import "@preview/folio:0.0.1": project-doc

#show: project-doc(
  data: (
    project: (
      name: "Minimal Test Project",
      description: "This is the simplest valid folio project.",
    ),
  ),
  config: (
    audit: true,
    toc: true,
  ),
)
