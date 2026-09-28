#import "@preview/cetz:0.5.2"
#import "@preview/rustycure:0.2.0": qr-code

// ==========================================
// 1. CÀI ĐẶT CHUNG & BẢNG MÀU THIẾT LẬP
// ==========================================
#let toan-setup(body, math-color: black, math-size: 1.2em, nmsize: 1em) = {
  show math.frac: it => {
    set text(fill: math-color, size: math-size)
    math.display(it)
  }
  show math.equation: it => {
    set text(size: nmsize)
    it
  }
  show list: it => {
    let any-frac = it.children.any(item => {
      let r = repr(item.body)
      r.contains("frac") and not r.contains("list(")
    })
    if any-frac {
      set list(spacing: 1.1em)
      it
    } else { it }
  }
  body
}

#let mau-sac = (
  lg : rgb("#a8f6f13c"),
  duong: rgb("#0057b8"),
  cau-pa: rgb("#1505f2"),
  daT: rgb("#f3072a")
)

#let to-abc(idx) = ("A", "B", "C", "D").at(idx)
#let to-ds(arr) = {
  let res = ""
  for v in arr { if v == 1 { res += "Đ" } else { res += "S" } }
  res
}

// ==========================================
// 2. THUẬT TOÁN BĂM & XÁO TRỘN ĐỀ
// ==========================================
#let ham-bam(index, seed) = {
  let h = index * 1664525 + seed * 1013904223
  h = calc.rem(h, 4294967296)
  h = calc.rem(h * 279470273, 4294967296)
  return h
}

#let tron-mang(arr, seed) = {
  if arr.len() <= 1 { return arr }
  let pairs = arr.enumerate().map((pair) => {
    let (i, item) = pair
    (ham-bam(i, seed), item)
  })
  let n = pairs.len()
  let sorted-pairs = ()
  let remaining = pairs

  for i in range(n) {
    let min-idx = 0
    for j in range(1, remaining.len()) {
      if remaining.at(j).at(0) < remaining.at(min-idx).at(0) {
        min-idx = j
      }
    }
    sorted-pairs.push(remaining.at(min-idx))
    remaining = remaining.slice(0, min-idx) + remaining.slice(min-idx + 1)
  }
  return sorted-pairs.map(p => p.at(1))
}

#let tron-mang-theo-lv(arr, seed) = {
  if arr.len() <= 1 { return arr }
  let get-lv(item) = item.at("lv", default: 1)

  let nhom1 = arr.filter(q => get-lv(q) == 1)
  let nhom2 = arr.filter(q => get-lv(q) == 2)
  let nhom3 = arr.filter(q => get-lv(q) == 3)
  let nhom-khac = arr.filter(q => {
    let lv = get-lv(q)
    lv != 1 and lv != 2 and lv != 3
  })

  return tron-mang(nhom1, seed + 11) + tron-mang(nhom2, seed + 22) + tron-mang(nhom3, seed + 33) + tron-mang(nhom-khac, seed + 44)
}

#let xao-theo-tuy-chon(arr, seed, theo-lv: false) = {
  if theo-lv {
    tron-mang-theo-lv(arr, seed)
  } else {
    tron-mang(arr, seed)
  }
}

// ==========================================
// 3. HÀM TẠO qr & HIỂN THỊ LỜI GIẢI
// ==========================================
#let tao-qr-code-key(results) = {
  let all-content = ""
  for entry in results {
    let ma-de = str(entry.value.seed)
    let part1 = entry.value.part1.join("")
    let part2 = entry.value.part2.join("")
    let part3 = entry.value.part3.map(str).join("|")
    all-content += ma-de + "\n" + part1 + "\n" + part2 + "\n" + part3 + "\n"
  }
  return all-content
}

#let hien-thi-lg(q, q-type, idx, seed, opt-indices: none, tf-indices: none) = {
  toan-setup({
    v(-0.4em)
    block(
      width: 100%, 
      inset: (y: 0.5em, x: 0.5em, left: 8pt, right: 8pt), 
      fill: mau-sac.lg, 
      radius: (right: 4pt),
      stroke: (left: 2pt + mau-sac.duong)
    )[
      #v(0.2em)
      #if q-type == "NLC" {
        let correct-idx = if opt-indices != none { opt-indices.position(i => i == q.da) } else { q.da }
        text(fill: blue.darken(100%), size: 11pt)[*Đáp án: #to-abc(correct-idx)*\ ] 
        text(fill: red.darken(0%), size: 15pt)[*Lời giải:*] 
      } else if q-type == "TF" or q-type == "tf" {
        let correct-ans = if tf-indices != none { to-ds(tf-indices.map(i => q.da.at(i))) } else { to-ds(q.da) }
        text(fill: blue.darken(100%), size: 11pt)[*Đáp án: #correct-ans*\ ] 
        text(fill: red.darken(0%), size: 15pt)[ *Lời giải:*]
      } else if q-type == "TLN" {
        text(fill: blue.darken(100%), size: 11pt)[*Kết quả: #q.da*]
        text(fill: red.darken(0%), size: 15pt)[\ *Lời giải:*]
      } else if q-type == "TL" {
        text(fill: red.darken(0%), weight: "bold", size: 16pt)[*Lời giải:*]
      }
      
      #if (q-type == "TF" or q-type == "tf") and type(q.lg) == array {
        let indices = if tf-indices != none { tf-indices } else { range(q.lg.len()) }
        let labels = ("a)", "b)", "c)", "d)")
        
        list(
          marker: none,
          spacing: 0.7em,
          ..indices.enumerate().map(((new-i, orig-i)) => {
            let is-true = q.da.at(orig-i) == 1
            let status-str = if is-true { "Đúng" } else { "Sai" }
            let lg-content = if orig-i < q.lg.len() { q.lg.at(orig-i) } else { [] }
            
            [#text(fill: mau-sac.cau-pa, weight: "bold")[#labels.at(new-i) - #status-str:] #text(fill: blue.darken(100%), style: "italic")[#lg-content]]
          })
        )
      } else {
        text(fill: blue.darken(100%), style: "italic")[#q.lg]
      }
    ]
    v(-0.1em)
  })
}

// ==========================================
// 4. BÀI TẬP INLINE / ÔN TẬP TÀI LIỆU
// ==========================================
#let render-sub-sol(q, type-str, show-lg) = {
  if not show-lg { return }
  v(-0.8em)
  block(
    width: 100%,
    stroke: (left: 2.5pt + mau-sac.duong),
    fill: mau-sac.lg,
    inset: (x: 10pt, y: 8pt),
    radius: (right: 4pt),
    breakable: true
  )[
    #set par(leading: 0.65em)
    #if type-str == "NLC" [
      #text(fill: mau-sac.duong, weight: "bold")[► Lời giải: \ ] 
      #if "lg" in q and q.lg != none and q.lg != [] [ #q.lg ] else [ Chưa có lời giải.]
    ]
    #if type-str == "TF" [
      #text(fill: mau-sac.duong, weight: "bold")[► Đáp án:] #text(fill: mau-sac.daT, weight: "bold")[#to-ds(q.da)] \
      #if "lg" in q and q.lg != none and q.lg != [] [
        #if type(q.lg) == array [
          #let labels = ("a)", "b)", "c)", "d)")
          #list(
            marker: none,
            spacing: 0.7em,
            ..q.lg.enumerate().map(((i, lg-item)) => {
              let is-true = q.da.at(i) == 1
              let status-str = if is-true { "Đúng" } else { "Sai" }
              [#text(fill: mau-sac.cau-pa, weight: "bold")[#labels.at(i)  #status-str]\ #lg-item]
            })
          )
        ] else [
          #q.lg
        ]
      ] else [ Chưa có lời giải.]
    ]
    #if type-str == "TLN" [
      #text(fill: mau-sac.duong, weight: "bold")[► Kết quả:] #text(fill: mau-sac.daT, weight: "bold")[#q.da] \
      #if "lg" in q and q.lg != none and q.lg != [] [ #v(0.01em)#q.lg #v(0.2em)] else [ Chưa có lời giải.]
    ]
    #if type-str == "TL" [
      #text(fill: mau-sac.duong, weight: "bold")[► Lời giải chi tiết:] \
      #if "lg" in q and q.lg != none and q.lg != [] [ #q.lg ] else [ Chưa có lời giải.]
    ]
  ]
}

