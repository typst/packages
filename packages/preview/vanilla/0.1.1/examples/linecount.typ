#import "@preview/vanilla:0.1.1": vanilla

#show: vanilla.with(
  body-line-spacing: "double",
  body-font-family: "Times New Roman",
)

#set par.line(numbering: "1:")
#for i in range(1, 25) {
  lorem(10)
  linebreak()
}

