#import "@preview/min-manual:0.1.0": manual

// This is another min-manual usage: doc-comments.
// It gathers documentation from special comments in assets/module.typ

#show: manual.with(
  title: "Package Name",
  description: "Short description, no longer than two lines.",
  authors: "Author <@author>",
  cmd: "pkg-name",
  version: "0.4.2",
  license: "MIT",
  logo: image("assets/logo.png"),
  from-comments: read("assets/module.typ")
)