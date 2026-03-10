#import "@preview/conchord:0.4.0": *

#set page(height: auto, width: 42em, margin: 1em)

#let chordname = "D#maj7sus4add13"

= #raw(chordname), guitar
#chord-notes("532xxx", default-tuning).join("-")
 \

#for c in get-chords(chordname) {
  box(stack(dir: ttb, red-missing-fifth(c), chord-notes(c, default-tuning).join("-")))
}

/*
= `ukulele`

#for c in n-best(get-chords("Am", tuning: "G1 C1 E1 A1", true-bass: false), n: 24) {
  box(stack(dir: ttb, red-missing-fifth(c), chord-notes(c, "G1 C1 E1 A1").join("-")))
}
