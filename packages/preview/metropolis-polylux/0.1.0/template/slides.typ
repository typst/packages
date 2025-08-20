#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import metropolis: new-section, focus

#show: metropolis.setup

#slide[
  #set page(header: none, footer: none, margin: 3em)

 
  #text(size: 1.3em)[
    *My presentation title*
  ]

  My subtitle

  #metropolis.divider
  
  #set text(size: .8em, weight: "light")
  The Author

  Jan 16, 2025

  Some extra info
]

#slide[
  = Agenda

  #metropolis.outline
]

#new-section[My first section]

#slide[
  = The Fundamental Theorem of Calculus

  For $f = (dif F) / (dif x)$ we _know_ that
  $
    integral_a^b f(x) dif x = F(b) - F(a)
  $

  See `https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus`
]

#slide[
  slide without a title
]

#new-section[My second section]

#slide[
  = Heron algorithm

  ```julia
  function heron(x)
      r = x
      while abs(r^2 - x) > eps()
          r = (r + x / r) / 2
      end
      return r
  end

  @test heron(42) ≈ sqrt(42)
  ```
]

#slide[
  #show: focus
  Something very important
]
