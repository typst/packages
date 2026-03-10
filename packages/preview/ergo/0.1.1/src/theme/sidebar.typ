#import "helpers.typ": (
  problem-counter,
  highlight-raw,
  get-proofname-content,
  get-statementname-content,
  get-proof-content,
  get-statement-content,
)


#let sidebar-proof-env(
  name,
  statement,
  proof-statement,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor1)
  let strokecolor = rgb(colors.env.strokecolor1)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let name-content      = get-proofname-content(kwargs.kind, name, problem: kwargs.problem, prob-nums: kwargs.prob-nums)
  let statement-content = get-statement-content(statement)
  let proof-content     = get-proof-content(proof-statement, kwargs.problem, kwargs.inline-qed)

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(strokecolor)[#name-content],
      statement-content,
      proof-content,
    ),
  )
}

#let sidebar-statement-env(
  name,
  statement,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor)
  let strokecolor = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let name-content      = get-statementname-content(kwargs.kind, name)
  let statement-content = get-statement-content(statement)

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(fill: strokecolor)[#name-content],
      statement-content,
    ),
  )
}

