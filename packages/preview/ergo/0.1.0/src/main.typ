#import "color/color.typ": (
  env_colors,
  valid_colors,
  get_ratio,
  get_colors,
  get_opts_colors,
)
#import "theme/helpers.typ": ergo-title-selector
#import "theme/theme.typ": (
  env_headers,
  valid_headers,
  tab_proof_env,
  tab_statement_env,
  classic_proof_env,
  classic_statement_env,
  sidebar_proof_env,
  sidebar_statement_env,
)






//-----Setup-----//
#let all-breakable-toggle = state("all-breakable-toggle", false)
#let inline-qed-toggle    = state("inline-qed-toggle", false)

#let ergo-init(
  body,
  colors:         "bootstrap",
  headers:        "tab",
  all-breakable:  false,
  inline-qed:     false,
) = context {
  if type(colors) == str and valid_colors(colors) {
    env_colors.update(colors)
  } else {
    panic("Unrecognized or invalid color")
  }
  if type(headers) == str and valid_headers(headers) {
    env_headers.update(headers)
  } else {
    panic("Unrecognized or invalid header style")
  }
  if type(all-breakable) == bool {
    all-breakable-toggle.update(all-breakable)
  } else {
    panic("Non boolean passed to boolean")
  }
  if type(inline-qed) == bool {
    inline-qed-toggle.update(inline-qed)
  } else {
    panic("Non boolean passed to boolean")
  }

  let opts_colors  = get_opts_colors(env_colors.get())

  let bg_color     = rgb(opts_colors.at("fill"))
  let t1_color     = rgb(opts_colors.at("text1"))
  let t2_color     = rgb(opts_colors.at("text2"))
  let h1_color     = rgb(opts_colors.at("h1"))
  let h2_color     = rgb(opts_colors.at("h2"))
  let strong_color = rgb(opts_colors.at("strong"))

  show strong: set text(fill: strong_color)
  show heading.where(level: 1): set text(fill: h1_color)
  show heading.where(level: 2): set text(fill: h2_color)

  set text(t1_color)
  set page(fill: bg_color)

  body
}






//-----Misc-----//
#let correction(body) = {
  text(fill: rgb("#ea4120"), weight: "semibold", body)
}

#let bookmark(
  title,
  info,
) = context {
  let theme       = env_colors.get()
  let colors      = get_colors(theme, "bookmark")

  let bgcolor     = rgb(colors.at("bgcolor"))
  let strokecolor = rgb(colors.at("strokecolor"))

  block(
    fill: bgcolor,
    width: 100%,
    inset: 8pt,
    stroke: strokecolor,
    breakable: false,
    grid(
      columns: (1fr, 1fr),
      align(left)[#title],
      align(right)[#info],
    )
  )
}

#let equation-box(
  equation,
) = context {
  let theme   = env_colors.get()
  let colors  = get_opts_colors(theme)
  let text1   = rgb(colors.at("text1"))

  align(center)[
    #rect(stroke: text1)[
      #equation
    ]
  ]
}





//-----Theorem Environments-----//
#let proof_env(
  kind,
  id,
  problem,
  inline-qed: none,
  breakable:  none,
  width:      100%,
  height:     auto,
  ..argv
) = context {
  let args    = argv.pos()
  let argc    = args.len()
  let kwargs  = argv.named() // passed to child function

  if argc < 2 {
    panic("Must pass in at least two positional arguments")
  } else if argc > 3 {
    panic("Must pass in at most 3 positional arguments")
  }

  let name            = if argc == 3 {args.at(0)} else {[]}
  let statement       = if argc == 2 {args.at(0)} else {args.at(1)}
  let proof_statement = if argc == 2 {args.at(1)} else {args.at(2)}

  let theme_name  = env_headers.get()
  let color_name  = env_colors.get()
  let colors      = (
    "env": get_colors(color_name, id),
    "opt": get_opts_colors(color_name),
    "raw": get_ratio(color_name, "raw", "saturation")
  )

  let new_breakable  = if type(breakable) == bool { breakable } else { all-breakable-toggle.get() }
  let new_qed = if type(inline-qed) == bool { inline-qed } else { inline-qed-toggle.get() }

  let child_argv = arguments(
    kind:       kind,
    id:         id,
    inline-qed: new_qed,
    breakable:  new_breakable,
    width:      width,
    height:     height,
    problem:    problem,
    ..kwargs
  )

  if (theme_name == "tab") {
    return tab_proof_env(
      name,
      statement,
      proof_statement,
      colors,
      ..child_argv
    )
  } else if (theme_name == "classic") {
    return classic_proof_env(
      name,
      statement,
      proof_statement,
      colors,
      ..child_argv
    )
  } else if (theme_name == "sidebar") {
    return sidebar_proof_env(
      name,
      statement,
      proof_statement,
      colors,
      ..child_argv
    )
  }
}

#let theorem = proof_env.with(
  [Theorem],
  "theorem",
  false
)

#let lemma = proof_env.with(
  [Lemma],
  "lemma",
  false
)

#let corollary = proof_env.with(
  [Corollary],
  "corollary",
  false
)

#let proposition = proof_env.with(
  [Proposition],
  "proposition",
  false
)

#let problem = proof_env.with(
  [Problem],
  "problem",
  true
)

#let exercise = proof_env.with(
  [Exercise],
  "exercise",
  true
)






//-----Definition Environments-----//
#let statement_env(
  kind,
  id,
  breakable:  none,
  width:      100%,
  height:     auto,
  ..argv
) = context {
  let args    = argv.pos()
  let argc    = args.len()
  let kwargs  = argv.named() // passed to child function

  if argc < 1 {
    panic("Must pass in at least one positional argument")
  } else if argc > 2 {
    panic("Muss pass in at most 2 positional arguments")
  }

  let name      = if argc == 2 {args.at(0)} else {[]}
  let statement = if argc == 1 {args.at(0)} else {args.at(1)}

  let theme_name  = env_headers.get()
  let color_name  = env_colors.get()
  let colors      = (
    "env": get_colors(color_name, id),
    "opt": get_opts_colors(color_name),
    "raw": get_ratio(color_name, "raw", "saturation")
  )

  let new_breakable = if type(breakable) == bool { breakable } else { all-breakable-toggle.get() }

  let child_argv = arguments(
    kind:      kind,
    id:        id,
    breakable: new_breakable,
    width:     width,
    height:    height,
    ..kwargs
  )

  if (theme_name == "tab") {
    return tab_statement_env(
      name,
      statement,
      colors,
      ..child_argv
    )
  } else if (theme_name == "classic") {
    return classic_statement_env(
      name,
      statement,
      colors,
      ..child_argv
    )
  } else if (theme_name == "sidebar") {
    return sidebar_statement_env(
      name,
      statement,
      colors,
      ..child_argv
    )
  }
}

#let note = statement_env.with(
  [Note],
  "note"
)

#let definition = statement_env.with(
  [Definition],
  "definition"
)

#let remark = statement_env.with(
  [Remark],
  "remark"
)

#let notation = statement_env.with(
  [Notation],
  "notation"
)

#let example = statement_env.with(
  [Example],
  "example"
)

#let concept = statement_env.with(
  [Concept],
  "concept"
)

#let computational-problem = statement_env.with(
  [Computational Problem],
  "computational-problem"
)

#let algorithm = statement_env.with(
  [Algorithm],
  "algorithm"
)

#let runtime = statement_env.with(
  [Runtime Analysis],
  "runtime"
)

