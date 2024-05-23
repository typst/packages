#import "util.typ": *

#let get-structure-size(structure-path, ..args) = {
  let structure = none
  if type(structure-path) == str {
    structure = json("structures/" + structure-path + ".json")
  } else {
    structure = structure-path
  }

  return (get-from-args(args, structure.width), get-from-args(args, structure.height))
}

#let render-structure(structure-path, color: none, fold-stroke: 0.3mm + gray, cut-stroke: 0.3mm + black, glue-pattern: none, clip: true, ..args) = {

  let get-structure-offset(structure, args) = {
    return (get-from-args(args, structure.offset-x), get-from-args(args, structure.offset-y))
  }

  let render-face(face, color, fold-stroke, cut-stroke, glue-pattern, clip, args, last-size: none, offset: (0mm,0mm), comes-from: none) = {
    let has-child = (
      top: false,
      left: false,
      bottom: false,
      right: false
    )

    let comes-from-triangle = comes-from
    if comes-from-triangle == none {
      comes-from-triangle = "bottom"
    }

    let width = if comes-from == none {
        get-from-args(args, face.width)
      } else {
        if comes-from == "top" {
          last-size
        } else if comes-from == "left" {
          get-from-args(args, face.size)
        } else if comes-from == "bottom" {
          last-size
        } else if comes-from == "right" {
          get-from-args(args, face.size)
        }
      }

    let height = if comes-from == none {
        get-from-args(args, face.height)
      } else {
        if comes-from == "top" {
          get-from-args(args, face.size)
        } else if comes-from == "left" {
          last-size
        } else if comes-from == "bottom" {
          get-from-args(args, face.size)
        } else if comes-from == "right" {
          last-size
        }
      }

    if (face.type == "box") {
      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #box(
          width: width,
          height: height,
          fill: color,
          clip: clip,
          if face.keys().contains("id") and args.pos().len() > face.id {args.pos().at(face.id)}
        )
      ]
    } else if (face.type.starts-with("triangle")) {
      let direction = face.type.split("-").at(1)

      assert(direction == "left" or direction == "right", message: "Triangle direction must be either 'left' or 'right'")

      let points = calculate-triangle-points(comes-from-triangle, direction, width, height)

      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #polygon(
          fill: color,
          stroke: 0mm,
          ..points
        )
      ]

      let triangle-line-type = cut-stroke
      if comes-from-triangle == "top" {
        has-child.at("bottom") = true

        if direction == "left" {
          has-child.at("left") = true
          if face.keys().contains("children") and face.children.keys().contains("left") and face.children.left == "none" {
            triangle-line-type = 0mm
          }
        } else {
          has-child.at("right") = true
          if face.keys().contains("children") and face.children.keys().contains("right") and face.children.right == "none" {
            triangle-line-type = 0mm
          }
        }
      } else if comes-from-triangle == "left" {
        has-child.at("right") = true

        if direction == "left" {
          has-child.at("bottom") = true
          if face.keys().contains("children") and face.children.keys().contains("bottom") and face.children.bottom == "none" {
            triangle-line-type = 0mm
          }
        } else {
          has-child.at("top") = true
          if face.keys().contains("children") and face.children.keys().contains("top") and face.children.top == "none" {
            triangle-line-type = 0mm
          }
        }
      } else if comes-from-triangle == "bottom" {
        has-child.at("top") = true

        if direction == "left" {
          has-child.at("right") = true
          if face.keys().contains("children") and face.children.keys().contains("right") and face.children.right == "none" {
            triangle-line-type = 0mm
          }
        } else {
          has-child.at("left") = true
          if face.keys().contains("children") and face.children.keys().contains("left") and face.children.left == "none" {
            triangle-line-type = 0mm
          }
        }
      } else if comes-from-triangle == "right" {
        has-child.at("left") = true

        if direction == "left" {
          has-child.at("top") = true
          if face.keys().contains("children") and face.children.keys().contains("top") and face.children.top == "none" {
            triangle-line-type = 0mm
          }
        } else {
          has-child.at("bottom") = true
          if face.keys().contains("children") and face.children.keys().contains("bottom") and face.children.bottom == "none" {
            triangle-line-type = 0mm
          }
        }
      }

      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #line(
          start: if direction == "left" {points.at(0)} else {points.at(1)},
          end: points.at(2),
          stroke: triangle-line-type
        )
      ]
    } else {
      assert(false, message: "Unknown face type: " + face.type)
    }

    if face.keys().contains("children") {
      for child in face.children.values().enumerate() {
        let add-offset = (0mm,0mm)
        let orientation = face.children.keys().at(child.at(0))
        let next-comes-from = none

        has-child.at(orientation) = true

        assert(orientation != comes-from, message: "Face cannot have a child coming from the same direction as it is coming from")


        assert(not (face.type.starts-with("triangle") and ((orientation == "right" and comes-from-triangle == "left")
        or (orientation == "top" and comes-from-triangle == "bottom")
        or (orientation == "left" and comes-from-triangle == "right")
        or (orientation == "bottom" and comes-from-triangle == "top"))), message: "Triangle does not support children to the opposite side of the parent face")

        if type(child.at(1)) == str {
          if child.at(1).starts-with("tab\u{0028}") {

            let tab-args = child.at(1).split("\u{0028}").at(1).split("\u{0029}").at(0)
            let tab-size = get-from-args(args, tab-args.split(",").at(0))
            let tab-cutin = get-from-args(args, tab-args.split(",").at(1))

            if (face.type.starts-with("triangle")) {
              let direction = face.type.split("-").at(1)
              let points = calculate-triangle-points(comes-from, direction, width, height)
              let line-points = (if direction == "left" {points.at(0)} else {points.at(1)}, points.at(2))
              let l1 = (line-points.at(1).at(1) - line-points.at(0).at(1)).pt()
              let l2 = (line-points.at(1).at(0) - line-points.at(0).at(0)).pt()
              let angle = 90deg - calc.atan2(l1, l2) + if direction == "left" {180deg} else {0deg}
              let length = calc.sqrt(calc.pow(l2, 2) + calc.pow(l1, 2)) * 1pt
              // half of the tab size in the normal direction of the line
              let add-offset = (
                calc.sin(angle) * tab-size / 2,
                -calc.cos(angle) * tab-size / 2
              )

              if ((comes-from == "right"
              and direction == "left" and orientation == "top")
              or (comes-from == "right"
              and direction == "right" and orientation == "bottom")
              or (comes-from == "left"
              and direction == "right" and orientation == "top")
              or (comes-from == "left"
              and direction == "left" and orientation == "bottom")
              or (comes-from == "top"
              and direction == "left" and orientation == "left")
              or (comes-from == "top"
              and direction == "right" and orientation == "right")
              or (comes-from == "bottom"
              and direction == "right" and orientation == "left")
              or (comes-from == "bottom"
              and direction == "left" and orientation == "right")) {
                place(
                  center + horizon,
                  dx: offset.at(0) + add-offset.at(0),
                  dy: offset.at(1) + add-offset.at(1)
                )[
                  #tab(
                    length,
                    tab-size,
                    tab-cutin,
                    angle,
                    color,
                    cut-stroke,
                    fold-stroke,
                    glue-pattern
                  )
                ]

                continue
              }
            }

            if orientation == "top" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) -(height + tab-size) / 2,
              )[
                #tab(
                  width,
                  tab-size,
                  tab-cutin,
                  0deg,
                  color,
                  cut-stroke,
                  fold-stroke,
                  glue-pattern
                )
              ]
            } else if orientation == "left" {
              place(
                center + horizon,
                dx: offset.at(0) - (width + tab-size) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  height,
                  tab-size,
                  tab-cutin,
                  270deg,
                  color,
                  cut-stroke,
                  fold-stroke,
                  glue-pattern
                )
              ]
            } else if orientation == "bottom" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) + (height + tab-size) / 2
              )[
                #tab(
                  width,
                  tab-size,
                  tab-cutin,
                  180deg,
                  color,
                  cut-stroke,
                  fold-stroke,
                  glue-pattern
                )
              ]
            } else if orientation == "right" {
              place(
                center + horizon,
                dx: offset.at(0) + (width + tab-size) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  height,
                  tab-size,
                  tab-cutin,
                  90deg,
                  color,
                  cut-stroke,
                  fold-stroke,
                  glue-pattern
                )
              ]
            }
          } else if child.at(1) == "none" {
          } else {
            assert(false, message: "Unknown child type: " + child.at(1))
          }
          continue
        }

        if (face.type.starts-with("triangle")){
          let direction = face.type.split("-").at(1)
          assert(not ((comes-from-triangle == "right"
          and direction == "left" and orientation == "top")
          or (comes-from-triangle == "right"
          and direction == "right" and orientation == "bottom")
          or (comes-from-triangle == "left"
          and direction == "right" and orientation == "top")
          or (comes-from-triangle == "left"
          and direction == "left" and orientation == "bottom")
          or (comes-from-triangle == "top"
          and direction == "left" and orientation == "left")
          or (comes-from-triangle == "top"
          and direction == "right" and orientation == "right")
          or (comes-from-triangle == "bottom"
          and direction == "right" and orientation == "left")
          or (comes-from-triangle == "bottom"
          and direction == "left" and orientation == "right")), message: "Triange does not support children to come from angeled sides")
        }

        if orientation == "top" {
          add-offset = (
            0mm, -(height + get-from-args(args, child.at(1).size)) / 2
          )
          next-comes-from = "bottom"
        } else if orientation == "left" {
          add-offset = (
            -(width + get-from-args(args, child.at(1).size)) / 2, 0mm
          )
          next-comes-from = "right"
        } else if orientation == "bottom" {
          add-offset = (
            0mm, (height + get-from-args(args, child.at(1).size)) / 2
          )
          next-comes-from = "top"
        } else if orientation == "right" {
          add-offset = (
            (width + get-from-args(args, child.at(1).size)) / 2, 0mm
          )
          next-comes-from = "left"
        }

        render-face(
          child.at(1),
          color,
          fold-stroke,
          cut-stroke,
          glue-pattern,
          clip,
          args,
          offset: (offset.at(0) + add-offset.at(0), offset.at(1) + add-offset.at(1)),
          comes-from: next-comes-from,
          last-size: if orientation == "top" or orientation == "bottom" {width} else {height}
        )
      }
    }

    if not has-child.at("top") {
      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #line(
          start: (0mm, -height / 2),
          end: (width, -height / 2),
          stroke: if comes-from == "top" {
            if face.keys().contains("no-fold") {
              0mm
            } else {
              fold-stroke
            }
          } else {
            cut-stroke
          }
        )
      ]
    }

    if not has-child.at("left") {
      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #line(
          start: (-width / 2, 0mm),
          end: (-width / 2, height),
          stroke: if comes-from == "left" {
            if face.keys().contains("no-fold") {
              0mm
            } else {
              fold-stroke
            }
          } else {
            cut-stroke
          }
        )
      ]
    }

    if not has-child.at("bottom") {
      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #line(
          start: (0mm, height),
          end: (width, height),
          stroke: if comes-from == "bottom" {
            if face.keys().contains("no-fold") {
              0mm
            } else {
              fold-stroke
            }
          } else {
            cut-stroke
          }
        )
      ]
    }

    if not has-child.at("right") {
      place(
        center + horizon,
        dx: offset.at(0),
        dy: offset.at(1)
      )[
        #line(
          start: (width, 0mm),
          end: (width, height),
          stroke: if comes-from == "right" {
            if face.keys().contains("no-fold") {
              0mm
            } else {
              fold-stroke
            }
          } else {
            cut-stroke
          }
        )
      ]
    }
  }

  if glue-pattern == none {
    glue-pattern = pattern-glue(gray)
  }

  let structure = none
  if type(structure-path) == str {
    structure = json("structures/" + structure-path + ".json")
  } else {
    structure = structure-path
  }

  for variable in structure.variables {
    assert(args.named().keys().contains(variable), message: "Structure needs variable: " + variable)
  }

  let structure-size = get-structure-size(structure, ..args)
  let structure-offset = get-structure-offset(structure, args)

  block(
    width: structure-size.at(0),
    height: structure-size.at(1),
    //stroke: cut-stroke
  )[
    #place(
      center + horizon,
      dx: (structure-offset.at(0)) / 2,
      dy: (structure-offset.at(1)) / 2
    )[
      #render-face(structure.root, color, fold-stroke, cut-stroke, glue-pattern, clip, args)
    ]
  ]
}