#let bai-tap-in-line(
  cm: 1,
  bank-data, 
  title: none,
  seed: 0,
  num-nlc: none, 
  num-tf: none, 
  num-tln: none, 
  num-tl: none,
  show-lg: false,
  dong-ke: none,
  co-nlc: none,
  co-tf: none,
  co-tln: none,
  co-tl: none,
  theo-lv: false,
) = {
  let cfg-nlc = if num-nlc != none { num-nlc } else { co-nlc }
  let cfg-tf  = if num-tf != none { num-tf } else { co-tf }
  let cfg-tln = if num-tln != none { num-tln } else { co-tln }
  let cfg-tl  = if num-tl != none { num-tl } else { co-tl }

  let actual-bank = if type(bank-data) == dictionary and "data" in bank-data { 
    bank-data.data 
  } else if type(bank-data) == module {
    bank-data.data
  } else { 
    bank-data 
  }
  
  let std-bank = actual-bank.map(q => {
    if "cau-hoi-con" in q and type(q.cau-hoi-con) == array and q.cau-hoi-con.len() > 0 { 
      let is-c = q.at("is-chum", default: q.cau-hoi-con.len() > 1)
      let dk = q.at("du-kien", default: none)
      let q-type = q.at("type", default: q.cau-hoi-con.at(0).at("type", default: "NLC"))
      let q-lv = q.at("lv", default: 1)
      (
        type: q-type,
        lv: q-lv,
        is-chum: is-c,
        du-kien: dk,
        cau-hoi-con: q.cau-hoi-con
      )
    } else { 
      (
        type: q.at("type", default: "NLC"),
        lv: q.at("lv", default: 1),
        is-chum: false, 
        du-kien: none, 
        cau-hoi-con: (q,)
      ) 
    }
  })

  let rut-cau(q-type, dem-config, sub-seed) = {
    let loc-ques = std-bank.filter(q => q.type == q-type)
    if loc-ques.len() == 0 or dem-config == none or dem-config == 0 { return () }

    let get-q-lv(item) = {
      if "lv" in item { item.lv }
      else if item.cau-hoi-con.len() > 0 and "lv" in item.cau-hoi-con.at(0) { item.cau-hoi-con.at(0).lv }
      else { 1 }
    }

    if type(dem-config) == int { 
      let processing = if seed == none { loc-ques } else { xao-theo-tuy-chon(loc-ques, seed + sub-seed, theo-lv: theo-lv) }
      return processing.slice(0, calc.min(dem-config, processing.len())) 
    }
    
    if type(dem-config) == array {
      let nb-req = dem-config.at(0, default: 0)
      let th-req = dem-config.at(1, default: 0)
      let vd-req = dem-config.at(2, default: 0)

      let b-nb = loc-ques.filter(q => get-q-lv(q) == 1)
      let b-th = loc-ques.filter(q => get-q-lv(q) == 2)
      let b-vd = loc-ques.filter(q => get-q-lv(q) == 3)

      if seed != none {
        b-nb = tron-mang(b-nb, seed + sub-seed + 11)
        b-th = tron-mang(b-th, seed + sub-seed + 22)
        b-vd = tron-mang(b-vd, seed + sub-seed + 33)
      }

      let res-nb = b-nb.slice(0, calc.min(nb-req, b-nb.len()))
      let res-th = b-th.slice(0, calc.min(th-req, b-th.len()))
      let res-vd = b-vd.slice(0, calc.min(vd-req, b-vd.len()))

      return res-nb + res-th + res-vd
    }

    return loc-ques
  }

  let ds-nlc = rut-cau("NLC", cfg-nlc, 107)
  let ds-tf  = rut-cau("TF", cfg-tf, 233)
  let ds-tln = rut-cau("TLN", cfg-tln, 357)
  let ds-tl  = rut-cau("TL", cfg-tl, 491)

  toan-setup({
    if title != none and title != "" {
      v(0.5em)
      align(center)[#text(fill: mau-sac.duong, weight: "bold", size: 13pt)[#title]]
      v(0.3em)
    }

    // PHẦN I: NLC
    if ds-nlc.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 {
        text(fill: mau-sac.cau-pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẮC NGHIỆM NHIỀU LỰA CHỌN]
      }
      let c-idx = 0
      for item in ds-nlc {
        if item.du-kien != none and item.du-kien != [] {
          let n-sub = item.cau-hoi-con.len()
          let start-c = c-idx + 1
          let end-c = c-idx + n-sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mau-sac.cau-pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mau-sac.cau-pa, weight: "bold")[Dữ kiện dùng cho từ Câu #start-c đến Câu #end-c:] \
              #v(0.1em) #item.du-kien
            ]
          ]
        }
        
        for q in item.cau-hoi-con {
          c-idx += 1
          v(-0.4em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) },
              gutter: 3pt,
              row-gutter: 8pt,
              align: (left + top, center + top),
              [
                #v(-0.4em)
                #text(fill: mau-sac.cau-pa, weight: "bold")[Câu #c-idx.] #q.nd \
                #v(-0.3em)
                
                #let is-img-option = q.pa.any(opt => {
                  let r = repr(opt)
                  r.contains("image(") or r.contains("cetz") or r.contains("canvas")
                })

                #if is-img-option [
                  #let n-cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n-cols,
                    column-gutter: 0.8em,
                    row-gutter: 0.5em,
                    align: center + horizon,
                    ..q.pa.enumerate().map(((i, v)) => {
                      let is-correct = show-lg and ("da" in q) and (i == q.da)
                      let label-text = [#h(1em)*#to-abc(i).*]
                      let formatted-label = if is-correct { underline(text(fill: mau-sac.daT, weight: "bold")[#label-text]) } else { text(fill: mau-sac.cau-pa)[#label-text] }
                      align(left)[#grid(columns:(auto,1fr), column-gutter:10pt, [#formatted-label], [#v])]
                    })
                  ) 
                ] else [
                  #let n-cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n-cols,
                    row-gutter: 0.95em,
                    column-gutter: 0.1em,
                    align: if n-cols > 1 { left + horizon } else { left },
                    inset: (x: 1em),
                    ..q.pa.enumerate().map(((i, v)) => {
                      let is-correct = show-lg and ("da" in q) and (i == q.da)
                      let label-text = [*#to-abc(i).*]
                      let formatted-label = if is-correct { underline(text(fill: mau-sac.daT, weight: "bold")[#label-text]) } else { text(fill: mau-sac.cau-pa)[#label-text] }
                      box[#grid(columns: (auto, 1fr), gutter: 2pt, align: left, formatted-label, v)]
                    })
                  ) #v(0.5em)
                ]
              ],
              if has-img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } ]
            )
          ]
          v(-0.7em)
          render-sub-sol(q, "NLC", show-lg)
        }
      }
    }

    // PHẦN II: TF
    if ds-tf.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.1em)
      if cm == 1 { text(fill: mau-sac.cau-pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẢ LỜI ĐÚNG/SAI] }
      let c-idx = 0
      for item in ds-tf {
        if item.du-kien != none and item.du-kien != [] {
          let n-sub = item.cau-hoi-con.len()
          let start-c = c-idx + 1
          let end-c = c-idx + n-sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mau-sac.cau-pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mau-sac.cau-pa, weight: "bold")[Dữ kiện dùng cho Câu #start-c đến Câu #end-c:] \
              #v(0.1em) #item.du-kien
            ]
          ]
        }
        for q in item.cau-hoi-con {
          c-idx += 1
          v(-0.6em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + top),
              [
                #v(0.2em)
                #text(fill: mau-sac.cau-pa, weight: "bold")[Câu #c-idx.] #q.nd \
                #list(
                  marker: none, 
                  spacing: 0.7em, 
                  ..q.ytf.enumerate().map(((i, sq)) => {
                    let label-text = [#("a)", "b)", "c)", "d)").at(i)]
                    let formatted-label = text(fill: mau-sac.cau-pa, weight: "bold")[#h(0.5em) #label-text]
                    let ans-str = if show-lg and ("da" in q) and type(q.da) == array and i < q.da.len() {
                      if q.da.at(i) == 1 { " [Đúng]" } else { " [Sai]" }
                    } else { "" }
                    [#formatted-label #sq #text(fill: mau-sac.daT, weight: "bold")[#ans-str]]
                  })
                )
              ],
              if has-img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } ]
            )
          ]
          v(-0.8em)
          render-sub-sol(q, "TF", show-lg)
        }
      }
    }

    // PHẦN III: TLN
    if ds-tln.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 { text(fill: mau-sac.cau-pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẢ LỜI NGẮN] }
      let c-idx = 0
      for item in ds-tln {
        if item.du-kien != none and item.du-kien != [] {
          let n-sub = item.cau-hoi-con.len()
          let start-c = c-idx + 1
          let end-c = c-idx + n-sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mau-sac.cau-pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mau-sac.cau-pa, weight: "bold", style: "italic")[Dữ kiện dùng cho Câu #start-c đến Câu #end-c:] \
              #v(0.1em) #text(style: "italic")[#item.du-kien]
            ]
          ]
        }
        for q in item.cau-hoi-con {
          c-idx += 1
          v(-0.8em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              row-gutter: 10pt,
              align: (left + top, center + horizon),
              [
                #v(-0.1em)
                #text(fill: mau-sac.cau-pa, weight: "bold")[Câu #c-idx.] #q.nd
                #v(0.1em)
                #if not show-lg [
                  #grid(
                    columns: (auto, auto), 
                    column-gutter: 8pt, 
                    align: horizon, 
                    [*Trả lời:*], 
                    [#(for i in range(4) { box(width: 1.2em, height: 1.2em, stroke: 0.4pt + gray.darken(80%), radius: 1pt); h(2pt) })]
                  )
                  #v(-0.4em)
                  #let num-lines = if dong-ke == none or dong-ke == 0 { none 
                  } else if "dong-ke" in q and q.dong-ke != none { q.dong-ke 
                  } else { dong-ke }
                  #if num-lines != none and type(num-lines) == int and num-lines > 0 {
                    v(0.3em)
                    for i in range(num-lines) {
                      v(0.4em)
                      line(length: 100%, stroke: (dash: "dotted", thickness: 0.75pt, paint: gray.darken(80%)))
                    }
                  }
                ]
              ],
              if has-img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } #v(0.2em)]
            )
          ]
          v(-0.4em)
          render-sub-sol(q, "TLN", show-lg)
        }
      }
    }

    // PHẦN IV: TL
    if ds-tl.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 { text(fill: mau-sac.cau-pa, weight: "bold", size: 11pt)[► BÀI TẬP TỰ LUẬN] }
      let c-idx = 0
      for item in ds-tl {
        for q in item.cau-hoi-con {
          c-idx += 1
          v(-0.4em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + top),
              [
                #v(-0.4em)
                #text(fill: mau-sac.cau-pa, weight: "bold")[Câu #c-idx.] #q.nd
                #v(0.5em)
              ],
              if has-img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } #v(1em)]
            )
            #v(-0.8em)
            #if not show-lg [
              #let num-lines = if dong-ke == none or dong-ke == 0 { none
              } else if "dong-ke" in q and q.dong-ke != none { q.dong-ke
              } else { dong-ke }
              #if num-lines != none and type(num-lines) == int and num-lines > 0 {
                v(0.3em)
                for i in range(num-lines) {
                  v(0.15em)
                  line(length: 100%, stroke: (dash: "dotted", thickness: 0.75pt, paint: gray.darken(80%)))
                  v(0.35em)
                }
              }
            ]
            #v(0.4em)
          ]
          v(-0.8em)
          render-sub-sol(q, "TL", show-lg)
        }
      }
    }
  })
}

