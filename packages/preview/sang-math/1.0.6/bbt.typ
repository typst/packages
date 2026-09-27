#import "@preview/cetz:0.5.2": canvas, draw

// Helper macro bổ sung giá trị trung gian chuẩn tkz-tab (\tkzTabVal)
#let tab-val(from-col, to-col, pos: 0.5, x: none, y: none, stroke: (dash: "dashed", paint: rgb("#dc2626"), thickness: 0.8pt), mark: "stealth", y-offset: 0, start-y: none, end-y: none) = {
  (
    from-col: from-col,
    to-col: to-col,
    pos: pos,
    x: x,
    y: y,
    stroke: stroke,
    mark: mark,
    y-offset: y-offset,
    start-y: start-y,
    end-y: end-y,
  )
}

#let bbtv2(
  var: $x$,
  var2: none,
  var2-vals: (),
  u-vals: (),
  der: $y'$,
  der2: none,
  func: $y$,
  x-vals: ($-oo$, $0$, $+oo$),
  d-signs: ($-$, $0$, $+$),
  d2-signs: (),
  v-vals: ($+oo$, $0$, $+oo$),
  shade: (),
  w1: 1.2,
  w2: auto,
  h1: 0.7,
  h2: 0.7,
  h3: auto,
  stroke: 0.8pt,
  arrow-stroke: none,
  arrow-mark: "stealth",
  node-pad: 0.18,
  arr-shorten: 3pt,
  guides: (),
  annotations: (),
  overlay: none,
) = context {
  let __clr = text.fill
  let main-stroke = if stroke == none { 0.8pt + __clr } else { stroke }
  let arr-stroke = if arrow-stroke != none { arrow-stroke } else { main-stroke }

  let v2-list = if var2-vals.len() > 0 { var2-vals } else { u-vals }

  let has-var2 = var2 != none
  let has-der2 = der2 != none
  let h-var = if has-var2 { h1 * 2 } else { h1 }
  let h-der = if has-der2 { h2 * 2 } else { h2 }

  let n = x-vals.len()

  let w2-calc = if w2 == auto or w2 == 6.8 {
    let min-col-w = 2.2
    let auto-w = (n - 1) * min-col-w
    calc.max(6.8, auto-w)
  } else { w2 }

  let sign-of(s) = {
    let r = repr(s)
    if s == "+" or s == $+$ or r.contains("+") { "+" }
    else if s == "-" or s == $-$ or r.contains("−") or r.contains("-") { "-" }
    else if s == "||" or r.contains("||") or r.contains("‖") or r.contains("parallel") { "||" }
    else if s == "" or s == [] or s == none or r == "\"\"" or r == "[]" or r == "none" or s == " " { "" }
    else { "0" }
  }

  let is-pos-inf(v) = { let r = repr(v); (r.contains("oo") or r.contains("∞")) and not (r.contains("-") or r.contains("−")) }
  let is-neg-inf(v) = { let r = repr(v); (r.contains("oo") or r.contains("∞")) and (r.contains("-") or r.contains("−")) }

  let ranks = ()
  let cur = 0
  ranks.push((cur,))
  for i in range(n - 1) {
    let sign-idx = 2 * i
    let sign = sign-of(d-signs.at(sign-idx, default: ""))
    if sign == "" or sign == "0" {
      let v1 = v-vals.at(i, default: "")
      let v2 = v-vals.at(i + 1, default: "")
      let v1-val = if type(v1) == array and v1.len() > 1 { v1.at(1) } else if type(v1) == array { v1.at(0) } else { v1 }
      let v2-val = if type(v2) == array { v2.at(0) } else { v2 }
      if is-pos-inf(v2-val) or is-neg-inf(v1-val) { sign = "+" }
      else if is-neg-inf(v2-val) or is-pos-inf(v1-val) { sign = "-" }
    }
    if sign == "+" { cur += 1 } else if sign == "-" { cur -= 1 }
    let next_idx = 2 * i + 1
    if next_idx < d-signs.len() and sign-of(d-signs.at(next_idx, default: "")) == "||" {
      let val = v-vals.at(i + 1, default: "")
      if type(val) == array {
        let ns = if next_idx + 1 < d-signs.len() { sign-of(d-signs.at(next_idx + 1, default: "")) } else { "+" }
        let rL = cur
        let rR = if ns == "-" { rL + 2 } else { rL - 2 }
        cur = rR
        ranks.push((rL, rR))
      } else { ranks.push((cur,)) }
    } else { ranks.push((cur,)) }
  }

  let flat-r = ()
  for r in ranks { for v in r { if v != none { flat-r.push(v) } } }
  let min-r = if flat-r.len() > 0 { calc.min(..flat-r) } else { 0 }
  let max-r = if flat-r.len() > 0 { calc.max(..flat-r) } else { 0 }
  let rank-span = max-r - min-r

  let h3-calc = if h3 == auto or h3 == 1.8 {
    let base = if rank-span >= 2 { 2.5 } else { 2.0 }
    let has-tall = v-vals.any(v => {
      if type(v) == array {
        v.any(sub => {
          let r = repr(sub)
          r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
        })
      } else {
        let r = repr(v)
        r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
      }
    })
    if has-tall { base + 0.6 } else { base }
  } else { h3 }

  let th = h-var + h-der + h3-calc

  canvas({
    import draw: *
    let tw = w1 + w2-calc

    let x-pos = ()
    for i in range(n) {
      let px = w1 + 0.6 + (w2-calc - 1.2) * i / (n - 1)
      x-pos.push(px)
    }

    rect((0, 0), (tw, -th), stroke: main-stroke)
    line((0, -h-var), (tw, -h-var), stroke: main-stroke)
    line((0, -h-var - h-der), (tw, -h-var - h-der), stroke: main-stroke)
    line((w1, 0), (w1, -th), stroke: main-stroke)

    if has-var2 { line((0, -h1), (tw, -h1), stroke: main-stroke) }
    if has-der2 { line((0, -h-var - h2), (tw, -h-var - h2), stroke: main-stroke) }

    for s in shade {
      let idxL = s.at(0, default: 0)
      let idxR = s.at(1, default: 0)
      if idxL < x-pos.len() and idxR < x-pos.len() {
        let xL = x-pos.at(idxL)
        let xR = x-pos.at(idxR)
        rect((xL, -h-var), (xR, -th), fill: rgb("#f8fafc"), stroke: none)
        let step = 0.22
        let H = th - h-var
        let x0 = xL - H + 0.1
        while x0 <= xR - 0.1 {
          let xA = calc.max(xL, x0)
          let xB = calc.min(xR, x0 + H)
          if xA < xB {
            let yA = -h-var - (xA - x0)
            let yB = -h-var - (xB - x0)
            line((xA, yA), (xB, yB), stroke: 0.45pt + rgb("#64748b"))
          }
          x0 += step
        }
        line((xL, -h-var - h-der), (xR, -h-var - h-der), stroke: main-stroke)
      }
    }

    if has-var2 {
      content((w1 / 2, -h1 / 2), var)
      content((w1 / 2, -h1 - h1 / 2), var2)
    } else {
      content((w1 / 2, -h1 / 2), var)
    }

    if has-der2 {
      content((w1 / 2, -h-var - h2 / 2), der)
      content((w1 / 2, -h-var - h2 - h2 / 2), der2)
    } else {
      content((w1 / 2, -h-var - h2 / 2), der)
    }

    content((w1 / 2, -h-var - h-der - h3-calc / 2), func)

    let render-sign(s) = {
      let sig = sign-of(s)
      if sig == "-" { $-$ } else if sig == "+" { $+$ } else if sig == "0" { $0$ } else if sig == "||" { none } else if sig == "" { none } else { s }
    }

    for i in range(n) {
      content((x-pos.at(i), -h1 / 2), x-vals.at(i), name: "x-" + str(i))
      if has-var2 and i < v2-list.len() {
        content((x-pos.at(i), -h1 - h1 / 2), v2-list.at(i))
      }
    }

    for i in range(n) {
      if i > 0 and i < n - 1 {
        let sign-idx = 2 * i - 1
        if sign-of(d-signs.at(sign-idx, default: "")) == "||" {
          let px = x-pos.at(i)
          let is-double = type(v-vals.at(i, default: "")) == array or v-vals.at(i, default: "") == "||" or v-vals.at(i, default: "") == none or (type(v-vals.at(i, default: "")) == content and (repr(v-vals.at(i, default: "")).contains("|") or repr(v-vals.at(i, default: "")).contains("||")))
          if is-double {
            line((px - 0.05, -h-var), (px - 0.05, -th), stroke: main-stroke)
            line((px + 0.05, -h-var), (px + 0.05, -th), stroke: main-stroke)
          } else {
            line((px - 0.05, -h-var), (px - 0.05, -h-var - h-der), stroke: main-stroke)
            line((px + 0.05, -h-var), (px + 0.05, -h-var - h-der), stroke: main-stroke)
          }
        } else {
          content((x-pos.at(i), -h-var - h2 / 2), render-sign(d-signs.at(sign-idx, default: "")))
        }
        if has-der2 and d2-signs.len() > sign-idx {
          content((x-pos.at(i), -h-var - h2 - h2 / 2), render-sign(d2-signs.at(sign-idx, default: "")))
        }
      }
      if i < n - 1 {
        let is-shaded = false
        for s in shade { if i >= s.at(0, default: 0) and i < s.at(1, default: 0) { is-shaded = true } }
        if not is-shaded {
          content(((x-pos.at(i) + x-pos.at(i + 1)) / 2, -h-var - h2 / 2), render-sign(d-signs.at(2 * i, default: "")))
          if has-der2 and d2-signs.len() > 2 * i {
            content(((x-pos.at(i) + x-pos.at(i + 1)) / 2, -h-var - h2 - h2 / 2), render-sign(d2-signs.at(2 * i, default: "")))
          }
        }
      }
    }

    let y-top = -h-var - h-der - 0.35
    let y-bot = -th + 0.35

    let map-y-node(r, val) = {
      if is-pos-inf(val) { return y-top }
      if is-neg-inf(val) { return y-bot }
      if max-r == min-r { (y-top + y-bot) / 2 } else { y-bot + (r - min-r) / (max-r - min-r) * (y-top - y-bot) }
    }

    for i in range(n) {
      let rv = ranks.at(i)
      let val = v-vals.at(i, default: "")
      let px = x-pos.at(i)
      if rv.len() == 1 {
        let v-text = if type(val) == array { val.at(0) } else { val }
        let y = map-y-node(rv.at(0), v-text)
        if val != "" and val != none {
          content((px, y), v-text, name: "v" + str(i), padding: node-pad, fill: white)
        }
      } else {
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let yL = map-y-node(rv.at(0), vL)
        let yR = map-y-node(rv.at(1), vR)
        let off = 0.15
        if vL != "" and vL != none { content((px - off, yL), vL, name: "v" + str(i) + "L", padding: node-pad, anchor: "east", fill: white) }
        if vR != "" and vR != none { content((px + off, yR), vR, name: "v" + str(i) + "R", padding: node-pad, anchor: "west", fill: white) }
      }
    }

    let node-anchors = ()
    for i in range(n) {
      let rv = ranks.at(i)
      let val = v-vals.at(i, default: "")
      let px = x-pos.at(i)
      if rv.len() == 1 {
        let v-text = if type(val) == array { val.at(0) } else { val }
        let y = map-y-node(rv.at(0), v-text)
        if val != "" and val != none {
          node-anchors.push(("v" + str(i), "v" + str(i)))
        } else {
          node-anchors.push(((px, y), (px, y)))
        }
      } else {
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let yL = map-y-node(rv.at(0), vL)
        let yR = map-y-node(rv.at(1), vR)
        let off = 0.15
        let aL = if vL == "" or vL == none { (px - off, yL) } else { "v" + str(i) + "L" }
        let aR = if vR == "" or vR == none { (px + off, yR) } else { "v" + str(i) + "R" }
        node-anchors.push((aL, aR))
      }
    }

    for i in range(n - 1) {
      let is-shaded = false
      for s in shade { if i >= s.at(0, default: 0) and i < s.at(1, default: 0) { is-shaded = true } }
      if not is-shaded {
        let s = node-anchors.at(i).at(1)
        let e = node-anchors.at(i + 1).at(0)
        if s != none and e != none {
          let mark-spec = (end: arrow-mark, fill: __clr)
          line(s, e, mark: mark-spec, stroke: arr-stroke, shorten-end: arr-shorten)
        }
      }
    }

    // Process guides / custom extra arrows:
    let all-items = ()
    for g in guides { all-items.push(g) }
    for a in annotations { all-items.push(a) }

    for item in all-items {
      let px = none
      let py = none
      let custom-start-y = none
      let custom-end-y = none
      let y-off = 0
      let label = none
      let x-val-text = none
      let item-stroke = (dash: "dashed", paint: rgb("#dc2626"), thickness: 0.8pt)
      let item-mark = "stealth"

      if type(item) == int {
        if item >= 0 and item < n {
          px = x-pos.at(item)
          custom-start-y = -h1 - 0.15
        }
      } else if type(item) == dictionary {
        if "stroke" in item { item-stroke = item.stroke }
        if "mark" in item { item-mark = item.mark }
        if "label" in item { label = item.label }
        if "y" in item { label = item.y }
        if "val" in item { label = item.val }
        if "x-label" in item { x-val-text = item.x-label }
        if "x" in item { x-val-text = item.x }
        if "y-offset" in item { y-off = item.y-offset }
        if "start-y" in item { custom-start-y = item.start-y }
        if "end-y" in item { custom-end-y = item.end-y }

        let iL = item.at("from-col", default: item.at("from-idx", default: none))
        let iR = item.at("to-col", default: item.at("to-idx", default: none))
        let pos = item.at("pos", default: 0.5)

        if iL != none and iR != none {
          if iL >= 0 and iL < n and iR >= 0 and iR < n {
            let xL = x-pos.at(iL)
            let xR = x-pos.at(iR)
            px = xL + pos * (xR - xL)

            let yL = map-y-node(ranks.at(iL).at(0), v-vals.at(iL, default: ""))
            let yR = map-y-node(ranks.at(iR).at(0), v-vals.at(iR, default: ""))
            py = yL + pos * (yR - yL) + y-off
          }
        } else if "idx" in item or "col" in item {
          let idx = item.at("col", default: item.at("idx", default: none))
          if idx != none and idx >= 0 and idx < n {
            px = x-pos.at(idx)
          }
        }
      }

      if px != none {
        if x-val-text != none {
          content((px, -h1 / 2), x-val-text, fill: white, padding: 0.08)
        }

        let yL = if custom-start-y != none { custom-start-y } else { -h1 - 0.15 }
        let target-y = if custom-end-y != none { custom-end-y } else if py != none { py } else { -h-var - h-der - h3-calc * 0.5 }

        let mark-spec = if item-mark != none and item-mark != "" { (end: item-mark, fill: item-stroke.at("paint", default: rgb("#dc2626"))) } else { none }

        let arrow-tip-y = if label != none and custom-end-y == none { target-y + 0.28 } else { target-y }

        line((px, yL), (px, arrow-tip-y), stroke: item-stroke, mark: mark-spec)

        if label != none {
          content((px, target-y), label, fill: white, padding: 0.25)
        }
      }
    }

    if overlay != none {
      overlay((
        x-pos: x-pos,
        h1: h1, h2: h2, h3: h3-calc,
        h-var: h-var, h-der: h-der, th: th,
        w1: w1, w2: w2-calc, tw: tw,
        y-top: y-top, y-bot: y-bot,
        draw: draw
      ))
    }
  })
}


