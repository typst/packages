// quan — 带圈数字 / Circled Numbers
//
// Public API:
//   `quan-init(digits: "1-20")`              声明字体支持范围，默认 1-10
//                                            declare font glyph coverage, default 1-10
//   `quan-style(stroke:.., ("11-50", (..)))` 配置画圈样式，范围外自动画圈
//                                            configure drawn-circle style
//   `quan(n)`                                输出带圈数字，范围外自动画圈
//                                            output circled number; draws circle if out of coverage

// ── 辅助函数 / Helpers ────────────────────────────────────────────────────

// 解析 "`1-5,7,9-11`" → `array<int>`  /  parse range string to int array
#let _parse-int-ranges(s) = {
  let result = ()
  for part in s.split(",") {
    let p = part.trim()
    if p == "" { continue }
    let dash = p.position("-")
    if dash != none and dash > 0 {
      let a = int(p.slice(0, dash).trim())
      let b = int(p.slice(dash + 1).trim())
      for i in range(a, b + 1) { result.push(i) }
    } else {
      result.push(int(p))
    }
  }
  result
}

#let _u(n) = calc.rem(n, 10)    // 个位 / units digit
#let _t(n) = calc.floor(n / 10) // 十位 / tens digit

// ── 状态 / State ─────────────────────────────────────────────────────────

// 字体字形覆盖范围  /  font glyph coverage
#let _quan-state = state("quan", (
  digits: range(1, 11),  // 默认 1-10 / default 1-10
))

// 画圈样式  /  drawn-circle style\
// `rules` 按顺序匹配，取第一个命中  /  `rules` are matched in order, first match wins
#let _quan-draw-state = state("quan-draw", (
  // `default` 作用于未命中任何 rule 的数字（含个位数及 100+）
  // `default` applies to numbers not matched by any rule (single-digit and 100+)
  default: (
    stroke:   0.0315em,
    radius:   50%,
    inset:    (x: 0em,    y: 0.015em),
    outset:   (y: 0.15em),
    baseline: -0.06em,
    size:     0.825em,
    kern:     -0.075em,
  ),
  // `rules` 覆盖 0-99，按字形宽度分五组
  // `rules` cover 0-99, grouped by digit visual width
  rules: (
    // 0-9：单位数，需较大水平内边距保持圆形视觉 / single digit, wider horizontal inset for circular look
    (values: range(0, 10),
     style:  (inset: (x: 0.25em, y: 0.015em))),
    // 11：双窄 / both narrow (1+1)
    (values: (11,),
     style:  (inset: (x: 0.09em, y: 0.015em), kern: -0.15em)),
    // 12、21：窄+中 / narrow + medium (1+2, 2+1)
    (values: (12, 21),
     style:  (inset: (x: 0.09em, y: 0.015em), kern: -0.125em)),
    // 窄+宽 / narrow + wide: 10、1X(X≥3) 或 X1(X≥3)
    // (units digit 0 is wide; tens digit 1 is narrow)
    (values: range(10, 20).filter(n => _u(n) != 1 and _u(n) != 2) + range(20, 100).filter(n => _u(n) == 1 and _t(n) >= 3),
     style:  (inset: (x: 0.08em, y: 0.015em), kern: -0.125em)),
    // 宽+宽 / wide + wide: 20-99，个位非 1
    (values: range(20, 100).filter(n => _u(n) != 1),
     style:  (inset: (x: 0.07em, y: 0.015em), kern: -0.1em)),
  ),
  // 针对 SimSun 调校 / tuned for SimSun\
  // 其他字体可能需要通过 `quan-style()` 调整\
  // adjust via `quan-style()` for other fonts
))

// ── 公开 API / Public API ────────────────────────────────────────────────

/// 声明字体支持的带圈数字范围。\
/// Declare which circled digits the current font supports.
/// 
/// 示例 / Example:\
/// "`1-20`", "`1-5,7,9-11`"
#let quan-init(digits: none) = {
  _quan-state.update(_ => (
    digits: if digits != none { _parse-int-ranges(digits) } else { () },
  ))
}

/// 配置画圈样式。具名参数修改全局默认；位置参数按范围覆盖。\
/// Configure drawn-circle style. Named args update global defaults;
/// positional args are (range-str, style-dict) tuples for per-range overrides.
///
/// 示例 / Example:\
///   `#quan-style(stroke: 0.05em, ("11-50", (size: 0.75em, kern: -0.1em)))`
///
/// 可配置字段 / Configurable fields:
///   `stroke`, `radius`, `inset`, `outset`, `baseline`, `size`, `kern`
#let quan-style(
  stroke:   none,
  radius:   none,
  inset:    none,
  outset:   none,
  baseline: none,
  size:     none,
  kern:     none,
  ..rules,
) = {
  _quan-draw-state.update(prev => {
    let d = prev.default
    if stroke   != none { d.insert("stroke",   stroke)   }
    if radius   != none { d.insert("radius",   radius)   }
    if inset    != none { d.insert("inset",    inset)    }
    if outset   != none { d.insert("outset",   outset)   }
    if baseline != none { d.insert("baseline", baseline) }
    if size     != none { d.insert("size",     size)     }
    if kern     != none { d.insert("kern",     kern)     }
    let parsed-rules = prev.rules
    for rule in rules.pos() {
      parsed-rules.push((
        values: _parse-int-ranges(rule.at(0)),
        style:  rule.at(1),
      ))
    }
    (default: d, rules: parsed-rules)
  })
}

// ── 内部渲染 / Internal Rendering ────────────────────────────────────────

// Unicode 带圈字符（0–50）/ Unicode circled digit characters (0–50)
#let _circled-digit(n) = {
  if      n == 0               { str.from-unicode(0x24EA) }
  else if n >= 1  and n <= 20  { str.from-unicode(0x245F + n) }
  else if n >= 21 and n <= 35  { str.from-unicode(0x3251 + (n - 21)) }
  else if n >= 36 and n <= 50  { str.from-unicode(0x32B1 + (n - 36)) }
  else { none }
}

// 根据 `value` 查找匹配的样式（`default` + 首条命中 `rule`）
// Resolve style for `value`: merge `default` with first matching `rule`.
#let _resolve-style(value, draw-cfg) = {
  let s = draw-cfg.default
  if type(value) == int {
    for rule in draw-cfg.rules {
      if value in rule.values {
        for (k, v) in rule.style.pairs() { s.insert(k, v) }
        break
      }
    }
  }
  s
}

// 画圈渲染  /  draw a circle around body
#let _drawn(body, value: none) = context {
  let s = _resolve-style(value, _quan-draw-state.get())
  box(
    stroke:   s.stroke,
    radius:   s.radius,
    inset:    s.inset,
    outset:   s.outset,
    baseline: s.baseline,
    text(size: s.size, tracking: s.kern, body),
  )
}

/// 输出带圈数字（`int`）。在 `quan-init` 声明的覆盖范围内使用 Unicode 字形；
/// 超出范围或字体不支持时自动画圈。仅接受整数，非整数输入会触发 panic。
///
/// Output a circled number (`int`). Uses Unicode glyphs within the coverage
/// declared by `quan-init`; falls back to a drawn circle otherwise.
/// Only integers are accepted; non-integer input panics.
#let quan(value) = {
  assert(type(value) == int, message: "quan: expected int, got " + str(type(value)))
  context {
    let cfg = _quan-state.get()
    let g = _circled-digit(value)
    if g == none or value not in cfg.digits {
      _drawn(str(value), value: value)
    } else {
      g
    }
  }
}
