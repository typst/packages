#let a-size(exponent) = {
  let a0-size = (841mm, 1189mm)

  for i in range(exponent) {
    let last-a-size = a0-size

    a0-size = (last-a-size.at(1) / 2, last-a-size.at(0))
  }

  return a0-size
}

#let calculate-smallest-a-size(width, height) = {

  let current-a-size = 0
  let current-size = a-size(current-a-size)
  
  while (width < current-size.at(1) and height < current-size.at(0)) {
    current-a-size = current-a-size + 1
    current-size = a-size(current-a-size)
  } 
  return current-a-size - 1
}

#let pattern-glue(color) = pattern(size: (30pt, 30pt))[
  #place[#box(fill: none, width: 100%, height: 100%)]
  #place(line(start: (5pt, 0%), end: (-5pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (15pt, 0%), end: (5pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (25pt, 0%), end: (15pt, 100%), stroke: 0.3mm + color))
  #place(line(start: (35pt, 0%), end: (25pt, 100%), stroke: 0.3mm + color))
]

#let tab(width, height, cutin, orientation, color, cut-stroke, fold-stroke, glue-pattern) = {
  let real-cutin = calc.min(cutin, width / 2)

  rotate(orientation, reflow: true)[
    #polygon(
      fill: color,
      (0% + real-cutin, 0%),
      (width - real-cutin, 0%),
      (width, height),
      (0%, height)
    )
    #place(center + horizon)[
      #polygon(
        fill: glue-pattern,
        (0% + real-cutin, 0%),
        (width - real-cutin, 0%),
        (width, height),
        (0%, height)
      )
    ]
    #place(top + center)[
      #line(
        start: (0%, 0%),
        end: (width - real-cutin * 2, 0%),
        stroke: cut-stroke
      )
    ]
    #place(top + center)[
      #line(
        start: (width, height),
        end: (width - real-cutin, 0%),
        stroke: cut-stroke
      )
    ]
    #place(top + left)[
      #line(
        start: (0%, height),
        end: (real-cutin, 0%),
        stroke: cut-stroke
      )
    ]
    #place(bottom + center)[
      #line(
        start: (0%, 0%),
        end: (width, 0%),
        stroke: fold-stroke
      )
    ]
  ]
}

#let calculate-triangle-points(comes-from, direction, width, height) = {
  return if comes-from == "top" {
    (
      (0mm, 0mm),
      (width, 0mm),
      if direction == "left" {
        (width, height)
      } else {
        (0mm, height)
      }
    )
  } else if comes-from == "left" {
    (
      (0mm, height),
      (0mm, 0mm),
      if direction == "left" {
        (width, 0mm)
      } else {
        (width, height)
      }
    )
  } else if comes-from == "bottom" {
    (
      (width, height),
      (0mm, height),
      if direction == "left" {
        (0mm, 0mm)
      } else {
        (width, 0mm)
      }
    )
  } else if comes-from == "right" {
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

#let evaluated-functions = (
  "hyp": (a, b) => calc.sqrt(calc.pow(a, 2) + calc.pow(b, 2)),
)

#let get-from-args(args, name) = {
  if name == "" {
    return 0pt
  }

  let converted-args = (:)

  for arg in args.named() {
    if type(arg.at(1)) == length {
      converted-args.insert(arg.at(0), arg.at(1).pt())
    }
  }

  return eval(name, scope: converted-args + evaluated-functions) * 1pt
}