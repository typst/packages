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

#let mausac = (
  lg : rgb("#a8f6f13c"),
  duong: rgb("#0057b8"),
  cau_pa: rgb("#1505f2"),
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
  let nhom_khac = arr.filter(q => {
    let lv = get-lv(q)
    lv != 1 and lv != 2 and lv != 3
  })

  return tron-mang(nhom1, seed + 11) + tron-mang(nhom2, seed + 22) + tron-mang(nhom3, seed + 33) + tron-mang(nhom_khac, seed + 44)
}

#let xao-theo-tuy-chon(arr, seed, theo_lv: false) = {
  if theo_lv {
    tron-mang-theo-lv(arr, seed)
  } else {
    tron-mang(arr, seed)
  }
}

// ==========================================
// 3. HÀM TẠO QR & HIỂN THỊ LỜI GIẢI
// ==========================================
#let tao-QRcode-key(results) = {
  let all_content = ""
  for entry in results {
    let ma_de = str(entry.value.seed)
    let part1 = entry.value.part1.join("")
    let part2 = entry.value.part2.join("")
    let part3 = entry.value.part3.map(str).join("|")
    all_content += ma_de + "\n" + part1 + "\n" + part2 + "\n" + part3 + "\n"
  }
  return all_content
}

#let hienthi-lg(q, q_type, idx, seed, opt_indices: none, tf_indices: none) = {
  toan-setup({
    v(-0.4em)
    block(
      width: 100%, 
      inset: (y: 0.5em, x: 0.5em, left: 8pt, right: 8pt), 
      fill: mausac.lg, 
      radius: (right: 4pt),
      stroke: (left: 2pt + mausac.duong)
    )[
      #v(0.2em)
      #if q_type == "NLC" {
        let correct_idx = if opt_indices != none { opt_indices.position(i => i == q.da) } else { q.da }
        text(fill: blue.darken(100%), size: 11pt)[*Đáp án: #to-abc(correct_idx)*\ ] 
        text(fill: red.darken(0%), size: 15pt, font: "UTM A&S Graceland")[*Lời giải:*] 
      } else if q_type == "TF" or q_type == "tf" {
        let correct_ans = if tf_indices != none { to-ds(tf_indices.map(i => q.da.at(i))) } else { to-ds(q.da) }
        text(fill: blue.darken(100%), size: 11pt)[*Đáp án: #correct_ans*\ ] 
        text(fill: red.darken(0%), size: 15pt, font: "UTM A&S Graceland")[ *Lời giải:*]
      } else if q_type == "TLN" {
        text(fill: blue.darken(100%), size: 11pt)[*Kết quả: #q.da*]
        text(fill: red.darken(0%), size: 15pt, font: "UTM A&S Graceland")[\ *Lời giải:*]
      } else if q_type == "TL" {
        text(fill: red.darken(0%), weight: "bold", font: "UTM A&S Graceland", size: 16pt)[*Lời giải:*]
      }
      
      #if (q_type == "TF" or q_type == "tf") and type(q.lg) == array {
        let indices = if tf_indices != none { tf_indices } else { range(q.lg.len()) }
        let labels = ("a)", "b)", "c)", "d)")
        
        list(
          marker: none,
          spacing: 0.7em,
          ..indices.enumerate().map(((new_i, orig_i)) => {
            let is_true = q.da.at(orig_i) == 1
            let status_str = if is_true { "Đúng" } else { "Sai" }
            let lg_content = if orig_i < q.lg.len() { q.lg.at(orig_i) } else { [] }
            
            [#text(fill: mausac.cau_pa, weight: "bold")[#labels.at(new_i) - #status_str:] #text(fill: blue.darken(100%), style: "italic")[#lg_content]]
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
#let render_sub_sol(q, type_str, show_lg) = {
  if not show_lg { return }
  v(-0.8em)
  block(
    width: 100%,
    stroke: (left: 2.5pt + mausac.duong),
    fill: mausac.lg,
    inset: (x: 10pt, y: 8pt),
    radius: (right: 4pt),
    breakable: true
  )[
    #set par(leading: 0.65em)
    #if type_str == "NLC" [
      #text(fill: mausac.duong, weight: "bold")[► Lời giải: \ ] 
      #if "lg" in q and q.lg != none and q.lg != [] [ #q.lg ] else [ Chưa có lời giải.]
    ]
    #if type_str == "TF" [
      #text(fill: mausac.duong, weight: "bold")[► Đáp án:] #text(fill: mausac.daT, weight: "bold")[#to-ds(q.da)] \
      #if "lg" in q and q.lg != none and q.lg != [] [
        #if type(q.lg) == array [
          #let labels = ("a)", "b)", "c)", "d)")
          #list(
            marker: none,
            spacing: 0.7em,
            ..q.lg.enumerate().map(((i, lg_item)) => {
              let is_true = q.da.at(i) == 1
              let status_str = if is_true { "Đúng" } else { "Sai" }
              [#text(fill: mausac.cau_pa, weight: "bold")[#labels.at(i)  #status_str]\ #lg_item]
            })
          )
        ] else [
          #q.lg
        ]
      ] else [ Chưa có lời giải.]
    ]
    #if type_str == "TLN" [
      #text(fill: mausac.duong, weight: "bold")[► Kết quả:] #text(fill: mausac.daT, weight: "bold")[#q.da] \
      #if "lg" in q and q.lg != none and q.lg != [] [ #v(0.01em)#q.lg #v(0.2em)] else [ Chưa có lời giải.]
    ]
    #if type_str == "TL" [
      #text(fill: mausac.duong, weight: "bold")[► Lời giải chi tiết:] \
      #if "lg" in q and q.lg != none and q.lg != [] [ #q.lg ] else [ Chưa có lời giải.]
    ]
  ]
}

#let baitap_inline(
  cm: 1,
  bank_data, 
  title: none,
  seed: 0,
  num_nlc: none, 
  num_tf: none, 
  num_tln: none, 
  num_tl: none,
  show_lg: false,
  dong_ke: none,
  co_NLC: none,
  co_tf: none,
  co_TLN: none,
  co_TL: none,
  theo_lv: false,
) = {
  let cfg_nlc = if num_nlc != none { num_nlc } else { co_NLC }
  let cfg_tf  = if num_tf != none { num_tf } else { co_tf }
  let cfg_tln = if num_tln != none { num_tln } else { co_TLN }
  let cfg_tl  = if num_tl != none { num_tl } else { co_TL }

  let actual_bank = if type(bank_data) == dictionary and "data" in bank_data { 
    bank_data.data 
  } else if type(bank_data) == module {
    bank_data.data
  } else { 
    bank_data 
  }
  
  let std_bank = actual_bank.map(q => {
    if "cau_hoi_con" in q and type(q.cau_hoi_con) == array and q.cau_hoi_con.len() > 0 { 
      let is_c = q.at("is_chum", default: q.cau_hoi_con.len() > 1)
      let dk = q.at("du_kien", default: none)
      let q_type = q.at("type", default: q.cau_hoi_con.at(0).at("type", default: "NLC"))
      let q_lv = q.at("lv", default: 1)
      (
        type: q_type,
        lv: q_lv,
        is_chum: is_c,
        du_kien: dk,
        cau_hoi_con: q.cau_hoi_con
      )
    } else { 
      (
        type: q.at("type", default: "NLC"),
        lv: q.at("lv", default: 1),
        is_chum: false, 
        du_kien: none, 
        cau_hoi_con: (q,)
      ) 
    }
  })

  let rut_cau(q_type, dem_config, sub_seed) = {
    let loc_ques = std_bank.filter(q => q.type == q_type)
    if loc_ques.len() == 0 or dem_config == none or dem_config == 0 { return () }

    let get_q_lv(item) = {
      if "lv" in item { item.lv }
      else if item.cau_hoi_con.len() > 0 and "lv" in item.cau_hoi_con.at(0) { item.cau_hoi_con.at(0).lv }
      else { 1 }
    }

    if type(dem_config) == int { 
      let processing = if seed == none { loc_ques } else { xao-theo-tuy-chon(loc_ques, seed + sub_seed, theo_lv: theo_lv) }
      return processing.slice(0, calc.min(dem_config, processing.len())) 
    }
    
    if type(dem_config) == array {
      let nb_req = dem_config.at(0, default: 0)
      let th_req = dem_config.at(1, default: 0)
      let vd_req = dem_config.at(2, default: 0)

      let b_nb = loc_ques.filter(q => get_q_lv(q) == 1)
      let b_th = loc_ques.filter(q => get_q_lv(q) == 2)
      let b_vd = loc_ques.filter(q => get_q_lv(q) == 3)

      if seed != none {
        b_nb = tron-mang(b_nb, seed + sub_seed + 11)
        b_th = tron-mang(b_th, seed + sub_seed + 22)
        b_vd = tron-mang(b_vd, seed + sub_seed + 33)
      }

      let res_nb = b_nb.slice(0, calc.min(nb_req, b_nb.len()))
      let res_th = b_th.slice(0, calc.min(th_req, b_th.len()))
      let res_vd = b_vd.slice(0, calc.min(vd_req, b_vd.len()))

      return res_nb + res_th + res_vd
    }

    return loc_ques
  }

  let ds_NLC = rut_cau("NLC", cfg_nlc, 107)
  let ds_TF  = rut_cau("TF", cfg_tf, 233)
  let ds_TLN = rut_cau("TLN", cfg_tln, 357)
  let ds_TL  = rut_cau("TL", cfg_tl, 491)

  toan-setup({
    if title != none and title != "" {
      v(0.5em)
      align(center)[#text(fill: mausac.duong, weight: "bold", size: 13pt)[#title]]
      v(0.3em)
    }

    // PHẦN I: NLC
    if ds_NLC.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 {
        text(fill: mausac.cau_pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẮC NGHIỆM NHIỀU LỰA CHỌN]
      }
      let c_idx = 0
      for item in ds_NLC {
        if item.du_kien != none and item.du_kien != [] {
          let n_sub = item.cau_hoi_con.len()
          let start_c = c_idx + 1
          let end_c = c_idx + n_sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mausac.cau_pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mausac.cau_pa, weight: "bold")[Dữ kiện dùng cho từ Câu #start_c đến Câu #end_c:] \
              #v(0.1em) #item.du_kien
            ]
          ]
        }
        
        for q in item.cau_hoi_con {
          c_idx += 1
          v(-0.4em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) },
              gutter: 3pt,
              row-gutter: 8pt,
              align: (left + top, center + top),
              [
                #v(-0.4em)
                #text(fill: mausac.cau_pa, weight: "bold")[Câu #c_idx.] #q.nd \
                #v(-0.3em)
                
                #let is_img_option = q.pa.any(opt => {
                  let r = repr(opt)
                  r.contains("image(") or r.contains("cetz") or r.contains("canvas")
                })

                #if is_img_option [
                  #let n_cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n_cols,
                    column-gutter: 0.8em,
                    row-gutter: 0.5em,
                    align: center + horizon,
                    ..q.pa.enumerate().map(((i, v)) => {
                      let is_correct = show_lg and ("da" in q) and (i == q.da)
                      let label_text = [#h(1em)*#to-abc(i).*]
                      let formatted_label = if is_correct { underline(text(fill: mausac.daT, weight: "bold")[#label_text]) } else { text(fill: mausac.cau_pa)[#label_text] }
                      align(left)[#grid(columns:(auto,1fr), column-gutter:10pt, [#formatted_label], [#v])]
                    })
                  ) 
                ] else [
                  #let n_cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n_cols,
                    row-gutter: 0.95em,
                    column-gutter: 0.1em,
                    align: if n_cols > 1 { left + horizon } else { left },
                    inset: (x: 1em),
                    ..q.pa.enumerate().map(((i, v)) => {
                      let is_correct = show_lg and ("da" in q) and (i == q.da)
                      let label_text = [*#to-abc(i).*]
                      let formatted_label = if is_correct { underline(text(fill: mausac.daT, weight: "bold")[#label_text]) } else { text(fill: mausac.cau_pa)[#label_text] }
                      box[#grid(columns: (auto, 1fr), gutter: 2pt, align: left, formatted_label, v)]
                    })
                  ) #v(0.5em)
                ]
              ],
              if has_img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } ]
            )
          ]
          v(-0.7em)
          render_sub_sol(q, "NLC", show_lg)
        }
      }
    }

    // PHẦN II: TF
    if ds_TF.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.1em)
      if cm == 1 { text(fill: mausac.cau_pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẢ LỜI ĐÚNG/SAI] }
      let c_idx = 0
      for item in ds_TF {
        if item.du_kien != none and item.du_kien != [] {
          let n_sub = item.cau_hoi_con.len()
          let start_c = c_idx + 1
          let end_c = c_idx + n_sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mausac.cau_pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mausac.cau_pa, weight: "bold")[Dữ kiện dùng cho Câu #start_c đến Câu #end_c:] \
              #v(0.1em) #item.du_kien
            ]
          ]
        }
        for q in item.cau_hoi_con {
          c_idx += 1
          v(-0.6em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + top),
              [
                #v(0.2em)
                #text(fill: mausac.cau_pa, weight: "bold")[Câu #c_idx.] #q.nd \
                #list(
                  marker: none, 
                  spacing: 0.7em, 
                  ..q.ytf.enumerate().map(((i, sq)) => {
                    let label_text = [#("a)", "b)", "c)", "d)").at(i)]
                    let formatted_label = text(fill: mausac.cau_pa, weight: "bold")[#h(0.5em) #label_text]
                    let ans_str = if show_lg and ("da" in q) and type(q.da) == array and i < q.da.len() {
                      if q.da.at(i) == 1 { " [Đúng]" } else { " [Sai]" }
                    } else { "" }
                    [#formatted_label #sq #text(fill: mausac.daT, weight: "bold")[#ans_str]]
                  })
                )
              ],
              if has_img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } ]
            )
          ]
          v(-0.8em)
          render_sub_sol(q, "TF", show_lg)
        }
      }
    }

    // PHẦN III: TLN
    if ds_TLN.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 { text(fill: mausac.cau_pa, weight: "bold", size: 13pt)[► BÀI TẬP TRẢ LỜI NGẮN] }
      let c_idx = 0
      for item in ds_TLN {
        if item.du_kien != none and item.du_kien != [] {
          let n_sub = item.cau_hoi_con.len()
          let start_c = c_idx + 1
          let end_c = c_idx + n_sub
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mausac.cau_pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mausac.cau_pa, weight: "bold", style: "italic")[Dữ kiện dùng cho Câu #start_c đến Câu #end_c:] \
              #v(0.1em) #text(style: "italic")[#item.du_kien]
            ]
          ]
        }
        for q in item.cau_hoi_con {
          c_idx += 1
          v(-0.8em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              row-gutter: 10pt,
              align: (left + top, center + horizon),
              [
                #v(-0.1em)
                #text(fill: mausac.cau_pa, weight: "bold")[Câu #c_idx.] #q.nd
                #v(0.1em)
                #if not show_lg [
                  #grid(
                    columns: (auto, auto), 
                    column-gutter: 8pt, 
                    align: horizon, 
                    [*Trả lời:*], 
                    [#(for i in range(4) { box(width: 1.2em, height: 1.2em, stroke: 0.4pt + gray.darken(80%), radius: 1pt); h(2pt) })]
                  )
                  #v(-0.4em)
                  #let num_lines = if dong_ke == none or dong_ke == 0 { none 
                  } else if "dong_ke" in q and q.dong_ke != none { q.dong_ke 
                  } else { dong_ke }
                  #if num_lines != none and type(num_lines) == int and num_lines > 0 {
                    v(0.3em)
                    for i in range(num_lines) {
                      v(0.4em)
                      line(length: 100%, stroke: (dash: "dotted", thickness: 0.75pt, paint: gray.darken(80%)))
                    }
                  }
                ]
              ],
              if has_img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } #v(0.2em)]
            )
          ]
          v(-0.4em)
          render_sub_sol(q, "TLN", show_lg)
        }
      }
    }

    // PHẦN IV: TL
    if ds_TL.len() > 0 {
      set par(first-line-indent: 0pt)
      v(-0.5em)
      if cm == 1 { text(fill: mausac.cau_pa, weight: "bold", size: 11pt)[► BÀI TẬP TỰ LUẬN] }
      let c_idx = 0
      for item in ds_TL {
        for q in item.cau_hoi_con {
          c_idx += 1
          v(-0.4em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + top),
              [
                #v(-0.4em)
                #text(fill: mausac.cau_pa, weight: "bold")[Câu #c_idx.] #q.nd
                #v(0.5em)
              ],
              if has_img [ #if type(q.hv) == content { q.hv } else { image(q.hv, width: 4.5cm) } #v(1em)]
            )
            #v(-0.8em)
            #if not show_lg [
              #let num_lines = if dong_ke == none or dong_ke == 0 { none
              } else if "dong_ke" in q and q.dong_ke != none { q.dong_ke
              } else { dong_ke }
              #if num_lines != none and type(num_lines) == int and num_lines > 0 {
                v(0.3em)
                for i in range(num_lines) {
                  v(0.15em)
                  line(length: 100%, stroke: (dash: "dotted", thickness: 0.75pt, paint: gray.darken(80%)))
                  v(0.35em)
                }
              }
            ]
            #v(0.4em)
          ]
          v(-0.8em)
          render_sub_sol(q, "TL", show_lg)
        }
      }
    }
  })
}

