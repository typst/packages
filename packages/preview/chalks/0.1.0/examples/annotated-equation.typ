#import "@preview/chalks:0.1.0": annotate, chalks-theme, ink, pin
#set page(width: 360pt, height: 200pt, margin: 24pt)
#set text(size: 14pt)
#chalks-theme(ink)

Einstein's relation
$ E = #pin("m")[$m$] #pin("c2")[$c^2$] $
shows how #pin("mass")[mass] converts entirely into #pin("energy")[energy].

#annotate(circle: "c2", color: rgb("#a03b2e"))
#annotate(underline: "m")
#annotate(arrow: ("mass", "energy"), dy: 16pt)
