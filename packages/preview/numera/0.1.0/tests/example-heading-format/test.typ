#import "@preview/numera:0.1.0": heading-dependent, normal-figure, numera
#set page(width: 17cm, height: auto, margin: 1cm)
#set heading(numbering: "1.")
#show heading.where(level: 1): set heading(supplement: [Chapter])
#show: numera(level: 1)
#show normal-figure: set figure(numbering: heading-dependent(1, "1"))
#set math.equation(numbering: heading-dependent(1, "(1)"))

= First chapter
#figure([Image], caption: [Default reference prefix]) <first>
$ x = 1 $ <equation>
@first; @equation.

== Nested heading
#figure(table([Cell]), caption: [Table counter]) <table>
#figure(`code`, caption: [Raw counter]) <raw>
@table; @raw.

= Second chapter
#figure([Image], caption: [Counter resets]) <second>
@second; @first.

#show normal-figure: set figure(numbering: heading-dependent(
  1,
  "1",
  heading-format: "display",
))
#figure([Image], caption: [Legacy display prefix]) <legacy>
@legacy.

#show normal-figure: set figure(numbering: heading-dependent(
  1,
  "(1)",
  separator: "-",
  heading-format: "reference",
))
#figure([Image], caption: [Element decoration is retained]) <decorated>
@decorated.

#set heading(numbering: (ref: false, ..nums) => {
  numbering("I", ..nums) + if ref { "" } else { ")" }
})
= Custom heading format
#show normal-figure: set figure(numbering: heading-dependent(1, "1"))
#figure([Image], caption: [Custom reference prefix]) <custom>
@custom.

#show normal-figure: set figure(numbering: heading-dependent(0, "1"))
#figure([Image], caption: [No heading prefix]) <zero>
@zero.

#set heading(numbering: none)
= Unnumbered heading
#show normal-figure: set figure(numbering: heading-dependent(1, "1"))
#figure([Image], caption: [No numbered heading]) <unnumbered>
@unnumbered.
