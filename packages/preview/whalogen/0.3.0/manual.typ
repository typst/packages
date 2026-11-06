#import "@local/whalogen:0.3.0": ce

#let pkg_name = "whalogen"
#let pkg_version = "v0.3.0"
#let author = (
  name: "Spencer Chang",
  email: "spencer@sycee.xyz",
)
#set document(author: author.name, title: pkg_name + " " + pkg_version)
#set page(numbering: "1", number-align: center)

#show raw.where(block: true): rect.with(
  fill: luma(240),
  width: 100%,
  inset: 3pt,
  radius: 2pt,
)

#let display_wide(..content) = {
  rect(
    width: 100%,
    fill: luma(240),
    inset: 1em,
    radius: 2pt,
    rect(
      width: 100%,
      fill: luma(255),
      radius: 2pt,
      stroke: (
        right: 2pt + luma(230),
        bottom: 2pt + luma(230),
      ),
      ..content
    )
  )
}

#let display(res, s) = {
  grid(columns: (1fr, 2fr),
    res,
    eval("[```typ\n" + s + "\n```]")
  )
}


// Title page.
#v(10.2fr)
#text(1.1em, datetime.today().display())

#text(2em, weight: 700, pkg_name + " " + pkg_version)\
#v(0.3em)
*#author.name* \
#author.email
#v(2.4fr)

#pagebreak()
#outline() 
#pagebreak()

= Quick Start Guide
```typst
#import "@preview/whalogen:0.2.0": ce

This is the formula for water: #ce("H2O")

This is a chemical reaction: 
#ce("CO2 + C -> 2CO")

It can be placed inside an equation: $#ce("CO2 + C -> 2CO")$

It can be placed on its own line:
$
#ce("CO2 + C -> 2CO")
$
```
#display_wide[
  This is the formula for water: #ce("H2O")

  This is a chemical reaction: 
  #ce("CO2 + C -> 2CO")

  It can be placed inside an equation: $#ce("CO2 + C -> 2CO")$

  It can be placed on its own line:
  $
  #ce("CO2 + C -> 2CO")
  $
]
#pagebreak()

= Introduction
This package is designed to facillitate the typesetting of chemical formulas in Typst. It mainly aims to 
replicate the functionality and operation of LaTeX's `mhchem` package. However, there are naturally some differences in the implementation of some features. 

All of the features of this package are designed to function in both text and math mode.

#show heading: it => {
  v(1em)
  it
  v(0.4em)
}

= Chemical Equations
#display(ce("CO2 + C -> 2CO"), "#ce(\"CO2 + C -> 2CO\")")

= Chemical Formulae
#display(ce("H2O"), "#ce(\"H2O\")")
#display(ce("Sb2O3"), "#ce(\"Sb2O3\")")

= Charges
#display(ce("H+"), "#ce(\"H+\")")
#display(ce("CrO4^2-"), "#ce(\"CrO4^2-\")")
#display(ce("[AgCl2]-"), "#ce(\"[AgCl2]-\")")
#display(ce("Y^99+"), "#ce(\"Y^99+\")")

