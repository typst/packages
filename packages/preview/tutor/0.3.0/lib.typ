
#let default-config() = {
  let cfg = (
    sol: false,
    level: 1,
    utils: (
      lines: ( spacing: 10mm ),
      checkbox: (
        sym_true: "☒",
        sym_false: "☐",
        sym_question: "☐"
      ),
      totalpoints: (
        outline: false,
      ),
    )
  )
  return cfg
}

#let checkbox(cfg, answer) = {
  if cfg.sol {
    if answer {
    cfg.utils.checkbox.sym_true
    } else {
    cfg.utils.checkbox.sym_false
    }
  } else {
    cfg.utils.checkbox.sym_question
  }
}

#let points(num) = {
  let c = state("points", 0.0)
  c.update(points => points + num)
  [ #num ]
}


#let totalpoints(cfg) = {
  locate(loc => {
    let c = state("points", 0.0)
    let points = c.final(loc)
    if cfg.utils.totalpoints.outline {
      points = points/2
    }
    [ #points ]
    }
  )
}

#let lines(cfg, count) = {
  let content = []
  let spacing = cfg.utils.lines.spacing
  if type(spacing) == "string" {
    spacing = eval(spacing)
  }
  for n in range(count) {
    content += [#v(spacing) #line(length:100%) ]
  }
  return content
}
