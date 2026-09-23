// Matching fixture for extra_block_11.svg: nested comparisons in an if/else
// inside a forever loop. Kept separate from the general prototype sheet so
// both SVGs can be opened or overlaid at their natural size.
#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Helvetica Neue", fallback: true)
#set-blockst(font: "Helvetica Neue")

#nepo("
Wiederhole unendlich oft
  wenn gib Wert % Lichtsensor < 50 und gib Wert % Lichtsensor ≤ 100
    Zeige Text \"T\"
  sonst
    wenn gib Wert % Lichtsensor < 20 und gib Wert % Lichtsensor ≤ 50
      Zeige Text \"D\"
    sonst
      Zeige Text \"N\"
")
