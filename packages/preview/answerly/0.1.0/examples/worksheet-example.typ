#import "@preview/answerly:0.1.0": *
#import "@preview/itemize:0.2.0": default-enum-list

#set enum(numbering: "1)a)i)")
#show: default-enum-list

= Integration by Substitution -- Exercises

+ Use the substitution $u = cos x + 1$ to find $ integral_0^(pi/2) e^(cos x + 1) sin x dif x $ #ans[$e(e-1)$]

+ Use the substitution $u = sec theta$ to find $ integral tan theta sec^3 theta dif theta $ #ans[$1/27 (8 sqrt(3)-9)$]

+ + Use the substitution $u = x sin x + cos x$ to find

    $ integral frac(x, x tan x + 1) dif x . $ #ans[$ln|x sin x + cos x| + c$]

  + By means of a similar substitution, or otherwise, find

    $ integral frac(x, x cot x - 1) dif x . $ #ans[$-ln|x cos x - sin x| + c$]

+ The finite region $R$ is bounded by the coordinate axes and the curve$ y = sqrt((3 - x)(x + 1)), #h(2em) 0 <= x <= 3 $

  + Use the substitution $x = 1 + 2 sin theta$ to show that

    $ integral_0^3 sqrt((3 - x)(x + 1)) dif x = k integral_(-pi/6)^(pi/2) cos^2 theta dif theta $

    where $k$ is a constant to be found.

  + Hence find the exact area of $R$. #ans[$(4pi)/3 + sqrt(3)/2$]

+ + Show that

    $ frac(dif, dif u) ln(u + sqrt(u^2 - 1)) = frac(1, sqrt(u^2 - 1)) $

  + Use the substitution $x + 3 = frac(1, t)$ and the result from part the previous part to find

    $ integral frac(1, (x + 3) sqrt(2x + 7)) dif x $ #ans[$ln(x+3) - ln(x + 4 + sqrt(2x+7)) + c$]

#v(1fr)

#rotate(180deg)[
  == Answers
  #display-answers()
]
