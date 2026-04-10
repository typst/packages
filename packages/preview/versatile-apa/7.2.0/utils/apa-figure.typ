#import "languages.typ": *
#import "to-string.typ": *

#let apa-figure-numbering(n) = {
  let header-counter = counter(heading).get().first()
  let queried-heading = query(selector(heading).before(here())).last().numbering
  if queried-heading == none {
    queried-heading = "A"
  }
  if header-counter == 0 {
    numbering("1", n)
  } else {
    numbering(queried-heading + "1", header-counter, n)
  }
}

#let apa-figure(
  body,
  ..args,
  note: none,
  specific-note: none,
  probability-note: none,
) = {
  figure(
    [
      #set par(first-line-indent: 0em)
      #body
      #set align(left)
      #if note != none [
        #context emph[#get-terms(text.lang, text.script).Note.]
        #note
      ]
      #parbreak()
      #specific-note
      #parbreak()
      #probability-note
    ],
    ..args,
  )
}
