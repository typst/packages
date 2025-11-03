#import "@preview/dvdtyp:1.0.1": *

#show: dvdtyp.with(
  title: "dvd.typ",
  subtitle: [potato, tomato, banana],
  author: "among us",
  abstract: lorem(50),
)

#outline()

== Colorful wooo!!

#problem[
  Prove that $1+1=3$.
]

#theorem("Euclid")[
  infinite primes what???
]

#definition("hi")[
  i define hi as a greeting
]

#proof[
  $ "hi"="hello"="greeting" $
]

= Making own theorem enviorments

to make your own theorem enviorments, you can use the `builder-thmbox` and `builder-thmline` functions to generate _theorem styles_ and then use those to make theorems (idk if this is too convoluted or not, make an issue on github if you have a better idea).

```typ
#let theorem-style = builder-thmbox(color: colors.at(6), shadow: (offset: (x: 3pt, y: 3pt), color: luma(70%)))
#let theorem = theorem-style("theorem", "Theorem")
#let lemma = theorem-style("lemma", "Lemma")

#let definition-style = builder-thmline(color: colors.at(8))
#let definition = definition-style("definition", "Definition")
#let proposition = definition-style("proposition", "Proposition")

```
There is also a color pallete

#{
  let nums = range(16)

  align(
    center,

    table(
      columns: 16,
      stroke: 0pt,
      inset: 0em,
      ..nums.map(i => rect([#i], fill: colors.at(i), width: 2em, height: 2em)),
    ),
  )
}
