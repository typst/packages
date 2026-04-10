#import "abbr.typ"

#show: abbr.show-rule
#abbr.load("example.csv")
#abbr.load-alt("example_alt.csv", supplement: "from French")
#abbr.list()

#abbr.add("test","TESTING")
#abbr.add("test-alt","TESTING 2")
#abbr.add-alt("test-alt", "test definition", supplement: "or alternatively,")

= Test
#lorem(8)

#table(columns:2,
"short", [@BC:s],
"automatic", [@BC],
"automatic", [@BC],
"long", [@BC:l],
"long only", [@BC:lo],
"plural short", [@DOF:pls],
"plural automatic", [@DOF:pla],
"plural automatic", [@DOF:pla],
"plural long", [@DOF:pll],
"plural long only", [@DOF:pllo],
"automatic, short form first", [@PDE:asf],
"long, short form first", [@PDE:lsf],
"long, with alternate definition", [@TGV:l],
[long, short form first\ (alternate will only appear once)], [@TGV:lsf],
[alternate definition with\ optional supplement], [@etc.:asf],
)

changing styling to #text(red)[red]
#abbr.config(style:x=>text(red, x))
- automatic+styling: @test

changing space-char `#sym.arrow.l.r` #sym.arrow.r.double expect #text(red)[red
styling] + arrows
#abbr.config(space-char: sym.arrow.l.r)
- manually added alternate definition: @test-alt

disabling short form pluralization, setting space-char to default
#sym.arrow.r.double expect #text(red)[red styling] + short NOT pluralized
#abbr.config(space-char: auto, pluralize-short: false)
- short pluralization disabled: @DOF:pll