// ==========================================
// 5. TRỘN ĐỀ THI
// ==========================================
#let render_test(
  ma_de, 
  q_bank, 
  matrix, 
  info, 
  is_first: false, 
  show_lg: false,
  tf_mode: "full",
  nlc_mode: "full",
  theo_lv: false,
) = {
  if not is_first {
    context { counter(page).update(1) }
  }

  let seed = int(ma_de)

  let raw_NLC = q_bank.filter(matrix.NLC_loc)
  let xao_NLC = xao-theo-tuy-chon(raw_NLC, seed + 107, theo_lv: theo_lv)
  let NLC_dem = calc.min(matrix.NLC_dem, xao_NLC.len())
  let s_NLC = xao_NLC.slice(0, NLC_dem)

  let raw_tf = q_bank.filter(matrix.tf_loc)
  let xao_tf = xao-theo-tuy-chon(raw_tf, seed + 233, theo_lv: theo_lv)
  let tf_dem = calc.min(matrix.tf_dem, xao_tf.len())
  let s_tf = xao_tf.slice(0, tf_dem)

  let raw_TLN = q_bank.filter(matrix.TLN_loc)
  let xao_TLN = xao-theo-tuy-chon(raw_TLN, seed + 357, theo_lv: theo_lv)
  let TLN_dem = calc.min(matrix.TLN_dem, xao_TLN.len())
  let s_TLN = xao_TLN.slice(0, TLN_dem)

  let raw_TL = q_bank.filter(matrix.TL_loc)
  let xao_TL = xao-theo-tuy-chon(raw_TL, seed + 491, theo_lv: theo_lv)
  let TL_dem = calc.min(matrix.TL_dem, xao_TL.len())
  let s_TL = xao_TL.slice(0, TL_dem)

  let part1_ans = ()
  let part2_ans = ()
  let part3_ans = ()
  let part4_ans = ()

  toan-setup({
    set page(paper: "a4", margin: 1.2cm, footer: context [
      #set text(size: 9pt); *#h(1fr) Trang #counter(page).display() - Mã đề #ma_de*
    ])

    grid(
      columns: (1.2fr, 1fr),
      gutter: 10pt,
      align(center)[
        #text(size: 11pt)[#info.so_gd] \
        #text(size: 11pt)[#strong(info.truong)] \
        #v(-0.5em)
        #line(length: 40%, stroke: 0.5pt)
      ],
      align(center)[
        #text(size: 11pt)[#strong(info.ky_thi)] \
        #text(size: 11pt)[Môn: #strong[#info.mon]] \
        #text(size: 10pt)[Thời gian: #emph[#info.thoi_gian]]
      ]
    )
    grid(columns: (1fr, auto),
      [Họ tên: ..............................................................................\ 
      #v(0.1em)
      Lớp: ................
      Số báo danh: .......................
      Phòng thi: ............],
      box(stroke: 0.8pt + black, inset: (x: 6pt, y: 6pt))[#strong[Mã đề: #ma_de]]
    )
    line(length: 100%, stroke: 0.5pt)

    if s_NLC.len() > 0 {
      let tong_so_cau = s_NLC.fold(0, (acc, q) => {
        if "is_chum" in q and q.is_chum == true and "cau_hoi_con" in q { acc + q.cau_hoi_con.len() } else { acc + 1 }
      })
      set par(first-line-indent: 0pt)
      v(-0.1em)
      text(fill: mausac.cau_pa)[*► Thí sinh trả lời từ câu 1 đến câu #tong_so_cau.* #emph[*Mỗi câu thí sinh chỉ được chọn một phương án.*]#v(0.2em)]
      
      let c_idx = 0
      for item in s_NLC {
        let is_item_chum = "is_chum" in item and item.is_chum == true and "cau_hoi_con" in item
        if is_item_chum {
          let n_sub = item.cau_hoi_con.len()
          let start_num = c_idx + 1
          let end_num = c_idx + n_sub
          v(0.2em)
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mausac.cau_pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mausac.cau_pa)[*Dữ kiện dùng cho từ Câu #start_num đến Câu #end_num:*] \
              #v(0.1em) #item.du_kien
            ]
          ]
        }

        let ds_cau_can_ve = if is_item_chum { item.cau_hoi_con } else { (item,) }

        for q in ds_cau_can_ve {
          let opt_indices = if seed == 0 or nlc_mode == "none" { range(4) } else { tron-mang(range(4), seed + c_idx * 73) }
          let new_opts = opt_indices.map(i => q.pa.at(i))
          part1_ans.push(to-abc(opt_indices.position(i => i == q.da)))
          
          v(-0.2em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) },
              gutter: 10pt,
              align: (left + top, center + horizon),
              [
                #v(-0.3em)
                #text(fill: mausac.cau_pa)[*Câu #(c_idx + 1).*] #q.nd \
                #v(-0.3em)
                #let is_img_option = new_opts.any(opt => {
                  let r = repr(opt)
                  r.contains("image(") or r.contains("cetz") or r.contains("canvas")
                })
                #if is_img_option [
                  #grid(
                    columns: (1fr, 1fr, 1fr, 1fr),
                    column-gutter: 0.8em, row-gutter: 0.5em, align: center + horizon,
                    ..new_opts.enumerate().map(((i, v)) => [#align(center)[#text(fill: mausac.cau_pa)[*#to-abc(i).*]) #v]])
                  )
                ] else [
                  #let n_cols = if "cot" in q { q.cot } else { 4 }
                  #grid(
                    columns: (1fr,) * n_cols, row-gutter: 0.6em, column-gutter: 1.2em, align: left + horizon,
                    ..new_opts.enumerate().map(((i, v)) => [#text(fill: mausac.cau_pa)[#h(1em)*#to-abc(i).*] #v])
                  )
                ]
              ],
              if has_img [ #align(center + top)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
            )
          ]
          v(-0.8em)
          if show_lg and "lg" in q and q.lg != [] { hienthi-lg(q, "NLC", c_idx, seed, opt_indices: opt_indices) }
          v(-0.2em)
          c_idx += 1
        }
      }
    }

    if s_tf.len() > 0 {
      set par(first-line-indent: 0pt)
      v(0.5em); text(mausac.cau_pa)[*► Thí sinh trả lời từ câu 1 đến câu #s_tf.len().* #emph[ *Trong mỗi ý a), b), c), d) của mỗi câu, thí sinh chọn đúng hoặc sai.*]]
      for (idx, q) in s_tf.enumerate() {
        let sub_indices = if tf_mode == "none" { range(4) }
        else if tf_mode == "y_only" {
          let content_str = repr(q.nd) + repr(q.ytf)
          let content_hash = calc.rem(content_str.len() * 265435761, 123456789)
          tron-mang(range(4), content_hash * 31 + int(ma_de) * 7919)
        } else { tron-mang(range(4), seed + idx * 109 + int(ma_de) * 10000) }
        let new_subs = sub_indices.map(i => q.ytf.at(i))
        part2_ans.push(to-ds(sub_indices.map(i => q.da.at(i))))
        v(-0.3em)
        block(width: 100%, inset: (y: 0.3em), breakable: true)[
          #let has_img = "hv" in q and q.hv != none and q.hv != ""
          #grid(
            columns: if has_img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + horizon),
            [
              #text(fill: mausac.cau_pa)[*Câu #(idx + 1).* ]#q.nd \
              #list(marker: none, spacing: 0.7em, ..new_subs.enumerate().map(((i, sq)) => [#h(0.5em) #text(fill: mausac.cau_pa)[#strong[#("a)", "b)", "c)", "d)").at(i)]] #sq]))
            ],
            if has_img [ #align(center + horizon)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
          )
        ]
        v(-0.4em)
        if show_lg and "lg" in q and q.lg != [] { hienthi-lg(q, "TF", idx + s_NLC.len(), seed, tf_indices: sub_indices) }
        v(-0.3em)
      }
    }

    if s_TLN.len() > 0 {
      let tong_so_cau = s_TLN.fold(0, (acc, q) => {
        if "is_chum" in q and q.is_chum == true and "cau_hoi_con" in q { acc + q.cau_hoi_con.len() } else { acc + 1 }
      })
      set par(first-line-indent: 0pt)
      v(0.5em); text(fill: mausac.cau_pa)[*► Thí sinh trả lời từ câu 1 đến câu #tong_so_cau.*]
      let c_idx = 0
      for item in s_TLN {
        let is_item_chum = "is_chum" in item and item.is_chum == true and "cau_hoi_con" in item
        let ds_cau_can_ve = if is_item_chum { item.cau_hoi_con } else { (item,) }

        if is_item_chum {
          let n_sub = item.cau_hoi_con.len()
          let start_num = c_idx + 1
          let end_num = c_idx + n_sub
          v(0.2em)
          block(width: 100%, breakable: false)[
            #rect(width: 100%, fill: rgb("#f8f9fa"), stroke: (left: 2.5pt + mausac.cau_pa), inset: (x: 8pt, y: 6pt), radius: (right: 3pt))[
              #text(fill: mausac.cau_pa)[*Dữ kiện dùng cho từ Câu #start_num đến Câu #end_num:*] \
              #v(0.1em) #item.du_kien
            ]
          ]
        }

        for q in ds_cau_can_ve {
          part3_ans.push(q.da)
          v(-0.5em)
          block(width: 100%, inset: (y: 0.3em), breakable: true)[
            #let has_img = "hv" in q and q.hv != none and q.hv != ""
            #grid(
              columns: if has_img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + horizon),
              [
                #text(fill: mausac.cau_pa)[*Câu #(c_idx + 1).* ]#q.nd
                #if not show_lg [
                  #v(-0.4em)
                  #pad(left: 0em)[
                    #grid(columns: (auto, auto), column-gutter: 10pt, align: (left + horizon, left + horizon), [*Trả lời:*], [#(for i in range(4) { box(width: 1.2em, height: 1.2em, stroke: 0.3pt); h(3pt) })])
                  ]
                ]
              ],
              if has_img [ #align(center + horizon)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
            )
          ]
          v(-1em)
          if show_lg and "lg" in q and q.lg != [] { hienthi-lg(q, "TLN", c_idx + s_NLC.len() + s_tf.len(), seed) }
          v(-0.2em)
          c_idx += 1
        }
      }
    }

    if s_TL.len() > 0 {
      set par(first-line-indent: 0pt)
      v(0.3em); text(mausac.cau_pa)[*► TỰ LUẬN (#s_TL.len() câu)*]
      v(-0.3em)
      for (idx, q) in s_TL.enumerate() {
        part4_ans.push((nd: q.nd, lg: q.lg))
        v(-0.3em)
        block(width: 100%, inset: (y: 0.3em), breakable: true)[
          #let has_img = "hv" in q and q.hv != none and q.hv != ""
          #grid(
            columns: if has_img { (1fr, auto) } else { (1fr,) }, gutter: 10pt, align: (left + top, center + top),
            [ #text(fill: mausac.cau_pa)[*Câu #(idx + 1).* ] #q.nd \ #v(-0.3em) ],
            if has_img [ #align(center + top)[#if type(q.hv) == content [ #q.hv ] else if type(q.hv) == str [ #image(q.hv, width: 4.5cm) ]] ]
          )
          #if show_lg and "lg" in q and q.lg != [] { hienthi-lg(q, "TL", idx, seed) }
          #v(-0.3em)
        ]
      }
    }

    align(center)[#text(size: 11pt)[#strong[---- hết ----]]]
  })

  [#metadata((
    seed: ma_de,
    part1: part1_ans,
    part2: part2_ans,
    part3: part3_ans,
    part4: part4_ans
  )) <exam_data>]
}

