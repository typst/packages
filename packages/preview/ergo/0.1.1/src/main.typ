#import "color/color.typ": (
  env-colors,
  valid-colors,
  get-ratio,
  get-colors,
  get-opts-colors,
)
#import "theme/helpers.typ": ergo-title-selector
#import "theme/theme.typ": (
  env-headers,
  valid-headers,
  tab-proof-env,
  tab-statement-env,
  classic-proof-env,
  classic-statement-env,
  sidebar-proof-env,
  sidebar-statement-env,
)






//-----Setup-----//
#let all-breakable-toggle = state("all-breakable-toggle", false)
#let inline-qed-toggle    = state("inline-qed-toggle", false)
#let prob-nums-toggle     = state("prob-nums-toggle", false)

#let ergo-init(
  body,
  colors:         "bootstrap",
  headers:        "tab",
  all-breakable:  false,
  inline-qed:     false,
  prob-nums:      true,
) = context {
  if type(colors) == str and valid-colors(colors) {
    env-colors.update(colors)
  } else {
    panic("Unrecognized or invalid color")
  }
  if type(headers) == str and valid-headers(headers) {
    env-headers.update(headers)
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
  if type(prob-nums) == bool {
    prob-nums-toggle.update(prob-nums)
  } else {
    panic("Non boolean passed to boolean")
  }

  let opts-colors  = get-opts-colors(env-colors.get())

  let bg-color     = rgb(opts-colors.at("fill"))
  let t1-color     = rgb(opts-colors.at("text1"))
  let t2-color     = rgb(opts-colors.at("text2"))
  let h1-color     = rgb(opts-colors.at("h1"))
  let h2-color     = rgb(opts-colors.at("h2"))
  let strong-color = rgb(opts-colors.at("strong"))

  show strong: set text(fill: strong-color)
  show heading.where(level: 1): set text(fill: h1-color)
  show heading.where(level: 2): set text(fill: h2-color)

  set text(t1-color)
  set page(fill: bg-color)

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
  let theme       = env-colors.get()
  let colors      = get-colors(theme, "bookmark")

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
  let theme   = env-colors.get()
  let colors  = get-opts-colors(theme)
  let text1   = rgb(colors.at("text1"))

  align(center)[
    #rect(stroke: text1)[
      #equation
    ]
  ]
}





//-----Theorem Environments-----//
#let proof-env(
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
  let proof-statement = if argc == 2 {args.at(1)} else {args.at(2)}

  let theme-name  = env-headers.get()
  let color-name  = env-colors.get()
  let colors      = (
    "env": get-colors(color-name, id),
    "opt": get-opts-colors(color-name),
    "raw": get-ratio(color-name, "raw", "saturation")
  )

  let new-breakable  = if type(breakable) == bool { breakable } else { all-breakable-toggle.get() }
  let new-qed = if type(inline-qed) == bool { inline-qed } else { inline-qed-toggle.get() }

  let child-argv = arguments(
    kind:       kind,
    id:         id,
    inline-qed: new-qed,
    breakable:  new-breakable,
    prob-nums:  prob-nums-toggle.get(),
    width:      width,
    height:     height,
    problem:    problem,
    ..kwargs
  )

  if (theme-name == "tab") {
    return tab-proof-env(
      name,
      statement,
      proof-statement,
      colors,
      ..child-argv
    )
  } else if (theme-name == "classic") {
    return classic-proof-env(
      name,
      statement,
      proof-statement,
      colors,
      ..child-argv
    )
  } else if (theme-name == "sidebar") {
    return sidebar-proof-env(
      name,
      statement,
      proof-statement,
      colors,
      ..child-argv
    )
  }
}

#let theorem = proof-env.with(
  [Theorem],
  "theorem",
  false
)

#let lemma = proof-env.with(
  [Lemma],
  "lemma",
  false
)

#let corollary = proof-env.with(
  [Corollary],
  "corollary",
  false
)

#let proposition = proof-env.with(
  [Proposition],
  "proposition",
  false
)

#let problem = proof-env.with(
  [Problem],
  "problem",
  true
)

#let exercise = proof-env.with(
  [Exercise],
  "exercise",
  true
)






//-----Definition Environments-----//
#let statement-env(
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

  let theme-name  = env-headers.get()
  let color-name  = env-colors.get()
  let colors      = (
    "env": get-colors(color-name, id),
    "opt": get-opts-colors(color-name),
    "raw": get-ratio(color-name, "raw", "saturation")
  )

  let new-breakable = if type(breakable) == bool { breakable } else { all-breakable-toggle.get() }

  let child-argv = arguments(
    kind:      kind,
    id:        id,
    breakable: new-breakable,
    width:     width,
    height:    height,
    ..kwargs
  )

  if (theme-name == "tab") {
    return tab-statement-env(
      name,
      statement,
      colors,
      ..child-argv
    )
  } else if (theme-name == "classic") {
    return classic-statement-env(
      name,
      statement,
      colors,
      ..child-argv
    )
  } else if (theme-name == "sidebar") {
    return sidebar-statement-env(
      name,
      statement,
      colors,
      ..child-argv
    )
  }
}

#let note = statement-env.with(
  [Note],
  "note"
)

#let definition = statement-env.with(
  [Definition],
  "definition"
)

#let remark = statement-env.with(
  [Remark],
  "remark"
)

#let notation = statement-env.with(
  [Notation],
  "notation"
)

#let example = statement-env.with(
  [Example],
  "example"
)

#let concept = statement-env.with(
  [Concept],
  "concept"
)

#let computational-problem = statement-env.with(
  [Computational Problem],
  "computational-problem"
)

#let algorithm = statement-env.with(
  [Algorithm],
  "algorithm"
)

#let runtime = statement-env.with(
  [Runtime Analysis],
  "runtime"
)

