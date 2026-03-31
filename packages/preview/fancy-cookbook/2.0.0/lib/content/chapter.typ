#import "../colors/palettes.typ": palette
#import "../colors/colors.typ": set-palette


#let chapter(change-palette: none, body) = context {  
  [
    = #body
  ]
  if change-palette != none {
    set-palette(change-palette)
  }
  
}