// ==========================================
// MACRO BẢNG XÉT DẤU (DÀNH CHO XÉT DẤU y', BẤT PHƯƠNG TRÌNH)
// ==========================================
// bxd: Bảng xét dấu — hỗ trợ nhiều dòng func
// func có thể là content đơn hoặc mảng content (nhiều dòng)
// f-signs: mảng mảng nếu nhiều dòng, hoặc mảng đơn nếu 1 dòng
#let bxd(
  var: $x$,
  func: $f(x)$, // content đơn hoặc mảng content cho nhiều dòng
  x-vals: (),
  f-signs: (), // mảng đơn hoặc mảng-của-mảng cho nhiều dòng
  w1: 1.5, // chiều rộng cột nhãn trái — tăng nếu nhãn dài
  w2: 8,
  h1: 0.8,
  h2: 0.8, // chiều cao mỗi dòng dấu
) = context {
  let __clr = text.fill
  // Chuẩn hóa: nếu func là mảng thì nhiều dòng
  let funcs = if type(func) == array { func } else { (func,) }
  let signs-list = if type(f-signs) == array and f-signs.len() > 0 and type(f-signs.at(0)) == array {
    f-signs
  } else {
    (f-signs,)
  }
  let nrows = funcs.len()

  canvas(length: 1cm, {
    import draw: *
    let n = x-vals.len()
    let tw = w1 + w2
    let th = h1 + h2 * nrows

    rect((0, 0), (tw, -th), stroke: 1pt + __clr)
    line((0, -h1), (tw, -h1), stroke: 1pt + __clr)
    line((w1, 0), (w1, -th), stroke: 1pt + __clr)
    // Đường ngang giữa các dòng dấu (nếu > 1 dòng)
    for r in range(1, nrows) {
      line((0, -h1 - h2 * r), (tw, -h1 - h2 * r), stroke: 0.5pt + luma(150))
    }

    content((w1 / 2, -h1 / 2), var)
    // Nhãn cột trái cho từng dòng
    for r in range(nrows) {
      content((w1 / 2, -h1 - h2 * r - h2 / 2), funcs.at(r))
    }

    let x-pos = ()
    for i in range(n) {
      let px = w1 + 0.6 + (w2 - 1.2) * i / (n - 1)
      x-pos.push(px)
      content((px, -h1 / 2), x-vals.at(i))
    }

    let sign-of(s) = {
      let r = repr(s)
      if s == "+" or s == $+$ or r.contains("+") { "+" }
      else if s == "-" or s == $-$ or r.contains("−") or r.contains("-") { "-" }
      else if s == "||" or r.contains("||") or r.contains("‖") or r.contains("parallel") { "||" }
      else if s == "" or s == [] or s == none or r == "\"\"" or r == "[]" or r == "none" or s == " " { "" }
      else { "0" }
    }
    let render-sign(s) = {
      let sig = sign-of(s)
      if sig == "-" { $-$ } else if sig == "+" { $+$ } else if sig == "0" { $0$ } else if sig == "||" { none } else if sig == "" { none } else { s }
    }

    for r in range(nrows) {
      let row-signs = signs-list.at(r)
      let y-mid = -h1 - h2 * r - h2 / 2
      let y-top-row = -h1 - h2 * r
      let y-bot-row = -h1 - h2 * r - h2
      for i in range(n) {
        if i > 0 and i < n - 1 {
          let sign-idx = 2 * i - 1
          if row-signs.len() > sign-idx and sign-of(row-signs.at(sign-idx)) == "||" {
            let px = x-pos.at(i)
            line((px - 0.05, y-top-row), (px - 0.05, y-bot-row), stroke: 0.8pt + __clr)
            line((px + 0.05, y-top-row), (px + 0.05, y-bot-row), stroke: 0.8pt + __clr)
          } else if row-signs.len() > sign-idx {
            content((x-pos.at(i), y-mid), render-sign(row-signs.at(sign-idx)))
          }
        }
        if i < n - 1 {
          let mid-x = (x-pos.at(i) + x-pos.at(i + 1)) / 2
          content((mid-x, y-mid), render-sign(row-signs.at(2 * i)))
        }
      }
    }
  })
}

