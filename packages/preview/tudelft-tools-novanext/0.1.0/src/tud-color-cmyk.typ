// Define the TU Delft corporate style colours.
// https://filelist.tudelft.nl/Websections/Huisstijl/Merk/Brandbook_nl.pdf

#let tud-blue = {cmyk(100%, 0%, 0%, 0%)}
#let tud-black = {cmyk(0%, 0%, 0%, 100%)}
#let tud-white = {cmyk(0%, 0%, 0%, 0%)}

#let tud-dark-blue = {cmyk(100%, 80%, 8%, 70%)}
#let tud-turquoise = {cmyk(72%, 0%, 24%, 0%)}
#let tud-royal-blue = {cmyk(98%, 40%, 0%, 0%)}
#let tud-light-purple = {cmyk(65%, 100%, 0%, 12%)}
#let tud-pink = {cmyk(0%, 70%, 0%, 0%)}
#let tud-burgundy = {cmyk(5%, 100%, 48%, 30%)}
#let tud-red = {cmyk(0%, 85%, 75%, 0%)}
#let tud-orange = {cmyk(0%, 70%, 75%, 0%)}
#let tud-yellow = {cmyk(0%, 31%, 98%, 0%)}
#let tud-green = {cmyk(63%, 0%, 84%, 0%)}
#let tud-forest-green = {cmyk(100%, 0%, 68%, 4%)}
#let tud-dark-grey = {cmyk(0%, 0%, 0%, 80%)}

// only for data visualisation
#let tud-dark-blue-pale = {cmyk(40%, 30%, 25%, 0%)}
#let tud-turquoise-pale = {cmyk(35%, 0%, 10%, 0%)}
#let tud-royal-blue-pale = {cmyk(40%, 10%, 0%, 0%)}
#let tud-red-pale = {cmyk(0%, 40%, 25%, 0%)}
#let tud-orange-pale = {cmyk(0%, 30%, 25%, 0%)}
#let tud-yellow-pale = {cmyk(0%, 20%, 70%, 0%)}
#let tud-light-purple-pale = {cmyk(20%, 40%, 0%, 0%)}
#let tud-pink-pale = {cmyk(0%, 30%, 0%, 0%)}
#let tud-burgundy-pale = {cmyk(10%, 50%, 15%, 0%)}
#let tud-green-pale = {cmyk(25%, 0%, 35%, 0%)}
#let tud-forest-green-pale = {cmyk(40%, 0%, 25%, 0%)}
#let tud-dark-grey-pale = {cmyk(25%, 20%, 20%, 0%)}

#let tud-blue-10 = tud-blue.lighten(90%)
#let tud-blue-50 = tud-blue.lighten(50%)
#let tud-dark-grey-15 = tud-dark-grey.lighten(85%)
#let tud-dark-grey-40 = tud-dark-grey.lighten(60%)
#let tud-dark-grey-60 = tud-dark-grey.lighten(40%)

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
}
