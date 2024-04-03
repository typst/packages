#import "@preview/zen-zine:0.1.0": zine

#set document(author: "Tom", title: "Zen Zine Example")
#set text(font: "Linux Libertine", lang: "en")

#let my_eight_pages = (
  range(8).map(
    number => [
      #pad(2em, text(10em, align(center, str(number))))
    ]
  )
)

// provide your content pages in order and they
// are placed into the zine template positions.
// the content is wrapped before movement so that
// padding and alignment are respected.
#zine(
  // draw_borders: true,
  // zine_page_margin: 5pt,
  contents: my_eight_pages
)
