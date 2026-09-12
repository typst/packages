#import "../../../core/setup.typ": nw-config

// Note: these implementations read the configuration state, so they
// must run inside a context (the wrappers in mod.typ provide one).
#let theorem-block(label, body, fill-color: white, stroke-color: black) = {
  let c = nw-config()
  v(c.box-margin)
  if c.block-design == "modern" {
    // Modern Design (Catalogue Style): Outlined, rounded, spacious
    block(
      fill: fill-color,
      stroke: 2pt + stroke-color,
      inset: 14pt,
      radius: 6pt,
      width: 100%,
      above: 1em,
      below: 1em,
    )[
      #text(weight: "bold", size: 11pt, fill: stroke-color, label)
      #v(8pt)
      #body
    ]
  } else {
    // Simple Design (Legacy): Filled, no border, Adlam font for title
    block(
      fill: fill-color,
      inset: c.box-inset,
      radius: 4pt,
      width: 100%,
      above: 1em,
      below: 1em,
    )[
      #text(size: 13pt, font: c.title-font, fill: stroke-color, weight: "bold")[#label]
      #v(5pt)
      #body
    ]
  }
}


#let create-block(config, ..args) = {
  assert(
    1 <= args.pos().len() and args.pos().len() <= 2,
    message: "create-block must be called with (config, name, body) or (config, body)",
  )
  [#std.metadata("block") <block-start>]
  let title = ""
  let body = none
  if args.pos().len() == 2 {
    title = args.at(0)
    body = args.at(1)
  } else if args.pos().len() == 1 {
    body = args.at(0)
  }
  let label = [#text(smallcaps(config.title)) | #title]
  theorem-block(label, body, fill-color: config.fill, stroke-color: config.stroke)
}

#let create-solution(config, ..args) = {
  assert(
    1 <= args.pos().len() and args.pos().len() <= 3,
    message: "solution must be called with (config, name, number, body) or (config, name, body) or (config, body)",
  )
  let pos = args.pos()
  let number = none
  let body = none
  let name = ""

  if pos.len() == 1 {
    body = pos.at(0)
    number = auto
  } else if pos.len() == 2 {
    name = pos.at(0)
    body = pos.at(1)
    number = auto
  } else if pos.len() == 3 {
    name = pos.at(0)
    body = pos.at(2)
    number = pos.at(1)
  }

  [#std.metadata("solution") <solution>]

  let number-content = if number == auto {
    context {
      let sol-loc = here()
      let start-locs = query(selector(<block-start>).before(sol-loc))

      if start-locs.len() > 0 {
        let start-loc = start-locs.last().location()
        let sols = query(selector(<solution>).after(start-loc).before(sol-loc))
        [#sols.len()]
      } else {
        let sols = query(selector(<solution>).before(sol-loc))
        [#sols.len()]
      }
    }
  } else {
    number
  }

  if nw-config().show-solution {
    let label = [#text(weight: "bold", config.title) #number-content | #name]
    theorem-block(label, body, fill-color: config.fill, stroke-color: config.stroke)
  }
}

#let create-proof(config, ..args) = {
  assert(
    1 <= args.pos().len() and args.pos().len() <= 2,
    message: "create-proof must be called with (config, name, body) or (config, body)",
  )
  let name = ""
  let body = none
  if args.pos().len() == 2 {
    name = args.at(0)
    body = args.at(1)
  } else if args.pos().len() == 1 {
    body = args.at(0)
  }
  let label = [#text(weight: "bold", config.title) | #name]
  theorem-block(label, body, fill-color: config.fill, stroke-color: config.stroke)
}
