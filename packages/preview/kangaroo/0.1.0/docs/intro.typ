#import "@local/kangaroo:0.1.0": *

#set page(width: auto, height: auto, margin: 1em)
#set text(size: 36pt)

#let cpa-real = library(title: lib(subject: $Sigma$)[cpa-real])[
  - $K <<- Sigma\.cal(K)$

  - #proc(subr[cpa.enc], args: $M$)
    - $C #hl[$:= Sigma\.algo("Enc")(K, M)$]$
    - return $C$
]

#let cpa-rand = library(title: lib(subject: $Sigma$)[cpa-rand])[
  - #proc(subr[cpa.enc], args: $M$)
    - $C #hl[$<<- Sigma\.cal(C)(|M|)$]$
    - return $C$
]

#chain(cpa-real, indist.is, cpa-rand)
