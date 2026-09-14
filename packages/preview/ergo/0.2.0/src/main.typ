#import "color/color.typ": (
  ergo-colors,
  valid-colors,
  get-ratio,
  get-colors,
  get-opts-colors,
)
#import "style/style.typ": (
  ergo-styles,
  valid-styles,
)






//-----Setup-----//
#let colors-state        = state("colors-state",      ergo-colors.bootstrap)
#let styles-state        = state("styles-state",      ergo-styles.tab2)
#let breakable-state     = state("breakable-state",   false)
#let inline-qed-state    = state("inline-qed-state",  false)
#let prob-nums-state     = state("prob-nums-state",   true)

#let ergo-init(
  body,
  colors:       ergo-colors.bootstrap,
  styles:       ergo-styles.tab1,
  breakable:    false,
  inline-qed:   false,
  prob-nums:    true,
) = context {
  if valid-colors(colors) {
    colors-state.update(colors)
  } else {
    panic("Unrecognized or invalid color")
  }
  if valid-styles(styles) {
    styles-state.update(styles)
  } else {
    panic("Unrecognized or invalid styles")
  }
  if type(breakable) == bool {
    breakable-state.update(breakable)
  } else {
    panic("Non boolean passed to boolean")
  }
  if type(inline-qed) == bool {
    inline-qed-state.update(inline-qed)
  } else {
    panic("Non boolean passed to boolean")
  }
  if type(prob-nums) == bool {
    prob-nums-state.update(prob-nums)
  } else {
    panic("Non boolean passed to boolean")
  }

  let opts-colors  = get-opts-colors(colors-state.get())

  let fill-color   = rgb(opts-colors.at("fill"))
  let text1-color  = rgb(opts-colors.at("text1"))
  let text2-color  = rgb(opts-colors.at("text2"))
  let h1-color     = rgb(opts-colors.at("h1"))
  let h2-color     = rgb(opts-colors.at("h2"))
  let strong-color = rgb(opts-colors.at("strong"))

  show strong: set text(fill: strong-color)
  show heading.where(level: 1): set text(fill: h1-color)
  show heading.where(level: 2): set text(fill: h2-color)

  set text(text1-color)
  set page(fill: fill-color)

  body
}






//-----Environments-----//
#let bookmark(
  title,
  info,
) = context {
  let colors          = colors-state.get()
  let bookmark-colors = get-colors(colors, "bookmark")
  let bgcolor         = rgb(bookmark-colors.at("bgcolor"))
  let strokecolor     = rgb(bookmark-colors.at("strokecolor"))

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
  let colors      = colors-state.get()
  let opts-colors = get-opts-colors(colors)
  let text1       = rgb(opts-colors.at("text1"))

  align(center)[
    #rect(stroke: text1)[
      #equation
    ]
  ]
}




#let ergo-solution(
  preheader,
  id,
  is-proof,
  colors:     none,
  styles:     none,
  breakable:  none,
  inline-qed: none,
  prob-nums:  none,
  width:      100%,
  height:     auto,
  ..argv
) = context {
  let args   = argv.pos()
  let argc   = args.len()
  let kwargs = argv.named()  // passed to child function

  if argc < 2 {
    panic("Must pass in at least two positional arguments")
  } else if argc > 3 {
    panic("Must pass in at most 3 positional arguments")
  }

  let title          = if argc == 3 {args.at(0)} else {[]}
  let statement-body = if argc == 2 {args.at(0)} else {args.at(1)}
  let solution-body  = if argc == 2 {args.at(1)} else {args.at(2)}

  let new-styles  = if valid-styles(styles) { styles } else { styles-state.get() }
  let new-colors  = if valid-colors(colors) { colors } else { colors-state.get() }
  let colors-dict = (
    "env": get-colors(new-colors, id),
    "opt": get-opts-colors(new-colors),
    "raw": get-ratio(new-colors, "raw", "saturation")
  )

  let new-breakable  = if type(breakable)  == bool { breakable }  else { breakable-state.get()  }
  let new-inline-qed = if type(inline-qed) == bool { inline-qed } else { inline-qed-state.get() }
  let new-prob-nums  = if type(prob-nums)  == bool { prob-nums }  else { prob-nums-state.get() }
  new-prob-nums  = not is-proof and new-prob-nums

  let child-argv = arguments(
    preheader:  preheader,
    id:         id,
    inline-qed: new-inline-qed,
    breakable:  new-breakable,
    prob-nums:  new-prob-nums,
    width:      width,
    height:     height,
    is-proof:   is-proof,
    ..kwargs
  )

  return (new-styles.solution)(
      title,
      statement-body,
      solution-body,
      colors-dict,
      ..child-argv
  )
}




#let ergo-statement(
  preheader,
  id,
  colors:     none,
  styles:     none,
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

  let title          = if argc == 2 {args.at(0)} else {[]}
  let statement-body = if argc == 1 {args.at(0)} else {args.at(1)}

  let new-styles  = if valid-styles(styles) { styles } else { styles-state.get() }
  let new-colors  = if valid-colors(colors) { colors } else { colors-state.get() }
  let colors-dict = (
    "env": get-colors(new-colors, id),
    "opt": get-opts-colors(new-colors),
    "raw": get-ratio(new-colors, "raw", "saturation")
  )

  let new-breakable = if type(breakable) == bool { breakable } else { breakable-state.get() }

  let child-argv = arguments(
    preheader: preheader,
    id:        id,
    breakable: new-breakable,
    width:     width,
    height:    height,
    ..kwargs
  )

  return (new-styles.statement)(
    title,
    statement-body,
    colors-dict,
    ..child-argv
  )
}
