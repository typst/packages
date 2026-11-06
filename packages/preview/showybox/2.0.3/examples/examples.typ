#import "@preview/codelst:1.0.0": *
#import "../showy.typ": *

#set text(font: "HK Grotesk", size: 12pt)
#set heading(numbering: "I.")

= Stokes' theorem example

#sourcecode(```typ
#showybox(
  title: "Stokes' theorem",
  frame: (
    border-color: blue,
    title-color: blue.lighten(30%),
    body-color: blue.lighten(95%),
    footer-color: blue.lighten(80%)
  ),
  footer: "Information extracted from a well-known public encyclopedia"
)[
  Let $Sigma$ be a smooth oriented surface in $RR^3$ with boundary $diff Sigma equiv Gamma$. If a vector field $bold(F)(x,y,z)=(F_x (x,y,z), F_y (x,y,z), F_z (x,y,z))$ is defined and has continuous first order partial derivatives in a region containing $Sigma$, then

  $ integral.double_Sigma (bold(nabla) times bold(F)) dot bold(Sigma) = integral.cont_(diff Sigma) bold(F) dot dif bold(Gamma) $
]
```)

#showybox(
  title: "Stokes' theorem",
  frame: (
    border-color: blue,
    title-color: blue.lighten(30%),
    body-color: blue.lighten(95%),
    footer-color: blue.lighten(80%)
  ),
  footer: "Information extracted from a well-known public encyclopedia"
)[
  Let $Sigma$ be a smooth oriented surface in $RR^3$ with boundary $diff Sigma equiv Gamma$. If a vector field $bold(F)(x,y,z)=(F_x (x,y,z), F_y (x,y,z), F_z (x,y,z))$ is defined and has continuous first order partial derivatives in a region containing $Sigma$, then

  $ integral.double_Sigma (bold(nabla) times bold(F)) dot bold(Sigma) = integral.cont_(diff Sigma) bold(F) dot dif bold(Gamma) $
]

= Gauss's Law example

#sourcecode(
```typ
#showybox(
  frame: (
    border-color: red.darken(30%),
    title-color: red.darken(30%),
    radius: 0pt,
    thickness: 2pt,
    body-inset: 2em,
    dash: "densely-dash-dotted"
  ),
  title: "Gauss's Law"
)[
  The net electric flux through any hypothetical closed surface is equal to $1/epsilon_0$ times the net electric charge enclosed within that closed surface. The closed surface is also referred to as Gaussian surface. In its integral form:

  $ Phi_E = integral.surf_S bold(E) dot dif bold(A) = Q/epsilon_0 $
]
```
)

#showybox(
  frame: (
    border-color: red.darken(30%),
    title-color: red.darken(30%),
    radius: 0pt,
    thickness: 2pt,
    body-inset: 2em,
    dash: "densely-dash-dotted"
  ),
  title: "Gauss's Law"
)[
  The net electric flux through any hypothetical closed surface is equal to $1/epsilon_0$ times the net electric charge enclosed within that closed surface. The closed surface is also referred to as Gaussian surface. In its integral form:

  $ Phi_E = integral.surf_S bold(E) dot dif bold(A) = Q/epsilon_0 $
]

= Carnot's cycle efficency example

#sourcecode(
```typ
#showybox(
  title-style: (
    weight: 900,
    color: red.darken(40%),
    sep-thickness: 0pt,
    align: center
  ),
  frame: (
    title-color: red.lighten(80%),
    border-color: red.darken(40%),
    thickness: (left: 1pt),
    radius: 0pt
  ),
  title: "Carnot cycle's efficency"
)[
  Inside a Carnot cycle, the efficiency $eta$ is defined to be:

  $ eta = W/Q_H = frac(Q_H + Q_C, Q_H) = 1 - T_C/T_H $
]
```
)

#showybox(
  title-style: (
    weight: 900,
    color: red.darken(40%),
    sep-thickness: 0pt,
    align: center
  ),
  frame: (
    title-color: red.lighten(80%),
    border-color: red.darken(40%),
    thickness: (left: 1pt),
    radius: 0pt
  ),
  title: "Carnot cycle's efficency"
)[
  Inside a Carnot cycle, the efficiency $eta$ is defined to be:

  $ eta = W/Q_H = frac(Q_H + Q_C, Q_H) = 1 - T_C/T_H $
]

= Clairaut's theorem example

#sourcecode(
```typ
#showybox(
  title-style: (
    boxed-style: (
      anchor: (
        x: center,
        y: horizon
      ),
      radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
    )
  ),
  frame: (
    title-color: green.darken(40%),
    body-color: green.lighten(80%),
    footer-color: green.lighten(60%),
    border-color: green.darken(60%),
    radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)
  ),
  title: "Clairaut's theorem",
  footer: text(size: 10pt, weight: 600, emph("This will be useful every time you want to interchange partial derivatives in the future."))
)[
  Let $f: A arrow RR$ with $A subset RR^n$ an open set such that its cross derivatives of any order exist and are continuous in $A$. Then for any point $(a_1, a_2, ..., a_n) in A$ it is true that

  $ frac(diff^n f, diff x_i ... diff x_j)(a_1, a_2, ..., a_n) = frac(diff^n f, diff x_j ... diff x_i)(a_1, a_2, ..., a_n) $
]
```
)

#showybox(
  title-style: (
    boxed-style: (
      anchor: (
        x: center,
        y: horizon
      ),
      radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
    )
  ),
  frame: (
    title-color: green.darken(40%),
    body-color: green.lighten(80%),
    footer-color: green.lighten(60%),
    border-color: green.darken(60%),
    radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)
  ),
  title: "Clairaut's theorem",
  footer: text(size: 10pt, weight: 600, emph("This will be useful every time you want to interchange partial derivatives in the future."))
)[
  Let $f: A arrow RR$ with $A subset RR^n$ an open set such that its cross derivatives of any order exist and are continuous in $A$. Then for any point $(a_1, a_2, ..., a_n) in A$ it is true that

  $ frac(diff^n f, diff x_i ... diff x_j)(a_1, a_2, ..., a_n) = frac(diff^n f, diff x_j ... diff x_i)(a_1, a_2, ..., a_n) $
]

= Divergence theorem example

#sourcecode(
```typ
#showybox(
  footer-style: (
    sep-thickness: 0pt,
    align: right,
    color: black
  ),
  title: "Divergence theorem",
  footer: [
    In the case of $n=3$, $V$ represents a volumne in three-dimensional space, and $diff V = S$ its surface
  ]
)[
  Suppose $V$ is a subset of $RR^n$ which is compact and has a piecewise smooth boundary $S$ (also indicated with $diff V = S$). If $bold(F)$ is a continuously differentiable vector field defined on a neighborhood of $V$, then:

  $ integral.triple_V (bold(nabla) dot bold(F)) dif V = integral.surf_S (bold(F) dot bold(hat(n))) dif S $
]```
)

#showybox(
  footer-style: (
    sep-thickness: 0pt,
    align: right,
    color: black
  ),
  title: "Divergence theorem",
  footer: [
    In the case of $n=3$, $V$ represents a volumne in three-dimensional space, and $diff V = S$ its surface
  ]
)[
  Suppose $V$ is a subset of $RR^n$ which is compact and has a piecewise smooth boundary $S$ (also indicated with $diff V = S$). If $bold(F)$ is a continuously differentiable vector field defined on a neighborhood of $V$, then:

  $ integral.triple_V (bold(nabla) dot bold(F)) dif V = integral.surf_S (bold(F) dot bold(hat(n))) dif S $
]

= Coulomb's law example

#sourcecode(
```typ
#showybox(
  shadow: (
    color: yellow.lighten(55%),
    offset: 3pt
  ),
  frame: (
    title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(80%)
  ),
  title: "Coulomb's law"
)[
  Coulomb's law in vector form states that the electrostatic force $bold(F)$ experienced by a charge $q_1$ at position $bold(r)$ in the vecinity of another charge $q_2$ at position $bold(r')$, in a vacuum is equal to

  $ bold(F) = frac(q_1 q_2, 4 pi epsilon_0) frac(bold(r) - bold(r'), bar.v bold(r) - bold(r') bar.v^3) $
]```
)

#showybox(
  shadow: (
    color: yellow.lighten(55%),
    offset: 3pt
  ),
  frame: (
    title-color: red.darken(30%),
    border-color: red.darken(30%),
    body-color: red.lighten(80%)
  ),
  title: "Coulomb's law"
)[
  Coulomb's law in vector form states that the electrostatic force $bold(F)$ experienced by a charge $q_1$ at position $bold(r)$ in the vecinity of another charge $q_2$ at position $bold(r')$, in a vacuum is equal to

  $ bold(F) = frac(q_1 q_2, 4 pi epsilon_0) frac(bold(r) - bold(r'), bar.v bold(r) - bold(r') bar.v^3) $
]

= Newton's second law example

#sourcecode(
```typ
#block(
  height: 4.5cm,
  inset: 1em,
  fill: luma(250),
  stroke: luma(200),
  breakable: false,
  columns(2)[
    #showybox(
      title-style: (
        boxed-style: (
          anchor: (x: center, y: horizon)
        )
      ),
      breakable: true,
      width: 90%,
      align: center,
      title: "Newton's second law"
    )[
      If a body of mass $m$ experiments an acceleration $bold(a)$ due to a net force $sum bold(F)$, this acceleration is related to the mass and force by the following equation:

      $ bold(a) = frac(sum bold(F), m) $
    ]
  ]
)```
)

#block(
  height: 4.5cm,
  inset: 1em,
  fill: luma(250),
  stroke: luma(200),
  breakable: false,
  columns(2)[
    #showybox(
      title-style: (
        boxed-style: (
          anchor: (x: center, y: horizon)
        )
      ),
      breakable: true,
      width: 90%,
      align: center,
      title: "Newton's second law"
    )[
      If a body of mass $m$ experiments an acceleration $bold(a)$ due to a net force $sum bold(F)$, this acceleration is related to the mass and force by the following equation:

      $ bold(a) = frac(sum bold(F), m) $
    ]
  ]
)

= Encapsulation example

#sourcecode(
```typ
#showybox(
  title: "Parent container",
  lorem(10),
  columns(2)[
    #showybox(
      title-style: (boxed-style: (:)),
      title: "Child 1",
      lorem(10)
    )
    #colbreak()
    #showybox(
      title-style: (boxed-style: (:)),
      title: "Child 2",
      lorem(10)
    )
  ]
)```
)

#showybox(
  title: "Parent container",
  lorem(10),
  columns(2)[
    #showybox(
      title-style: (boxed-style: (:)),
      title: "Child 1",
      lorem(10)
    )
    #colbreak()
    #showybox(
      title-style: (boxed-style: (:)),
      title: "Child 2",
      lorem(10)
    )
  ]
)