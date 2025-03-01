#import "data-model.typ": get-element-counts, get-element, get-weight, define-molecule, define-hydrate, reaction, get-shell-configuration, get-electron-configuration, display-electron-configuration
// === 化学方程式解析与排版库 ===
#import "regex.typ": patterns

// === 配置设置 ===
#let config = (
  arrow: (arrow_size: 120%, reversible_size: 150%),
  conditions: (
    bottom: (
      symbols: (heating: ("Delta", "delta", "Δ", "δ", "fire", "heat", "hot", "heating")),
      identifiers: (("T=", "t="), ("P=", "p=")),
      units: ("°C", "K", "atm", "bar"),
    ),
  ),
  match_order: (
    // 使用regex.typ中的模式名称
    basic: ("bracket","coefficient", "element",  "charge"),
    full: ("bracket", "coefficient", "element", "plus", "charge", "arrow"),
  ),
)

// === 基本处理函数 ===
#let process_element(element, count) = { 
$#element _count$
}

#let process_bracket(bracket, count) = { 
  $#bracket _count$
}

#let process_charge(input, charge) = context {
  show "+": math.plus
  show "-": math.minus
  $#block(height: measure(input).height)^#charge$
}

// === 公式解析函数 ===
#let parse_formula(formula) = {
  let remaining = formula.trim()
  let result = none
  
  while remaining.len() > 0 {
    let matched = false
    for pattern in config.match_order.basic {
      let match = remaining.match(patterns.at(pattern))
      if match != none {
        result += if pattern == "coefficient" { 
          $#match.captures.at(0)$ 
        } else if pattern == "element" {
          process_element(match.captures.at(0), match.captures.at(1))
        } else if pattern == "bracket" { 
          process_bracket(match.captures.at(0), match.captures.at(1))
        } else if pattern == "charge" {
          process_charge(result, match.captures.at(0))
        }
        
        remaining = remaining.slice(match.end)
        matched = true
        break
      }
    }
    
    if not matched {
      result += text(remaining.first())
      remaining = remaining.slice(1)
    }
  }
  
  return if result == none { formula } else { result }
}

// === 条件处理函数 ===
#let process_condition(cond) = {
  let cond = cond.trim()
  
  // 处理加热符号条件
  if cond.match(patterns.heating) != none {
    return (none, { sym.Delta })
  }
  
  // 检查是否是底部条件
  let is_bottom = (
    config.conditions.bottom.identifiers.any(ids => ids.any(id => cond.starts-with(id)))
      or config.conditions.bottom.units.any(unit => cond.ends-with(unit))
  )
  
  return if is_bottom { (none, cond) } else { (parse_formula(cond), none) }
}

// === 箭头处理函数 ===
#let process_arrow(arrow_text, condition: none) = {
  let arrow = if arrow_text.contains("<-") {
    $stretch(#sym.harpoons.rtlb, size: #config.arrow.reversible_size)$
  } else if arrow_text.contains("=") {
    $stretch(=, size: #config.arrow.arrow_size)$
  } else {
    $stretch(->, size: #config.arrow.arrow_size)$
  }
  
  let top = ()
  let bottom = ()
  
  if condition != none {
    for cond in condition.split(",") {
      let (t, b) = process_condition(cond)
      if t != none { top.push(t) }
      if b != none { bottom.push(b) }
    }
  }
  
  $arrow^#top.join(",")_#bottom.join(",")$
}

// === 主解析函数 ===
#let ce = (formula, condition: none) => {
  let remaining = formula.trim()
  let result = none
  
  while remaining.len() > 0 {
    let matched = false
    for pattern in config.match_order.full {
      let match = remaining.match(patterns.at(pattern))
      if match != none {
        result += if pattern == "plus" { 
          $+$ 
        } else if pattern == "coefficient" { 
          $#match.captures.at(0)$ 
        } else if pattern == "element" {
          process_element(match.captures.at(0), match.captures.at(1))
        } else if pattern == "bracket" {
          process_bracket(match.captures.at(0), match.captures.at(1))
        } else if pattern == "charge" { 
          process_charge(result, match.captures.at(0)) 
        } else {
          process_arrow(match.text, condition: condition)
        }
        
        remaining = remaining.slice(match.end)
        matched = true
        break
      }
    }
    
    if not matched {
      result += text(remaining.first())
      remaining = remaining.slice(1)
    }
  }
  
  $upright(display(result))$
}
