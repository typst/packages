// "../lib.typ" should be replaced with "@preview/conchord:0.1.0" if used outside of package
#import "../lib.typ": new-chordgen, overchord

// For better png in README
#set page(height: auto)

#let standard-chord = new-chordgen()
#let chord(tabs, name) = box(standard-chord(tabs, name: name), inset: 0.3em)

#set page(margin: (right: 40%))

#place(right, dx: 70%,
    block(width: 70%,
        block(stroke: gray + 0.2pt, inset: 1em, below: 3em)[
            #set align(left)

            // Make all text in chord graph bold
            #show text: strong

            // List used chords there
            #chord("022000", "Em")
            #chord("x32010", "C") 
            #chord("320003", "G")
            #chord("xx0232", "D")
        ]
    )
)


#align(center)[
    // Song name
    = Zombie
    // Band
    == The Cranberries
]

#let och(it) = overchord(strong(it))

=== #raw("[Verse 1]")

#och[Em] Another head 
#och[C] hangs lowly \
#och[G] Child is slowly
#och[D] taken \
#och[Em] And the violence
#och[C] caused such silence \
#och[G] Who are we
#och[D] mistaken?

=== #raw("[Pre-Chorus]")

#och[Em] But you see, it's not me,
#och[C] it's not my family \
#och[G] In your head, in your head they are
#och[D] fightin' \
#och[Em] With their tanks and their bombs 
#och[C] and their bombs and their guns \
#och[G] In your head, in your head they are
#och[D] cryin'

=== #raw("[Chorus]")

#och[Em] In your head,
#och[C] in your head  \
#och[G] Zombie, zombie,
#och[D] zombie-ie-ie \
#och[Em] What's in your head,
#och[C] in your head  \
#och[G] Zombie, zombie,
#och[D] zombie-ie-ie, oh

<…>
