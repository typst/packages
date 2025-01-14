/// Chemical formula typesetting package
/// Version: 0.0.1

// 修改预编译的正则表达式模式
#let rx = regex("([A-Z][a-z]?)(?:\\(([A-Z][A-Za-z]+|[0-9]*n(?:[+-][0-9]+)*)\\))?([0-9]+)?(?:\\^\\(([0-9+-]+)\\))?(?:\\(([a-z]+)\\))?")

// 新增有机化学正则表达式
#let organic = (
  // 基本结构 - 改进对Cn模式的支持
  basic: regex("([A-Z][a-z]?)(?:\\(([A-Z][A-Za-z]+|[0-9]*n(?:[+-][0-9]+)*)\\))?([0-9]+|n)?(?:[A-Z][0-9]+)*"),
  // 双键和三键
  bonds: regex("(=|≡)"),
  // 有机基团 (如 -CH3, -OH, -COOH 等)
  groups: regex("\\-([A-Z][A-Za-z0-9]+)"),
  // 取代基位置
  position: regex("([0-9]+)\\-"),
  // 苯环缩写
  phenyl: regex("Ph"),
)

// 预定义连接符样式
#let bond-styles = (
  single: $minus$,  // 单键
  double: $=$,      // 双键
  triple: $≡$,      // 三键
)

/// 格式化化学式
#let format(content) = {
  // 基础替换规则
  show "react": $arrow$
  show "equilibrium": math.arrow.l.r
  show "Delta": sym.Delta
  show "+": $+$
  show "-": bond-styles.single
  show "=": bond-styles.double
  show "≡": bond-styles.triple
  show "Ph": "⌬"
  
  // 有机化学特殊处理
  show organic.groups: it => {
    let group = it.text.slice(1)
    h(0.15em) + $minus$ + h(0.1em) + $upright(#group)$ // 优化基团连接
  }
  
  show organic.position: it => {
    let pos = it.text.slice(0,-1)
    $upright(#pos)$ + h(0.1em) + $minus$ + h(0.15em) // 优化位置标记连接
  }

  // 修改统一的匹配与处理部分
  show rx: it => {
    let groups = it.text.match(rx)
    if groups == none { return it }
    
    let (base, group, num, charge, state) = groups.captures.slice(0)
    
    let result = $upright(#base)$
    if group != none { 
      // 处理括号中的表达式
      if group.contains("n") {
        // 改进对数学表达式的处理
        let expr = group
          .replace("n+", "n plus ")  // 临时替换以避免与化学加号冲突
          .replace("n-", "n minus ")
        expr = $#expr.replace("plus", "+").replace("minus", "-")$
        result = $#result _(#expr)$
      } else {
        result = $#result thin (#group)$
      }
    }
    if num != none { 
      // 特殊处理n的情况
      if num == "n" {
        result = $#result_n$
      } else {
        result = $#result _#num$
      }
    }
    if charge != none { 
      show "+": math.plus
      show "-": math.minus
      result = $#result^#charge$
    }
    if state != none {
      // 修改状态标记显示方式
      let pure_state = state.trim("()")
      result = $#result _(#pure_state)$ // 使用双括号确保正确显示
    }
    
    result
  }

  $upright(#content)$
}

// 导出接口
#let chemical = format