The en-dash (#sym.dash.en) will be used for minus. 

= Oxidation States
#display(ce("Fe^II Fe^III_2O4"), "#ce(\"Fe^II Fe^III_2O4\")")

A caret (^) will imply that subsequent characters should be in the superscript unless interrupted by certain characters (i.e. whitespace and underscore).

= Unpaired Electrons and Radical Dots
#display(ce("OCO^.-"), "#ce(\"OCO^.-\")")
#display(ce("NO^2.-"), "#ce(\"NO^2.-\")")

#pagebreak()
= Stoichiometric Numbers
#display(ce("2H2O"), "#ce(\"2H2O\")")
#display(ce("2 H2O"), "#ce(\"2 H2O\")")
#display(ce("0.5H2O"), "#ce(\"0.5H2O\")")
#display(ce("1/2H2O"), "#ce(\"1/2H2O\")")

The behavior of the fraction line is inherited from Typst's default behavior and generally obeys the rules
for grouping numbers and automatically removing parenthesis.

When whitespace is inserted between the stoichiometric number and a compound with a subscript, the whitespace is automatically trimmed. If there is no subscript, the whitespace is not trimmed. This is a characteristic of Typst. 
#display(ce("2 CO"), "#ce(\"2 CO\")")

= Nuclides, Isotopes
#display(ce("@Th,227,90@^+"), "#ce(\"@Th,227,90@^+\")")
#display(ce("@n,0,-1@^-"), "#ce(\"@n,0,-1@^-\")")
#display(ce("@Tc,99m,@"), "#ce(\"@Tc,99m,@\")")

To simplify implementation of the parser, this string pattern is introduced to specify nuclides and isotopes.
This is different from `mhchem`.

= Parenthesis, Brackets, Braces
#display(ce("(NH4)2S"), "#ce(\"(NH4)2S\")")

The parenthesis, brackets, and braces will automatically size to match the inner content.
#display(ce("[{(X2)3}2]^3+"), "#ce(\"[{(X2)3}2]^3+\")")

#pagebreak()

= Reaction Arrows
#display(ce("A -> B"), "#ce(\"A -> B\")")
#display(ce("A <- B"), "#ce(\"A <- B\")")
#display(ce("A <-> B"), "#ce(\"A <-> B\")")
#display(ce("A <--> B"), "#ce(\"A <--> B\")")
#display(ce("A <=> B"), "#ce(\"A <=> B\")")

These reaction arrows come from the built-in `sym` module.

It is also possible to include text above the arrow. The backend uses the `xarrow` package to resize the arrows and place respective text.

#display(ce("A ->[H2O] B"), "#ce(\"A ->[H2O] B\")")
#display(ce("A ->[some text] B"), "#ce(\"A ->[some text] B\")")
#display(ce("A ->[some text][other text] B"), "#ce(\"A ->[some text][other text] B\")")

= States of Aggregation
#display(ce("H2(aq)"), "#ce(\"H2(aq)\")")
#display(ce("NaOH(aq, #sym.infinity)"), "#ce(\"NaOH(aq, #sym.infinity)\")")

In Typst, when parenthesis and similar follow a subscript, it is also included in the subscript. This results in seemingly different behavior for very similar input as seen above. The #ce("H2") has an implied underscore whereas the #ce("NaOH") does not.

To achieve the opposite behavior as shown above, insert whitespace or underscore respectively. 
#display(ce("H2 (aq)"), "#ce(\"H2 (aq)\")")
#display(ce("NaOH_(aq, #sym.infinity)"), "#ce(\"NaOH_(aq, #sym.infinity)\")")

= Variables
#display(ce("H2O <=>[$k_1$][$k_-1$] OH- + H+"), "#ce(\"H2O <=>[$k_1$][$k_-1$] OH- + H+\")")
#display(ce("$x$ NaOH + H2SO4 -> Na$_x$ H$_(2 -x)$SO4"), "#ce(\"$x$ NaOH + H2SO4 = Na$_x$ H$_(2 -x)$SO4\")")
Sometimes it is needed to use variables in mathematical notation (i.e. italic). This is possible by using the equation delimiter $\$dots\$$ inside `ce()`.

#pagebreak()
= Further Examples
`ce` is a function that takes string input and returns a content block. As such, it can interact with the same rules as other content blocks in math mode. 

```typ
Example to calculate $K_a$:
$
K_a = (#h(1.3em) [#ce("H+")] overbrace(#ce("[A-]"), "conjugate acid"))/ underbrace(#ce("[HA]"), "acid")
$
Using `ce` in limit text:
$
lim_#ce("[H+]->#sym.infinity") K_a = #sym.infinity
$
Aligning multiple equations:
$
#ce("H2SO4 (aq) &<-> H+ (aq) + HSO4^- (aq)")\
#ce("H+ (aq) + HSO4^- (aq) &<-> H2SO4 (aq)")
$
```
#display_wide[
  Example to calculate $K_a$:
  $
  K_a = (#h(1.3em) [#ce("H+")] overbrace(#ce("[A-]"), "conjugate acid"))/ underbrace(#ce("[HA]"), "acid")
  $
  Using `ce` in limit text:
  $
  lim_#ce("[H+]->#sym.infinity") K_a = #sym.infinity
  $
  Aligning multiple equations:
  $
  #ce("H2SO4 (aq) &<-> H+ (aq) + HSO4^- (aq)")\
  #ce("H+ (aq) + HSO4^- (aq) &<-> H2SO4 (aq)")
  $
]

#pagebreak()
= Appendix
== Under the Hood
This package works by parsing the provided simple text input and converting it into Typst
equation input. In general, inserting whitespace will reset the parser's state machine. 
If there is still some strange behavior, the underlying Typst output can be inspected 
by setting the debug flag:
#display(ce("H2(aq)", debug: true), "#ce(\"H2(aq)\", debug: true)")