#let in_dapan_TL(results) = {
  context {
    counter(page).update(1)
    set page(footer: none)
  }
  toan-setup({
    align(center)[#text(20pt, weight: "bold")[HƯỚNG DẪN CHẤM TỰ LUẬN]]
    v(-0.2em)
    for entry in results {
      let ma_de = str(entry.value.seed)
      let lg_TL = entry.value.part4
      if lg_TL.len() > 0 {
        align(left)[
          #block(fill: gray.lighten(80%), inset: 5pt, radius: 4pt)[
            #text(14pt, weight: "bold")[Mã đề: #ma_de]
          ]
          #v(-0.51em)
        ]
        for (idx, ans) in lg_TL.enumerate() {
          align(left)[
            #text(12pt)[*Câu #(idx + 1). * #ans.nd]
            #v(-0.5em)
            #text(11pt, fill: blue.darken(40%))[*Lời giải:* ]
            #v(-0.5em)
            #block(inset: 12pt, fill: yellow.lighten(95%), radius: 4pt, width: 100%)[
              #text(fill: mausac.cau_pa, style: "italic")[#ans.lg]
            ]
            #v(-0.5em)
          ]
        }
      }
    }
  })
}

#let rut_cauLevel(raw_bank, q_type, dem_config, seed) = {
  let actual_bank = if type(raw_bank) == dictionary and "data" in raw_bank { raw_bank.data }
  else if type(raw_bank) == module { raw_bank.data } else { raw_bank }

  let loc_ques = actual_bank.filter(q => q.type == q_type)
  if loc_ques.len() == 0 { return () }

  let bank_chum = loc_ques.filter(q => "is_chum" in q and q.is_chum == true)
  let bank_don  = loc_ques.filter(q => not ("is_chum" in q and q.is_chum == true))

  let safe-slice(arr, req_count) = {
    if req_count <= 0 or arr.len() == 0 { return () }
    let take = calc.min(req_count, arr.len())
    return arr.slice(0, take)
  }

  let xao_chum = tron-mang(bank_chum, seed)
  let xao_don  = tron-mang(bank_don, seed + 101)

  let nb_req = 0
  let th_req = 0
  let vd_req = 0
  let chum_req = 0

  if type(dem_config) == array {
    nb_req = dem_config.at(0, default: 0)
    th_req = dem_config.at(1, default: 0)
    vd_req = dem_config.at(2, default: 0)
  } else if type(dem_config) == dictionary {
    let don_arr = dem_config.at("don", default: (0, 0, 0))
    nb_req = don_arr.at(0, default: 0)
    th_req = don_arr.at(1, default: 0)
    vd_req = don_arr.at(2, default: 0)
    chum_req = dem_config.at("chum", default: 0)
  } else if type(dem_config) == int {
    nb_req = dem_config
  }

  let res_chum = safe-slice(xao_chum, chum_req)

  let b_nb = xao_don.filter(q => ("lv" in q and q.lv == 1) or not ("lv" in q))
  let b_th = xao_don.filter(q => "lv" in q and q.lv == 2)
  let b_vd = xao_don.filter(q => "lv" in q and q.lv == 3)

  let res_don = safe-slice(b_nb, nb_req) + safe-slice(b_th, th_req) + safe-slice(b_vd, vd_req)

  return res_chum + res_don
}

