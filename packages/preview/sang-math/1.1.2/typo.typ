// ================================================================
// SANG-TYPST — lớp hoàn thiện kiểu chữ toán chuẩn LaTeX cho đề Việt Nam
// Lõi dùng chung: gói @local/sang-typst và sang-math ≥ 1.1.1 (file typo.typ).
// Sửa ở typst-pkg-sang-typst/src/typo.typ rồi chép sang sang-math để hai bản giống hệt.
//
// Dùng: #show: sang-typst   — đặt SAU CÙNG trong các show rule (sau template,
//       sau #show math.frac: math.display). Không bật thì không đổi gì.
// ================================================================

#let _seq = [].func()
#let _symbol = $,$.body.func()
#let _digits = regex("^\d+$")
#let _signs = ("−", "-", "+", "±")
#let _opens = ("(", "[", "{", "⟨")
#let _closes = (")", "]", "}", "⟩")

// Chữ số là `text`; dấu , ≤ ≥ ± ( ) trong toán là `symbol` — cả hai có trường text
#let _is-atom(c) = type(c) == content and (c.func() == text or c.func() == _symbol)
#let _is-text(c, s) = _is-atom(c) and c.text == s
#let _is-digits(c) = type(c) == content and c.func() == text and c.text.match(_digits) != none

// ── Phân số cỡ chỉ số (giống \frac trong số mũ/cận của TeX) ─────────
// Tử/mẫu cỡ scriptscript, gạch ngang nằm đúng trục toán của dòng chỉ số.
// Dựng bằng box nên không bị `show math.frac: math.display` phóng to.
#let sfrac(n, d) = {
  set text(top-edge: "bounds", bottom-edge: "bounds")
  context {
    let nb = box(math.equation(math.sscript(n)))
    let db = box(math.equation(math.sscript(d)))
    let w = calc.max(measure(nb).width, measure(db).width) + 0.12em
    let th = 0.035em // độ dày gạch phân số (≈ default rule thickness)
    let gap = 0.12em
    let axis = 0.25em * 0.7 // trục toán ở cỡ chỉ số
    let top = box(width: w, align(center, nb))
    let st = block(stack(
      dir: ttb,
      spacing: gap,
      top,
      line(length: w, stroke: th),
      box(width: w, align(center, db)),
    ))
    let bar = measure(top).height + gap + th / 2
    box(baseline: measure(st).height - bar - axis, st)
  }
}

// ── Dựng lại phần tử toán ───────────────────────────────────────────
// Tên tham số vị trí của từng phần tử; "x?" = vị trí tùy chọn, "..x" = biến số.
#let _positional = (
  frac: ("num", "denom"),
  attach: ("base",),
  lr: ("body",),
  accent: ("base", "accent"),
  class: ("class", "body"),
  cases: ("..children",),
  vec: ("..children",),
  mat: ("..rows",),
  binom: ("upper", "..lower"),
  overbrace: ("body", "annotation?"),
  underbrace: ("body", "annotation?"),
  overbracket: ("body", "annotation?"),
  underbracket: ("body", "annotation?"),
  overparen: ("body", "annotation?"),
  underparen: ("body", "annotation?"),
  overline: ("body",),
  underline: ("body",),
  abs: ("body",),
  norm: ("body",),
  floor: ("body",),
  ceil: ("body",),
  round: ("body",),
  cancel: ("body",),
  stretch: ("body",),
  limits: ("body",),
  scripts: ("body",),
  sequence: ("..children",),
)

// Ánh xạ fn lên mọi nội dung con rồi dựng lại; phần tử lạ giữ nguyên.
#let _map-children(c, fn) = {
  let f = c.func()
  if f == _seq { return c.children.map(fn).join() }
  if repr(f) == "root" {
    // root(index, radicand): index là vị trí tùy chọn đứng trước nên phải truyền cả hai
    let idx = c.at("index", default: none)
    return math.root(if idx == none { none } else { fn(idx) }, fn(c.radicand))
  }
  let spec = _positional.at(repr(f), default: none)
  if spec == none { return c }
  let fields = c.fields()
  let rec(v) = if type(v) == content { fn(v) } else if type(v) == array { v.map(rec) } else { v }
  let pos = ()
  for p in spec {
    if p.starts-with("..") {
      let v = fields.remove(p.slice(2), default: ())
      pos += if type(v) == array { v.map(rec) } else { (rec(v),) }
    } else if p.ends-with("?") {
      let key = p.slice(0, -1)
      if key in fields and fields.at(key) != none { pos.push(rec(fields.remove(key))) }
      let _ = fields.remove(key, default: none)
    } else {
      pos.push(rec(fields.remove(p)))
    }
  }
  let _ = fields.remove("label", default: none)
  // attach: duyệt cả chỉ số trên/dưới
  for k in ("t", "b", "tl", "bl", "tr", "br") {
    if k in fields and type(fields.at(k)) == content { fields.insert(k, fn(fields.at(k))) }
  }
  f(..pos, ..fields)
}

