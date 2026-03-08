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
  let kwargs        = argv.named()
  let bgcolor1      = rgb(colors.env.bgcolor1)
  let bgcolor2      = rgb(colors.env.bgcolor2)
  let strokecolor1  = rgb(colors.env.strokecolor1)
  let strokecolor2  = rgb(colors.env.strokecolor2)

  show raw.where(block: false): r => highlight-raw(r, bgcolor1.saturate(colors.raw))

  let title-content = get-title-content(
    kwargs.preheader,
    title,
    is-proof: kwargs.is-proof,
    prob-nums: kwargs.prob-nums
  )

  title-content = block(
    fill:   strokecolor1,
    width:  100%,
    text(rgb(colors.opt.text2))[#title-content]
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
      stroke:     strokecolor1,
      fill:       bgcolor1,
      inset:      (bottom: 4pt),
      width:      kwargs.width,
      height:     kwargs.height,
      breakable:  kwargs.breakable,
      radius:     6pt,
      clip:       true,
      stack(
        title-content,
        statement-content,
      )
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
  let kwargs       = argv.named()
  let bgcolor      = rgb(colors.env.bgcolor)
  let strokecolor  = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight-raw(r, bgcolor.saturate(colors.raw))

  let title-content = get-title-content(kwargs.preheader, title)

  title-content = block(
    fill:  strokecolor,
    width: 100%,
    text(rgb(colors.opt.text2))[#title-content]
  )

  let statement-content = get-statement-content(statement-body)

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
      title-content,
      statement-content
    )
  )
}

