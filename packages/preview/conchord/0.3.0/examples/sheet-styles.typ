#import "../lib.typ": (
  overchord,
  chordlib,
  chordify,
  change-tonality,
  sized-chordlib,
  change-tonality,
  inlinechord,
  fulloverchord,
)
// For better png in README, doesn't matter
#set page(height: auto, margin: (right: 0%))
#show heading: set block(spacing: 1em)

= Another Brick in the wall, Pink Floyd

#[
  #show: chordify.with(heading-reset-tonality: 2)

  // in fact, heading-reset just adds change-tonality(0) there
  == Default `overchord`
  [Dm] We dоn't need nо еduсаtiоn, \
  [Dm] We dоn't need nо thоught соntrоl, \
  #change-tonality(1)
  [Dm] Nо dark sarcasm in the сlаssrооm. \
  [Dm] Teacher leave them kids [G] аlоnе. \
  [G] Hey, Teacher! Leave them kids аlоnе.
]

#[
  #show: chordify.with(line-chord: inlinechord, heading-reset-tonality: 2)
  == `inlinechord`
  [Dm] We dоn't need nо еduсаtiоn, \
  [Dm] We dоn't need nо thоught соntrоl, \
  #change-tonality(1)
  [Dm] Nо dark sarcasm in the сlаssrооm. \
  [Dm] Teacher leave them kids [G] аlоnе. \
  [G] Hey, Teacher! Leave them kids аlоnе. \
]


#[
  #show: chordify.with(line-chord: fulloverchord, heading-reset-tonality: 2)
  == `fulloverchord`
  // chordlib still works!
  #sized-chordlib(width: 150pt, N: 3, prefix: [_Chord library_ #linebreak()])

  [Dm] We dоn't need nо еduсаtiоn, \
  [Dm] We dоn't need nо thоught соntrоl, \
  #change-tonality(1)
  [Dm] Nо dark sarcasm in the сlаssrооm. \
  // every function can be also used directly
  #fulloverchord("Dm", n: 1) Teacher leave them kids #inlinechord[G] аlоnе. \
  [G] Hey, Teacher! Leave them kids аlоnе.
]
