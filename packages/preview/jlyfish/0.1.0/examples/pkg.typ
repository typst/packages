#set page(width: auto, height: auto, margin: 1em)
#import "../typst/lib.typ": *

#read-julia-output(json("pkg-jlyfish.json"))

#jl-pkg("Example@0.4", "Plots")

What is $3 + 5$?

#jl(```julia
  import Example

  Example.domath(3)
```)

Let's plot something!

#set image(width: 10em)
#jl(```julia
  using Plots
  plot(pi .* (-3:.01:3), sin, legend = nothing)
```)
