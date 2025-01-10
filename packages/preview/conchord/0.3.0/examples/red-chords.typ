#import "../lib.typ": n-best, get-chords, red-missing-fifth
#set page(height: auto, width: 42em, margin: 1em)

= `Am`
// select first 18 chords (empirically fine default)
#for c in n-best(get-chords("Am")) {
  box(red-missing-fifth(c))
}

Notice: the further, the worse are the variants. Okay, now let's take only five for C7.

= `C7`
// select five first chords
#for c in n-best(get-chords("C7"), n: 5) {
  box(red-missing-fifth(c))
}
