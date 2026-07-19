#import "@preview/phonokit:0.5.9": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

#multi-tier(
  levels: (
    ("O", "R", "", "O", "R", "O", "R"),
    ("", "N1", "", "", "N2", "", "N3"),
    ("", "x", "x", "x", "x", "x", "x"),
    ("", "", "s", "t", "E", "m", ""),
  ),
  links: (("r2", "x2"),),
  ipa: (3,),
  arrows: (("t1", "s1"), ("r2", "r1")),
  arrow-delinks: (1,),
  spacing: 1,
)

// Figure from Goad (2012); see phonokit.pdf for full reference.