// ==========================================
// 5. TRỘN ĐỀ THI
// ==========================================
#let render-test(
  ma-de, 
  q-bank, 
  matrix, 
  info, 
  is-first: false, 
  show-lg: false,
  tf-mode: "full",
  nlc-mode: "full",
  theo-lv: false,
) = {
  if not is-first {
    context { counter(page).update(1) }
  }

  let seed = int(ma-de)

  let raw-nlc = q-bank.filter(matrix.nlc-loc)
  let xao-nlc = xao-theo-tuy-chon(raw-nlc, seed + 107, theo-lv: theo-lv)
  let nlc-dem = calc.min(matrix.nlc-dem, xao-nlc.len())
  let s-nlc = xao-nlc.slice(0, nlc-dem)

  let raw-tf = q-bank.filter(matrix.tf-loc)
  let xao-tf = xao-theo-tuy-chon(raw-tf, seed + 233, theo-lv: theo-lv)
  let tf-dem = calc.min(matrix.tf-dem, xao-tf.len())
  let s-tf = xao-tf.slice(0, tf-dem)

  let raw-tln = q-bank.filter(matrix.tln-loc)
  let xao-tln = xao-theo-tuy-chon(raw-tln, seed + 357, theo-lv: theo-lv)
  let tln-dem = calc.min(matrix.tln-dem, xao-tln.len())
  let s-tln = xao-tln.slice(0, tln-dem)

  let raw-tl = q-bank.filter(matrix.tl-loc)
  let xao-tl = xao-theo-tuy-chon(raw-tl, seed + 491, theo-lv: theo-lv)
  let tl-dem = calc.min(matrix.tl-dem, xao-tl.len())
  let s-tl = xao-tl.slice(0, tl-dem)

  let part1-ans = ()
  let part2-ans = ()
  let part3-ans = ()
  let part4-ans = ()

  toan-setup({
    set page(paper: "a4", margin: 1.2cm, footer: context [
      #set text(size: 9pt); *#h(1fr) Trang #counter(page).display() - Mã đề #ma-de*
    ])

    grid(
      columns: (1.2fr, 1fr),
      gutter: 10pt,
      align(center)[
        #text(size: 11pt)[#info.so-gd] \
        #text(size: 11pt)[#strong(info.truong)] \
        #v(-0.5em)
        #line(length: 40%, stroke: 0.5pt)
      ],
      align(center)[
        #text(size: 11pt)[#strong(info.ky-thi)] \
        #text(size: 11pt)[Môn: #strong[#info.mon]] \
        #text(size: 10pt)[Thời gian: #emph[#info.thoi-gian]]
      ]
    )
    grid(columns: (1fr, auto),
      [Họ tên: ..............................................................................\ 
      #v(0.1em)
      Lớp: ................
      Số báo danh: .......................
      Phòng thi: ............],
      box(stroke: 0.8pt + black, inset: (x: 6pt, y: 6pt))[#strong[Mã đề: #ma-de]]
    )
    line(length: 100%, stroke: 0.5pt)

    if s-nlc.len() > 0 {
      let tong-so-cau = s-nlc.fold(0, (acc, q) => {
        if "is-chum" in q and q.is-chum == true and "cau-hoi-con" in q { acc + q.cau-hoi-con.len() } else { acc + 1 }
      })
      set par(first-line-indent: 0pt)
      v(-0.1em)
      text(fill: mau-sac.cau-pa)[*► Thí sinh trả lời từ câu 1 đến câu #tong-so-cau.* #emph[*Mỗi câu thí sinh chỉ được chọn một phương án.*]#v(0.2em)]
      
      let c-idx = 0
      for item in s-nlc {
        let is-item-chum = "is-chum" in item and item.is-chum == true and "cau-hoi-con" in item
        if is-item-chum {
          let n-sub = item.cau-hoi-con.len()
          let start-num = c-idx + 1
          let end-num = c-idx + n-sub
          v(0.2em)
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mau-sac.cau-pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mau-sac.cau-pa)[*Dữ kiện dùng cho từ Câu #start-num đến Câu #end-num:*] \
              #v(0.1em) #item.du-kien
            ]
          ]
        }

        let ds-cau-can-ve = if is-item-chum { item.cau-hoi-con } else { (item,) }

        for q in ds-cau-can-ve {
          let opt-indices = if seed == 0 or nlc-mode == "none" { range(4) } else { tron-mang(range(4), seed + c-idx * 73) }
          let new-opts = opt-indices.map(i => q.pa.at(i))
          part1-ans.push(to-abc(opt-indices.position(i => i == q.da)))
          
          v(-0.2em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + horizon),
              [
                #v(-0.3em)
                #text(fill: mau-sac.cau-pa)[*Câu #(c-idx + 1).*] #q.nd \
                #v(-0.3em)
                #let is-img-option = new-opts.any(opt => {
                  let r = repr(opt)
                  r.contains("image(") or r.contains("cetz") or r.contains("canvas")
                })
                #if is-img-option [
                  #grid(
                    columns: (1fr, 1fr, 1fr, 1fr),
                    column-gutter: 0.8em, row-gutter: 0.5em, align: center + horizon,
                    ..new-opts.enumerate().map(((i, v)) => [#align(center)[#text(fill: mau-sac.cau-pa)[*#to-abc(i).*]) #v]])
                  )
                ] else [
                  #let n-cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n-cols, row-gutter: 0.6em, column-gutter: 1.2em, align: left + horizon,
                    ..new-opts.enumerate().map(((i, v)) => [#text(fill: mau-sac.cau-pa)[#h(1em)*#to-abc(i).*] #v])
                  )
                ]
              ],
              if has-img [ #align(center + top)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
            )
          ]
          v(-0.8em)
          if show-lg and "lg" in q and q.lg != [] { hien-thi-lg(q, "NLC", c-idx, seed, opt-indices: opt-indices) }
          v(-0.2em)
          c-idx += 1
        }
      }
    }

    if s-tf.len() > 0 {
      set par(first-line-indent: 0pt)
      v(0.5em); text(mau-sac.cau-pa)[*► Thí sinh trả lời từ câu 1 đến câu #s-tf.len().* #emph[ *Trong mỗi ý a), b), c), d) của mỗi câu, thí sinh chọn đúng hoặc sai.*]]
      for (idx, q) in s-tf.enumerate() {
        let sub-indices = if tf-mode == "none" { range(4) }
        else if tf-mode == "y-only" {
          let content-str = repr(q.nd) + repr(q.ytf)
          let content-hash = calc.rem(content-str.len() * 265435761, 123456789)
          tron-mang(range(4), content-hash * 31 + int(ma-de) * 7919)
        } else { tron-mang(range(4), seed + idx * 109 + int(ma-de) * 10000) }
        let new-subs = sub-indices.map(i => q.ytf.at(i))
        part2-ans.push(to-ds(sub-indices.map(i => q.da.at(i))))
        v(-0.3em)
        block(width: 100%, inset: (y: 0.3em), breakable: true)[
          #let has-img = "hv" in q and q.hv != none and q.hv != ""
          #grid(
            columns: if has-img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + horizon),
            [
              #text(fill: mau-sac.cau-pa)[*Câu #(idx + 1).* ]#q.nd \
              #list(marker: none, spacing: 0.7em, ..new-subs.enumerate().map(((i, sq)) => [#h(0.5em) #text(fill: mau-sac.cau-pa)[#strong[#("a)", "b)", "c)", "d)").at(i)]] #sq]))
            ],
            if has-img [ #align(center + horizon)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
          )
        ]
        v(-0.4em)
        if show-lg and "lg" in q and q.lg != [] { hien-thi-lg(q, "TF", idx + s-nlc.len(), seed, tf-indices: sub-indices) }
        v(-0.3em)
      }
    }

    if s-tln.len() > 0 {
      let tong-so-cau = s-tln.fold(0, (acc, q) => {
        if "is-chum" in q and q.is-chum == true and "cau-hoi-con" in q { acc + q.cau-hoi-con.len() } else { acc + 1 }
      })
      set par(first-line-indent: 0pt)
      v(0.5em); text(fill: mau-sac.cau-pa)[*► Thí sinh trả lời từ câu 1 đến câu #tong-so-cau.*]
      let c-idx = 0
      for item in s-tln {
        let is-item-chum = "is-chum" in item and item.is-chum == true and "cau-hoi-con" in item
        let ds-cau-can-ve = if is-item-chum { item.cau-hoi-con } else { (item,) }

        if is-item-chum {
          let n-sub = item.cau-hoi-con.len()
          let start-num = c-idx + 1
          let end-num = c-idx + n-sub
          v(0.2em)
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mau-sac.cau-pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mau-sac.cau-pa)[*Dữ kiện dùng cho từ Câu #start-num đến Câu #end-num:*] \
              #v(0.1em) #item.du-kien
            ]
          ]
        }

        for q in ds-cau-can-ve {
          part3-ans.push(q.da)
          v(-0.5em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has-img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has-img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + horizon),
              [
                #text(fill: mau-sac.cau-pa)[*Câu #(c-idx + 1).* ]#q.nd
                #if not show-lg [
                  #v(-0.4em)
                  #pad(left: 0em)[
                    #grid(columns: (auto, auto), column-gutter: 10pt, align: (left + horizon, left + horizon), [*Trả lời:*], [#(for i in range(4) { box(width: 1.2em, height: 1.2em, stroke: 0.3pt); h(3pt) })])
                  ]
                ]
              ],
              if has-img [ #align(center + horizon)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
            )
          ]
          v(-1em)
          if show-lg and "lg" in q and q.lg != [] { hien-thi-lg(q, "TLN", c-idx + s-nlc.len() + s-tf.len(), seed) }
          v(-0.2em)
          c-idx += 1
        }
      }
    }

    if s-tl.len() > 0 {
      set par(first-line-indent: 0pt)
      v(0.3em); text(mau-sac.cau-pa)[*► TỰ LUẬN (#s-tl.len() câu)*]
      v(-0.3em)
      for (idx, q) in s-tl.enumerate() {
        part4-ans.push((nd: q.nd, lg: q.lg))
        v(-0.3em)
        block(width: 100%, inset: (y: 0.3em), breakable: true)[
          #let has-img = "hv" in q and q.hv != none and q.hv != ""
          #grid(
            columns: if has-img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + top),
            [ #text(fill: mau-sac.cau-pa)[*Câu #(idx + 1).* ] #q.nd \ #v(-0.3em) ],
            if has-img [ #align(center + top)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
          )
          #if show-lg and "lg" in q and q.lg != [] { hien-thi-lg(q, "TL", idx, seed) }
          #v(-0.3em)
        ]
      }
    }

    align(center)[#text(size: 11pt)[#strong[---- hết ----]]]
  })

  [#metadata((
    seed: ma-de,
    part1: part1-ans,
    part2: part2-ans,
    part3: part3-ans,
    part4: part4-ans
  )) <exam-data>]
}

