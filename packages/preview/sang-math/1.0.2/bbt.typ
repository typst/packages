#import "@preview/cetz:0.5.2": canvas, draw
// ==========================================
// BỘ MACRO HOÀN MỸ CHO BẢNG BIẾN THIÊN VÀ BẢNG XÉT DẤU
// Cập nhật tính năng:
// 1. shade: Tô vùng không xác định (gạch chéo) chuẩn tkz-tab
// 2. Tự động ngắt mũi tên đi qua vùng không xác định
// 3. Tích hợp thêm macro bxd (Bảng xét dấu) siêu gọn nhẹ
// ==========================================

#let bbtv2(
  var: $x$,
  der: $y'$,
  func: $y$,
  x-vals: (),
  d-signs: (),
  v-vals: (),
  shade: (), // Mảng chứa các cặp index vùng gạch chéo. VD: ((1, 2),)
  w1: 1.5,
  w2: 10,
  h1: auto,
  h2: 0.8,
  h3: auto,
) = context {
  let __clr = text.fill
  // Tự động phân tích AST để điều chỉnh chiều cao nếu h1, h3 là auto
  let h1 = if h1 == auto {
    let has-tall = x-vals.any(x => {
      let r = repr(x)
      r.contains("frac(") or r.contains("integral(") or r.contains("lim(") or r.contains("cases(")
    })
    if has-tall { 1.2 } else { 0.8 }
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
    if has-tall { 2.8 } else { 2.2 }
  } else { h3 }

  canvas(length: 1cm, {
    import draw: *

    let n = x-vals.len()
    let tw = w1 + w2
    let th = h1 + h2 + h3

    // Tọa độ x cho các cột nội dung
    let x-pos = ()
    for i in range(n) {
      let px = w1 + 0.6 + (w2 - 1.2) * i / (n - 1)
      x-pos.push(px)
    }

    // 1. Kẻ khung cơ bản
    rect((0, 0), (tw, -th), stroke: 1pt + __clr)
    line((0, -h1), (tw, -h1), stroke: 1pt + __clr)
    line((0, -h1 - h2), (tw, -h1 - h2), stroke: 1pt + __clr)
    line((w1, 0), (w1, -th), stroke: 1pt + __clr)

    // 2. Xử lý vùng Shade (gạch chéo vùng không xác định)
    let hatch = tiling(size: (8pt, 8pt))[
      #std.line(start: (0pt, 8pt), end: (8pt, 0pt), stroke: rgb("888888") + 0.5pt)
    ]
    for s in shade {
      let xL = x-pos.at(s.at(0))
      let xR = x-pos.at(s.at(1))
      rect((xL, -h1), (xR, -th), fill: hatch, stroke: none)
      line((xL, -h1 - h2), (xR, -h1 - h2), stroke: 1pt + __clr)
    }

    // Nhãn cột trái
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

    for i in range(n) {
      content((x-pos.at(i), -h1 / 2), x-vals.at(i))
    }

    let is-inf(v) = { if type(v) != content { false } else { repr(v).contains("oo") } }

    // Hàng 2: dấu đạo hàm và khoảng
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
        let is-shaded = false
        for s in shade { if i >= s.at(0) and i < s.at(1) { is-shaded = true } }
        if not is-shaded {
          content(((x-pos.at(i) + x-pos.at(i + 1)) / 2, -h1 - h2 / 2), render-sign(d-signs.at(2 * i)))
        }
      }
    }

    // Hàng 3: rank → map-y
    // Rank luôn được tính kể cả qua vùng shade; chỉ mũi tên mới bị ẩn
    let ranks = ()
    let cur = 0
    ranks.push((cur,))
    for i in range(n - 1) {
      let sign = sign-of(d-signs.at(2 * i))
      if sign == "+" { cur += 1 } else if sign == "-" { cur -= 1 }
      let next_idx = 2 * i + 1
      if next_idx < d-signs.len() and sign-of(d-signs.at(next_idx)) == "||" {
        let val = v-vals.at(i + 1)
        if type(val) == array {
          // Tại tiệm cận đứng: bên trái và bên phải có rank riêng
          // Dấu sau || quyết định chiều của đoạn tiếp theo
          let ns = if next_idx + 1 < d-signs.len() { sign-of(d-signs.at(next_idx + 1)) } else { "+" }
          let rL = cur // bên trái tiệm cận: rank hiện tại
          // bên phải: ngược chiều so với bên trái để tạo gián đoạn
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
          content((px, y), v-text, name: "v" + str(i), padding: 0.15)
        }
      } else {
        let yL = map-y(rv.at(0))
        let yR = map-y(rv.at(1))
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let off = 0.15
        if not is-inf(vL) { content((px - off, yL), vL, name: "v" + str(i) + "L", padding: 0.15, anchor: "east") }
        if not is-inf(vR) { content((px + off, yR), vR, name: "v" + str(i) + "R", padding: 0.15, anchor: "west") }
      }
    }

    // Tính anchor (tách khỏi render để tránh cetz/string join)
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
      let is-shaded = false
      for s in shade { if i >= s.at(0) and i < s.at(1) { is-shaded = true } }
      if not is-shaded {
        let s = node-anchors.at(i).at(1)
        let e = node-anchors.at(i + 1).at(0)
        if s != none and e != none {
          line(s, e, mark: (end: ">", fill: __clr), stroke: 0.8pt + __clr)
        }
      }
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
          content((px, y), v-text, name: "v" + str(i), padding: 0.15)
        }
      } else {
        let yL = map-y(rv.at(0))
        let yR = map-y(rv.at(1))
        let vL = if type(val) == array and val.len() > 0 { val.at(0) } else { val }
        let vR = if type(val) == array and val.len() > 1 { val.at(1) } else { val }
        let off = 0.15
        if not is-inf(vL) { content((px - off, yL), vL, name: "v" + str(i) + "L", padding: 0.15, anchor: "east") }
        if not is-inf(vR) { content((px + off, yR), vR, name: "v" + str(i) + "R", padding: 0.15, anchor: "west") }
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
        line(s, e, mark: (end: ">", fill: __clr), stroke: 0.8pt + __clr)
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
