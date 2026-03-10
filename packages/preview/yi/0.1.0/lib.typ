#let gua(bits) = {
  assert(bits.len() == 6 or bits.len() == 3, message: "卦应是三爻或六爻")
  let thick = if bits.len() == 6 { 0.1em } else { 0.12em }
  let space = if bits.len() == 6 { 0.18em } else { 0.45em }

  let yang = line(length: 100%, stroke: (thickness: thick, cap: "round"))
  let yin = line(length: 100%, stroke: (thickness: thick, cap: "round", dash: (0.35em, 0.2em)))

  let a = ()
  for bit in bits { a.push(if bit == "0" { yin } else { yang }) }
  box(width: 1em, height: 1em, inset: 0.05em, baseline: 0.18em)[
    #stack(spacing: space, ..a.rev())
  ]
}

