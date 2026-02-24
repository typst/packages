#import "@preview/markly:0.2.0": *

#let markly_context = markly_setup(
  stock_width:4in,
  stock_height:3in,

  content_width: 3in,
  content_height:2in,
)

#show: markly_page_setup.with(markly_context)

// Here the local title template uses markly's to_bleed
#let title(body, inset_y:12pt) = {
  to_bleed(text(white, size:2.5em, body), markly_context)
}

#title[Bannar]

- Content
