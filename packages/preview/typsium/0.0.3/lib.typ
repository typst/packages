// === 正则表达式匹配模式定义 ===
#let regex_patterns = (
  element: regex("^([A-Z][a-z]?)(\d*)"), // 元素符号：大写字母+可选小写字母+可选数字
  bracket: regex("^([\(\[\]\)])(\d*)"), // 括号：左右括号和方括号+可选数字
  charge: regex("^\^?\(([0-9+-]+)\)?"), // 离子电荷：上标括号中的数字和正负号
  arrow: regex("^(<-|-)?([^->]*?)->"), // 反应箭头：可逆/不可逆+反应条件
  coef: regex("^(\d+)"), // 化学计量数：纯数字
  plus: regex("^\+"), // 加号：反应物或生成物之间的连接符
)
// === 元素处理函数 ===
#let process_element(element, count) = { if count != "" { $element_count$ } else { $element$ } }
// === 括号处理函数 ===
#let process_bracket(bracket, count) = { if count != "" { $bracket _ #count$ } else { $bracket$ } }
// === 电荷处理函数 ===
#let process_charge(input, charge) = {
  if charge != none {
    show "+": math.plus
    show "-": math.minus
    $#input^#charge$
  } else { input }
}
// === 箭头处理函数 ===
#let process_arrow(arrow_text) = {
  let is_reversible = arrow_text.starts-with("<-")
  let conditions = arrow_text.slice(if is_reversible { 2 } else { 1 }, -2)
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
  let bottom_symbols = ("Delta", "delta", "Δ", "δ", "heat", "hot")
  for cond in conditions {
    cond = cond.trim()
    if cond in bottom_symbols {
      bottom.push(if cond in ("heat", "hot") { sym.Delta } else { sym.Delta })
    } else if (
      cond.starts-with("T=")
        or cond.starts-with("P=")
        or cond.starts-with("t=")
        or cond.starts-with("p=")
        or cond.ends-with("°C")
        or cond.ends-with("K")
        or cond.ends-with("atm")
        or cond.ends-with("bar")
    ) {
      bottom.push(cond)
    } else if cond != "" {
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

// === 主解析函数 ===
#let ce(formula) = {
  let remaining = formula
  let result = $$
  let has_charge = false
  while remaining.len() > 0 {
    remaining = remaining.trim()
    if remaining.len() == 0 { break }
    let matched = false
    let old_remaining = remaining
    let patterns = ("coef", "element", "arrow", "bracket", "plus", "charge")
    for pattern in patterns {
      let match = remaining.match(regex_patterns.at(pattern))
      if match != none {
        if pattern == "coef" { result += $#match.text$ } else if pattern == "plus" { result += $+$ } else if (
          pattern == "element"
        ) {
          result += process_element(match.captures.at(0), match.captures.at(1))
        } else if pattern == "bracket" {
          result += process_bracket(match.captures.at(0), match.captures.at(1))
        } else if pattern == "charge" {
          let charge = match.captures.at(0)
          result = process_charge(result, charge)
          has_charge = charge != none
        } else if pattern == "arrow" {
          result += process_arrow(match.text)
        }
        remaining = remaining.slice(match.end)
        matched = true
        break
      }
    }
    //==用于显示错误信息==
    if remaining == old_remaining {
      panic("解析错误：" + remaining)
      panic("请查看文档了解支持的语法：" + remaining[0])
    }
  }
  $display(result)$
}