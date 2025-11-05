#import "@preview/conchord:0.4.0": (
  overchord,
  fancy-styling-plain,
  fancy-styling-autotonality,
  smart-chord,
  sized-chordlib,
  change-tonality,
  inlinechord,
  chordify
)
// For better png in README, doesn't matter
#set page(width: auto, height: auto, margin: 1em)

#[
  // to make tonality change automatically
  #show: chordify

  #overchord[A\#9] Lyrics #overchord(styling: emph)[A\#9] Lyrics
  #overchord(styling: fancy-styling-autotonality)[A\#9] Lyrics

  `| tonality change |`

  #change-tonality(1)

  #overchord[A\#9] Lyrics #overchord(styling: emph)[A\#9] Lyrics
  // of course, if you want to use certain a lot, use an alias: 
  #let fo = overchord.with(styling: fancy-styling-autotonality)
  #fo[A\#9] Lyrics

  #sized-chordlib(
    smart-chord: smart-chord.with(styling: it => strong(fancy-styling-plain(it)))
  )
]

#[
  // or it can be used even in chordify
  // and stylings can be composed
  #show: chordify.with(line-chord: inlinechord.with(styling: it => strong(fancy-styling-autotonality(it))))
  
  [A#9] Lyrics
]