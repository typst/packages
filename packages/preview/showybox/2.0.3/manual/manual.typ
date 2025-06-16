#import "../showy.typ": *
#import "template.typ": *
#import "@preview/codelst:2.0.1": sourcecode

#show: front-page


= Introduction

Showybox is a Typst package for creating colorful and customizable boxes, similar as `tcolorbox` for LaTeX users.

Currently, Showybox is still on developement, and all the code can be found at its GitHub repository #link("https://github.com/Pablo-Gonzalez-Calderon/showybox-package", "here"). New features are welcome. So, if you have an idea that would improve this package, go on and send us the code as a Pull Request.

= Usage

To use this library through the Typst package manager (for Typst 0.6.0 or greater), write #raw(lang: "typ", block: false, "#import \"@preview/showybox:" + version +"\": showybox") at the beginning of your Typst file.

Once imported, you can create an empty showybox by using the function #line-raw("showybox()") and giving a default body content inside the parenthesis or outside them using the squared brackets `[]`.

By default a showybox with these properties will be created:

#grid(
  columns: (1fr, 2fr),
  gutter: 20pt,
  [
  - No title
  - No shadow
  - Not breakable
  - Black borders
  - White background
  - #raw(lang: "typc", "5pt") of border radius
  - #raw(lang: "typc", "1pt") of border thickness
],[
  #sourcecode(raw(
    block: true,
    lang: "typ",
    "#import \"@preview/showybox:" + version +"\": showybox \n\n#showybox()[This is a simple showybox with the properties said before :)]"
  ))

  #showybox()[This is a simple showybox with the properties said before :)]
])

= Parameters

In version #version all the parameters that the #raw(lang: "typc", "showybox()") function can receive are shown below:

#sbox-parameters()

The usage and posible values of all the parameters are listed below.

== Title #type-block("string") #type-block("content")

When it's not empty, correponds to a #type-block("string") or a #type-block("content") used as the title of the showybox.

Default value is #line-raw("\"\"") (empty string)

