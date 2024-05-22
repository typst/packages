#import "util.typ": *

#let render_face(face, color, fold_stroke, cut_stroke, glue_pattern_p, clip, args, last_size: none, offset: (0mm,0mm), comes_from: none) = {
  let has_child = (
    top: false,
    left: false,
    bottom: false,
    right: false
  )

  let comes_from_triangle = comes_from
  if comes_from_triangle == none {
    comes_from_triangle = "bottom"
  }

  let width = if comes_from == none {
      get_from_args(args, face.width)
    } else {
      if comes_from == "top" {
        last_size
      } else if comes_from == "left" {
        get_from_args(args, face.size)
      } else if comes_from == "bottom" {
        last_size
      } else if comes_from == "right" {
        get_from_args(args, face.size)
      }
    }

  let height = if comes_from == none {
      get_from_args(args, face.height)
    } else {
      if comes_from == "top" {
        get_from_args(args, face.size)
      } else if comes_from == "left" {
        last_size
      } else if comes_from == "bottom" {
        get_from_args(args, face.size)
      } else if comes_from == "right" {
        last_size
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
    let direction = face.type.split("_").at(1)

    assert(direction == "left" or direction == "right", message: "Triangle direction must be either 'left' or 'right'")

    let points = calculate_triangle_points(comes_from_triangle, direction, width, height)

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

    let triangle_line_type = cut_stroke
    if comes_from_triangle == "top" {
      has_child.at("bottom") = true

      if direction == "left" {
        has_child.at("left") = true
        if face.keys().contains("children") and face.children.keys().contains("left") and face.children.left == "none" {
          triangle_line_type = 0mm
        }
      } else {
        has_child.at("right") = true
        if face.keys().contains("children") and face.children.keys().contains("right") and face.children.right == "none" {
          triangle_line_type = 0mm
        }
      }
    } else if comes_from_triangle == "left" {
      has_child.at("right") = true

      if direction == "left" {
        has_child.at("bottom") = true
        if face.keys().contains("children") and face.children.keys().contains("bottom") and face.children.bottom == "none" {
          triangle_line_type = 0mm
        }
      } else {
        has_child.at("top") = true
        if face.keys().contains("children") and face.children.keys().contains("top") and face.children.top == "none" {
          triangle_line_type = 0mm
        }
      }
    } else if comes_from_triangle == "bottom" {
      has_child.at("top") = true

      if direction == "left" {
        has_child.at("right") = true
        if face.keys().contains("children") and face.children.keys().contains("right") and face.children.right == "none" {
          triangle_line_type = 0mm
        }
      } else {
        has_child.at("left") = true
        if face.keys().contains("children") and face.children.keys().contains("left") and face.children.left == "none" {
          triangle_line_type = 0mm
        }
      }
    } else if comes_from_triangle == "right" {
      has_child.at("left") = true

      if direction == "left" {
        has_child.at("top") = true
        if face.keys().contains("children") and face.children.keys().contains("top") and face.children.top == "none" {
          triangle_line_type = 0mm
        }
      } else {
        has_child.at("bottom") = true
        if face.keys().contains("children") and face.children.keys().contains("bottom") and face.children.bottom == "none" {
          triangle_line_type = 0mm
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
        stroke: triangle_line_type
      )
    ]
  } else {
    assert(false, message: "Unknown face type: " + face.type)
  }

  if face.keys().contains("children") {
    for child in face.children.values().enumerate() {
      let add_offset = (0mm,0mm)
      let orientation = face.children.keys().at(child.at(0))
      let next_comes_from = none

      has_child.at(orientation) = true

      assert(orientation != comes_from, message: "Face cannot have a child coming from the same direction as it is coming from")


      assert(not (face.type.starts-with("triangle") and ((orientation == "right" and comes_from_triangle == "left")
      or (orientation == "top" and comes_from_triangle == "bottom")
      or (orientation == "left" and comes_from_triangle == "right")
      or (orientation == "bottom" and comes_from_triangle == "top"))), message: "Triangle does not support children to the opposite side of the parent face")

      if type(child.at(1)) == str {
        if child.at(1).starts-with("tab|") {

          let tab_size = get_from_args(args, child.at(1).split("|").at(1))
          let tab_cutin = get_from_args(args, child.at(1).split("|").at(2))

          if (face.type.starts-with("triangle")) {
            let direction = face.type.split("_").at(1)
            let points = calculate_triangle_points(comes_from, direction, width, height)
            let line_points = (if direction == "left" {points.at(0)} else {points.at(1)}, points.at(2))
            let l1 = (line_points.at(1).at(1) - line_points.at(0).at(1)).pt()
            let l2 = (line_points.at(1).at(0) - line_points.at(0).at(0)).pt()
            let angle = 90deg - calc.atan2(l1, l2) + if direction == "left" {180deg} else {0deg}
            let length = calc.sqrt(calc.pow(l2, 2) + calc.pow(l1, 2)) * 1pt
            // half of the tab size in the normal direction of the line
            let add_offset = (
              calc.sin(angle) * tab_size / 2,
              -calc.cos(angle) * tab_size / 2
            )

            if ((comes_from == "right"
            and direction == "left" and orientation == "top")
            or (comes_from == "right"
            and direction == "right" and orientation == "bottom")
            or (comes_from == "left"
            and direction == "right" and orientation == "top")
            or (comes_from == "left"
            and direction == "left" and orientation == "bottom")
            or (comes_from == "top"
            and direction == "left" and orientation == "left")
            or (comes_from == "top"
            and direction == "right" and orientation == "right")
            or (comes_from == "bottom"
            and direction == "right" and orientation == "left")
            or (comes_from == "bottom"
            and direction == "left" and orientation == "right")) {
              place(
                center + horizon,
                dx: offset.at(0) + add_offset.at(0),
                dy: offset.at(1) + add_offset.at(1)
              )[
                #tab(
                  length,
                  tab_size,
                  tab_cutin,
                  angle,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]

              continue
            }
          }

          if orientation == "top" {
            place(
              center + horizon,
              dx: offset.at(0),
              dy: offset.at(1) -(height + tab_size) / 2,
            )[
              #tab(
                width,
                tab_size,
                tab_cutin,
                0deg,
                color,
                cut_stroke,
                fold_stroke,
                glue_pattern_p
              )
            ]
          } else if orientation == "left" {
            place(
              center + horizon,
              dx: offset.at(0) - (width + tab_size) / 2,
              dy: offset.at(1)
            )[
              #tab(
                height,
                tab_size,
                tab_cutin,
                270deg,
                color,
                cut_stroke,
                fold_stroke,
                glue_pattern_p
              )
            ]
          } else if orientation == "bottom" {
            place(
              center + horizon,
              dx: offset.at(0),
              dy: offset.at(1) + (height + tab_size) / 2
            )[
              #tab(
                width,
                tab_size,
                tab_cutin,
                180deg,
                color,
                cut_stroke,
                fold_stroke,
                glue_pattern_p
              )
            ]
          } else if orientation == "right" {
            place(
              center + horizon,
              dx: offset.at(0) + (width + tab_size) / 2,
              dy: offset.at(1)
            )[
              #tab(
                height,
                tab_size,
                tab_cutin,
                90deg,
                color,
                cut_stroke,
                fold_stroke,
                glue_pattern_p
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
        let direction = face.type.split("_").at(1)
        assert(not ((comes_from_triangle == "right"
        and direction == "left" and orientation == "top")
        or (comes_from_triangle == "right"
        and direction == "right" and orientation == "bottom")
        or (comes_from_triangle == "left"
        and direction == "right" and orientation == "top")
        or (comes_from_triangle == "left"
        and direction == "left" and orientation == "bottom")
        or (comes_from_triangle == "top"
        and direction == "left" and orientation == "left")
        or (comes_from_triangle == "top"
        and direction == "right" and orientation == "right")
        or (comes_from_triangle == "bottom"
        and direction == "right" and orientation == "left")
        or (comes_from_triangle == "bottom"
        and direction == "left" and orientation == "right")), message: "Triange does not support children to come from angeled sides")
      }

      if orientation == "top" {
        add_offset = (
          0mm, -(height + get_from_args(args, child.at(1).size)) / 2
        )
        next_comes_from = "bottom"
      } else if orientation == "left" {
        add_offset = (
          -(width + get_from_args(args, child.at(1).size)) / 2, 0mm
        )
        next_comes_from = "right"
      } else if orientation == "bottom" {
        add_offset = (
          0mm, (height + get_from_args(args, child.at(1).size)) / 2
        )
        next_comes_from = "top"
      } else if orientation == "right" {
        add_offset = (
          (width + get_from_args(args, child.at(1).size)) / 2, 0mm
        )
        next_comes_from = "left"
      }

      render_face(
        child.at(1),
        color,
        fold_stroke,
        cut_stroke,
        glue_pattern_p,
        clip,
        args,
        offset: (offset.at(0) + add_offset.at(0), offset.at(1) + add_offset.at(1)),
        comes_from: next_comes_from,
        last_size: if orientation == "top" or orientation == "bottom" {width} else {height}
      )
    }
  }

  if not has_child.at("top") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (0mm, -height / 2),
        end: (width, -height / 2),
        stroke: if comes_from == "top" {
          if face.keys().contains("no-fold") {
            0mm
          } else {
            fold_stroke
          }
        } else {
          cut_stroke
        }
      )
    ]
  }

  if not has_child.at("left") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (-width / 2, 0mm),
        end: (-width / 2, height),
        stroke: if comes_from == "left" {
          if face.keys().contains("no-fold") {
            0mm
          } else {
            fold_stroke
          }
        } else {
          cut_stroke
        }
      )
    ]
  }

  if not has_child.at("bottom") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (0mm, height),
        end: (width, height),
        stroke: if comes_from == "bottom" {
          if face.keys().contains("no-fold") {
            0mm
          } else {
            fold_stroke
          }
        } else {
          cut_stroke
        }
      )
    ]
  }

  if not has_child.at("right") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (width, 0mm),
        end: (width, height),
        stroke: if comes_from == "right" {
          if face.keys().contains("no-fold") {
            0mm
          } else {
            fold_stroke
          }
        } else {
          cut_stroke
        }
      )
    ]
  }
}

#let render_structure(structure_path, color: none, fold_stroke: 0.3mm + gray, cut_stroke: 0.3mm + black, glue_pattern_p: none, clip: true, ..args) = {
  if glue_pattern_p == none {
    glue_pattern_p = glue_pattern(gray)
  }

  let structure = none
  if type(structure_path) == str {
    structure = json("structures/" + structure_path + ".json")
  } else {
    structure = structure_path
  }

  for variable in structure.variables {
    assert(args.named().keys().contains(variable), message: "Structure needs variable: " + variable)
  }

  let structure_size = get_structure_size(structure, args)
  let structure_offset = get_structure_offset(structure, args)

  block(
    width: structure_size.at(0),
    height: structure_size.at(1),
    //stroke: cut_stroke
  )[
    #place(
      center + horizon,
      dx: (structure_offset.at(0)) / 2,
      dy: (structure_offset.at(1)) / 2
    )[
      #render_face(structure.root, color, fold_stroke, cut_stroke, glue_pattern_p, clip, args)
    ]
  ]
}