#let in-dap-an-tl(results) = {
  context {
    counter(page).update(1)
    set page(footer: none)
  }
  toan-setup({
    align(center)[#text(20pt, weight: "bold")[HƯỚNG DẪN CHẤM TỰ LUẬN]]
    v(-0.2em)
    for entry in results {
      let ma-de = str(entry.value.seed)
      let lg-tl = entry.value.part4
      if lg-TL.len() > 0 {
        align(left)[
          #block(fill: gray.lighten(80%), inset: 5pt, radius: 4pt)[
            #text(14pt, weight: "bold")[Mã đề: #ma-de]
          ]
          #v(-0.51em)
        ]
        for (idx, ans) in lg-TL.enumerate() {
          align(left)[
            #text(12pt)[*Câu #(idx + 1). * #ans.nd]
            #v(-0.5em)
            #text(11pt, fill: blue.darken(40%))[*Lời giải:* ]
            #v(-0.5em)
            #block(inset: 12pt, fill: yellow.lighten(95%), radius: 4pt, width: 100%)[
              #text(fill: mau-sac.cau-pa, style: "italic")[#ans.lg]
            ]
            #v(-0.5em)
          ]
        }
      }
    }
  })
}

#let rut-cau-level(raw-bank, q-type, dem-config, seed) = {
  let actual-bank = if type(raw-bank) == dictionary and "data" in raw-bank { raw-bank.data }
  else if type(raw-bank) == module { raw-bank.data } else { raw-bank }

  let loc-ques = actual-bank.filter(q => q.type == q-type)
  if loc-ques.len() == 0 { return () }

  let bank-chum = loc-ques.filter(q => "is-chum" in q and q.is-chum == true)
  let bank-don  = loc-ques.filter(q => not ("is-chum" in q and q.is-chum == true))

  let safe-slice(arr, req-count) = {
    if req-count <= 0 or arr.len() == 0 { return () }
    let take = calc.min(req-count, arr.len())
    return arr.slice(0, take)
  }

  let xao-chum = tron-mang(bank-chum, seed)
  let xao-don  = tron-mang(bank-don, seed + 101)

  let nb-req = 0
  let th-req = 0
  let vd-req = 0
  let chum-req = 0

  if type(dem-config) == array {
    nb-req = dem-config.at(0, default: 0)
    th-req = dem-config.at(1, default: 0)
    vd-req = dem-config.at(2, default: 0)
  } else if type(dem-config) == dictionary {
    let don-arr = dem-config.at("don", default: (0, 0, 0))
    nb-req = don-arr.at(0, default: 0)
    th-req = don-arr.at(1, default: 0)
    vd-req = don-arr.at(2, default: 0)
    chum-req = dem-config.at("chum", default: 0)
  } else if type(dem-config) == int {
    nb-req = dem-config
  }

  let res-chum = safe-slice(xao-chum, chum-req)

  let b-nb = xao-don.filter(q => ("lv" in q and q.lv == 1) or not ("lv" in q))
  let b-th = xao-don.filter(q => "lv" in q and q.lv == 2)
  let b-vd = xao-don.filter(q => "lv" in q and q.lv == 3)

  let res-don = safe-slice(b-nb, nb-req) + safe-slice(b-th, th-req) + safe-slice(b-vd, vd-req)

  return res-chum + res-don
}

