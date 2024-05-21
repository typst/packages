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