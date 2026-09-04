#import "@preview/algol:0.1.0": algol

#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)
// math-compliant smallcaps font
#show smallcaps: set text(font: "Libertinus Serif")

#let algorithm = figure.with(kind: "algorithm", supplement: [Algorithm])

#let my-algol(it) = {
  show regex("if|then|else|return"): it => text(blue, strong(it))
  algol(it)
}

#let lcomment(c) = [$triangle.small.r$ _ #c _]          // left-aligned comment
#let rcomment(c) = [#h(1fr) $triangle.small.r$ _ #c _]  // right-aligned comment

#let fib = smallcaps[Fibonacci]

#algorithm(my-algol[
$fib(n)$: #rcomment[provide some $n in NN$]
- #lcomment[base case: $n = 0$ or $1$]
- if $n = 0 or n = 1$ then return $n$
- #lcomment[recursive case: add the 2 previous Fib. numbers]
- return $fib(n - 1) + fib(n - 2)$
],
caption: [
  Fibonacci's algorithm.
]) <alg:fibonacci>

@alg:fibonacci describes the recursive algorithm to compute the $n$-th Fibonacci number.