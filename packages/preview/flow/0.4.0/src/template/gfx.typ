#import "common.typ": *
#import "modern.typ": modern

#let gfx(body, ..args) = {
  show: modern.with(..args)
  set page(width: auto, height: auto)

  body
}

