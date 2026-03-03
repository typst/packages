#import "@preview/toot:0.1.0": setup-toot

#let (toot-page, example, i-link) = setup-toot(
  name: [My package],
  universe-url: "https://typst.app/universe/package/my-package",
  root: "",
  styling: (accent-color: eastern),
  outline: include "OUTLINE.typ",
  snippets: (
    (
      trigger: "// SETUP",
      expansion: ```typ
      // LIGHT DARK
      ```.text,
    ),
  ),
)
