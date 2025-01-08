#import "viewing.typ": *
#import "convert.typ": hex-to-dec

#let color = "#ffff"

#color

#view-pigment(color)

#let hxa = (0, 0, 0)
#let cnt = 0
#let hxi-cnt = 0
#let rgb-cnt = 0
#let hxv = ""

#if type(color) == "string" {
  color = color.trim("#")
} else if type(color) == "color" {
  color = color.to-hex().trim("#")
}

#if type(color) == "integer" {
  color = str(color)
}

#for i in color {
  hxv += i // collect HEX pairs
  if cnt == 1 {
    hxa.at(rgb-cnt) = hex-to-dec(hxv)
    rgb-cnt += 1 // move to next color space R/G/B
    cnt = 0 // reset
    hxv = "" // reset
  } else {
    cnt += 1 // next value in hex pair
  }
}

#hxa

// * VERIFY
#let r = hxa.at(0)
#let g = hxa.at(1)
#let b = hxa.at(2)

#view-pigment(rgb(r,g,b))
