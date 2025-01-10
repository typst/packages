#import "../lib.typ": n-best, get-chords, red-missing-fifth
#set page(height: auto, width: 42em, margin: 1em)

= `Am`
`true-bass = true`, default:

#for c in n-best(get-chords("Am", tuning: "G1 C1 E1 A1"), n: 5) {
  box(red-missing-fifth(c))
}

`true-bass = false`:

#for c in n-best(get-chords("Am", tuning: "G1 C1 E1 A1", true-bass: false), n: 5) {
  box(red-missing-fifth(c))
}