#import "@preview/phonokit:0.2.0": *
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
  winner: 1,
  dashed-lines: (1,),
)

