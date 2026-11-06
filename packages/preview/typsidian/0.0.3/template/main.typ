#import "@preview/typsidian:0.0.3": *

#show: typsidian.with(
  title: "My Document", 
  course: "My Course",
  author: "Author Name"
)

#make-title()

= Heading

#lorem(50)

#box(title: "Box", [
  #lorem(50)
])

#box(theme: "example", title: "Example", [
  #lorem(50)
])