// ═══════════════════════════════════════════════════════════
// bxd-tich — Bảng xét dấu TÍCH/THƯƠNG, TỰ TÍNH dòng kết quả
// Giáo viên chỉ khai dấu từng thừa số; dòng f(x) được nhân dấu tự động.
// Thương dùng chung quy tắc dấu với tích: dấu(a/b) = dấu(a·b).
// factors: (( nhãn, (dấu-1, dấu-2, ...) ), ...) — mỗi dấu-i dài 2n-1 như bxd.
//   Ký hiệu: $+$ / $-$ / $0$ / "||" (không xác định) / [] (bỏ trống).
// ═══════════════════════════════════════════════════════════
#let bxd-tich(
  var: $x$,
  x-vals: (),
  factors: (),
  rows: (),
  result-label: $f(x)$,
  func: none,
  w1: 1.5,
  w2: 8,
  h1: 0.8,
  h2: 0.8,
) = {
  let factors = if factors.len() > 0 { factors } else { rows }
  let result-label = if func != none { func } else { result-label }
  let norm(s) = {
    let r = repr(s)
    if s == "+" or s == $+$ or r.contains("+") { "+" }
    else if s == "-" or s == $-$ or r.contains("−") or r.contains("-") { "-" }
    else if s == "||" or r.contains("||") or r.contains("parallel") { "||" }
    else if s == "" or s == [] or s == none or r == "\"\"" or r == "[]" or r == "none" { "" }
    else { "0" }
  }
  let mul2(a, b) = {
    if a == "||" or b == "||" { "||" }
    else if a == "0" or b == "0" { "0" }
    else if a == "" or b == "" { "" }
    else if a == b { "+" } else { "-" }
  }
  let nsig = if factors.len() > 0 { factors.at(0).at(1).len() } else { 0 }
  let result = ()
  for i in range(nsig) {
    let acc = "+"
    for f in factors { acc = mul2(acc, norm(f.at(1).at(i))) }
    result.push(
      if acc == "+" { $+$ } else if acc == "-" { $-$ } else if acc == "0" { $0$ } else if acc == "||" { $|$ } else { [] },
    )
  }
  let all-funcs = factors.map(f => f.at(0)) + (result-label,)
  let all-signs = factors.map(f => f.at(1)) + (result,)
  bxd(var: var, func: all-funcs, x-vals: x-vals, f-signs: all-signs, w1: w1, w2: w2, h1: h1, h2: h2)
}

