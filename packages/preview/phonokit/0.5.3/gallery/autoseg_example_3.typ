#import "phonokit/lib.typ": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

#autoseg(
  ("p", "a", "S", "E", "i"),
  features: ("", "L", "", "H", "L"),
  tone: true,
  spacing: 0.5, // keep consistent
  delinks: ((1, 1),),
  float: (4,),
  baseline: 37%,
  gloss: [_delinking & floating tone_],
)
#autoseg(
  ("Z", "W", "p", "K", "u"),
  features: ("", "H", "", "", ""), // H at position 1, but will be repositioned
  tone: true,
  float: (1,), // Mark H as floating so it doesn't draw vertical stem
  multilinks: ((1, (1, 4)),), // H links to segments at positions 1 and 4
  spacing: 0.5,
  baseline: 37%,
  arrow: false,
  gloss: [_one-to-many relationships_],
)

#autoseg(
  ("m", "@", "a"),
  features: ("", "", ("H", "L")),
  links: (((2, 0), 1),), // From H (first tone at position 2) to segment 1
  tone: true,
  highlight: ((2, 0),), // Highlight the H tone
  baseline: 37%,
  spacing: 1.0,
  arrow: true,
  gloss: [_contour tone, linking & highlighting_],
)
#autoseg(
  ("m", "@", "a"),
  features: ("", "", ("H", "L")),
  links: (((2, 0), 1),), // From H (first tone at position 2) to segment 1
  tone: true,
  highlight: ((2, 0),), // Highlight the H tone
  baseline: 37%,
  spacing: 0.35,
  arrow: true,
  gloss: [_quick spacing adjustments_],
)
