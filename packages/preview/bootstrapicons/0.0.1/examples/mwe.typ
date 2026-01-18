#import "@preview/bootstrapicons:0.0.1": bsicons
#show link: underline

Weather Conditions: #bsicon("cloud-fog2-fill") with some #bsicon("sun-fill", color: color.hsl(51deg, 100%, 50%))

Mode of Transport: #bsicon("airplane", color: red)

A very large checkbox:

#bsicon("check2-square", height: 3em, color: rgb("#ff0000"))


// define a function that adds the Github icon before the URL
#let gh-link(src) = {
  link(src)[#bsicon("github") #src]
}
Find the source of this project at #gh-link("https://github.com/DavZim/bootstrapicons")
