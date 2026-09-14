#import "@preview/agregyst:0.1.0" : tableau, dev, recap, item
#show : tableau

= Title of the lesson

#pagebreak()
== First Part

// This item does not have a source
// is will be show gray in the recap
// @NAN
#item("Définition")[A Graph][
    is ...
]

// @NAN
#item("Définition")[A Graph][
    is ...
]

#pagebreak()

// This part has the SIP reference
// it will have a special color in the recap
// @SIP
== Second Part 

#pagebreak()
// @NAN
== Third Part 

#recap()

// #bibliography(read("bib.yaml", encoding: none))

===== Remark

#align(center + bottom)[
    fst author & snd author
]
