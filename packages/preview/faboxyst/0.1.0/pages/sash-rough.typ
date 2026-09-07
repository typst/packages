// typst compile pages/sash-rough.typ pages/sash-rough.png --root .

#import "/lib.typ": *

#set page(width: 16cm, height: auto, margin: 8mm)
#set text(font: "DejaVu Sans", size: 12pt)

= crisp vs sloppy (encre magenta)

#grid(columns: (1fr, 1fr), gutter: 6mm,
  [
    *sans* `rough`\
    #sashbox(kind: "arch", fill: rgb("#FFD54F"))[CRISP]
  ],
  [
    *avec* `rough: true` + `ink: magenta`\
    #sashbox(kind: "arch", rough: true, ink: rgb("#E91E63"), pen: 3.2pt,
      fill: rgb("#FFD54F"))[SLOPPY]
  ],
)