#let bbbt(
  var: $x$,
  der: $y'$,
  func: $y$,
  x-vals: (),
  d-signs: (),
  v-vals: (),
  ranks: none,
  w1: 1.5,
  w2: 11.5,
  h1: auto,
  h2: 0.98, 
  h3: auto,
  node-pad: 0.18,
  arr-shorten: 3pt,
) = context {
  let __clr = text.fill
  // Tự động phân tích AST để điều chỉnh chiều cao nếu h1, h3 là auto
  let h1 = if h1 == auto {
    let has-tall = x-vals.any(x => {
      let r = repr(x)
      r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
    })
    if has-tall { 1.2 } else { 0.98 }
  } else { h1 }

  let h3 = if h3 == auto {
    let has-tall = v-vals.any(v => {
      if type(v) == array {
        let r = repr(v.at(0)) + repr(v.at(1))
        r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
      } else {
        let r = repr(v)
        r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
      }
    })
    if has-tall { 3.2 } else { 2.8 }
  } else { h3 }

  canvas(length: 1cm, {
    import draw: *

    let n = x-vals.len()
    let tw = w1 + w2
    let th = h1 + h2 + h3

    // Kẻ khung
    rect((0, 0), (tw, -th), stroke: 1pt + __clr)
    line((0, -h1), (tw, -h1), stroke: 1pt + __clr)
    line((0, -h1 - h2), (tw, -h1 - h2), stroke: 1pt + __clr)
    line((w1, 0), (w1, -th), stroke: 1pt + __clr)

    content((w1 / 2, -h1 / 2), var)
    content((w1 / 2, -h1 - h2 / 2), der)
    content((w1 / 2, -h1 - h2 - h3 / 2), func)

    let sign-of(s) = {
      let r = repr(s)
      if s == "+" or s == $+$ or r.contains("+") { "+" }
      else if s == "-" or s == $-$ or r.contains("−") or r.contains("-") { "-" }
      else if s == "||" or r.contains("||") or r.contains("‖") or r.contains("parallel") { "||" }
      else if s == "" or s == [] or s == none or r == "\"\"" or r == "[]" or r == "none" or s == " " { "" }
      else { "0" }
    }
    let render-sign(s) = {
      let sig = sign-of(s)
      if sig == "-" { $-$ } else if sig == "+" { $+$ } else if sig == "0" { $0$ } else if sig == "||" { none } else if sig == "" { none } else { s }
    }

    let x-pos = ()
    for i in range(n) {
      let px = w1 + 0.6 + (w2 - 1.2) * i / (n - 1)
      x-pos.push(px)
      content((px, -h1 / 2), x-vals.at(i))
    }

    let is-inf(v) = { if type(v) != content { false } else { repr(v).contains("oo") } }

    // Hàng 2: dấu đạo hàm
    for i in range(n) {
      if i > 0 and i < n - 1 {
        let sign-idx = 2 * i - 1
        if sign-of(d-signs.at(sign-idx)) == "||" {
          let px = x-pos.at(i)
          let is-double = type(v-vals.at(i)) == array or v-vals.at(i) == "||" or v-vals.at(i) == none or (type(v-vals.at(i)) == content and (repr(v-vals.at(i)).contains("|") or repr(v-vals.at(i)).contains("||")))
          if is-double {
            line((px - 0.05, -h1), (px - 0.05, -th), stroke: 0.8pt + __clr)
            line((px + 0.05, -h1), (px + 0.05, -th), stroke: 0.8pt + __clr)
          } else {
            line((px - 0.05, -h1), (px - 0.05, -h1 - h2), stroke: 0.8pt + __clr)
            line((px + 0.05, -h1), (px + 0.05, -h1 - h2), stroke: 0.8pt + __clr)
          }
        } else {
          content((x-pos.at(i), -h1 - h2 / 2), render-sign(d-signs.at(sign-idx)))
        }
      }
      if i < n - 1 {
        content(((x-pos.at(i) + x-pos.at(i + 1)) / 2, -h1 - h2 / 2), render-sign(d-signs.at(2 * i)))
      }
    }

    // Hàng 3: rank → map-y
    let ranks = if ranks != none {
      ranks.map(r => if type(r) == array { r } else { (r,) })
    } else {
      let computed = ()
      let cur = 0
      computed.push((cur,))
      for i in range(n - 1) {
        let sign = sign-of(d-signs.at(2 * i))
        if sign == "+" { cur += 1 } else if sign == "-" { cur -= 1 }
        let next_idx = 2 * i + 1
        if next_idx < d-signs.len() and sign-of(d-signs.at(next_idx)) == "||" {
          let val = v-vals.at(i + 1)
          if type(val) == array {
            let ns = if next_idx + 1 < d-signs.len() { sign-of(d-signs.at(next_idx + 1)) } else { "+" }
            let lr = cur
            cur = if ns == "-" { lr + 2 } else { lr - 2 }
            computed.push((lr, cur))
          } else { computed.push((cur,)) }
        } else { computed.push((cur,)) }
      }
      computed
    }
    let flat-r = ()
    for r in ranks { for v in r { flat-r.push(v) } }
    let min-r = calc.min(..flat-r)
    let max-r = calc.max(..flat-r)
    let y-top = -h1 - h2 - 0.5
    let y-bot = -th + 0.4
    let map-y(r) = {
      if max-r == min-r { (y-top + y-bot) / 2 } else { y-bot + (r - min-r) / (max-r - min-r) * (y-top - y-bot) }
    }

    // Vẽ labels
    for i in range(n) {
      let rv = ranks.at(i)
      let val = v-vals.at(i)
      let px = x-pos.at(i)
      if rv.len() == 1 {
        let y = map-y(rv.at(0))
        let v-text = if type(val) == array { val.at(0) } else { val }
        if not is-inf(v-text) and val != "" and val != none {
          content((px, y), v-text, name: "v" + str(i), padding: node-pad)
        }
      } else {
        let yL = map-y(rv.at(0))
        let yR = map-y(rv.at(1))
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let off = 0.15
        if not is-inf(vL) { content((px - off, yL), vL, name: "v" + str(i) + "L", padding: node-pad, anchor: "east") }
        if not is-inf(vR) { content((px + off, yR), vR, name: "v" + str(i) + "R", padding: node-pad, anchor: "west") }
      }
    }

    // Tính anchor (tách loop để tránh cetz/string join)
    let node-anchors = ()
    for i in range(n) {
      let rv = ranks.at(i)
      let val = v-vals.at(i)
      let px = x-pos.at(i)
      if rv.len() == 1 {
        let y = map-y(rv.at(0))
        let v-text = if type(val) == array { val.at(0) } else { val }
        if not is-inf(v-text) and val != "" and val != none {
          node-anchors.push(("v" + str(i), "v" + str(i)))
        } else {
          node-anchors.push(((px, y), (px, y)))
        }
      } else {
        let yL = map-y(rv.at(0))
        let yR = map-y(rv.at(1))
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let off = 0.15
        let aL = if is-inf(vL) { (px - off, yL) } else { "v" + str(i) + "L" }
        let aR = if is-inf(vR) { (px + off, yR) } else { "v" + str(i) + "R" }
        node-anchors.push((aL, aR))
      }
    }

    // Mũi tên
    for i in range(n - 1) {
      let s = node-anchors.at(i).at(1)
      let e = node-anchors.at(i + 1).at(0)
      if s != none and e != none {
        line(s, e, mark: (end: ">", fill: __clr), stroke: 0.8pt + __clr, shorten-end: arr-shorten)
      }
    }
  })
}
// Chuyên dùng cho các bài toán tối ưu (1 cực trị trên đoạn)
// ==========================================
#let bbt-opt(
  var: $x$,
  der: $y'$,
  func: $y$,
  x-vals: ($0$, $x_0$, $oo$),
  d-signs: ($-$, $0$, $+$),
  v-vals: ($oo$, $0$, $oo$),
  is-min: true, // true: cực tiểu (\/), false: cực đại (/\)
  w1: 1.5, // Chiều rộng cột nhãn
  w2: 7, // Chiều rộng cột nội dung
) = context {
  let __clr = text.fill
  canvas(length: 1cm, {
    import draw: *

    let h1 = 0.8
    let h2 = 0.8
    let h3 = 2.2
    let tw = w1 + w2
    let th = h1 + h2 + h3

    // Kẻ khung và các đường ngang, dọc
    rect((0, 0), (tw, -th), stroke: 1pt + __clr)
    line((0, -h1), (tw, -h1), stroke: 1pt + __clr)
    line((0, -h1 - h2), (tw, -h1 - h2), stroke: 1pt + __clr)
    line((w1, 0), (w1, -th), stroke: 1pt + __clr)

    // Nhãn các hàng
    content((w1 / 2, -h1 / 2), var)
    content((w1 / 2, -h1 - h2 / 2), der)
    content((w1 / 2, -h1 - h2 - h3 / 2), func)

    // Tọa độ x cho các cột nội dung
    let x1 = w1 + 0.6
    let x2 = w1 + w2 / 2
    let x3 = tw - 0.6

    // Hàng 1: x
    content((x1, -h1 / 2), x-vals.at(0))
    content((x2, -h1 / 2), x-vals.at(1))
    content((x3, -h1 / 2), x-vals.at(2))

    // Hàng 2: Đạo hàm
    content(((x1 + x2) / 2, -h1 - h2 / 2), d-signs.at(0))
    content((x2, -h1 - h2 / 2), d-signs.at(1))
    content(((x2 + x3) / 2, -h1 - h2 / 2), d-signs.at(2))

    // Hàng 3: Biến thiên
    let y-top = -h1 - h2 - 0.5
    let y-bot = -th + 0.4

    let (y1, y2, y3) = if is-min {
      (y-top, y-bot, y-top)
    } else {
      (y-bot, y-top, y-bot)
    }

    content((x1, y1), v-vals.at(0), name: "v1", padding: 0.1)
    content((x2, y2), v-vals.at(1), name: "v2", padding: 0.1)
    content((x3, y3), v-vals.at(2), name: "v3", padding: 0.1)

    // Vẽ mũi tên biến thiên
    line("v1", "v2", mark: (end: ">", fill: __clr), stroke: 0.8pt + __clr)
    line("v2", "v3", mark: (end: ">", fill: __clr), stroke: 0.8pt + __clr)
  })
}

