#import "@preview/problemst:0.1.2": pset

#show: pset.with(
  class: "6.100",
  student: "Alyssa P. Hacker",
  title: "PSET 0",
  date: datetime.today(),
  collaborators: ("Ben Bitdiddle", "Louis Reasoner"),
)

#let deriv(num, dnm) = [$ (d num) / (d dnm) $]

= Definition of the derivative
Something something infinitesimals something something. We can then define the derivative as the limit of the difference quotient as $Delta x arrow 0$:
$ deriv(f(x), x)&= lim_(Delta x arrow 0) (f(x + Delta x) - f(x)) / (Delta x). $

== Code!
```go
import "fmt"

func main() {
  fmt.Println("python sux!!1!")
}
```

=== Subproblem
We can nest subproblems!

==== Subsubproblem
As far as we want!

#pagebreak()

We also have a nice little header for the ensuing pages!
