#import "@preview/tufted:0.1.1"

#let template = tufted.tufted-web.with(
  header-links: (
    "/": "Home",
    "/docs/": "Docs",
    "/blog/": "Blog",
    "/cv/": "CV",
  ),
  title: "Tufted",
)