// ── Phân số trong chỉ số → sfrac ──────────────────────────────────────
#let _shrink-fracs(c) = {
  if type(c) != content { return c }
  if repr(c.func()) == "frac" and c.at("style", default: "vertical") == "vertical" {
    return sfrac(_shrink-fracs(c.num), _shrink-fracs(c.denom))
  }
  _map-children(c, _shrink-fracs)
}

// ── Dấu phẩy thập phân (giống gói icomma của LaTeX) ─────────────────
// "0,75" → 0,75 (không giãn sau dấu phẩy). Viết "1, 2" (có khoảng trắng)
// khi là liệt kê. Dãy nhiều dấu phẩy (2,1,3) và cặp (1,2) giữ là liệt kê.
#let _decimal(children) = {
  // bỏ dấu ngoặc hai đầu để nhận ra cặp (1,2)
  // Chỉ coi là cặp khi có ngoặc bao quanh: (1,2) ; còn $0,75$ đứng một mình là số thập phân
  let n0 = children.len()
  if (
    n0 == 5 and _is-atom(children.first()) and children.first().text in _opens
      and _is-atom(children.last()) and children.last().text in _closes
      and _is-digits(children.at(1)) and _is-text(children.at(2), ",") and _is-digits(children.at(3))
  ) {
    return children
  }
  let n = children.len()
  let out = children
  for i in range(1, calc.max(n - 1, 1)) {
    if not _is-text(children.at(i), ",") { continue }
    if not (_is-digits(children.at(i - 1)) and _is-digits(children.at(i + 1))) { continue }
    // Có dấu phẩy ngay trước số bên trái (bỏ qua một dấu ±) → là liệt kê
    let j = i - 2
    if j >= 0 and _is-atom(children.at(j)) and children.at(j).text in _signs { j -= 1 }
    if j >= 0 and _is-text(children.at(j), ",") { continue }
    // Có dấu phẩy ngay sau số bên phải → là liệt kê
    if i + 2 < n and _is-text(children.at(i + 2), ",") { continue }
    out.at(i) = math.class("normal", [,])
  }
  out
}

#let _fix-decimal(c) = {
  if type(c) != content { return c }
  if c.func() == _seq { return _decimal(c.children.map(_fix-decimal)).join() }
  if repr(c.func()) == "lr" and type(c.body) == content and c.body.func() == _seq {
    let named = if c.has("size") { (size: c.size) } else { (:) }
    return math.lr(_decimal(c.body.children.map(_fix-decimal)).join(), ..named)
  }
  _map-children(c, _fix-decimal)
}

// ── Bộ font kiểu LaTeX ─────────────────────────────────────────────
#let _font-presets = (
  // Giống LaTeX mặc định (Latin Modern / vntex)
  latex: (text: ("New Computer Modern",), math: ("New Computer Modern Math",)),
  // Giống \usepackage{newtxtext,newtxmath}: chữ Times + toán kiểu Times
  times: (text: ("Times New Roman", "Times"), math: ("STIX Two Math", "New Computer Modern Math")),
  // Giống STIX/XITS
  stix: (text: ("STIX Two Text", "Times New Roman"), math: ("STIX Two Math",)),
)

// ── Định dạng số trong toán ───────────────────────────────────────
// "0.5" → "0,5" (point-to-comma); "1234567" → "1 234 567" (group-digits, ≥ 5 chữ số)
#let _group(int, sep: "\u{2009}", min: 5) = {
  if int.len() < min { return int }
  let groups = ()
  let k = int.len()
  while k > 3 {
    groups.insert(0, int.slice(k - 3, k))
    k -= 3
  }
  groups.insert(0, int.slice(0, k))
  groups.join(sep)
}

