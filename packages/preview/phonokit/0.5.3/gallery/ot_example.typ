#import "phonokit/lib.typ": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))


#tableau(
  input: "kraTa",
  candidates: ("[kra.Ta]", "[ka.Ta]", "[ka.ra.Ta]"),
  constraints: ("Max", "Dep", "*Complex"),
  violations: (
    ("", "", "*"),
    ("*!", "", ""),
    ("", "*!", ""),
  ),
  winner: 0,
  dashed-lines: (1,),
)

