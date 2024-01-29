#import "../lib.typ": square-printer-test, gradient-printer-test, circular-printer-test, crosshair-printer-test

#set text(
  font: "Arial"
)

= #underline[All together]

#raw("#square-printer-test()", lang: "typst")
#square-printer-test()

#raw("#gradient-printer-test()", lang: "typst")
#gradient-printer-test()

#raw("#circular-printer-test()", lang: "typst")
#circular-printer-test()

#raw("#crosshair-printer-test()", lang: "typst")
#crosshair-printer-test()

#pagebreak()

== #underline[Square test]

#raw("#square-printer-test(dir: rtl)", lang: "typst")
#square-printer-test(dir: rtl)

#raw("#square-printer-test(dir: ttb)", lang: "typst")
#square-printer-test(dir: ttb)

#raw("#square-printer-test(size: 50pt)", lang: "typst")
#square-printer-test(size: 50pt)

#raw("#square-printer-test(dir: ttb, size: 5pt)", lang: "typst")
#square-printer-test(dir: ttb, size: 5pt)

#pagebreak()

== #underline[Gradient test]

#raw("#gradient-printer-test(dir: rtl)", lang: "typst")
#gradient-printer-test(dir: rtl)

#raw("#gradient-printer-test(dir: btt)", lang: "typst")
#gradient-printer-test(dir: btt)

#raw("#gradient-printer-test(width: 50pt)", lang: "typst")
#gradient-printer-test(width: 50pt)

#raw("#gradient-printer-test(height: 40pt)", lang: "typst")
#gradient-printer-test(height: 40pt)

#raw("#gradient-printer-test(width: 400pt, height: 10pt)", lang: "typst")
#gradient-printer-test(width: 400pt, height: 10pt)

#pagebreak()

== #underline[Circular test]

#raw("#circular-printer-test(size: 15pt)", lang: "typst")
#circular-printer-test(size: 15pt)

#raw("#circular-printer-test(size: 200pt)", lang: "typst")
#circular-printer-test(size: 200pt)

#pagebreak()

== #underline[Crosshair test]

#raw("#crosshair-printer-test(dir: rtl)", lang: "typst")
#crosshair-printer-test(dir: rtl)

#raw("#crosshair-printer-test(dir: ttb)", lang: "typst")
#crosshair-printer-test(dir: ttb)

#raw("#crosshair-printer-test(size: 75pt)", lang: "typst")
#crosshair-printer-test(size: 75pt)