#let tron_de_bankLevel(banks_matrix, info, show_lg: false, hienthi_bangdapan: true, theo_lv: false) = {
  for (i, ma_de) in info.ds_ma_de.enumerate() {
    let is_first = (i == 0)
    let base_seed = int(ma_de)
    
    let rut_NLC = ()
    let rut_tf = ()
    let rut_TLN = ()
    let rut_TL = ()

    for (b_idx, item) in banks_matrix.enumerate() {
      let b = item.bank
      let NLC_seed = base_seed * 999999 + b_idx * 999999 + 107
      let tf_seed  = base_seed * 999999 + b_idx * 999999 + 233
      let TLN_seed = base_seed * 999999 + b_idx * 999999 + 357
      let TL_seed  = base_seed * 999999 + b_idx * 999999 + 491

      if "NLC_dem" in item { rut_NLC += rut_cauLevel(b, "NLC", item.NLC_dem, NLC_seed) }
      if "tf_dem"  in item { rut_tf  += rut_cauLevel(b, "TF",  item.tf_dem,  tf_seed)  }
      if "TLN_dem" in item { rut_TLN += rut_cauLevel(b, "TLN", item.TLN_dem, TLN_seed) }
      if "TL_dem"  in item { rut_TL  += rut_cauLevel(b, "TL",  item.TL_dem,  TL_seed)  }
    }

    rut_NLC = xao-theo-tuy-chon(rut_NLC, base_seed + 991,  theo_lv: theo_lv)
    rut_tf  = xao-theo-tuy-chon(rut_tf,  base_seed + 997,  theo_lv: theo_lv)
    rut_TLN = xao-theo-tuy-chon(rut_TLN, base_seed + 1009, theo_lv: theo_lv)
    rut_TL  = xao-theo-tuy-chon(rut_TL,  base_seed + 1013, theo_lv: theo_lv)

    let final_bank = rut_NLC + rut_tf + rut_TLN + rut_TL
    
    let fake_matrix = (
      NLC_loc: q => q.type == "NLC",
      NLC_dem: rut_NLC.len(),
      tf_loc:  q => q.type == "TF",
      tf_dem:  rut_tf.len(),
      TLN_loc: q => q.type == "TLN",
      TLN_dem: rut_TLN.len(),
      TL_loc:  q => q.type == "TL",
      TL_dem:  rut_TL.len(),
    )

    render_test(ma_de, final_bank, fake_matrix, info, is_first: is_first, show_lg: show_lg, theo_lv: theo_lv)
    
    if i < info.ds_ma_de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hienthi_bangdapan {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam_data>)
      if results.len() > 0 {
        let total_q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total_q > 0 {
          table(
            columns: (auto, ..info.ds_ma_de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds_ma_de.map(m => [*#m*]),
            ..range(total_q).map(i => {
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
      let results = query(<exam_data>)
      if results.any(r => r.value.part4.len() > 0) {
        in_dapan_TL(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QR ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam_data>)
      let all_qrcode = tao-QRcode-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all_qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

#let tron_de_chiY(
  banks_matrix, 
  info, 
  seed_goc: 2024,
  show_lg: false, 
  hienthi_bangdapan: true,
  tf_mode: "y_only",
  nlc_mode: "full",
  theo_lv: false,
) = {
  let rut_NLC = ()
  let rut_tf  = ()
  let rut_TLN = ()
  let rut_TL  = ()

  for (b_idx, item) in banks_matrix.enumerate() {
    let b = item.bank
    let NLC_seed = seed_goc * 999999 + b_idx * 999999 + 107
    let tf_seed  = seed_goc * 999999 + b_idx * 999999 + 233
    let TLN_seed = seed_goc * 999999 + b_idx * 999999 + 357
    let TL_seed  = seed_goc * 999999 + b_idx * 999999 + 491

    if "NLC_dem" in item { rut_NLC += rut_cauLevel(b, "NLC", item.NLC_dem, NLC_seed) }
    if "tf_dem"  in item { rut_tf  += rut_cauLevel(b, "TF",  item.tf_dem,  tf_seed)  }
    if "TLN_dem" in item { rut_TLN += rut_cauLevel(b, "TLN", item.TLN_dem, TLN_seed) }
    if "TL_dem"  in item { rut_TL  += rut_cauLevel(b, "TL",  item.TL_dem,  TL_seed)  }
  }

  rut_NLC = tron-mang(rut_NLC, seed_goc + 991)
  rut_tf  = tron-mang(rut_tf,  seed_goc + 997)
  rut_TLN = tron-mang(rut_TLN, seed_goc + 1009)
  rut_TL  = tron-mang(rut_TL,  seed_goc + 1013)

  for (i, ma_de) in info.ds_ma_de.enumerate() {
    let is_first = (i == 0)
    let final_bank = rut_NLC + rut_tf + rut_TLN + rut_TL

    let fake_matrix = (
      NLC_loc: q => q.type == "NLC",
      NLC_dem: rut_NLC.len(),
      tf_loc:  q => q.type == "TF",
      tf_dem:  rut_tf.len(),
      TLN_loc: q => q.type == "TLN",
      TLN_dem: rut_TLN.len(),
      TL_loc:  q => q.type == "TL",
      TL_dem:  rut_TL.len(),
    )

    render_test(
      ma_de, 
      final_bank, 
      fake_matrix, 
      info, 
      is_first: is_first, 
      show_lg: show_lg,
      tf_mode: "y_only",
      nlc_mode: "none",
      theo_lv: false,
    )

    if i < info.ds_ma_de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hienthi_bangdapan {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam_data>)
      if results.len() > 0 {
        let total_q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total_q > 0 {
          table(
            columns: (auto, ..info.ds_ma_de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds_ma_de.map(m => [*#m*]),
            ..range(total_q).map(i => {
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
      let results = query(<exam_data>)
      if results.any(r => r.value.part4.len() > 0) {
        in_dapan_TL(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QR ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam_data>)
      let all_qrcode = tao-QRcode-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all_qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

#let tron_de_cungNoiDung(
  banks_matrix, 
  info, 
  seed_goc: 2024,
  show_lg: false, 
  hienthi_bangdapan: true,
  xao_cau: true,
  xao_pa: true,
  theo_lv: false,
) = {
  let rut_NLC = ()
  let rut_tf  = ()
  let rut_TLN = ()
  let rut_TL  = ()

  for (b_idx, item) in banks_matrix.enumerate() {
    let b = item.bank
    let NLC_seed = seed_goc * 999999 + b_idx * 999999 + 107
    let tf_seed  = seed_goc * 999999 + b_idx * 999999 + 233
    let TLN_seed = seed_goc * 999999 + b_idx * 999999 + 357
    let TL_seed  = seed_goc * 999999 + b_idx * 999999 + 491

    if "NLC_dem" in item { rut_NLC += rut_cauLevel(b, "NLC", item.NLC_dem, NLC_seed) }
    if "tf_dem"  in item { rut_tf  += rut_cauLevel(b, "TF",  item.tf_dem,  tf_seed)  }
    if "TLN_dem" in item { rut_TLN += rut_cauLevel(b, "TLN", item.TLN_dem, TLN_seed) }
    if "TL_dem"  in item { rut_TL  += rut_cauLevel(b, "TL",  item.TL_dem,  TL_seed)  }
  }

  rut_NLC = tron-mang(rut_NLC, seed_goc + 991)
  rut_tf  = tron-mang(rut_tf,  seed_goc + 997)
  rut_TLN = tron-mang(rut_TLN, seed_goc + 1009)
  rut_TL  = tron-mang(rut_TL,  seed_goc + 1013)

  for (i, ma_de) in info.ds_ma_de.enumerate() {
    let is_first = (i == 0)
    let base_seed = int(ma_de)

    let final_NLC = if xao_cau { xao-theo-tuy-chon(rut_NLC, base_seed + 2001, theo_lv: theo_lv) } else { rut_NLC }
    let final_tf  = if xao_cau { xao-theo-tuy-chon(rut_tf,  base_seed + 2011, theo_lv: theo_lv) } else { rut_tf }
    let final_TLN = if xao_cau { xao-theo-tuy-chon(rut_TLN, base_seed + 2027, theo_lv: theo_lv) } else { rut_TLN }
    let final_TL  = if xao_cau { xao-theo-tuy-chon(rut_TL,  base_seed + 2039, theo_lv: theo_lv) } else { rut_TL }

    let final_bank = final_NLC + final_tf + final_TLN + final_TL

    let fake_matrix = (
      NLC_loc: q => q.type == "NLC",
      NLC_dem: final_NLC.len(),
      tf_loc:  q => q.type == "TF",
      tf_dem:  final_tf.len(),
      TLN_loc: q => q.type == "TLN",
      TLN_dem: final_TLN.len(),
      TL_loc:  q => q.type == "TL",
      TL_dem:  final_TL.len(),
    )

    render_test(
      ma_de, 
      final_bank, 
      fake_matrix, 
      info, 
      is_first: is_first, 
      show_lg: show_lg,
      theo_lv: theo_lv,
    )

    if i < info.ds_ma_de.len() - 1 {
      pagebreak(weak: true)
    }
  }

  if hienthi_bangdapan {
    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[BẢNG ĐÁP ÁN TRẮC NGHIỆM TỔNG HỢP]]
    v(-0.5em)
    
    context {
      let results = query(<exam_data>)
      if results.len() > 0 {
        let total_q = results.at(0).value.part1.len() + results.at(0).value.part2.len() + results.at(0).value.part3.len()
        if total_q > 0 {
          table(
            columns: (auto, ..info.ds_ma_de.map(_ => 1fr)),
            align: center + horizon,
            stroke: 0.5pt,
            fill: (x, y) => if y == 0 { gray.lighten(80%) },
            [*Câu*], ..info.ds_ma_de.map(m => [*#m*]),
            ..range(total_q).map(i => {
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
      let results = query(<exam_data>)
      if results.any(r => r.value.part4.len() > 0) {
        in_dapan_TL(results)
      }
    }

    pagebreak()
    context { counter(page).update(1); set page(footer: none) }
    align(center)[#text(16pt, weight: "bold")[MÃ QR ĐÁP ÁN TRẮC NGHIỆM]]
    v(1em)
    context {
      let results = query(<exam_data>)
      let all_qrcode = tao-QRcode-key(results)
      align(center)[
        #block(inset: 15pt, fill: white, radius: 8pt, stroke: gray.lighten(30%) + 1pt)[
          #text(size: 14pt, weight: "bold")[ĐÁP ÁN TRẮC NGHIỆM CÁC MÃ ĐỀ] \
          #v(5pt)
          #text(size: 10pt)[Số lượng mã đề: #results.len()] \
          #qr-code(all_qrcode, dark-color: black, light-color: white, quiet-zone: true) \
          #text(size: 9pt, fill: blue.darken(20%))[(Đáp án trắc nghiệm dành cho Unt)]
        ]
      ]
    }
  }
}

// ==========================================
// 6. CÁC HÀM TRANG TRÍ TIÊU ĐỀ
// ==========================================
#let tdbai(title, bsize: 18pt, clorfont: rgb("#0309a7"), bground: rgb("#00ffff3b"), cle: center) = {
  block(
    width: 100%, fill: bground, radius: 8pt, stroke: 0.5pt + rgb("#c405ef"), inset: (x: 25pt, y: 8pt),
    align(cle)[#text(fill: clorfont, size: bsize, weight: "bold", font: "Times New Roman", title)]
  )
}

#let dang(title, STT: "1", kieu: "Dạng") = [
  #grid(
    columns: (auto, 1fr), align: center + horizon, column-gutter: -2pt,
    box(fill: rgb("#72f0b1a2"), radius: 8pt, inset: (x: 10pt, y: 10pt), stroke: 2pt + rgb("#72f0b1a2"))[
      #stack(spacing: 3pt, text(weight: "bold", fill: rgb("#f92a01fd"), size: 1.4em)[#kieu #STT:])
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

#let tieude(noi-dung, cap: 1) = {
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

#let chimuc(title, tsize: 16pt) = {
  set par(first-line-indent: 0pt)
  block(width: 100%)[
    #box(fill: rgb("#00ffff2e"), radius: (top-left: 0pt, top-right: 8pt, bottom-left: 0pt, bottom-right: 0pt), stroke: 0.5pt + rgb("#ee05ea"), inset: (x: 4pt, y: 8pt))[
      #text(fill: rgb("#003B5C"), size: tsize, weight: "bold", font: "Times New Roman", title)
    ]
    #v(-15pt)
    #line(length: 100%, stroke: 2pt + rgb("#FF0066"))
  ]
}

#let luuy(title, body) = {
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
#let exercise = baitap_inline
#let make-exam-matrix = tron_de_bankLevel
#let make-exam-sync = tron_de_cungNoiDung
#let make-exam-sub-only = tron_de_chiY
