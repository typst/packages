// Notion-style quote
#let quotion(
  doc
) = {   
  
  let gray-quote = rgb("#B6B6B4") 
  
  set quote(block: true, quotes: false)
  
  show quote.where(block: true): it => box(
    width: 100%,
    stroke: (left: 2pt + gray-quote, rest: none),
    inset: (left: 12pt, right: 0pt, y: 4pt),
  )[
    #it.body
  ]
  
  doc
}

// Now we rename the styled quote to qquote
#import quote as qquote

// And now define a new quote function that is like qquote but has an optional boolean parameter `big`
#let quote(body, big: false, ..args) = {
  qquote(
    ..args,
  )[
    #if big { 
      text(size: 1.15em)[
        #body
      ]
    } else {
      body
    }
  ]
}