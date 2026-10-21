#set page(fill: none, width: 6cm, height: 3cm)

#import "/lib.typ": *
#import parsers as p

#import "@preview/beautiframe:0.4.0": theorem, beautiframe-setup
#beautiframe-setup(style: "academic")

#let theorem-parser = (
  ([Theorem], p.space),
  p.until(p.anything, ([.], p.space)),
  ([.], p.space)
)
#let theorem-handler((_, num, _), rest) = theorem(rest, number: num.join())
#show par: crawl.with((theorem-parser, theorem-handler))

Theorem 1.2'. Blah blah *blah* blah blah.
