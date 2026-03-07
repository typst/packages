#import "@preview/typsidian:0.0.2": *

#show: typsidian.with(theme: "light", title: "My Document", course: "CS4999")

#make-title()

= Heading

#lorem(50)

#box(title: "Box", [
  #lorem(50)
])

#box(theme: "example", title: "Example", [
  #lorem(50)
])
