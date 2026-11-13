#import "@preview/thyme:0.1.0": *
#import "@preview/thyme:0.1.0": blog

#show: blog.site.with(
  description: "Algebraic invariants, automata, and bilingual static notes.",
  url: "https://notes.example.org",
  author: "Emmy Noether",
  src: path("site.typ"),
  feed-content: "full",
  heading-permalinks: true,
  backlinks: true,
  post-nav: true,
  open-graph: true,
  scholar-meta: true,
  robots: path("robots.txt"),
  llms: path("llms.txt"),
)

#blog.mount(path("about.typ")) <about>

= `noether`

Algebraic invariants, finite-state machines, and static scholarly notes.

#blog.links(
  direction: "row",
  link(<about>)[colophon],
  link(<tags>)[tags],
  [@rss[rss]],
  [@atom[atom]],
)

== Notes

#blog.post(path("posts/bilingual-notes.typ")) <bilingual-notes>
#blog.post(path("posts/state-machine/site.typ")) <state-machine>
