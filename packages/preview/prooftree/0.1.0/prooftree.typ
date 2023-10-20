#let rule(name: [], ccl, ..prem) = (
  name: name,
  ccl: ccl,
  prem: prem.pos()
)

#let proof-tree(rule, spacing: 1cm, inset: 2pt) = {
  let aux(styles, rule) = {

    let prem = rule.at("prem").map(r => if type(r) == "dictionary" {
      aux(styles, r)
    } else {
      (left-blank: 0, right-blank: 0, content: box(inset: (x: inset), r))
    })
    let prem-content = prem.map(p => p.content)

    let top = stack(dir: ltr, spacing: spacing, ..prem-content)
    let ccl = box(inset: (x: inset), rule.ccl)

    let top-size = measure(top, styles).width.pt()
    let ccl-size = measure(ccl, styles).width.pt()
    let total-size = calc.max(top-size, ccl-size)

    let left-blank = 0
    let right-blank = 0
    
    if prem.len() >= 1 {
      left-blank = prem.at(0).left-blank
      right-blank = prem.at(-1).right-blank
    }

    if ccl-size > total-size - left-blank - right-blank {
      let d = (total-size - left-blank - right-blank - ccl-size) / 2
      left-blank += d
      right-blank += d 
    }    
    let line-size = calc.max(total-size - left-blank - right-blank, ccl-size)
    let blank-size = (line-size - ccl-size) / 2
    
    let content = block(width: total-size * 1pt, stack(spacing: 1pt,
      align(center + bottom, top),
      align(left + horizon, stack(dir: ltr, 
        h(left-blank * 1pt),
        line(start: (0pt, 2pt), length: line-size * 1pt, stroke: 0.4pt),  
        h(inset),
        rule.name)
      ),
      align(left, h((left-blank + blank-size) * 1pt) + ccl)
    ))

    return (
      left-blank: blank-size + left-blank, 
      right-blank: blank-size + right-blank, 
      content: content
    )
  }

  style(styles => {
    let content = aux(styles, rule).content
    let width = measure(content, styles).width
    rect(width: width+0.5cm, stroke: none, inset: 0pt, content)
  })
}
