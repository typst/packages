#import "phonokit/lib.typ": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

#multi-tier(
  levels: (
    ("O", "R", "", "O", "R", "O", "R"),
    ("", "N1", "", "", "N2", "", "N3"),
    ("", "x", "x", "x", "x", "x", "x"),
    ("", "", "s", "t", "E", "m", ""),
  ),
  links: (((0, 1), (2, 2)),),
  ipa: (3,),
  arrows: (((3, 3), (3, 2)), ((0, 4), (0, 1))),
  arrow-delinks: (1,),
  spacing: 1,
)

// Figure from Goad (2012); see phonokit.pdf for full reference.