// ═══════════════════════════════════════════════════════════
// BẢNG GIÁ TRỊ — Table đơn giản (không mũi tên)
// items: ((nhãn, giá trị), ...) → hiển thị dạng bảng 2 dòng
// Dùng cho: bảng giá trị hàm số, bảng xác suất, bảng tần số
// ═══════════════════════════════════════════════════════════
#let bang-gia-tri(
  labels: (),    // hàng tiêu đề cột
  rows: (),      // mảng các hàng, mỗi hàng là tuple giá trị
  accent: rgb("#0057b8"),
  scale: 1cm,
) = context {
  let __clr = text.fill
  canvas(length: scale, {
    import draw: *
    let ncols = labels.len()
    let nrows = rows.len() + 1
    let cw = 2.2
    let rh = 1.0
    let tw = ncols * cw
    let th = nrows * rh
    rect((0, 0), (tw, -th), stroke: 0.8pt + __clr )
    for i in range(1, ncols) {
      line((i * cw, 0), (i * cw, -th), stroke: 0.5pt + luma(180))
    }
    for j in range(1, nrows) {
      line((0, -j * rh), (tw, -j * rh), stroke: 0.5pt + luma(180))
    }
    for (i, lbl) in labels.enumerate() {
      content((i * cw + cw / 2, -rh / 2), text(weight: "bold")[#lbl])
    }
    for (r, row) in rows.enumerate() {
      for (c, val) in row.enumerate() {
        content((c * cw + cw / 2, -(r + 1) * rh - rh / 2), val)
      }
    }
  })
}

// ═══════════════════════════════════════════════════════════
// BẢNG PHÂN PHỐI — Dạng table 2 cột: X | P
// Dùng cho bảng phân phối xác suất, tần suất
// ═══════════════════════════════════════════════════════════
#let bang-phan-phoi(
  header: ($X$, $P$),
  items: (),     // ((x1, p1), (x2, p2), ...)
  accent: rgb("#0057b8"),
  scale: 1cm,
) = context {
  let __clr = text.fill
  canvas(length: scale, {
    import draw: *
    let n = items.len()
    let cw = 2.4
    let rh = 0.9
    let tw = 2 * cw
    let th = (n + 1) * rh
    rect((0, 0), (tw, -th), stroke: 0.8pt + __clr )
    line((cw, 0), (cw, -th), stroke: 0.5pt + luma(180))
    for j in range(1, n + 2) {
      line((0, -j * rh), (tw, -j * rh), stroke: 0.5pt + luma(180))
    }
    content((cw / 2, -rh / 2), text(weight: "bold")[#header.at(0)])
    content((cw + cw / 2, -rh / 2), text(weight: "bold")[#header.at(1)])
    for (i, item) in items.enumerate() {
      content((cw / 2, -(i + 1) * rh - rh / 2), item.at(0))
      content((cw + cw / 2, -(i + 1) * rh - rh / 2), item.at(1))
    }
  })
}

// ═══════════════════════════════════════════════════════════
// Ô CHÉO (diagonal-split cell) — Typst KHÔNG có sẵn, tự vẽ bằng place+line.
// Dùng cho ô tiêu đề chia chéo, vd góc bảng "Lớp \ Môn".
// NỐI Ô thì Typst có sẵn: table.cell(colspan: n) / table.cell(rowspan: n).
// ───────────────────────────────────────────────────────────
#let o-cheo(a, b, width: 100%, height: 1.2cm, stroke: 0.6pt, inset: 5pt, dir: "tl-br") = context {
  let __clr = text.fill
  let s = if type(stroke) == length { stroke + __clr } else { stroke }
  box(width: width, height: height, stroke: none)[
    #if dir == "tr-bl" [
      #place(line(start: (100%, 0%), end: (0%, 100%), stroke: s))
      #place(top + left, dx: inset, dy: inset * 0.6)[#a]
      #place(bottom + right, dx: -inset, dy: -inset * 0.6)[#b]
    ] else [
      #place(line(start: (0%, 0%), end: (100%, 100%), stroke: s))
      #place(top + right, dx: -inset, dy: inset * 0.6)[#a]
      #place(bottom + left, dx: inset, dy: -inset * 0.6)[#b]
    ]
  ]
}

#let o-cheo-cell(a, b, height: 1.2cm, stroke: 0.6pt, fill: none, inset: 4pt, dir: "tl-br") = table.cell(inset: 0pt, fill: fill)[
  #o-cheo(a, b, width: 100%, height: height, stroke: stroke, inset: inset, dir: dir)
]

#let o-cheo3(a, b, c, width: 100%, height: 1.6cm, stroke: 0.6pt, inset: 4pt) = context {
  let __clr = text.fill
  let s = if type(stroke) == length { stroke + __clr } else { stroke }
  box(width: width, height: height, stroke: none)[
    #place(line(start: (0%, 0%), end: (100%, 50%), stroke: s))
    #place(line(start: (0%, 0%), end: (50%, 100%), stroke: s))
    #place(top + right, dx: -inset, dy: inset * 0.3)[#a]
    #place(bottom + right, dx: -inset, dy: -inset * 0.3)[#b]
    #place(bottom + left, dx: inset * 0.6, dy: -inset * 0.3)[#c]
  ]
}

#let o-cheo3-cell(a, b, c, height: 1.6cm, stroke: 0.6pt, fill: none, inset: 4pt) = table.cell(inset: 0pt, fill: fill)[
  #o-cheo3(a, b, c, width: 100%, height: height, stroke: stroke, inset: inset)
]

