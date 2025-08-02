#import "@preview/itemize:0.1.2" as el
#set page(height: auto, margin: 25pt)

= reference the item
#[
  #let code = ```typ
  #show ref: el.ref-enum
  #show: el.default-enum-list
  #set enum(numbering: "(1).(a).(i)", full: true)
  + #lorem(50) <item:1>
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(10) <item:2>
    + #lorem(20)
  + #lorem(20)

  #show ref: set text(fill: orange)

  The @item:1[item] is referenced; you can see the conclusion@item:2 also holds.

  #set enum(numbering: "(1).(a).(i)", full: false)
  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$ @eq0 #el.elabel("eq")
    + #lorem(20)
      + #lorem(10)
      + #lorem(10) <item:4>
    + #lorem(20)
  + #lorem(20)

  The @eq[item] is referenced; you can see some thing@item:4. Note that `@eq0` will not work (since `@eq0` is labelled to the equation).
  ```

  #let result = [
    #show ref: el.ref-enum
    #show: el.default-enum-list
    #set enum(numbering: "(1).(a).(i)", full: true)
    + #lorem(50) <item:1>
    + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
      + #lorem(20)
        + #lorem(10)
        + #lorem(10) <item:2>
      + #lorem(20)
    + #lorem(20)

    #show ref: set text(fill: orange)

    The @item:1[item] is referenced; you can see the conclusion@item:2 also holds.

    #set enum(numbering: "(1).(a).(i)", full: false)
    + #lorem(50)
    + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$ <eq0> #el.elabel("eq")
      + #lorem(20)
        + #lorem(10)
        + #lorem(10) <item:4>
      + #lorem(20)
    + #lorem(20)

    The @eq[item] is referenced, you can see some thing@item:4. Note that `@eq0` will not work (since `@eq0` is labelled to the equation).
  ]

  The code is:
  #block(stroke: 1pt + red, inset: 5pt, code)
  The result is:
  #block(stroke: 1pt + blue, inset: 5pt, result)
]



#let eqs = $
  norm(x+y)^2 + norm(x-y)^2 = 2(norm(x)^2 + norm(y)^2)
$

#let inline-eq1 = [$l^p = {bold(x) = (x_1, x_2,...) : norm(bold(x))_p :=(sum_(j=1)^oo|x_j|^p)^(1 / p) < oo }$ ($1<=p<oo$)]
#let inline-eq2 = [$vec(1, 1, 1, 1)$]

#let simple-test = [
  + #lorem(5)
    #eqs
    + $vec(1, 1, 1, 1)$ #lorem(5)
      + #lorem(5)
      + #lorem(5)

        #lorem(5)
  + + + #lorem(5)
  - #lorem(5)
    #eqs
    - $vec(1, 1, 1, 1)$ #lorem(5)
      - #lorem(5)
      - #lorem(5)

        #lorem(20)
  - - - #lorem(5)
]