// ── Cấu hình dựng sẵn ─────────────────────────────────────────────
// Chỉ cần nhớ: #show: sang-typst  hoặc  #show: sang-typst.with(preset: "latex")
#let _presets = (
  // Giữ nguyên giao diện sang-math, chỉ sửa lỗi kiểu chữ toán
  chuan: (
    decimal-comma: true, point-to-comma: true, group-digits: false, script-frac: false,
    ineq: "keep", fonts: "keep", leading: "keep", eq-number: false, display-skip: auto,
  ),
  // Như một tài liệu LaTeX: Latin Modern, ⩽ ⩾, dòng đều, đánh số PT có nhãn
  latex: (
    decimal-comma: true, point-to-comma: true, group-digits: true, script-frac: false,
    ineq: "slant", fonts: "latex", leading: "latex", eq-number: true, display-skip: 0.7em,
  ),
  // Như LaTeX + newtxtext/newtxmath: chữ Times, toán STIX Two
  times: (
    decimal-comma: true, point-to-comma: true, group-digits: true, script-frac: false,
    ineq: "slant", fonts: "times", leading: "latex", eq-number: true, display-skip: 0.7em,
  ),
)

// ── Template chính ─────────────────────────────────────────────────
// preset:         "chuan" (mặc định) | "latex" | "times" — mọi tùy chọn bên dưới
//                 để auto sẽ lấy theo preset; ghi rõ tùy chọn nào thì tùy chọn đó thắng
// decimal-comma:  0,75 không giãn sau dấu phẩy (icomma)
// point-to-comma: viết $0.5$ in ra 0,5 — dùng trong đối số heva/hoac/cases,
//                 nơi dấu phẩy là dấu ngăn tham số
// group-digits:   số nguyên từ 5 chữ số trong toán nhóm 3: 1 234 567 (siunitx)
// script-frac:    false giữ phân số to đẹp như Equation/dfrac;
//                 true thu nhỏ phân số trong số mũ/cận như TeX gốc
// ineq:           "keep" (≤ ≥) | "slant" (⩽ ⩾ như \leqslant hay dùng ở VN)
// fonts:          "keep" | "latex" | "times" | "stix"
// leading:        "keep" | "latex" — khoảng cách hai đường cơ sở cố định 1.2em
//                 như \baselineskip (dòng chỉ giãn khi công thức cao hơn)
// eq-number:      true → chỉ phương trình đứng riêng CÓ NHÃN <eq:...> được đánh số (1), (2)
// display-skip:   auto | độ dài — khoảng trống trên/dưới công thức đứng riêng dòng
#let sang-typst(
  body,
  preset: "chuan",
  decimal-comma: auto,
  point-to-comma: auto,
  group-digits: auto,
  script-frac: auto,
  ineq: auto,
  fonts: auto,
  leading: auto,
  eq-number: auto,
  display-skip: auto,
) = {
  assert(preset in _presets, message: "sang-typst: preset là \"chuan\", \"latex\" hoặc \"times\"")
  let base = _presets.at(preset)
  let pick(v, key) = if v == auto { base.at(key) } else { v }
  let decimal-comma = pick(decimal-comma, "decimal-comma")
  let point-to-comma = pick(point-to-comma, "point-to-comma")
  let group-digits = pick(group-digits, "group-digits")
  let script-frac = pick(script-frac, "script-frac")
  let ineq = pick(ineq, "ineq")
  let fonts = pick(fonts, "fonts")
  let leading = pick(leading, "leading")
  let eq-number = pick(eq-number, "eq-number")
  let display-skip = pick(display-skip, "display-skip")
  assert(ineq in ("keep", "slant"), message: "sang-typst: ineq là \"keep\" hoặc \"slant\"")
  assert(fonts in ("keep", "latex", "times", "stix"), message: "sang-typst: fonts là keep|latex|times|stix")
  assert(leading in ("keep", "latex"), message: "sang-typst: leading là keep|latex")

  show: it => if fonts == "keep" { it } else {
    let p = _font-presets.at(fonts)
    set text(font: p.text)
    show math.equation: set text(font: p.math)
    it
  }
  show: it => if leading == "keep" { it } else {
    // 0.8em + 0.2em = 1em thân chữ; + 0.2em leading = 1.2em giữa hai đường cơ sở
    set text(top-edge: 0.8em, bottom-edge: -0.2em)
    set par(leading: 0.2em, spacing: 0.7em)
    it
  }
  show: it => if display-skip == auto { it } else {
    show math.equation.where(block: true): set block(above: display-skip, below: display-skip)
    it
  }
  show: it => if not eq-number { it } else {
    set math.equation(numbering: "(1)")
    it
  }
  // Phân số trong chỉ số: show rule trên attach/root nên lọt cả vào heva/hoac
  show math.attach: it => {
    if not script-frac { return it }
    let new = it.fields()
    let _ = new.remove("label", default: none)
    let base = new.remove("base")
    for k in ("t", "b", "tl", "bl", "tr", "br") {
      if k in new and type(new.at(k)) == content { new.insert(k, _shrink-fracs(new.at(k))) }
    }
    let out = math.attach(base, ..new)
    if out == it { it } else { out }
  }
  show math.root: it => {
    let idx = it.at("index", default: none)
    if not script-frac or idx == none { return it }
    let new-idx = _shrink-fracs(idx)
    if new-idx == idx { it } else { math.root(new-idx, it.radicand) }
  }
  show math.equation: it => {
    show "≤": it => if ineq == "slant" { sym.lt.eq.slant } else { it }
    show "≥": it => if ineq == "slant" { sym.gt.eq.slant } else { it }
    show regex("^\d+(\.\d+)?$"): it => {
      let parts = it.text.split(".")
      let int = if group-digits { _group(parts.at(0)) } else { parts.at(0) }
      let out = if parts.len() > 1 { int + (if point-to-comma { "," } else { "." }) + parts.at(1) } else { int }
      if out == it.text { it } else { out }
    }
    // Không dùng `return` ở đây: return bỏ qua các show rule vừa đặt ở trên.
    // Phương trình có nhãn giữ nguyên để không vỡ tham chiếu @eq.
    let labeled = it.has("label")
    let b = if decimal-comma and not labeled { _fix-decimal(it.body) } else { it.body }
    // eq-number: phương trình không nhãn thì không đánh số (trả lại số đã đếm)
    let drop-number = eq-number and it.block and not labeled and it.numbering != none
    if b == it.body and not drop-number { it } else {
      let f = it.fields()
      let _ = f.remove("body")
      if drop-number {
        let _ = f.remove("numbering", default: none)
        counter(math.equation).update(n => n - 1)
        math.equation(..f, numbering: none, b)
      } else if it.numbering != none {
        // dựng lại PT đã đánh số: trừ lần đếm của bản gốc để không đếm đôi
        counter(math.equation).update(n => n - 1)
        math.equation(..f, b)
      } else {
        math.equation(..f, b)
      }
    }
  }
  body
}

