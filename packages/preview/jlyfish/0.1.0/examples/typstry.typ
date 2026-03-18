#import "../typst/lib.typ": *

#read-julia-output(json("typstry-jlyfish.json"))

#jl-pkg("Typstry")

#jl(```julia
  using Typstry
```)

#jl(result: false, ```julia
  A = rand(1:5, 4, 3) .// 3
  B = rand(1:5, 3, 5) .// 2
  C = A * B
```)

An example of a matrix-matrix product:

$
  #jl(`Typst(A)`) #jl(`Typst(B)`) = #jl(`Typst(C)`)
$

The largest noninteger unit fraction:
#jl(preferred-mimes: "text/typst", `typst"$1 / 2$"`)
