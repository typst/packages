#import "../lib.typ": new-chordgen
#set page(height: auto, width: auto, margin: 1em)

#let crazy-chord = new-chordgen(string-number: 3,
    colors: (shadow-barre: orange,
        grid: gray.darken(30%),
        hold: red,
        barre: purple,),
    number-to-left: true,
    thick-nut: false
)

#set text(fill: purple)
#box(crazy-chord("320", name: "C"))
#box(crazy-chord("2,4,4,*", name: "Bm"))
#box(crazy-chord("2,2,2, *"))
#box(crazy-chord("x,3,2, !"))
#box(crazy-chord("12,12,12, !"))