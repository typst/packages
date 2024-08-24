// Import subfigure package and make it work with the chapter-relative numbering
#import "@preview/subpar:0.1.1"

#let subfigure-grid(in_appendix: none, ..args) = {

  let numbering_format = "1.1"
  if in_appendix{
    numbering_format = "A.1"
  }

  subpar.grid(
    
    numbering: super => numbering(numbering_format, counter(heading).get().first(), super),
    
    numbering-sub-ref: (super, sub) => numbering(numbering_format+"a", counter(heading).get().first(), super, sub),
    
    ..args
    
  )
  
}


// Add ability to show shorter captions in the indices
#let in-outline = state("in-outline")

#let flex-caption(long, short) = context if in-outline.get() { short } else { long }
