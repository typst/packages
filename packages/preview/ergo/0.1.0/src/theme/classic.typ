#import "helpers.typ": (
  problem_counter,
  highlight_raw,
  get_proofname_content,
  get_statementname_content,
  get_proof_content,
  get_statement_content,
)


#let classic_proof_env(
  name,
  statement,
  proof_statement,
  colors,
  ..argv
) = {
  let kwargs        = argv.named()
  let bgcolor1      = rgb(colors.env.bgcolor1)
  let bgcolor2      = rgb(colors.env.bgcolor2)
  let strokecolor1  = rgb(colors.env.strokecolor1)
  let strokecolor2  = rgb(colors.env.strokecolor2)

  show raw.where(block: false): r => highlight_raw(r, bgcolor1.saturate(colors.raw))

  let name_content = get_proofname_content(kwargs.kind, name, problem: kwargs.problem)

  let statement_content = get_statement_content(
    block(
      fill:   bgcolor2,
      inset:  8pt,
      radius: 2pt,
      width:  100%,
      stroke: (left: strokecolor2 + 6pt),
      statement
    )
  )

  let proof_content = get_proof_content(proof_statement, kwargs.problem, kwargs.inline_qed)

  block(
    stroke:     strokecolor1,
    fill:       bgcolor1,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    radius:     6pt,
    clip:       true,
    stack(
      name_content,
      statement_content,
      proof_content,
    )
  )
}

#let classic_statement_env(
  name,
  statement,
  colors,
  ..argv
) = {
  let kwargs       = argv.named()
  let bgcolor      = rgb(colors.env.bgcolor)
  let strokecolor  = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight_raw(r, bgcolor.saturate(colors.raw))

  let name_content      = get_statementname_content(kwargs.kind, name)
  let statement_content = get_statement_content(statement)

  block(
    stroke:     strokecolor,
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    radius:     6pt,
    clip:       true,
    stack(
      name_content,
      statement_content
    )
  )
}

