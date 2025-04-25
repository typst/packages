/// Chemical formula typesetting package
/// Version: 0.0.2

#let chem_patterns = (
  element: "([A-Z][a-z]?)",
  group: "(?:\\(([A-Z][A-Za-z]+|[0-9]*n(?:[+-][0-9]+)*)\\))?",
  subscript: "([0-9]+|[nx])?",
  charge: "(?:\\^\\(([0-9+-]+)\\))?",
  state: "(?:\\(([a-z]+)\\))?",
  post_number: "([0-9]+)?",
)
#let rx = {
  let parts = (
    chem_patterns.element,
    chem_patterns.group,
    chem_patterns.subscript,
    chem_patterns.charge,
    chem_patterns.state,
    chem_patterns.post_number,
  )
  regex(parts.join(""))
}
#let format(content) = {
  show "Delta": sym.Delta
  show "+": $+$
  show "-": $-$
  let bottom_symbols = ("Delta", "delta", "Δ", "δ")
  show regex("(?:<=|=)([^=]*)=>") : it => {
    let is_reversible = it.text.starts-with("<=")
    let conditions = it.text.slice(if is_reversible {2} else {1}, -2)
    if conditions == "" { 
      return if is_reversible { 
        $stretch(#sym.harpoons.rtlb, size: #120%)$ 
      } else { 
        $stretch(->, size: #120%)$ 
      }
    }
    conditions = conditions.split(",")
    let top = ()
    let bottom = ()
    for cond in conditions {
      cond = cond.trim()
      if cond in bottom_symbols {
        bottom.push(sym.Delta)
      } else {
        top.push(cond)
      }
    }
    let arrow = if is_reversible {
      $stretch(#sym.harpoons.rtlb, size: #150%)$
    } else {
      $stretch(->, size: #120%)$
    }
    if top.len() > 0 and bottom.len() > 0 {
      arrow = $#arrow^#top.join(",")_#bottom.join(",")$
    } else if top.len() > 0 {
      arrow = $#arrow^#top.join(",")$
    } else if bottom.len() > 0 {
      arrow = $#arrow _#bottom.join(",")$
    }
    arrow
  }
  show rx: it => {
    let groups = it.text.match(rx)
    if groups == none { return it }
    let (base, group, num, charge, state, post_number) = groups.captures.slice(0) 
    let result = $upright(#base)$
    if group != none { 
      if group.contains("n") {
        let expr = group
        expr = $#expr$
        result = $#result _(#expr)$
      } else {
        result = $#result thin (#group)$
      }
    }
    let commapend(prev, cur) = {
      if prev == none { return cur }
      [#prev,#sym.space #cur]
    }
    if num != none { 
      result = $#result _#num$
    }
    if charge != none { 
      show "+": math.plus
      show "-": math.minus
      result = $#result^#charge$
    }
    if state != none {
      let pure = state.trim("()")
      result = $#result _(#pure)$
    }
    if post_number != none {
      result = $#result _#post_number$
    }
    result
  }
  $inline(upright(#content))$
}
