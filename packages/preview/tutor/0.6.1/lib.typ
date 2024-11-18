/// Load the default tutor config.
///
/// The tutor configuration holds all settings for the individual utilities provided by tutor.
///
/// #example(`
/// let cfg = tutor.default-config()
/// [#cfg]
/// `)
///
/// -> dictionary
#let default-config() = {
  let cfg = (
    sol: false,
    level: 1,
    test: true,
    utils: (
      lines: ( spacing: 10mm ),
      grid: ( spacing: 4mm ),
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

/// Show a checkbox. 
///
/// *Example in Question Mode:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// [What does FHIR stand for?
/// - #tutor.checkbox(cfg, false) Finally He Is Real
/// - #tutor.checkbox(cfg, true) Fast Health Interoperability Resources]
/// `)
/// 
/// *Example in Solution Mode:*
///
/// #example(`
/// let cfg = tutor.default-config()
/// (cfg.sol = true) // enable solutions
/// [What does FHIR stand for?
/// - #tutor.checkbox(cfg, false) Finally He Is Real
/// - #tutor.checkbox(cfg, true) Fast Health Interoperability Resources]
/// `)
/// 
/// - cfg (dictionary): Global Tutor configuration
/// - answer (boolean): Wheter the checkbox should be filled in solution mode.
/// -> content
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




/// Print a blank line with a solution text.
///
/// *Example in Question Mode:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// [Word for top of mountain: #tutor.blankline(cfg, 2cm, [peak])]
/// `)
/// 
/// *Example in Solution Mode:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// (cfg.sol = true) // enable solutions
/// [Word for top of mountain: #tutor.blankline(cfg, 2cm, [peak])] 
/// `)
/// 
/// - cfg (dictionary): Global Tutor configuration
/// - width (length): Line length.
/// - answer (content): Answer to display in solution mode.
/// -> content
#let blankline(cfg, width, answer) = {
  if cfg.sol {
    box(width: width, baseline: 5pt, stroke: (bottom: black),text(baseline:-5pt)[#answer])
  } else {
    box(width: width, baseline: 5pt, stroke: (bottom: black))[]
  }
}

/// Print lines for students to write answers.
///
/// *Example:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// (cfg.utils.lines.spacing = 2mm)
/// [Write answer here:]
/// tutor.lines(cfg, 3)`)
/// 
/// 
/// 
/// - cfg (dictionary): Global Tutor configuration
/// - count (integer): Number of lines to display.
/// -> content
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

/// Print a grid for students to write answers.
///
/// *Example:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// [Write answer here:]
/// tutor.grid(cfg, 4cm, 2cm)`)
/// 
/// 
/// 
/// - cfg (dictionary): Global Tutor configuration
/// - width (length): Width of grid box.
/// - height (length): Length of grid box.
/// -> content
#let grid(cfg, width, height) = {
  let spacing = cfg.utils.grid.spacing
  if type(spacing) == "string" {
    spacing = eval(spacing)
  }
  
  let pat = pattern(size: (spacing, spacing))[
    #place(line(start: (0%, 0%), end: (0%, 100%), stroke: 0.2pt))
    #place(line(start: (0%, 0%), end: (100%, 0%), stroke: 0.2pt))
  ]

  align(center,rect(fill: pat, width: width, height: height, stroke: 0.2pt))
}



/// Maximum points that can be achieved for a question. Will be internally added up to the total points counter.
///
/// *Example:*
/// 
/// #example(`[In this question a maxiumum of #tutor.points(4.5) points can be achieved.]`)
/// 
/// 
/// 
/// - num (integer, float): Number of points. 
/// -> content
#let points(num) = {
  let c = state("points", 0.0)
  c.update(points => points + num)
  [ #num ]
}


/// Display the total points of this exam, typically in the exam header.
///
/// *Example:*
/// 
/// #example(`
/// let cfg = tutor.default-config()
/// [In this a exam a total of #tutor.totalpoints(cfg) points can be achieved.]`)
/// 
/// 
/// - cfg (dictionary): Global Tutor configuration
/// -> content
#let totalpoints(cfg) = {
    context {
      let c = state("points", 0.0)
      let points = c.final()
      if cfg.utils.totalpoints.outline {
        points = points/2
      }
      [ #points ]
    }
}

/// Display only in solution mode.
///
/// - cfg (dictionary): Global Tutor configuration
/// - sol (content): Content to be shown in solution mode
/// -> content
#let if_sol(cfg, sol) = {
  if cfg.sol {
    sol
  }
}

/// Display different content in solution and question mode.
///
/// - cfg (dictionary): Global Tutor configuration
/// - sol (content): Content to be shown in solution mode
/// - question (content): Content to be shown in question mode
/// -> content
#let if_sol_else(cfg, sol, question) = {
  if cfg.sol {
    sol
  } else {
    question
  }
}

/// Display only in test mode.
///
/// - cfg (dictionary): Global Tutor configuration
/// - test (content): Content to be shown in test mode
/// -> content
#let if_test(cfg, test) = {
  if cfg.test {
    test
  }
}

/// Display different content in solution and question mode.
///
/// - cfg (dictionary): Global Tutor configuration
/// - test (content): Content to be shown in test mode
/// - exercise (content): Content to be shown in question mode
/// -> content
#let if_test_else(cfg, test, exercise) = {
  if cfg.test {
    test
  } else {
    exercise
  }
}

