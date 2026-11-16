#import "@preview/thyme:0.1.0": *

#show: webpage.with(
  title: [Colophon],
  description: "Notes on this static site and its pure-Typst build pipeline.",
  created: datetime(year: 2026, month: 10, day: 20),
  modified: datetime(year: 2026, month: 10, day: 28),
)

= Colophon

This standalone `webpage` subpage is mounted directly inside a `blog` preset bundle via `#mount(path("about.typ")) <about>`, inheriting the monochrome stylesheet and top utility bar automatically.

Recent notes include @bilingual-notes and @state-machine, or browse all topics under #link(<tags>)[`/tags`].
