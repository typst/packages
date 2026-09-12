// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/linguify:0.5.0": *

#import "../colors.typ": *
#import "../lang.typ": *

#let authors(..authors, styled: false) = {

  let concat = [ #linguify("lib_author_concat", from: lang-db, default: "key") ]
  
  let by = authors
    .pos()
    .join(", ", last: concat)

  if styled {    
  align(left,
    emph(
      text(fill: hm-red, [#by])
    )
  )
  } else {
    text([#by])
  }
}