#let cetz-cell(content, colspan: 1, rowspan: 1, fill: none) = (
  type: "cell", body: content, colspan: colspan, rowspan: rowspan, fill: fill
)

#let cetz-o-cheo(a, b, dir: "tl-br", fill: none) = (
  type: "o-cheo", a: a, b: b, dir: dir, fill: fill, colspan: 1, rowspan: 1
)

#let cetz-o-cheo3(a, b, c, fill: none) = (
  type: "o-cheo3", a: a, b: b, c: c, fill: fill, colspan: 1, rowspan: 1
)

#let cetz-table(
  cols: (3.2cm, 2.2cm, 2.2cm),
  row-height: 1.2cm,
  data: (),
  line-stroke: 0.8pt,
  fill-header: none,
) = canvas({
  import draw: *
  let n-cols = cols.len()
  let n-rows = data.len()
  
  let x-offsets = (0cm,)
  let acc = 0cm
  for w in cols {
    acc += w
    x-offsets.push(acc)
  }
  let total-w = acc
  let total-h = n-rows * row-height

  if fill-header != none {
    rect((0cm, 0cm), (total-w, -row-height), fill: fill-header, stroke: none)
  }

  let spans = ()
  for r in range(n-rows) {
    let row-spans = ()
    let row-data = data.at(r)
    let y-top = -r * row-height
    
    for c in range(row-data.len()) {
      let item = row-data.at(c)
      let is-dict = type(item) == dictionary
      let c-span = if is-dict { item.at("colspan", default: 1) } else { 1 }
      let r-span = if is-dict { item.at("rowspan", default: 1) } else { 1 }
      let fill-clr = if is-dict { item.at("fill", default: none) } else { none }
      
      row-spans.push((colspan: c-span, rowspan: r-span))
      
      let xL = x-offsets.at(c)
      let xR = x-offsets.at(calc.min(n-cols, c + c-span))
      let y-bot = -calc.min(n-rows, r + r-span) * row-height
      let x-center = (xL + xR) / 2
      let y-center = (y-top + y-bot) / 2
      
      if fill-clr != none {
        rect((xL, y-top), (xR, y-bot), fill: fill-clr, stroke: none)
      }
      
      if is-dict and item.at("type", default: "") == "o-cheo" {
        let dir = item.at("dir", default: "tl-br")
        if dir == "tr-bl" {
          line((xR, y-top), (xL, y-bot), stroke: line-stroke)
          content((xL + 0.6cm, y-top - 0.3cm), item.a)
          content((xR - 0.6cm, y-bot + 0.3cm), item.b)
        } else {
          line((xL, y-top), (xR, y-bot), stroke: line-stroke)
          content((xR - 0.6cm, y-top - 0.3cm), item.a)
          content((xL + 0.6cm, y-bot + 0.3cm), item.b)
        }
      } else if is-dict and item.at("type", default: "") == "o-cheo3" {
        line((xL, y-top), (xR, y-top + (y-bot - y-top) * 0.5), stroke: line-stroke)
        line((xL, y-top), (xL + (xR - xL) * 0.5, y-bot), stroke: line-stroke)
        content((xR - 0.5cm, y-top - 0.3cm), item.a)
        content((xR - 0.5cm, y-bot + 0.3cm), item.b)
        content((xL + 0.5cm, y-bot + 0.3cm), item.c)
      } else {
        let body = if is-dict { item.at("body", default: "") } else { item }
        content((x-center, y-center), body)
      }
    }
    spans.push(row-spans)
  }

  rect((0cm, 0cm), (total-w, -total-h), stroke: line-stroke)

  for r in range(1, n-rows) {
    let y = -r * row-height
    for c in range(n-cols) {
      let x1 = x-offsets.at(c)
      let x2 = x-offsets.at(c + 1)
      let is-blocked = false
      for r0 in range(0, r) {
        if c < spans.at(r0).len() {
          let sp = spans.at(r0).at(c)
          if r0 + sp.rowspan > r {
            is-blocked = true
            break
          }
        }
      }
      if not is-blocked {
        line((x1, y), (x2, y), stroke: line-stroke)
      }
    }
  }

  for c in range(1, n-cols) {
    let x = x-offsets.at(c)
    for r in range(n-rows) {
      let y1 = -r * row-height
      let y2 = -(r + 1) * row-height
      let is-blocked = false
      for c0 in range(0, c) {
        if c0 < spans.at(r).len() {
          let sp = spans.at(r).at(c0)
          if c0 + sp.colspan > c {
            is-blocked = true
            break
          }
        }
      }
      if not is-blocked {
        line((x, y1), (x, y2), stroke: line-stroke)
      }
    }
  }
})
#let o-cheo3(a, b, c, width: 3.2cm, height: 1.6cm, stroke: 0.6pt, inset: 4pt) = context {
  let __clr = text.fill
  let s = if type(stroke) == length { stroke + __clr } else { stroke }
  box(width: width, height: height, stroke: s)[
    #place(line(start: (0%, 0%), end: (60%, 100%), stroke: s))
    #place(line(start: (0%, 0%), end: (100%, 60%), stroke: s))
    #place(top + right, dx: -inset, dy: inset * 0.5)[#a]
    #place(horizon + right, dx: -inset)[#b]
    #place(bottom + left, dx: inset, dy: -inset * 0.5)[#c]
  ]
}

