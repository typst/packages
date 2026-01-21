#import "@preview/dvdtyp:1.0.0": *

#show: dvdtyp.with(
  title: "dvd.typ",
  subtitle: [potato, tomato, banana],
  author: "among us",
  abstract: lorem(50),
)

#outline()

= Lorem ipsum is my favourite
#lorem(50)

== Colorful wooo!!

#problem[
  Prove that $1+1=3$.
]

#example("addition")[$ 1+1=3 $
]

#theorem("Euclid")[ infinite primes what???
]

#definition("hi")[ i define hi as a greeting
]

#proof[
  $ "hi"="hello"="greeting" $
]

= new page cuz why not

#lorem(100)