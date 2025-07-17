# The `adaptable-pset` Package
<div align="center">Version 0.2.0</div>

This is an easy to use template that can be used to submit school assignments and problem sets. Originally intended for math homeworks, it works great for other subjects like physics and computer science as well. Heavily inspired by [gRox167's now outdated template](https://github.com/gRox167/typst-assignment-template/tree/main), and modernized to take advantage of [showybox](https://typst.app/universe/package/showybox). I've been personally using this template for quite some time, and also shared it among friends and friends of friends to convert to Typst, so I figured it'd be good to make this template publicly available.

## Quick start

Click [here](https://typst.app/app?template=adaptable-pset&version=0.1.1) to get started, or click the "Create project in app" link on the typst universe link to get started easily with this template on the typst webapp.

## Showcase

For a more in-depth example, check out this [example pdf](https://github.com/stuxf/adaptable-pset/blob/main/example.pdf):

### Cover Page

![Example cover page](https://raw.githubusercontent.com/stuxf/adaptable-pset/main/example_cover.png)

### Example problem

![Example problem](https://raw.githubusercontent.com/stuxf/adaptable-pset/main/example_problem.png)

## Starter code

You can use this to get started, or just use the quick start above for a more detailed template on the webapp

```typ
#import "@preview/adaptable-pset:0.2.0": *

// Feel free to omit any of the below, just set it to "" and it won't show
#let title = "HW5f"
#let author = "Stephen Xu"
#let collaborators = []
#let course-id = "Math 172: Galois Theory"
#let instructor = "Prof. Thonkers"
#let semester = "Spring 2024"
#let due-time = "Jun 14 at 1:00"

#show: homework.with(
  title: title,
  author: author,
  collaborators: collaborators,
  course-id: course-id,
  instructor: instructor,
  semester: semester,
  due-time: due-time,

  // Optional setting to change the paper size depending on region
  // (Defaults to A4)
  // paper-size: "us-letter", 
)

// Numbering
#set enum(numbering: "a)")

// Enable to get a latex-like look
// #set text(font: "New Computer Modern")

// #prob(title: "", color: green)[content goes here]
// Default color is green, can be changed to black if you want to print
// Note that title is optional, it can be removed if you just don't set it to anything (just do #prob[content])

#prob(title: "24.3.7")[
  Let $alpha = sqrt(2+sqrt(2)) in CC$.
  1. Compute $f = min_QQ (alpha)$.
  2. Find $E subset.eq CC$ such that $E$ is the splitting field for $f$ over $QQ$. Compute $|E:QQ|$.
  3. Show that $"Gal"(E\/QQ)$ contains an element of order $4$.
]

1. Consider $alpha^2 - sqrt(2) = 2$. Rearranging, we obtain $alpha^2 = 2 + sqrt(2)$. We thus have $alpha^4 = (2 + sqrt(2))^2 => alpha^4 - 4sqrt(2) -6 = 0$. We can rewrite $4sqrt(2)+6$ in terms of $alpha^2$, obtaining $4sqrt(2) +6 = 4alpha^2 -2$. Therefore $alpha^4 -4 alpha^2 +2$. As such we obtain a potential minimal polynomial $x^4 - 4x^2 +2$. Using Eisenstein's, we see it's irreducible and monic with $alpha$ as a root. Therefore $f = x^4-4x^2+2$. 

2. We can find the roots as $plus.minus sqrt(2+sqrt(2)), plus.minus sqrt(2-sqrt(2))$. We note that because they share the same minimal polymial, $|E:QQ| = deg(min_QQ (alpha)) = 4$, and we have that $E = QQ(sqrt(2+sqrt(2)),sqrt(2-sqrt(2)))$. 

3. Consider the automorphism $sigma in "Gal"(E\/QQ)$ such that $phi(alpha) = beta$, where $beta = sqrt(2-sqrt(2))$. Consider

   $ phi(sqrt(2)) = phi(sqrt(alpha beta)) = phi(alpha^2 - 2) = phi(alpha)^2 - phi(2) = beta^2 - 2  = -sqrt(2) $

   Using this, we see that we can use $sigma$ recursively to obtain $beta, alpha, -alpha, -beta$. We thus show that $sigma$ is an element of order $4$ in $"Gal"(E\/QQ)$. #emoji.heart

// Generally good to have a pagebreak between new problems
#pagebreak(weak: true)
```
<!-- 
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture> -->

## Appendix

* `#problem` is just a wrapper to showybox, for more information I reccomend checking their [documentation](https://typst.app/universe/package/showybox). 
