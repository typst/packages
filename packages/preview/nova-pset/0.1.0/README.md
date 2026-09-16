# The `nova-pset` Package
<div align="center">Version 0.1.0</div>

Homework template for STEM coursework and problem sets. Spin-off of [adaptable-pset](https://github.com/stuxf/adaptable-pset?tab=readme-ov-file) with some modifications and additional functions.

## Examples

### Example front page

![Front page of a math homework set with title, author, and problem boxes](https://raw.githubusercontent.com/samyakj5/nova-pset/b814394a286b4f8c813189cdba5cf2db9badde6e/example.png)

### Example logo integrations

![Homework set with square logo in the top right corner](https://raw.githubusercontent.com/samyakj5/nova-pset/b814394a286b4f8c813189cdba5cf2db9badde6e/square_example.png)

![Homework set with circle logo in the top right corner](https://raw.githubusercontent.com/samyakj5/nova-pset/b814394a286b4f8c813189cdba5cf2db9badde6e/circle_example.png)

![Homework set with triangle logo in the top right corner](https://raw.githubusercontent.com/samyakj5/nova-pset/b814394a286b4f8c813189cdba5cf2db9badde6e/triangle_example.png)

## Logos
The example images use placeholder logos. To use your own logo, obtain it from your institution and pass it as an image:
```typ
#let logo = image("your-logo.png", height: 25pt)
```

## Example Code

```typ
#import "@preview/nova-pset:0.1.0": *

#let class = "math 347h"
#let assignment = "Homework 4"
#let author = "Samyak Jain"
// To use a logo, add an image to this folder and replace none:
// #let logo = image("your-logo.png", height: 25pt)
#let logo = none
#let instructor = "Prof. Fernandough"
#let semester = "Fall 2025"
#let due-time = "September 25, 2025"

#show: homework.with(
  class: class,
  assignment: assignment,
  author: author,
  logo: logo,
  instructor: instructor,
  semester: semester,
  due-time: due-time,
  paper-size: "us-letter",
  accent-color: rgb("#1c2b39"),
)

#set enum(numbering: "a)")

#q(title: "Problem 1")[
    Prove that the composition of two surjective functions is surjective.
]

#b() Suppose that $f : A -> B$ and $g : B -> C$ are surjective functions. Then the composition $g compose f : A -> C$ is $g compose f (a) = g(f(a))$. We claim that $g(f(a))$ is surjective, or that

$ forall c in C, exists a in A "such that" g(f(a)) = c $

Let $c in C$ be arbitrary. Because $g$ is surjective, we know that

$ forall c in C, exists b in B "such that" g(b) = c $

So there exists a $b in B$ such that $g(b) = c$. Then, because $f$ is surjective, we know that

$ forall b in B, exists a in A "such that" f(a) = b $

So there exists an $a in A$ such that $f(a) = b$. Then $g(f(a)) = g(b) = c$. This means that the composition $g compose f$ is surjective.

#Q()
```
