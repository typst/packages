#import "@preview/tieflang:0.1.0": tr

#let page-number-footer = context {
  let alignment = if calc.rem(here().page(), 2) == 0 { left } else { right }
  align(alignment)[ #counter(page).display() #label("page-num") ]
}

#let no-footer = [#box()#label("page-num")]
