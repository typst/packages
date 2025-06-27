#import "helpers.typ": (
  problem_counter,
  highlight_raw,
  get_proofname_content,
  get_statementname_content,
  get_proof_content,
  get_statement_content,
)


#let sidebar_proof_env(
  name,
  statement,
  proof_statement,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor1)
  let strokecolor = rgb(colors.env.strokecolor1)

  show raw.where(block: false): r => highlight_raw(r, bgcolor.saturate(colors.raw))

  let name_content      = get_proofname_content(kwargs.kind, name, problem: kwargs.problem)
  let statement_content = get_statement_content(statement)
  let proof_content     = get_proof_content(proof_statement, kwargs.problem, kwargs.inline-qed)

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(strokecolor)[#name_content],
      statement_content,
      proof_content,
    ),
  )
}

#let sidebar_statement_env(
  name,
  statement,
  colors,
  ..argv
) = {
  let kwargs      = argv.named()
  let bgcolor     = rgb(colors.env.bgcolor)
  let strokecolor = rgb(colors.env.strokecolor)

  show raw.where(block: false): r => highlight_raw(r, bgcolor.saturate(colors.raw))

  let name_content      = get_statementname_content(kwargs.kind, name)
  let statement_content = get_statement_content(statement)

  block(
    stroke:     (left: strokecolor + 3pt),
    fill:       bgcolor,
    inset:      (y: 4pt),
    width:      kwargs.width,
    height:     kwargs.height,
    breakable:  kwargs.breakable,
    clip:       true,
    stack(
      text(fill: strokecolor)[#name_content],
      statement_content,
    ),
  )
}

