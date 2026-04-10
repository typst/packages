#import "helpers.typ": (
  problem-counter,
  highlight-raw,
  get-proofname-content,
  get-statementname-content,
  get-proof-content,
  get-statement-content,
)


#let tab-proof-env(
  name,
  statement,
  proof-statement,
  colors,
  ..argv
) = {
  let kwargs        = argv.named()
  let bgcolor1      = rgb(colors.env.bgcolor1)
  let bgcolor2      = rgb(colors.env.bgcolor2)
  let strokecolor1  = rgb(colors.env.strokecolor1)
  let strokecolor2  = rgb(colors.env.strokecolor2)

  show raw.where(block: false): r => highlight-raw(r, bgcolor1.saturate(colors.raw))

  let name-content = get-proofname-content(kwargs.kind, name, problem: kwargs.problem, prob-nums: kwargs.prob-nums)

  name-content = block(
    fill:   strokecolor1,
    width:  100%,
    text(rgb(colors.opt.text2))[#name-content]
  )

  let statement-content = get-statement-content(
    block(
      fill:   bgcolor2,
      inset:  8pt,
      radius: 2pt,
      width:  100%,
      stroke: (left: strokecolor2 + 6pt),
      statement
    )
  )

  let proof-content = get-proof-content(proof-statement, kwargs.problem, kwargs.inline-qed)

  block(
    stroke:     strokecolor1,
    fill:       bgcolor1,
    inset:      (bottom: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    radius:     6pt,
    clip:       true,
    stack(
      name-content,
      statement-content,
      proof-content,
    )
  )
}

#let tab-statement-env(
  name,
  statement,
  colors,
  ..argv
) = {
  let kwargs       = argv.named()
  let bgcolor      = rgb(colors.env.bgcolor)
  let strokecolor  = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let name-content = get-statementname-content(kwargs.kind, name)

  name-content = block(
    fill:  strokecolor,
    width: 100%,
    text(rgb(colors.opt.text2))[#name-content]
  )

  let statement-content = get-statement-content(statement)

  block(
    stroke:     strokecolor,
    fill:       bgcolor,
    inset:      (bottom: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    radius:     6pt,
    clip:       true,
    stack(
      name-content,
      statement-content
    )
  )
}

