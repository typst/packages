#let true-blue = rgb(30, 100, 200)
#let caribbean-current = rgb(30, 100, 101)
#let proper-purple = rgb("#6f006f")
#let federal-blue = rgb(31, 28, 92)
#let earth-yellow = rgb(224, 164, 88)
#let atomic-tangerine = rgb(222, 143, 110)

#let __formats = state("boxaroo__formats", (
  info: state("boxaroo_info"),
  definition: state("boxaroo_definition"),
  question: state("boxaroo_question"),
  important: state("boxaroo_important"),
  conclusion: state("boxaroo_conclusion"),
  good: state("boxaroo_good"),
  note: state("boxaroo_note"),
))

/// Define a new format.
#let define-format(name, prefix: none, icon: none, fill-color: none, stroke-color: none) = {
  // Allow a default value for stroke-color.
  if fill-color == none and stroke-color != none {
    fill-color = stroke-color.lighten(90%)
  }

  __formats.update(formats => {
    formats.insert(name, state("boxaroo_" + name, (
      prefix: prefix,
      icon: icon,
      fill-color: fill-color,
      stroke-color: stroke-color,
    )))
    formats
  })
}

#let bbox(body, kind: "info", radius: 5pt, footer: none, icon: true, breakable: false) = locate(loc => {
  let format = __formats.at(loc)
  assert(format.keys().contains(kind), message: "Unknown boxaroo format: " + kind)

  let settings = format.at(kind)
  assert(type(settings) == state, message: "Invalid boxaroo settings for: " + kind)

  let settings = settings.at(loc)
  assert(settings != none, message: "Invalid boxaroo settings for: " + kind)
  assert(type(settings) == type((:)), message: "Invalid boxaroo settings for: " + kind)

  let keys = settings.keys();
  assert(keys.contains("prefix"), message: "Missing prefix for: " + kind)
  assert(keys.contains("icon"), message: "Missing icon for: " + kind)
  assert(keys.contains("fill-color"), message: "Missing fill-color for: " + kind)
  assert(keys.contains("stroke-color"), message: "Missing stroke-color for: " + kind)

  show par: set block(spacing: 0pt)
  let extra = if footer == none {
    none
  } else {
    linebreak()
    h(1fr)
    underline[#footer]
  }

  let contents = if icon and settings.icon != none {
    table(
      columns: if icon { (38pt, 1fr) } else { 1 },
      inset: 9.6pt,
      stroke: none,
      align: horizon,
      block(settings.icon, width: 32pt, height: 32pt),
      {
        settings.prefix
        body
        extra
      }
    )
  } else {
    show: box.with(inset: 9.6pt)
    settings.prefix
    body
    extra
  }
  block(
    width: 100%,
    fill: settings.fill-color,
    stroke: 1pt + settings.stroke-color,
    radius: radius,
    inset: 0pt,
    breakable: breakable,
    contents,
  )
})

// An info box.
#let binfo(body, ..args) = bbox(body, kind: "info", ..args)

// A definition box.
#let bdefinition(body, ..args) = bbox(body, kind: "definition", ..args)

// A question box.
#let bquestion(body, ..args) = bbox(body, kind: "question", ..args)

// An important box.
#let bimportant(body, ..args) = bbox(body, kind: "important", ..args)

// A conclusion box.
#let bconclusion(body, ..args) = bbox(body, kind: "conclusion", ..args)

// A note box.
#let bnote(body, ..args) = bbox(body, kind: "note", ..args)

#let boxaroo(body) = {
  define-format(
    "info",
    icon: image("./assets/circle-info.svg"),
    stroke-color: true-blue,
  )

  define-format(
    "definition",
    prefix: underline(smallcaps[*Definition*]) + smallcaps[:],
    icon: image("./assets/highlighter-solid.svg"),
    stroke-color: caribbean-current,
  )

  define-format(
    "question",
    icon: image("./assets/circle-question.svg"),
    stroke-color: proper-purple,
  )

  define-format(
    "important",
    icon: image("./assets/circle-exclamation.svg"),
    fill-color: federal-blue.lighten(90%),
    stroke-color: federal-blue.darken(20%),
  )

  define-format(
    "conclusion",
    icon: image("./assets/lightbulb-solid.svg"),
    stroke-color: earth-yellow,
  )

  define-format(
    "note",
    prefix: underline(smallcaps[*Note*]) + smallcaps[:],
    icon: image("./assets/note-sticky.svg"),
    stroke-color: atomic-tangerine,
  )

  body
}