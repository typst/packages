#import "@preview/answerly:0.1.0": *
#import "@preview/itemize:0.2.0": default-enum-list

#set enum(numbering: "1)a)i)")
#show: default-enum-list

= Simple Example

+ + Factorise $x^2 - 5 x + 6$. #ans[$(x - 2)(x - 3)$]

  + Hence solve the equation  $x^2 - 5 x + 6 = 0$. #ans[$x = 2$ or $x = 3$]

+ Solve each of the following equations:

  + $x^2 - 9 = 16$ #ans[$x = plus.minus 5$]

  + $x^2 = 36 x$ #ans[$x = 36$ or $x = 0$]

== Answers

#display-answers(clear: false)
