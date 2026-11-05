#import "@preview/heh-template:1.0.0": *

#show: heh-document.with(
  document-config-fn: config.default-document-config.with(
    title: "Titre du document",
    description: "Description du document",
    formation: none,
    orientation: none,
    authors: (
      ("Auteur", "john.doe@example.com"),
    ),
  ),
  print-config-fn: config.default-print-config.with(
    monochrome: "monochrome" in sys.inputs and sys.inputs.monochrome == "true",
  ),
)

= Hello, world