#let tron-de-bank-level(banks-matrix, info, show-lg: false, hien-thi-bang-dap-an: true, theo-lv: false) = {
  for (i, ma-de) in info.ds-ma-de.enumerate() {
    let is-first = (i == 0)
    let base-seed = int(ma-de)
    
    let rut-nlc = ()
    let rut-tf = ()
    let rut-tln = ()
    let rut-tl = ()

    for (b-idx, item) in banks-matrix.enumerate() {
      let b = item.bank
      let nlc-seed = base-seed * 999999 + b-idx * 999999 + 107
      let tf-seed  = base-seed * 999999 + b-idx * 999999 + 233
      let tln-seed = base-seed * 999999 + b-idx * 999999 + 357
      let tl-seed  = base-seed * 999999 + b-idx * 999999 + 491

      if "nlc-dem" in item { rut-nlc += rut-cau-level(b, "NLC", item.nlc-dem, nlc-seed) }
      if "tf-dem"  in item { rut-tf  += rut-cau-level(b, "TF",  item.tf-dem,  tf-seed)  }
      if "tln-dem" in item { rut-tln += rut-cau-level(b, "TLN", item.tln-dem, tln-seed) }
      if "tl-dem"  in item { rut-tl  += rut-cau-level(b, "TL",  item.tl-dem,  tl-seed)  }
    }

    rut-nlc = xao-theo-tuy-chon(rut-nlc, base-seed + 991,  theo-lv: theo-lv)
    rut-tf  = xao-theo-tuy-chon(rut-tf,  base-seed + 997,  theo-lv: theo-lv)
    rut-tln = xao-theo-tuy-chon(rut-tln, base-seed + 1009, theo-lv: theo-lv)
    rut-tl  = xao-theo-tuy-chon(rut-tl,  base-seed + 1013, theo-lv: theo-lv)

    let final-bank = rut-nlc + rut-tf + rut-tln + rut-tl
    
    let fake-matrix = (
      nlc-loc: q => q.type == "NLC",
      nlc-dem: rut-nlc.len(),
      tf-loc:  q => q.type == "TF",
      tf-dem:  rut-tf.len(),
      tln-loc: q => q.type == "TLN",
      tln-dem: rut-tln.len(),
      tl-loc:  q => q.type == "TL",
      tl-dem:  rut-tl.len(),
    )

    render-test(ma-de, final-bank, fake-matrix, info, is-first: is-first, show-lg: show-lg, theo-lv: theo-lv)
    
    if i < info.ds-ma-de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hien-thi-bang-dap-an {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam-data>)
      if results.len() > 0 {
        let total-q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total-q > 0 {
          table(
            columns: (auto, ..info.ds-ma-de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds-ma-de.map(m => [*#m*]),
            ..range(total-q).map(i => {
              let row = ([#(i+1)],)
              for entry in results {
                let p1 = entry.value.part1
                let p2 = entry.value.part2
                let p3 = entry.value.part3
                let ans = if i < p1.len() { p1.at(i, default: "") }
                          else if i < p1.len() + p2.len() { p2.at(i - p1.len(), default: "") }
                          else { p3.at(i - p1.len() - p2.len(), default: "") }
                row += ([#ans],)
              }
              row
            }).flatten()
          )
        }
      }
    }

    context {
      let results = query(<exam-data>)
      if results.any(r => r.value.part4.len() > 0) {
        in-dap-an-tl(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QRCODE ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam-data>)
      let all-qrcode = tao-qr-code-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all-qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

#let tron-de-chi-y(
  banks-matrix, 
  info, 
  seed-goc: 2024,
  show-lg: false, 
  hien-thi-bang-dap-an: true,
  tf-mode: "y-only",
  nlc-mode: "full",
  theo-lv: false,
) = {
  let rut-nlc = ()
  let rut-tf  = ()
  let rut-tln = ()
  let rut-tl  = ()

  for (b-idx, item) in banks-matrix.enumerate() {
    let b = item.bank
    let nlc-seed = seed-goc * 999999 + b-idx * 999999 + 107
    let tf-seed  = seed-goc * 999999 + b-idx * 999999 + 233
    let tln-seed = seed-goc * 999999 + b-idx * 999999 + 357
    let tl-seed  = seed-goc * 999999 + b-idx * 999999 + 491

    if "nlc-dem" in item { rut-nlc += rut-cau-level(b, "NLC", item.nlc-dem, nlc-seed) }
    if "tf-dem"  in item { rut-tf  += rut-cau-level(b, "TF",  item.tf-dem,  tf-seed)  }
    if "tln-dem" in item { rut-tln += rut-cau-level(b, "TLN", item.tln-dem, tln-seed) }
    if "tl-dem"  in item { rut-tl  += rut-cau-level(b, "TL",  item.tl-dem,  tl-seed)  }
  }

  rut-nlc = tron-mang(rut-nlc, seed-goc + 991)
  rut-tf  = tron-mang(rut-tf,  seed-goc + 997)
  rut-tln = tron-mang(rut-tln, seed-goc + 1009)
  rut-tl  = tron-mang(rut-tl,  seed-goc + 1013)

  for (i, ma-de) in info.ds-ma-de.enumerate() {
    let is-first = (i == 0)
    let final-bank = rut-nlc + rut-tf + rut-tln + rut-tl

    let fake-matrix = (
      nlc-loc: q => q.type == "NLC",
      nlc-dem: rut-nlc.len(),
      tf-loc:  q => q.type == "TF",
      tf-dem:  rut-tf.len(),
      tln-loc: q => q.type == "TLN",
      tln-dem: rut-tln.len(),
      tl-loc:  q => q.type == "TL",
      tl-dem:  rut-tl.len(),
    )

    render-test(
      ma-de, 
      final-bank, 
      fake-matrix, 
      info, 
      is-first: is-first, 
      show-lg: show-lg,
      tf-mode: "y-only",
      nlc-mode: "none",
      theo-lv: false,
    )

    if i < info.ds-ma-de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hien-thi-bang-dap-an {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam-data>)
      if results.len() > 0 {
        let total-q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total-q > 0 {
          table(
            columns: (auto, ..info.ds-ma-de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds-ma-de.map(m => [*#m*]),
            ..range(total-q).map(i => {
              let row = ([#(i+1)],)
              for entry in results {
                let p1 = entry.value.part1
                let p2 = entry.value.part2
                let p3 = entry.value.part3
                let ans = if i < p1.len() { p1.at(i, default: "") }
                          else if i < p1.len() + p2.len() { p2.at(i - p1.len(), default: "") }
                          else { p3.at(i - p1.len() - p2.len(), default: "") }
                row += ([#ans],)
              }
              row
            }).flatten()
          )
        }
      }
    }

    context {
      let results = query(<exam-data>)
      if results.any(r => r.value.part4.len() > 0) {
        in-dap-an-tl(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QRCODE ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam-data>)
      let all-qrcode = tao-qr-code-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all-qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

#let tron-de-cung-noi-dung(
  banks-matrix, 
  info, 
  seed-goc: 2024,
  show-lg: false, 
  hien-thi-bang-dap-an: true,
  xao-cau: true,
  xao-pa: true,
  theo-lv: false,
) = {
  let rut-nlc = ()
  let rut-tf  = ()
  let rut-tln = ()
  let rut-tl  = ()

  for (b-idx, item) in banks-matrix.enumerate() {
    let b = item.bank
    let nlc-seed = seed-goc * 999999 + b-idx * 999999 + 107
    let tf-seed  = seed-goc * 999999 + b-idx * 999999 + 233
    let tln-seed = seed-goc * 999999 + b-idx * 999999 + 357
    let tl-seed  = seed-goc * 999999 + b-idx * 999999 + 491

    if "nlc-dem" in item { rut-nlc += rut-cau-level(b, "NLC", item.nlc-dem, nlc-seed) }
    if "tf-dem"  in item { rut-tf  += rut-cau-level(b, "TF",  item.tf-dem,  tf-seed)  }
    if "tln-dem" in item { rut-tln += rut-cau-level(b, "TLN", item.tln-dem, tln-seed) }
    if "tl-dem"  in item { rut-tl  += rut-cau-level(b, "TL",  item.tl-dem,  tl-seed)  }
  }

  rut-nlc = tron-mang(rut-nlc, seed-goc + 991)
  rut-tf  = tron-mang(rut-tf,  seed-goc + 997)
  rut-tln = tron-mang(rut-tln, seed-goc + 1009)
  rut-tl  = tron-mang(rut-tl,  seed-goc + 1013)

  for (i, ma-de) in info.ds-ma-de.enumerate() {
    let is-first = (i == 0)
    let base-seed = int(ma-de)

    let final-nlc = if xao-cau { xao-theo-tuy-chon(rut-nlc, base-seed + 2001, theo-lv: theo-lv) } else { rut-nlc }
    let final-tf  = if xao-cau { xao-theo-tuy-chon(rut-tf,  base-seed + 2011, theo-lv: theo-lv) } else { rut-tf }
    let final-tln = if xao-cau { xao-theo-tuy-chon(rut-tln, base-seed + 2027, theo-lv: theo-lv) } else { rut-tln }
    let final-tl  = if xao-cau { xao-theo-tuy-chon(rut-tl,  base-seed + 2039, theo-lv: theo-lv) } else { rut-tl }

    let final-bank = final-nlc + final-tf + final-tln + final-tl

    let fake-matrix = (
      nlc-loc: q => q.type == "NLC",
      nlc-dem: final-nlc.len(),
      tf-loc:  q => q.type == "TF",
      tf-dem:  final-tf.len(),
      tln-loc: q => q.type == "TLN",
      tln-dem: final-tln.len(),
      tl-loc:  q => q.type == "TL",
      tl-dem:  final-tl.len(),
    )

    render-test(
      ma-de, 
      final-bank, 
      fake-matrix, 
      info, 
      is-first: is-first, 
      show-lg: show-lg,
      theo-lv: theo-lv,
    )

    if i < info.ds-ma-de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hien-thi-bang-dap-an {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam-data>)
      if results.len() > 0 {
        let total-q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total-q > 0 {
          table(
            columns: (auto, ..info.ds-ma-de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds-ma-de.map(m => [*#m*]),
            ..range(total-q).map(i => {
              let row = ([#(i+1)],)
              for entry in results {
                let p1 = entry.value.part1
                let p2 = entry.value.part2
                let p3 = entry.value.part3
                let ans = if i < p1.len() { p1.at(i, default: "") }
                          else if i < p1.len() + p2.len() { p2.at(i - p1.len(), default: "") }
                          else { p3.at(i - p1.len() - p2.len(), default: "") }
                row += ([#ans],)
              }
              row
            }).flatten()
          )
        }
      }
    }

    context {
      let results = query(<exam-data>)
      if results.any(r => r.value.part4.len() > 0) {
        in-dap-an-tl(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QRCODE ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam-data>)
      let all-qrcode = tao-qr-code-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all-qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

// ==========================================
// 6. CÁC HÀM TRANG TRÍ TIÊU ĐỀ
// ==========================================
#let td-bai(title, bsize: 18pt, clorfont: rgb("#0309a7"), bground: rgb("#00ffff3b"), cle: center) = {
  block(
    width: 100%, fill: bground, radius: 8pt, stroke: 0.5pt + rgb("#c405ef"), inset: (x: 25pt, y: 8pt),
    align(cle)[#text(fill: clorfont, size: bsize, weight: "bold", font: "Times New Roman", title)]
  )
}

#let dang(title, stt: "1", kieu: "Dạng") = [
  #grid(
    columns: (auto, 1fr), align: center + horizon, column-gutter: -2pt,
    box(fill: rgb("#72f0b1a2"), radius: 8pt, inset: (x: 10pt, y: 10pt), stroke: 2pt + rgb("#72f0b1a2"))[
      #stack(spacing: 3pt, text(weight: "bold", fill: rgb("#f92a01fd"), size: 1.4em)[#kieu #stt:])
    ],
    box(fill: rgb("#6ff6e484"), width: 100%, radius: 8pt, inset: (x: 15pt, y: 10pt), stroke: 2pt + rgb("#6ff6e484"))[
      #text(weight: "bold", fill: rgb("#e90335f8"), size: 1.4em)[#title]
    ]
  )
  #v(0.5em)
]

#let mau-cap1 = rgb("#1f02c3")
#let mau-cap2 = rgb("#0501f0")
#let mau-cap3 = rgb("#024905")

#let tieu-de(noi-dung, cap: 1) = {
  if cap == 1 {
    block(width: 100%, below: 0.7em, inset: (x: 0pt, y: 8pt), fill: rgb("#f3b40659"), radius: 4pt)[
      #align(left)[#text(weight: "bold", size: 1.3em, fill: mau-cap2)[#noi-dung]]
      #v(0.15em)
    ]
  } else if cap == 2 {
    block(width: 100%, below: 0.5em, inset: (x: 0pt, y: 7pt), fill: rgb("#65e4eb36"), radius: 4pt)[
      #text(weight: "bold", size: 1.2em, fill: mau-cap2)[#noi-dung]
      #v(0.1em)
    ]
  } else if cap == 3 {
    block(width: 100%, below: 0.3em, inset: (x: 0pt, y: 8pt), fill: rgb("#9bf29525"), radius: 3pt)[
      #text(weight: "bold", size: 1.1em, fill: mau-cap3)[▸ #noi-dung]
    ]
  } else {
    block(width: 100%, below: 0.3em, inset: (x: 0pt, y: 4pt))[
      #text(weight: "regular", size: 1.0em, fill: rgb("#424242"))[◦ #noi-dung]
    ]
  }
  v(0.3em)
}

#let chi-muc(title, tsize: 16pt) = {
  set par(first-line-indent: 0pt)
  block(width: 100%)[
    #box(fill: rgb("#00ffff2e"), radius: (top-left: 0pt, top-right: 8pt, bottom-left: 0pt, bottom-right: 0pt), stroke: 0.5pt + rgb("#ee05ea"), inset: (x: 4pt, y: 8pt))[
      #text(fill: rgb("#003B5C"), size: tsize, weight: "bold", font: "Times New Roman", title)
    ]
    #v(-15pt)
    #line(length: 100%, stroke: 2pt + rgb("#FF0066"))
  ]
}

#let luu-y(title, body) = {
  block(width: 100%, below: 0.1em, stroke: (paint: red, thickness: 1pt), inset: (x: 12pt, y: 10pt), radius: 4pt, fill: rgb("#99eee832"))[
    #text(weight: "bold", fill: blue.darken(40%))[#underline(title, offset: 3pt)]
    #v(-0.3em)
    #set text(fill: oklab(36.99%, -0.019, -0.229), style: "italic")
    #body
  ]
  v(1em)
}

#let ps(a, b) = text(size: 1.5em)[#math.display(math.frac([#a], [#b]))]

// ==========================================
// 7. BÍ DANH TIẾNG ANH (API CHUẨN UNIVERSE)
// ==========================================
#let exercise = bai-tap-in-line
#let make-exam-matrix = tron-de-bank-level
#let make-exam-sync = tron-de-cung-noi-dung
#let make-exam-sub-only = tron-de-chi-y
