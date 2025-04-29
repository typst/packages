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

// Enable to get a latex-like look
// #set text(font: "New Computer Modern")

// Set Numbering (optional)
#set enum(numbering: "a)")

/*=================================
  Packages you may want to enable
=================================*/

// #import "@preview/quick-maths:0.2.0": shorthands
// #show: shorthands.with(
//   ($|=$, math.tack.double),
// )

// #import "@preview/diverential:0.2.0": *
// #import "@preview/physica:0.9.4": *

// #import "@preview/codly:1.2.0": *
// #import "@preview/codly-languages:0.1.8": *
// #codly(languages: codly-languages)
// #show: codly-init

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

#prob(title:"New Problem")[
  Content 1 from part 1
][
  Content 2 from part 2
]

1. Answering question posed from part 1.

2. Answering question posed from part 2.
