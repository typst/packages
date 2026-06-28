#import "@preview/elembic:1.1.1"as e
#import "utils.typ": mod

#let transformed-image = e.element.declare(
  "transformed-image",
  prefix: "tesselate.transform",
  fields: (
    e.field(
      "body",
      content,
      named: false,
      required: true,
    ),
    e.field(
      "rotation",
      int,
      named: true,
      default: 0,
    ),
    e.field(
      "mirrored",
      bool,
      named: true,
      default: false,
    )
  ),
  display: el => {
    let (body, rotation, mirrored) = e.fields(el)
    rotation = mod(rotation, 4)
    if rotation != 0 {
      body = rotate(body, rotation * 90deg, reflow: true)
    }
    if mirrored {
      body = scale(body, x: -100%, reflow: true)
    }
    body
  }
)

#let upside-down(body) = transformed-image(body, rotation: 2)
#let cw(body) = transformed-image(body, rotation: 1)
#let ccw(body) = transformed-image(body, rotation: -1)
#let mirrored-x(body) = transformed-image(body, mirrored: true)
#let mirrored-y(body) = transformed-image(body, rotation: 2, mirrored: true)

#let rescale(
  body,
  width: auto,
  height: auto,
  fit: "cover",
  alignment: center + horizon,
) = {
  if height == auto {
    if width == auto {
      body
    } else {
      let (width: orig-width) = measure(body)
      let scale-ratio = width / orig-width
      scale(width / orig-width * 100%, body, reflow: true)
    }
  } else if width == auto {
    let (height: orig-height) = measure(body)
    scale(height / orig-height * 100%, body, reflow: true)
  } else {
    let (width: orig-width, height: orig-height) = measure(body)
    if fit == "stretch" {
      scale(
        body,
        x: width / orig-width * 100%,
        y: height / orig-height * 100%,
        reflow: true,
      )
    } else {
      // if orig-width == 0pt {
      //   panic(body)
      // }
      let width-scale-ratio = width / orig-width * 100%
      let h1 = width-scale-ratio * orig-height
      let scale-ratio = if h1 < height {
        height / orig-height * 100%
      } else {
        width-scale-ratio
      }
      box(
        align(
          scale(
            box(body, width: orig-width, height: orig-height),
            scale-ratio,
            reflow: true
          ),
          alignment,
        ),
        clip: true,
      )
    }
  }
}