// ── Số và đơn vị (giống siunitx: \num, \qty) ───────────────────────
// #num(1234567.5) → 1 234 567,5 ; #num("0,125") → 0,125
// Nhóm 3 chữ số bằng khoảng trắng mảnh khi phần nguyên có từ 5 chữ số.
#let num(value, decimal: ",", group: "\u{2009}", min-digits: 5) = {
  let s = if type(value) == str { value } else { str(value) }
  s = s.replace(".", ",").replace("-", "−")
  let sign = ""
  if s.starts-with("−") or s.starts-with("+") {
    sign = s.first()
    s = s.slice(sign.len())
  }
  let parts = s.split(",")
  let int = _group(parts.at(0), sep: group, min: min-digits)
  let out = sign + int
  if parts.len() > 1 { out += decimal + parts.slice(1).join("") }
  math.equation(math.upright(out))
}

// #qty(5, "cm^2") → 5 cm² ; #qty(9.8, "m/s^2") ; #qty(30, "°")
#let _unit(u) = {
  if type(u) == content { return math.upright(u) }
  let m = u.match(regex("^(.*?)\^(-?\d+)$"))
  if m != none { math.attach(math.upright(m.captures.at(0)), tr: m.captures.at(1)) } else { math.upright(u) }
}
#let qty(value, unit) = {
  if type(unit) == str and unit in ("°", "%") { return [#num(value)#math.equation(math.upright(unit))] }
  let pieces = if type(unit) == str { unit.split("/").map(_unit) } else { (_unit(unit),) }
  [#num(value)#h(0.1667em)#math.equation(pieces.join(math.upright("/")))]
}

// ── Ký hiệu Việt Nam ───────────────────────────────────────────────
#let tg = math.op("tg")
#let cotg = math.op("cotg")
#let arctg = math.op("arctg")
#let arccotg = math.op("arccotg")
// Cung AB (\wideparen), góc ABC (\widehat)
#let cung(body) = math.overparen(body)
#let goc(body) = math.hat(body)
