#let a_size(exponent) = {
  let a0_size = (841mm, 1189mm)

  for i in range(exponent) {
    let last_a_size = a0_size

    a0_size = (last_a_size.at(1) / 2, last_a_size.at(0))
  }

  return a0_size
}

#let calculate_smallest_a_size(width, height) = {

  let current_a_size = 0
  let current_size = a_size(current_a_size)
  
  while (width < current_size.at(1) and height < current_size.at(0)) {
    current_a_size = current_a_size + 1
    current_size = a_size(current_a_size)
  } 
  return current_a_size - 1
}

#let glue_pattern(color) = pattern(size: (30pt, 30pt))[
  #place[#box(fill: none, width: 100%, height: 100%)]
  #place(line(start: (5pt, 0%), end: (-5pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (15pt, 0%), end: (5pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (25pt, 0%), end: (15pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (35pt, 0%), end: (25pt, 100%), stroke: 0.3mm + color))
]

#let tab(width, height, cutin, orientation, color, cut_stroke, fold_stroke, glue_pattern_p) = {
  let real_cutin = calc.min(cutin, width / 2)

  rotate(orientation, reflow: true)[
    #polygon(
      fill: color,
      (0% + real_cutin, 0%),
      (width - real_cutin, 0%),
      (width, height),
      (0%, height)
    )
    #place(center + horizon)[
      #polygon(
        fill: glue_pattern_p,
        (0% + real_cutin, 0%),
        (width - real_cutin, 0%),
        (width, height),
        (0%, height)
      )
    ]
    #place(top + center)[
      #line(
        start: (0%, 0%),
        end: (width - real_cutin * 2, 0%),
        stroke: cut_stroke
      )
    ]
    #place(top + center)[
      #line(
        start: (width, height),
        end: (width - real_cutin, 0%),
        stroke: cut_stroke
      )
    ]
    #place(top + left)[
      #line(
        start: (0%, height),
        end: (real_cutin, 0%),
        stroke: cut_stroke
      )
    ]
    #place(bottom + center)[
      #line(
        start: (0%, 0%),
        end: (width, 0%),
        stroke: fold_stroke
      )
    ]
  ]
}

#let calculate_triangle_points(comes_from, direction, width, height) = {
  return if comes_from == "top" {
    (
      (0mm, 0mm),
      (width, 0mm),
      if direction == "left" {
        (width, height)
      } else {
        (0mm, height)
      }
    )
  } else if comes_from == "left" {
    (
      (0mm, height),
      (0mm, 0mm),
      if direction == "left" {
        (width, 0mm)
      } else {
        (width, height)
      }
    )
  } else if comes_from == "bottom" {
    (
      (width, height),
      (0mm, height),
      if direction == "left" {
        (0mm, 0mm)
      } else {
        (width, 0mm)
      }
    )
  } else if comes_from == "right" {
    (
      (width, 0mm),
      (width, height),
      if direction == "left" {
        (0mm, height)
      } else {
        (0mm, 0mm)
      }
    )
  }
}

#let evaluated_functions = (
  "hyp": (a, b) => calc.sqrt(calc.pow(a, 2) + calc.pow(b, 2)),
)

#let get_from_args(args, name) = {
  if name == "" {
    return 0pt
  }

  let converted_args = (:)

  for arg in args.named() {
    if type(arg.at(1)) == length {
      converted_args.insert(arg.at(0), arg.at(1).pt())
    }
  }

  return eval(name, scope: converted_args + evaluated_functions) * 1pt
}

#let get_structure_size(structure, args) = {
  return (get_from_args(args, structure.width), get_from_args(args, structure.height))
}

#let get_structure_offset(structure, args) = {
  return (get_from_args(args, structure.offset_x), get_from_args(args, structure.offset_y))
}