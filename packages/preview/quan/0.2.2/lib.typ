// quan — 带圈数字 / Circled Numbers
//
// Public API:
//   `quan-init(digits: "1-20")`              声明字体支持范围，默认 1-10
//                                            declare font glyph coverage, default 1-10
//   `quan-style(stroke:.., ("11-50", (..)))` 配置画圈样式，范围外自动画圈
//                                            configure drawn-circle style
//   `quan(n)`                                输出带圈数字，范围外自动画圈
//                                            output circled number; draws circle if out of coverage
//   `#show: quan-footnote`                   将脚注序号改为带圈数字
//                                            apply circled-number footnote markers globally

// ── 辅助函数 / Helpers ────────────────────────────────────────────────────

// 范围串中的单个数字 → int，报错时指明出处
// one token of a range string → int, with a readable error naming the input
#let _to-int(s, ctx) = {
  let t = s.trim()
  assert(t.match(regex("^-?[0-9]+$")) != none,
    message: "quan: invalid number \"" + t + "\" in range string \"" + ctx + "\"")
  int(t)
}

// 解析 "`1-5,7,9-11`" → `array<int>`，支持负数端点（如 "`-5--1`"）
// parse range string to int array; negative endpoints supported (e.g. "-5--1")
#let _parse-int-ranges(s) = {
  let result = ()
  for part in s.split(",") {
    let p = part.trim()
    if p == "" { continue }
    // 跳过开头的符号位再找区间分隔符 / find the separator dash after an optional sign
    let body = if p.starts-with("-") { p.slice(1) } else { p }
    let dash = body.position("-")
    if dash != none {
      let cut = dash + (p.len() - body.len())
      let a = _to-int(p.slice(0, cut), s)
      let b = _to-int(p.slice(cut + 1), s)
      assert(a <= b, message: "quan: invalid range \"" + p + "\" (start > end)")
      for i in range(a, b + 1) { result.push(i) }
    } else {
      result.push(_to-int(p, s))
    }
  }
  result
}

#let _u(n) = calc.rem(n, 10)    // 个位 / units digit
#let _t(n) = calc.floor(n / 10) // 十位 / tens digit

// 具名字重 → 数值 / named font weight → numeric
#let _weight-num(w) = {
  if type(w) == int { w } else {
    (thin: 100, extralight: 200, light: 300, regular: 400, medium: 500,
     semibold: 600, bold: 700, extrabold: 800, black: 900).at(w, default: 400)
  }
}

// ── 状态 / State ─────────────────────────────────────────────────────────

// 字体字形覆盖范围  /  font glyph coverage
#let _quan-state = state("quan", (
  digits: range(1, 11),  // 默认 1-10 / default 1-10
))

// 画圈样式，四层解析、后层优先：
//   default → 内置 rules（首个命中） → 用户具名参数 → 用户范围规则（全部命中、后注册优先）
// drawn-circle style, resolved in four layers, later layers win:
//   default → built-in rules (first match) → user named args → user range rules (all matches, later wins)
#let _quan-draw-state = state("quan-draw", (
  default: (
    stroke:   0.0315em,
    radius:   50%,
    // x 内边距兜底给三位数及负数；0-99 的 inset 由内置 rules 按字宽精调
    // the x inset serves 100+ and negatives; 0-99 get width-tuned insets from the rules below
    inset:    (x: 0.28em, y: 0.015em),
    outset:   (y: 0.15em),
    baseline: -0.06em,
    size:     0.825em,
    kern:     -0.075em,
    gap:      0.1em,   // 相邻画圈之间的水平间距 / horizontal gap between adjacent circles
  ),
  // 内置 `rules` 覆盖 0-99，按字形宽度分五组
  // built-in `rules` cover 0-99, grouped by digit visual width
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
  // 其他字体通过 `quan-style()` 调整（叠加在内置规则之上）\
  // adjust via `quan-style()` for other fonts (layered on top of the built-in rules)

  // 用户通过 `quan-style` 注册的范围规则、及显式设置过的全局字段名
  // range rules registered via `quan-style`, and names of explicitly-set global fields
  user-rules: (),
  user-keys: (),
))

// ── 公开 API / Public API ────────────────────────────────────────────────