#grid(
  columns: (1fr, 1.5fr),
  column-gutter: 11pt,
)[
  #showybox(
    title: "Hi there! I'm Mr. Title"
  )[And I'm Mrs. Body]

  #showybox()[And I'm Mrs. Body]
][
#sourcecode(```typ
#showybox(
  title: "Hi there! I'm Mr. Title"
)[And I'm Mrs. Body]

#showybox(/*Untitled*/)[And I'm Mrs. Body]
```)
]

== Footer #type-block("string") #type-block("content")

When it's not empy, corresponds to a #type-block("string") or a #type-block("content") used as the footer of the showybox.

Default is #raw(lang: "typc", "\"\"") (empty `string`).

#sourcecode(```typ
#showybox(
  title: "Hi there! I'm Mr. Title",
  footer: "And finally I'm Mr. Footer"
)[And I'm Mrs. Body]
```)

#showybox(
  title: "Hi there! I'm Mr. Title",
  footer: "And finally I'm Mr. Footer"
)[And I'm Mrs. Body]

== Frame #type-block("dictionary")

This parameter contains all options that are useful for setting a showybox's frame properties. The frame contains the title,the body and the footer of the showybox. It even includes the showybox borders! Frame's dictionary options are listed below:

#frame-parameters()

=== title-color
#type-block("color")

The color used as background where the title goes.

Default is #line-raw("black").

=== body-color
#type-block("color")

The color that is used as background where the showybox's body goes.

Default is #line-raw("white").

=== footer-color
#type-block("color")

The color that is used as background where the footer goes.

Default is #line-raw("luma(220)")

=== border-color
#type-block("color")

It's the color used for the frame's borders and the boxed-title borders. It's independent of `title-color`, `body-color` and `footer-color`, so maybe you would want to use similar colors with them.

Default is #line-raw("black").

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

=== radius
#type-block("relative-length") #type-block("dictionary")

Indicates how much round are the borders of the frame. It sets _all_ the border radii together if a #type-block("relative-length") passed, or individually if a #type-block("dictionary") is given.

It excludes the boxed-title border radii (if present). Their radius is set in `boxed-style` dictionary inside `title-style`.

Default is #line-raw("5pt").

=== thickness
#type-block("length") #type-block("dictionary")

Indicates the thickness of the frame borders as a #type-block("length") or a #type-block("dictionary"). If it's a dictionary, it can specify `top`, `bottom`, `left`, `right`, `x`, `y` or `rest` thickness.

It excludes the thickness of any separator located inside the box (their thickness is set in `sep` property).

Default is #line-raw("1pt").

=== dash
#type-block("string")

Corresponds to the frame border's style. It can be any kind of style used for #line-raw("line()"). For instance, it can be #line-raw("\"solid\""), #line-raw("\"dotted\""), #line-raw("\"densely-dotted\""), #line-raw("\"loosely-dotted\""), #line-raw("\"dashed\""), #line-raw("\"densely-dashed\""), #line-raw("\"loosely-dashed\""), #line-raw("\"dash-dotted\""), #line-raw("\"densely-dash-dotted\"") or #line-raw("\"loosely-dash-dotted\"")

Default is #line-raw("\"solid\"").

=== inset, title-inset, body-inset, and footer-inset
#type-block("relative-length") #type-block("dictionary")

How much to pad the showybox's content. It can be a #type-block("relative-length") or a #type-block("dictionary"). If it's a dictionary, it can specify `top`, `bottom`, `left`, `right`, `x`, `y` or `rest` insets.

If `title-inset`, `body-inset` or `footer-inset` is given, this property is ignored while setting the inset of the title, the body or the footer, respectively.

Default is #line-raw("(x: 1em, y: 0.65em)").

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

== Title style #type-block("dictionary")

This parameter contains all options that are useful for setting showybox's title properties. Despite you can set some of this properties while setting `title` parameter, it becomes a useful option while making several showyboxes with similar styles.

#title-style-parameters()

=== color
#type-block("color")

Title's text color.

Default is `white`.

=== weight
#type-block("integer") #type-block("string")

Title's font weight. It can be an integer between #line-raw("100") and #line-raw("900"), or a predefined weight name (#line-raw("\"thin\""), #line-raw("\"extralight\""), #line-raw("\"light\""), #line-raw("\"regular\""), #line-raw("\"medium\""), #line-raw("\"semibold\""), #line-raw("\"bold\""), #line-raw("\"extrabold\"") and #line-raw("\"black\"")).

Default is #line-raw("\"regular\"").

=== align
#type-block("alignment") #type-block("2d-alignment")

How to align title's content. It can be an unidimensional alignment or a bidimensional alignment.

Default is `left`.

=== sep-thickness
#type-block("length")

How much is the thickness of the separator line that is between the title and the body.

Default is #line-raw("1pt").

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

=== boxed-style
#type-block("dictionary") #type-block("none")

If it's not #line-raw("none") (i.e. it's a #type-block("dictionary")), indicates that the title must be placed as a "floating box" around the
top side of the showybox's body.

Further details are present in @boxed-style

Default is #line-raw("none").

== Boxed style #type-block("dictionary") <boxed-style>

#boxed-style-parameters()

=== anchor
#type-block("dictionary")

A #type-block("dictionary") with keys `x` and `y` indicating where to place the anchor of the boxed-title. The possible values for each direction are listed below:

For `x` anchor:
- #line-raw("left"): Set the anchor to the left side of the boxed-title.
- #line-raw("center"): Set the anchor to the center of the horizontal center of the boxed-title.
- #line-raw("right"): Set the anchor to the right side of the boxed-title.

For `y` anchor:
- #line-raw("top"): Set the anchor to the top of the boxed-title.
- #line-raw("horizon"): Set the anchor to the vertical center of the boxed-title.
- #line-raw("bottom"): Set the anchor to the bottom of the boxed-title.

Default is #line-raw("(x: left, y: horizon)").

=== offset
#type-block("dictionary")

A #type-block("dictionary") with keys `x` and `y` indicating how much to offset the boxed-title in x and y directions.

Default is #line-raw("(x: 0pt, y: 0pt)").

#observation()[
  By default, the boxed-title has a #line-raw("1em") "invisible-offset" (it's not set via `offset` property) at both left and right sides. This is made for aesthetic purposes, so the boxed-title will look nicer by default.

  Additionally, the boxed-title *never* will have the full width of the showybox's main container, because otherwise it'll look like a "strange" version of default titles, loosing the "floating" illusion.
]

=== radius
#type-block("relative-length") #type-block("dictionary")

Radius of the boxed-title. It is applied to all corners simultaneously if a #type-block("relative-length") is given, or it's applied individually to each of them according to a #type-block("dictionary") keys.

Default is #line-raw("5pt").

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

== Body style #type-block("dictionary")

This parameter contains all options that are useful for setting general-style properties for the showybox's body.

#body-style-parameters()

=== color
#type-block("color")

Body's text color.

Default is `black`.

=== align
#type-block("alignment") #type-block("2d-alignment")

How to align body's content. It can be an unidimensional alignement or a bidimensional alignement.

Default is `left`.

#sourcecode(
```typ
#showybox(
  body-style: (
    align: center,
    color: red.darken(20%)
  ),
  frame: (
    body-color: yellow.lighten(60%),
    title-color: red.darken(20%),
    thickness: 0pt,
    body-inset: (y: 1em)
  ),
  title-style: (
    sep-thickness: 0pt,
    color: yellow.lighten(80%),
    align: center
  ),
  width: 70%,
  align: center,
  title: "That is the question"
)[
  To be, or not to be, that is the question: \
  Whether 'tis nobler in the mind to suffer \
  The slings and arrows of outrageous fortune, \
  Or to take Arms against a Sea of troubles, \
  And by opposing end them: to die, to sleep \
  No more; and by a sleep, to say we end \
  The heart-ache, and the thousand natural shocks \
  That Flesh is heir to? 'Tis a consummation \
  Devoutly to be wished. To die, to sleep, \
  To sleep, perchance to Dream...
]```
)

#showybox(
  body-style: (
    align: center,
    color: red.darken(20%)
  ),
  frame: (
    body-color: yellow.lighten(60%),
    title-color: red.darken(20%),
    thickness: 0pt,
    body-inset: (y: 1em)
  ),
  title-style: (
    sep-thickness: 0pt,
    color: yellow.lighten(80%),
    align: center
  ),
  width: 70%,
  align: center,
  title: "That is the question"
)[
  To be, or not to be, that is the question: \
  Whether 'tis nobler in the mind to suffer \
  The slings and arrows of outrageous fortune, \
  Or to take Arms against a Sea of troubles, \
  And by opposing end them: to die, to sleep \
  No more; and by a sleep, to say we end \
  The heart-ache, and the thousand natural shocks \
  That Flesh is heir to? 'Tis a consummation \
  Devoutly to be wished. To die, to sleep, \
  To sleep, perchance to Dream...
]

== Footer style #type-block("dictionary")

This parameter contains all options that are useful for setting showybox's footer properties. Despite you can set some of this properties while setting `footer` parameter, it becomes a useful option while making several showyboxes with similar styles.

#footer-style-parameters()

=== color
#type-block("color")

Footer's text color.

Default is #line-raw("luma(85)").

=== weight
#type-block("integer") #type-block("string")

Footer's font weight. It can be an integer between #line-raw("100") and #line-raw("900"), or a predefined weight name (#line-raw("\"thin\""), #line-raw("\"extralight\""), #line-raw("\"light\""), #line-raw("\"regular\""), #line-raw("\"medium\""), #line-raw("\"semibold\""), #line-raw("\"bold\""), #line-raw("\"extrabold\"") and #line-raw("\"black\"")).

Default is #line-raw("\"regular\"").

=== align
#type-block("alignment") #type-block("2d-alignment")

How to align footer's content. It can be an unidimensional alignment or a bidimensional alignment.

Default is `left`.

=== sep-thickness
#type-block("length")

How much is the thickness of the separator line that is between the footer and the body.

Default is #line-raw("1pt").

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

== Separator properties (`sep`) #type-block("dictionary")

This parameter contains all options that are used for setting all the separator's styles of your showybox. To learn more about how to use separators, see @separators.

#sep-parameters()

=== thickness
#type-block("length")

Corresponds to the separator thickness.

Default is #line-raw("1pt").

=== gutter
#type-block("relative-length")

The size of the gutter space above and below the separator.

Default is #line-raw("0.65em").

=== dash
#type-block("string")

It's the separator's dash pattern. It can be any kind of style used for #line-raw("line()"). For instance, it can be #line-raw("\"solid\""), #line-raw("\"dotted\""), #line-raw("\"densely-dotted\""), #line-raw("\"loosely-dotted\""), #line-raw("\"dashed\""), #line-raw("\"densely-dashed\""), #line-raw("\"loosely-dashed\""), #line-raw("\"dash-dotted\""), #line-raw("\"densely-dash-dotted\"") or #line-raw("\"loosely-dash-dotted\"")

Default is #line-raw("\"solid\"").

#sourcecode(
```typ
#showybox(
  sep: (
    thickness: 0.5pt,
    dash: "loosely-dashed"
  ),
  title: "Coordinate systems"
)[
  *Cartesian coordinate system*

  A Cartesian coordinate system for a three-dimensional space consists of an ordered triplet of lines (the axes) that go through a common point (the origin), and are pair-wise perpendicular.

  A way to represent a point $r$ is using the unit vectors ($bold(i)$, $bold(j)$, and $bold(k)$) is:

  $ bold(r) = x bold(i) + y bold(j) + z bold(k) $
][
  *Spherical coordinate system*

  A spherical coordinate system is a coordinate system for three-dimensional space where the position of a point is specified by three numbers: the radial distance of that point from a fixed origin ($r$); its polar angle measured from a fixed polar axis or zenith direction ($theta$); and the azimuthal angle of its orthogonal projection on a reference plane that passes through the origin and is orthogonal to the fixed axis, measured from another fixed reference direction on that plane ($phi$).

  The position of a point or particle (although better written as a triple $(r, theta, phi)$ can be written as:

  $ bold(r) = r bold(hat(r)) $
]```
)

#showybox(
  sep: (
    thickness: 0.5pt,
    dash: "loosely-dashed"
  ),
  title: "Coordinate systems"
)[
  *Cartesian coordinate system*

  A Cartesian coordinate system for a three-dimensional space consists of an ordered triplet of lines (the axes) that go through a common point (the origin), and are pair-wise perpendicular.

  A way to represent a point $r$ is using the unit vectors ($bold(i)$, $bold(j)$, and $bold(k)$) is:

  $ bold(r) = x bold(i) + y bold(j) + z bold(k) $
][
  *Spherical coordinate system*

  A spherical coordinate system is a coordinate system for three-dimensional space where the position of a point is specified by three numbers: the radial distance of that point from a fixed origin ($r$); its polar angle measured from a fixed polar axis or zenith direction ($theta$); and the azimuthal angle of its orthogonal projection on a reference plane that passes through the origin and is orthogonal to the fixed axis, measured from another fixed reference direction on that plane ($phi$).

  The position of a point or particle (although better written as a triple $(r, theta, phi)$ can be written as:

  $ bold(r) = r bold(hat(r)) $
]

== Shadow properties #type-block("dictionary")

The given #type-block("dictionary") contains all properties that are used for showing a showybox with a shadow. When this property is absent (i.e. it's not set or set as #line-raw("none")), the showybox has no shadow.

#shadow-parameters()

=== color
#type-block("color")

Shadow's color.

Default is #line-raw("luma(128)").

=== offset
#type-block("relative-length") #type-block("dictionary")

How much to offset the shadow in x and y direction either as a #type-block("relative-length") or a #type-block("dictionary") with keys `x` and `y`.

Default is #line-raw("4pt").

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

== Width #type-block("relative-length")

This parameter sets the showybox's width.

Default is #line-raw("100%").

== Align #type-block("alignment")

How to align showybox inside it's container (useful for showyboxes with #line-raw("width < 100%")).

Default is `left`.

== Breakable #type-block("boolean")

This parameter indicates whether a showybox can or cannot break if it reaches an end of page or the end of its container.

Default is #line-raw("false")

== Spacing, above, and below #type-block("relative-length")

`spacing` sets how much space to insert above and below the showybox, unless `above` or `below` are given.

By default it's the `block`'s default spacing in your document.

#sourcecode(
```typ
#block(
  height: 4.5cm,
  inset: 1em,
  fill: luma(250),
  stroke: luma(200),
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

= Separators <separators>

Sometimes you would wish to split a content into two or more sections inside the same showybox. The #line-raw("showybox()") function allows you to do that by putting several #type-block("content") elements separated by commas inside the parenthesis `()` of the function. Each individual #type-block("content") element will be a separated section inside the showybox.

Alternatively, you can put adjacent #type-block("content")elements one after another next to the closing parenthesis of the function. Both cases generates the same outcome.

= Encapsulation

Showyboxes can be put inside another showyboxes! As you may think, it's easy to do it: just put a showybox inside the body of another, and ta-da!

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