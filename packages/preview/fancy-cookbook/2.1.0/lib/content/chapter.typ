#import "../colors/palettes.typ": palette
#import "../colors/colors.typ": set-palette, page-palette
#import "citation.typ": citation-block



#let chapter(change-palette: none, quote-author: none, quote-content: none, body) = context {  
  [
    = #body
  ]
  if change-palette != none {
    set-palette(change-palette)
  }

  let current-palette = page-palette(here().position().page)
  

  if quote-content != none {
    citation-block(
      content: quote-content,
      author: quote-author,
      palette: current-palette,
      offset: 2em
    )
  }
}