#import "@preview/zen-zine:0.3.0": zine8

#set document(author: "Tom", title: "Zen Zine Example")
#set text(font: "Libertinus Serif", lang: "en")

// this page size is what the printer page size is
// if building a digital zine, the page will be re-set
// so that the PDF pages align with the zine page size
// and not the printer page size
#set page("us-letter")

// update heading rule to show that style is preserved
#show heading.where(level: 1): hd => {
  pad(top: 2em, text(10em, align(center, hd.body)))
}

#show: zine8.with(
  // whether to make output PDF pages align with zine pages (true)
  // or have the zine pages located onto a printer page (false)
  // with this code, you can provide which kind you want on the command line
  //   typst compile input.typ output.pdf --input digital=(true|false)
  digital: json(bytes(sys.inputs.at("digital", default: "false"))),
  // draw border in printer page zine to help with design
  draw-border: true
)

// provide your content pages in order and they
// are placed into the zine template positions.
// the content is wrapped before movement so that
// padding and alignment are respected.

= 1

#pagebreak()

= 2

#pagebreak()

== 3
#lorem(50)

#pagebreak()

== 4

#pagebreak()

= 5
#v(1fr)
five

#pagebreak()

six

#pagebreak()

= 7
seven

#pagebreak()

$ 8 $

