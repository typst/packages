#let rule(name: "", ccl, ..prem) = (name: name, ccl: ccl, prem: prem.pos())

#let proof-tree(
  rule,
  prem-min-spacing: 15pt,
  title-inset: 2pt,
  stroke: 0.4pt,
  horizontal-spacing: 0pt,
) = {
  let aux(styles, rule) = {
    let prem = rule.at("prem").map(r => if type(r) == "dictionary" {
      aux(styles, r)
    } else {
      (
        left-blank: 0,
        right-blank: 0,
        content: box(inset: (x: title-inset), r),
      )
    })
    let prem-content = prem.map(p => p.content)

    let number_prem = prem.len()
    let top = stack(dir: ltr, ..prem-content)
    let name = rule.name
    let ccl = box(inset: (x: title-inset), rule.ccl)

    let top-size = measure(top, styles).width.pt()
    let ccl-size = measure(ccl, styles).width.pt()
    let total-size = calc.max(top-size, ccl-size)
    let name-size = measure(name, styles).width.pt()

    let complete_size = total-size * 1pt + name-size * 1pt + title-inset

    let left-blank = 0
    let right-blank = 0
    if number_prem >= 1 {
      left-blank = prem.at(0).left-blank
      right-blank = prem.at(number_prem - 1).right-blank
    }
    let prem_spacing = 0pt
    if number_prem >= 1 {
      // Same spacing between all premisses
      prem_spacing = calc.max(prem-min-spacing, (total-size - top-size) / (number_prem + 1) * 1pt)
    }
    let top = stack(dir: ltr, spacing: prem_spacing, ..prem-content)
    top-size = measure(top, styles).width.pt()
    total-size = calc.max(top-size, ccl-size)
    complete_size = total-size * 1pt + name-size * 1pt + title-inset

    if ccl-size > total-size - left-blank - right-blank {
      let d = (total-size - left-blank - right-blank - ccl-size) / 2
      left-blank += d
      right-blank += d
    }
    let line-size = calc.max(total-size - left-blank - right-blank, ccl-size)
    let blank-size = (line-size - ccl-size) / 2

    let top_height = measure(top, styles).height.pt()
    let ccl_height = measure(ccl, styles).height.pt()

    let content = block(
      // stroke: red + 0.3pt, // DEBUG
      width: complete_size,
      stack(spacing: horizontal-spacing, {
        let alignment = left
        // Maybe a fix for having center premisses with big trees
        // let alignment = center
        // If there are only one premisses
        // if top_height <= 1.5 * ccl_height {
        //  alignment = left
        // }
        align(alignment, block(
          // stroke: green + 0.3pt, // DEBUG
          width: total-size * 1pt,
          align(center + bottom, top),
        ))
      }, align(left + horizon, box(
        // stroke: red + 0.3pt, // DEBUG
        inset: (bottom: {
          if (name == "") { 0.2em } else { 0.05em }
        }),
        stack(
          dir: ltr,
          h(left-blank * 1pt),
          line(start: (0pt, 2pt), length: line-size * 1pt, stroke: stroke),
          if (name != "") { h(title-inset) },
          name,
        ),
      )), align(left, stack(dir: ltr, h(left-blank * 1pt), block(
        // stroke: blue + 0.3pt, // DEBUG
        width: line-size * 1pt,
        align(center, ccl),
      )))),
    )
    return (
      left-blank: blank-size + left-blank,
      right-blank: blank-size + right-blank,
      content: content,
    )
  }
  style(styles => {
    box(
      // stroke : black + 0.3pt, // DEBUG
      aux(styles, rule).content,
    )
  })
}