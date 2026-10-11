// A diploma: `certificate` frame with its corner flourishes and the guilloché rosette background.
//   typst compile --root . examples/certificate.typ
#import "../lib.typ": *
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("#1d2a44"))
#set page(width: 297mm, height: 210mm)
#show: framed.with(style: "certificate-ribbon", color: rgb("#2c4a9a"), accent: rgb("#7d8fd0"),
  texture: "rosettes", seal: true, paper: white)
#align(center + horizon)[
  #text(size: 34pt, weight: "bold")[Certificate]
  #v(2pt)
  #text(size: 13pt, style: "italic")[of achievement]
  #v(18pt)
  This certifies that
  #v(8pt)
  #text(size: 24pt)[Your Name]
  #v(8pt)
  has completed the course with distinction.
]
