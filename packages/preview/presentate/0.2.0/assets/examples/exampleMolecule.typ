#import "@submit/presentate:0.2.0": *

#import "@preview/alchemist:0.1.6" as alc

#set page(paper: "presentation-16-9")
#set text(size: 25pt)

#let modifier(func, ..args) = func(stroke: none, ..args) // set stroke to `none`
#let (single,) = animation.animate(modifier: modifier, alc.single) 
#let (fragment,) = animation.animate(modifier: (func, ..args) => none, alc.fragment) // set atom colors to white

#slide[
  = Alchemist Molecules
  #render(s => ({
      alc.skeletize({
        fragment(s, "H_3C")
        s.push(auto)
        single(s, angle: 1)
        fragment(s, "CH_2")
        s.push(auto)
        single(s, angle: -1, from: 0)
        fragment(s, "CH_2")
        s.push(auto)
        single(s, from: 0, angle: 1)
        fragment(s, "CH_3")
      })
    },s)
  )
]
