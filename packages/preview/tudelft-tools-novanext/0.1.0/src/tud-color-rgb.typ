// Define the TU Delft corporate style colours.
// https://filelist.tudelft.nl/Websections/Huisstijl/Merk/Brandbook_nl.pdf

#let tud-blue = {rgb("#00A6D6")}
#let tud-black = {rgb("#000000")}
#let tud-white = {rgb("#FFFFFF")}

#let tud-blue-50 = {rgb("#80D3EB")}
#let tud-blue-10 = {rgb("#E6F6FA")}

#let tud-dark-grey-60 = {rgb("#9D9D9D")}
#let tud-dark-grey-40 = {rgb("#BEBEBE")}
#let tud-dark-grey-15 = {rgb("#E7E7E7")}

#let tud-dark-blue = {rgb("#0C2340")}
#let tud-turquoise = {rgb("#00B8C8")}
#let tud-royal-blue = {rgb("#0076C2")}
#let tud-light-purple = {rgb("#6F1D77")}
#let tud-pink = {rgb("#EF60A3")}
#let tud-burgundy = {rgb("#A50034")}
#let tud-red = {rgb("#E03C31")}
#let tud-orange = {rgb("#EC6842")}
#let tud-yellow = {rgb("#FFB81C")}
#let tud-green = {rgb("#6CC24A")}
#let tud-forest-green = {rgb("#009B77")}
#let tud-dark-grey = {rgb("#5C5C5C")}

// only for data visualisation
#let tud-dark-blue-pale = {rgb("#9A9FAA")}
#let tud-turquoise-pale = {rgb("#99E4EA")}
#let tud-royal-blue-pale = {rgb("#99C6E5")}
#let tud-red-pale = {rgb("#F29E97")}
#let tud-orange-pale = {rgb("#F6B7A1")}
#let tud-yellow-pale = {rgb("#FFE099")}
#let tud-light-purple-pale = {rgb("#C6A2C9")}
#let tud-pink-pale = {rgb("#F9B3D4")}
#let tud-burgundy-pale = {rgb("#D9809A")}
#let tud-green-pale = {rgb("#C1E0B3")}
#let tud-forest-green-pale = {rgb("#99CCBD")}
#let tud-dark-grey-pale = {rgb("#B9B9B9")}

#let tud-color-cycle = (
  tud-dark-grey-60,
  tud-blue,
  tud-blue-50,
  tud-light-purple,
  tud-pink-pale,
  tud-light-purple-pale,
  tud-orange,
  tud-orange-pale,
  tud-yellow-pale,
  tud-forest-green,
  tud-forest-green-pale,
  tud-dark-grey-40,
)

#{
  let r(fill) = box(rect(
    fill: fill,
    width: 1em,
    height: 1em,
  ))

  set page(width: auto, height: auto, margin: .5em)
  tud-color-cycle.map(r).join()

  linebreak()

  r(tud-blue-10)
  r(tud-blue.lighten(90%))
  r(tud-blue-50)
  r(tud-blue.lighten(50%))
  r(tud-dark-grey-15)
  r(tud-dark-grey.lighten(85%))
  r(tud-dark-grey-40)
  r(tud-dark-grey.lighten(60%))
  r(tud-dark-grey-60)
  r(tud-dark-grey.lighten(40%))
}
