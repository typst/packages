#import "../helpers.typ": (
  problem-counter,
  highlight-raw,
  get-title-content,
  get-solution-content,
  get-statement-content,
)


#let custom-solution(
  title,
  statement-body,
  solution-body,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor1)
  let strokecolor = rgb(colors.env.strokecolor1)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let title-content     = get-title-content(
    kwargs.preheader,
    title,
    is-proof: kwargs.is-proof,
    prob-nums: kwargs.prob-nums
  )
  let statement-content = get-statement-content(statement-body)
  let solution-content  = get-solution-content(
    solution-body,
    kwargs.is-proof,
    kwargs.inline-qed,
  )

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(strokecolor)[#title-content],
      statement-content,
      solution-content,
    ),
  )
}

#let custom-statement(
  title,
  statement-body,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor)
  let strokecolor = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let title-content     = get-title-content(kwargs.preheader, title)
  let statement-content = get-statement-content(statement-body)

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(fill: strokecolor)[#title-content],
      statement-content,
    ),
  )
}

