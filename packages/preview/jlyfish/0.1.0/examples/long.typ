#import "../typst/lib.typ": *

#read-julia-output(json("long-jlyfish.json"))

#jl(recompute: false, ```julia
  seconds = @elapsed sleep(10)
  @show seconds
  "Wow, this took $(round(Int, seconds)) seconds!"
```)

#jl(`"This is so fast!"`)
