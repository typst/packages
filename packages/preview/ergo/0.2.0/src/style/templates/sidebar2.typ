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
  let kwargs       = argv.named()
  let bgcolor      = rgb(colors.env.bgcolor1)
  let strokecolor1 = rgb(colors.env.strokecolor1)
  let strokecolor2 = rgb(colors.env.strokecolor2)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let title-content     = get-title-content(
    kwargs.preheader,
    title,
    is-proof: kwargs.is-proof,
    prob-nums: kwargs.prob-nums,
  )
  let statement-content = get-statement-content(statement-body)

  let solution-block = if solution-body == [] {
    []
  } else {
    let solution-content  = get-solution-content(
      solution-body,
      kwargs.is-proof,
      kwargs.inline-qed,
      sol-color: strokecolor2,
    )

    block(
      stroke:     (left: strokecolor2 + 4pt),
      inset:      -3pt,
      width:      kwargs.width,
      height:     kwargs.height,
      breakable:  kwargs.breakable,
      solution-content
    )
  }


  stack(
    block(
      stroke:     (left: strokecolor1 + 3pt),
      fill:       bgcolor,
      inset:      (y: 4pt),
      width:      kwargs.width,
      height:     kwargs.height,
      breakable:  kwargs.breakable,
      clip:       true,
      stack(
        text(strokecolor1)[#title-content],
        statement-content,
      ),
    ),
    solution-block,
    spacing: if solution-body == [] {none} else {13pt},
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