/// 声明字体支持的带圈数字范围。\
/// Declare which circled digits the current font supports.
///
/// 示例 / Example:\
/// "`1-20`", "`1-5,7,9-11`"
#let quan-init(digits: none) = {
  let parsed = if digits != none { _parse-int-ranges(digits) } else { () }
  _quan-state.update(_ => (digits: parsed))
}

/// 配置画圈样式。具名参数修改全局默认，并优先于内置的 SimSun 规则；
/// 位置参数为 (范围字符串, 样式字典) 元组，按范围叠加覆盖 —— 所有命中
/// 的规则依次生效，后注册（含后一次调用）的优先。\
/// Configure drawn-circle style. Named args update the global defaults and
/// take precedence over the built-in SimSun rules; positional args are
/// (range-str, style-dict) tuples applied cumulatively per range, with
/// later-registered rules (including later calls) winning.
///
/// 示例 / Example:\
///   `#quan-style(stroke: 0.05em, ("11-50", (size: 0.75em, kern: -0.1em)))`
///
/// 可配置字段 / Configurable fields:
///   `stroke`, `radius`, `inset`, `outset`, `baseline`, `size`, `kern`, `gap`
#let quan-style(
  stroke:   none,
  radius:   none,
  inset:    none,
  outset:   none,
  baseline: none,
  size:     none,
  kern:     none,
  gap:      none,
  ..rules,
) = {
  // 解析在 update 闭包外完成：只跑一次，报错也定位在调用处
  // parse outside the update closure: runs once, errors point at the call site
  let parsed = rules.pos().map(rule => {
    assert(
      type(rule) == array and rule.len() == 2
        and type(rule.at(0)) == str and type(rule.at(1)) == dictionary,
      message: "quan-style: positional args must be (range-str, style-dict) tuples",
    )
    (values: _parse-int-ranges(rule.at(0)), style: rule.at(1))
  })
  let named = (stroke: stroke, radius: radius, inset: inset, outset: outset,
               baseline: baseline, size: size, kern: kern, gap: gap)
  _quan-draw-state.update(prev => {
    let d = prev.default
    let keys = prev.user-keys
    for (k, v) in named.pairs() {
      if v != none {
        d.insert(k, v)
        if k not in keys { keys.push(k) }
      }
    }
    (default: d, rules: prev.rules,
     user-rules: prev.user-rules + parsed, user-keys: keys)
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

// 根据 `value` 逐层合并样式：
//   default → 内置规则（首个命中）→ 用户具名参数 → 用户范围规则（全部命中、后者优先）
// Resolve style for `value`, merging layer by layer:
//   default → built-in rule (first match) → user named args → user range rules (all matches, later wins)
#let _resolve-style(value, draw-cfg) = {
  let s = draw-cfg.default
  if type(value) == int {
    for rule in draw-cfg.rules {
      if value in rule.values {
        for (k, v) in rule.style.pairs() { s.insert(k, v) }
        break
      }
    }
    // 用户显式设置过的全局字段优先于内置规则
    // explicitly-set global fields take precedence over the built-in rules
    for k in draw-cfg.user-keys {
      s.insert(k, draw-cfg.default.at(k))
    }
    for rule in draw-cfg.user-rules {
      if value in rule.values {
        for (k, v) in rule.style.pairs() { s.insert(k, v) }
      }
    }
  }
  s
}

// 画圈渲染  /  draw a circle around body
// 在 box 两侧各加 `gap/2` 间距，模拟 Unicode 字形的左右 bearing。
// 这样 drawn+drawn、Unicode+drawn、drawn+Unicode 三种相邻情形的视觉间距都接近一致。
// Add `gap/2` on both sides of the box to mimic the left/right bearings of
// Unicode glyphs. This keeps spacing visually consistent across all three
// adjacency cases: drawn+drawn, Unicode+drawn, drawn+Unicode.
//
// 裸长度 `stroke` 跟随 text.fill 与 text.weight（`set text` 设置的字重；
// `*..*`/`strong` 走字重增量，context 读不到），与同行 Unicode 字形观感一致；
// 显式给出颜色的 stroke（如 `0.05em + red`）原样使用。
// A bare-length `stroke` tracks text.fill and text.weight (as set via
// `set text`; `strong`'s weight delta is invisible to context) so drawn
// circles match native glyphs on the same line; strokes with an explicit
// paint (e.g. `0.05em + red`) are used as-is.
#let _drawn(body, value: none) = context {
  let s = _resolve-style(value, _quan-draw-state.get())
  let sk = stroke(s.stroke)
  if sk.paint == auto {
    let factor = calc.max(1.0, 1.0 + (_weight-num(text.weight) - 400) / 400 * 0.6)
    let th = if sk.thickness == auto { 0.0315em } else { sk.thickness }
    sk = stroke((paint: text.fill, thickness: th * factor,
                 cap: sk.cap, join: sk.join, dash: sk.dash, miter-limit: sk.miter-limit))
  }
  let half = s.gap / 2
  h(half)
  box(
    stroke:   sk,
    radius:   s.radius,
    inset:    s.inset,
    outset:   s.outset,
    baseline: s.baseline,
    text(size: s.size, tracking: s.kern, body),
  )
  h(half)
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

// 与 `quan` 同样的渲染逻辑（自然尺寸画圈，行为一致）。
// Same rendering logic as `quan` — natural box sizing, matching body output.
#let _quan-marker(n) = context {
  let cfg = _quan-state.get()
  let g = _circled-digit(n)
  if g == none or n not in cfg.digits {
    _drawn(str(n), value: n)
  } else {
    g
  }
}

/// 全局将脚注序号改为带圈数字。样式跟随 `quan-init` 与 `quan-style`。\
/// Globally replace footnote markers with circled numbers.
/// Styling follows `quan-init` and `quan-style`.
///
/// 实现细节：正文 marker 和条目编号默认都被 `super` 包裹，而 `super` 会压扁
/// 画圈的横纵比，因此自行渲染，并保留内建脚注的各项行为：
/// - marker 用 `move` 上移（不撑高所在行）；
/// - marker 前置弱间距，吃掉前面的空格、避免 marker 被孤立断行；
/// - 引用式脚注（`#footnote(<label>)`）解析到被引脚注本体的编号；
/// - marker 与条目编号互为超链接；
/// - 条目缩进跟随 `set footnote.entry(indent: ..)`。
/// Implementation: both the inline marker and the entry number are wrapped
/// in `super` by default, which squashes drawn circles, so both are rendered
/// manually while preserving the built-in behaviours: the marker is raised
/// with `move` (no line-height inflation) and preceded by weak spacing
/// (eats the space before it, prevents orphaned line breaks); label
/// references (`#footnote(<label>)`) resolve to the referenced note's
/// number; marker and entry number hyperlink to each other; and the entry
/// respects `set footnote.entry(indent: ..)`.
///
/// 注意：编号形式由本包接管，`set footnote(numbering: ..)` 在
/// `quan-footnote` 下不生效。规则须置于文档开头（Typst 从页面起点解析
/// 脚注条目样式，规则晚于本页内容时条目保持默认样式）。
/// Note: numbering is taken over by this package; `set footnote(numbering: ..)`
/// has no effect under `quan-footnote`. Apply the rule before any content —
/// Typst resolves footnote-entry styles from the start of the page, so entries
/// on a page whose content precedes the rule keep the default style.
///
/// 用法 / Usage:\
///   `#show: quan-footnote`
#let quan-footnote(body) = {
  // 正文 marker / inline marker
  show footnote: it => context {
    // 引用式脚注解析到被引脚注本体 / label form resolves to the referenced note
    let loc = if type(it.body) == label {
      let hits = query(it.body)
      assert(hits.len() > 0,
        message: "quan: footnote label " + repr(it.body) + " not found")
      hits.first().location()
    } else {
      it.location()
    }
    let n = counter(footnote).at(loc).first()
    // 链接目标：对应的脚注条目（找不到时退回脚注本体位置）
    // link target: the matching entry (falls back to the note's own location)
    let entries = query(footnote.entry).filter(e => e.note.location() == loc)
    let dest = if entries.len() > 0 { entries.first().location() } else { loc }
    h(0pt, weak: true)
    link(dest, box(text(size: 0.7em, move(dy: -0.4em, _quan-marker(n)))))
  }
  // 脚注条目 / entry
  show footnote.entry: it => context {
    let n = counter(footnote).at(it.note.location()).first()
    h(it.indent)
    link(it.note.location(), _quan-marker(n))
    h(0.5em)
    it.note.body
  }
  body
}
