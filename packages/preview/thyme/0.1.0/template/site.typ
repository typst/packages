#import "@preview/thyme:0.1.0": *
#import blog: *

#show: site.with(
  description: "Notes on programming languages, formal methods, and systems.",
  url: "https://blog.example.org",
  author: "Ada Lovelace",
  src: path("site.typ"),
)

= `folio`

Notes on programming languages, formal methods, mathematics, and systems.

#links(
  direction: "row",
  link("https://example.org")[example.org],
  link("https://github.com/example")[github],
  [@rss[rss]],
  [@atom[atom]],
)

== Posts

#post(path("posts/fixed-points.typ")) <fixed-points>
#post(path("posts/minimal-bundles.typ")) <minimal-bundles>
