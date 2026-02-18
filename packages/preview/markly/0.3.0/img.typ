#import "@preview/markly:0.3.0"

#let markly_context = markly.setup(
  stock-width:6in,
  stock-height:4in,

  bleed: 12pt,
  content-width: 4in,
  content-height:3in,
)

#show: markly.page-setup.with(markly_context)

// Here the local title template uses markly's to_bleed
#let title(body, inset_y:12pt) = {
  markly.to-bleed(text(white, size:2.5em, body), markly_context)
}

#title[Bannar]

- Content