// ═══════════════════════════════════════════════════════════
// auto-bbt — BBT tự động kiểu cũ (giữ nguyên để tương thích)
// ═══════════════════════════════════════════════════════════
#let auto-bbt(
  x: (),
  y-phay: (),
  y: (),
) = context {
  let __clr = text.fill
  align(center)[
    #canvas({
      import draw: *

      // Khởi tạo các thông số tự động
      let n = x.len()
      let col1 = 1.5 // Độ rộng cột tiêu đề
      let step = 3.0 // Khoảng cách giữa các điểm x
      let w = col1 + (n - 1) * step
      let h = 4.0

      // Vẽ khung và lưới cơ bản
      rect((0, 0), (w, h), stroke: 0.75pt + __clr )
      line((0, 2), (w, 2), stroke: 0.75pt + __clr )
      line((0, 3), (w, 3), stroke: 0.75pt + __clr )
      line((col1, 0), (col1, h), stroke: 0.75pt + __clr )

      // Cột tiêu đề
      content((col1 / 2, 3.5), [$x$])
      content((col1 / 2, 2.5), [$f'(x)$])
      content((col1 / 2, 1.0), [$f(x)$])

      // 1. Điền hàng x tự động
      for i in range(n) {
        let cx = col1 + i * step
        content((cx, 3.5), x.at(i))
      }

      // 2. Điền hàng f'(x) tự động
      // Mảng y-phay có độ dài 2n - 1 (gồm nghiệm và khoảng giữa)
      for i in range(y-phay.len()) {
        let cx = col1 + i * (step / 2)
        content((cx, 2.5), y-phay.at(i))
      }

      // 3. Điền hàng f(x) và thuật toán tự động vẽ mũi tên
      let y_top = 1.6
      let y_mid = 1.0
      let y_bot = 0.4

      // Hàm phụ xác định cao độ: 1 (Trên), -1 (Dưới), 0 (Giữa)
      let get-y-coord(pos) = {
        if pos == 1 { y_top } else if pos == -1 { y_bot } else { y_mid }
      }

      // Điền các giá trị cực trị / giới hạn
      for i in range(n) {
        let item = y.at(i)
        let cx = col1 + i * step
        let cy = get-y-coord(item.at(1))
        content((cx, cy), item.at(0))
      }

      // Vòng lặp tự động phóng mũi tên
      let dx = 0.6 // Độ thu vào trục x (không đâm vào chữ)
      let dy = 0.25 // Độ thu vào trục y

      for i in range(n - 1) {
        let item1 = y.at(i)
        let item2 = y.at(i + 1)

        let x_start = col1 + i * step
        let y_start = get-y-coord(item1.at(1))

        let x_end = col1 + (i + 1) * step
        let y_end = get-y-coord(item2.at(1))

        // Thuật toán xét mũi tên đi lên hay đi xuống
        let x1 = x_start + dx
        let x2 = x_end - dx

        if y_start > y_end {
          // Nghịch biến (Đi xuống)
          line((x1, y_start - dy), (x2, y_end + dy), mark: (end: "stealth", fill: __clr))
        } else if y_start < y_end {
          // Đồng biến (Đi lên)
          line((x1, y_start + dy), (x2, y_end - dy), mark: (end: "stealth", fill: __clr))
        } else {
          // Hàm hằng (Đi ngang)
          line((x1 + 0.2, y_start), (x2 - 0.2, y_end), mark: (end: "stealth", fill: __clr))
        }
      }
    })
  ]
}
