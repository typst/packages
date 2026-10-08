// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — 12 TN + 4 Đ/S VÀ 12 TN + 4 TLN
//
// FILE ĐỘC LẬP.
// Không cần package, ảnh hay file phụ.
//
// Trang 1: 12 TN + 4 Đ/S — A5 ngang.
// Trang 2: 12 TN + 4 Đ/S — A4 dọc.
// Trang 3: 12 TN + 4 TLN — A5 ngang.
// Trang 4: 12 TN + 4 TLN — A4 dọc.
//
// TN:
// - 12 câu.
// - Mỗi câu chọn 1 trong 4 đáp án A, B, C, D.
//
// Đ/S:
// - 4 câu, đánh số riêng 1–4.
// - Mỗi câu có 4 ý a, b, c, d.
//
// TLN:
// - 4 câu, đánh số riêng 1–4.
// - Mỗi đáp án tối đa 4 ký tự.
//
// SBD: 6 hoặc 8 chữ số.
// Mã đề: 4 chữ số.
// ============================================================

// ------------------------------------------------------------
// 1. CẤU HÌNH SBD — CHỈ NHẬP 6 HOẶC 8
// ------------------------------------------------------------

#let sbd-12tn4ds-a5 = 6
#let sbd-12tn4ds-a4 = 6

#let sbd-12tn4tln-a5 = 6
#let sbd-12tn4tln-a4 = 6

// ------------------------------------------------------------
// 2. THIẾT LẬP CHUNG
// ------------------------------------------------------------

#set text(size: 9pt, fill: black)
#set par(leading: 0pt, spacing: 0pt)
#set block(spacing: 0pt)

#let ink = rgb("#25344D")
#let accent = rgb("#485FA8")
#let muted = rgb("#637086")
#let soft = rgb("#F0F3FA")
#let rule-color = rgb("#C7D0E1")

// ------------------------------------------------------------
// 3. HÀM CƠ BẢN
// ------------------------------------------------------------

#let at(x, y, body) = {
  place(
    top + left,
    dx: x,
    dy: y,
    body,
  )
}

#let tx(
  body,
  size: 8pt,
  weight: "regular",
  fill: ink,
) = {
  text(
    size: size,
    weight: weight,
    fill: fill,
    body,
  )
}

#let centered(w, body) = {
  block(width: w)[
    #align(center, body)
  ]
}

#let righted(w, body) = {
  block(width: w)[
    #align(right, body)
  ]
}

#let pill(body, w, h, size: 8pt) = {
  rect(
    width: w,
    height: h,
    inset: 0pt,
    radius: 1mm,
    fill: soft,
    stroke: none,
    align(
      center + horizon,
      tx(
        body,
        size: size,
        weight: "bold",
        fill: accent,
      ),
    ),
  )
}

#let bubble(symbol, diameter: 3mm, marked: false) = {
  circle(
    radius: diameter / 2,
    inset: 0pt,
    fill: white,
    stroke: 0.45pt + black,
    align(
      center + horizon,
      if marked { circle(radius: diameter * 0.36, stroke: none, fill: black) } else { text(
        size: diameter * 0.60,
        fill: black,
        symbol,
      ) },
    ),
  )
}

#let write-box(w, h, digit: "") = {
  rect(
    width: w,
    height: h,
    inset: 0pt,
    fill: white,
    stroke: 0.4pt + black,
    align(center + horizon, text(size: h * 0.65, fill: black, digit)),
  )
}

#let field(title, w, compact: false) = {
  block(width: w, height: 9mm)[
    #at(
      0mm,
      0mm,
      tx(
        title,
        size: if compact { 7pt } else { 8.5pt },
        fill: muted,
      ),
    )

    #at(
      0mm,
      if compact { 5mm } else { 6mm },
      line(
        length: w,
        stroke: 0.3pt + rule-color,
      ),
    )
  ]
}

#let section(
  title,
  note,
  w,
  compact: false,
) = {
  let note-w = if compact { 68mm } else { 104mm }

  block(
    width: w,
    height: if compact { 6mm } else { 9mm },
  )[
    #at(
      0mm,
      0mm,
      tx(
        title,
        size: if compact { 7.6pt } else { 10pt },
        weight: "bold",
        fill: accent,
      ),
    )

    #at(
      w - note-w,
      0.2mm,
      righted(
        note-w,
        tx(
          note,
          size: if compact { 6.1pt } else { 8pt },
          fill: muted,
        ),
      ),
    )

    #at(
      0mm,
      if compact { 4.5mm } else { 6.5mm },
      line(
        length: w,
        stroke: 0.45pt + rule-color,
      ),
    )
  ]
}

// ------------------------------------------------------------
// 4. MỐC ĐỊNH VỊ
//
// Vùng nội dung:
// - A5 ngang: 190 × 128 mm.
// - A4 dọc:   190 × 277 mm.
//
// Lề: 10 mm.
//
// 12 mốc chính: 4 × 4 mm.
// 1 mốc phụ nhận chiều: 2.5 × 2.5 mm.
// ------------------------------------------------------------

#let registration(h) = {
  let w = 190mm

  let points = (
    (-5mm, -5mm),
    (w / 3, -5mm),
    (2 * w / 3, -5mm),
    (w + 1mm, -5mm),

    (-5mm, h / 3),
    (w + 1mm, h / 3),
    (-5mm, 2 * h / 3),
    (w + 1mm, 2 * h / 3),

    (-5mm, h + 1mm),
    (w / 3, h + 1mm),
    (2 * w / 3, h + 1mm),
    (w + 1mm, h + 1mm),
  )

  for p in points {
    at(
      p.at(0),
      p.at(1),
      rect(
        width: 4mm,
        height: 4mm,
        inset: 0pt,
        fill: black,
        stroke: none,
      ),
    )
  }

  at(
    3mm,
    -5mm,
    rect(
      width: 2.5mm,
      height: 2.5mm,
      inset: 0pt,
      fill: black,
      stroke: none,
    ),
  )
}

// ------------------------------------------------------------
// 5. TIÊU ĐỀ PHIẾU
//
// second:
// - "ds":  12 TN + 4 Đ/S.
// - "tln": 12 TN + 4 TLN.
// ------------------------------------------------------------

#let header(second: "ds", compact: false) = {
  let subtitle = if second == "ds" {
    "12 câu trắc nghiệm A–D  ·  04 câu đúng / sai × 4 ý"
  } else {
    "12 câu trắc nghiệm A–D  ·  04 câu trả lời ngắn"
  }

  let badge = if second == "ds" {
    "12 TN + 4 Đ/S"
  } else {
    "12 TN + 4 TLN"
  }

  block(
    width: 190mm,
    height: if compact { 11mm } else { 17mm },
  )[
    #at(
      0mm,
      0.5mm,
      tx(
        [PHIẾU TRẢ LỜI],
        size: if compact { 14pt } else { 19pt },
        weight: "bold",
      ),
    )

    #at(
      0mm,
      if compact { 6mm } else { 9.5mm },
      tx(
        subtitle,
        size: if compact { 7pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      153mm,
      0.5mm,
      pill(
        badge,
        37mm,
        if compact { 5mm } else { 6.5mm },
        size: if compact { 7.5pt } else { 9pt },
      ),
    )

    #at(
      145mm,
      if compact { 6.5mm } else { 10mm },
      righted(
        45mm,
        tx(
          if compact {
            [A5 NGANG / OMR]
          } else {
            [A4 DỌC / OMR]
          },
          size: if compact { 6pt } else { 7.5pt },
          fill: muted,
        ),
      ),
    )

    #at(
      0mm,
      if compact { 10mm } else { 15.5mm },
      line(
        length: 190mm,
        stroke: 0.5pt + rule-color,
      ),
    )

    #at(
      0mm,
      if compact { 10mm } else { 15.5mm },
      line(
        length: 25mm,
        stroke: 1.1pt + accent,
      ),
    )
  ]
}

// ------------------------------------------------------------
// 6. LƯỚI SBD / MÃ ĐỀ
// ------------------------------------------------------------

#let identity(title, columns, compact: false) = {
  let code = if columns == 4 { ma-de } else { sbd }
  let px = if compact { 4.5mm } else { 6.8mm }
  let py = if compact { 3.6mm } else { 5.1mm }
  let d = if compact { 3mm } else { 3.8mm }

  let box-y = if compact { 5mm } else { 6mm }
  let box-h = if compact { 4mm } else { 5.5mm }
  let grid-y = if compact { 10mm } else { 13mm }

  let w = columns * px

  block(
    width: w,
    height: if compact { 46mm } else { 64mm },
  )[
    #at(
      0mm,
      0mm,
      centered(
        w,
        tx(
          title,
          size: if compact { 7pt } else { 9pt },
          weight: "bold",
        ),
      ),
    )

    #for col in range(columns) {
      at(
        col * px + 0.3mm,
        box-y,
        write-box(digit: code.at(col, default: ""), px - 0.6mm, box-h),
      )

      for digit in range(10) {
        at(
          col * px + (px - d) / 2,
          grid-y + digit * py,
          bubble(marked: code.at(col, default: "") == str(digit),
            str(digit),
            diameter: d,
          ),
        )
      }
    }
  ]
}

// ------------------------------------------------------------
// 7. THÔNG TIN THÍ SINH — A5
// ------------------------------------------------------------

#let candidate-a5(sbd-digits, second: "ds") = {
  let titles = (
    [Họ và tên:],
    [Lớp / Trường:],
    [Môn thi / Kỳ thi:],
    [Ngày thi / Phòng thi:],
  )

  let sbd-w = sbd-digits * 4.5mm

  block(width: 61mm, height: 109mm)[
    #for i in range(titles.len()) {
      at(
        0mm,
        i * 7.5mm,
        field(
          titles.at(i),
          61mm,
          compact: true,
        ),
      )
    }

    #at(
      (36mm - sbd-w) / 2,
      35mm,
      identity(
        [SỐ BÁO DANH],
        sbd-digits,
        compact: true,
      ),
    )

    #at(
      43mm,
      35mm,
      identity(
        [MÃ ĐỀ],
        4,
        compact: true,
      ),
    )

    #at(
      0mm,
      84mm,
      rect(
        width: 61mm,
        height: 24mm,
        inset: 0pt,
        radius: 1mm,
        fill: soft,
        stroke: none,
      ),
    )

    #at(
      2mm,
      86mm,
      block(width: 57mm)[
        #set text(size: 6.4pt, fill: ink)
        #set par(leading: 1.3pt)

        *HƯỚNG DẪN* \
        SBD #str(sbd-digits) số; mã đề 4 số. \
        Tô đủ chữ số 0 ở đầu, nếu có. \
        TN: mỗi câu chỉ chọn 1 ô A, B, C hoặc D. \
        #if second == "ds" [
          Đ/S: mỗi ý chỉ chọn 1 ô Đ hoặc S.
        ] else [
          TLN: tối đa 4 ký tự; cột dư để trống.
        ] \
        Tô bằng bút chì 2B; tẩy sạch khi sửa.
      ],
    )
  ]
}

// ------------------------------------------------------------
// 8. THÔNG TIN THÍ SINH — A4
// ------------------------------------------------------------

#let candidate-a4(sbd-digits) = {
  let titles = (
    [Họ và tên:],
    [Lớp / Trường:],
    [Môn thi / Kỳ thi:],
    [Ngày thi / Phòng thi:],
  )

  let sbd-w = sbd-digits * 6.8mm
  let sbd-x = 88mm + (58mm - sbd-w) / 2

  block(width: 190mm, height: 66mm)[
    #for i in range(titles.len()) {
      at(
        0mm,
        i * 9.5mm,
        field(titles.at(i), 79mm),
      )
    }

    #at(
      0mm,
      40mm,
      rect(
        width: 79mm,
        height: 21mm,
        inset: 0pt,
        radius: 1.2mm,
        fill: soft,
        stroke: none,
      ),
    )

    #at(
      2mm,
      42mm,
      block(width: 75mm)[
        #set text(size: 8pt, fill: ink)
        #set par(leading: 2pt)

        *LƯU Ý KHI LÀM BÀI* \
        Tô kín bằng bút chì 2B; tẩy sạch khi sửa. \
        SBD #str(sbd-digits) số; mã đề 4 số. \
        Tô đủ các chữ số 0 ở đầu, nếu có.
      ],
    )

    #at(
      sbd-x,
      0mm,
      identity(
        [SỐ BÁO DANH],
        sbd-digits,
      ),
    )

    #at(
      160mm,
      0mm,
      identity([MÃ ĐỀ], 4),
    )
  ]
}

// ------------------------------------------------------------
// 9. MỘT DÒNG TRẮC NGHIỆM A–D
//
// Tọa độ ô bên trong dòng:
//
// A5:
// - Đường kính: 3.2 mm.
// - Góc trái ô A: x = 9 mm, y = 0.
// - Bước giữa các lựa chọn: 7 mm.
//
// A4:
// - Đường kính: 4.2 mm.
// - Góc trái ô A: x = 14 mm, y = 0.
// - Bước giữa các lựa chọn: 11 mm.
// ------------------------------------------------------------

#let tn-row(question, compact: false) = {
  let w = if compact { 40mm } else { 62mm }
  let h = if compact { 6mm } else { 8mm }

  let d = if compact { 3.2mm } else { 4.2mm }
  let option-x = if compact { 9mm } else { 14mm }
  let option-step = if compact { 7mm } else { 11mm }

  let label-w = if compact { 6mm } else { 9mm }
  let symbols = ("A", "B", "C", "D")

  block(width: w, height: h)[
    #at(
      0mm,
      0.2mm,
      righted(
        label-w,
        tx(
          str(question),
          size: if compact { 8pt } else { 10pt },
          weight: "bold",
        ),
      ),
    )

    #for i in range(4) {
      at(
        option-x + i * option-step,
        0mm,
        bubble(
          symbols.at(i),
          diameter: d,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// 10. LƯỚI 12 CÂU TRẮC NGHIỆM
//
// 3 cột × 4 hàng.
//
// Đánh số theo cột:
// Cột 1: câu 1–4.
// Cột 2: câu 5–8.
// Cột 3: câu 9–12.
//
// A5:
// - Bước cột: 41 mm.
// - Bước hàng: 8 mm.
//
// A4:
// - Bước cột: 64 mm.
// - Bước hàng: 11 mm.
// ------------------------------------------------------------

#let tn-grid(compact: false) = {
  let w = if compact { 122mm } else { 190mm }
  let h = if compact { 32mm } else { 43mm }

  let col-step = if compact { 41mm } else { 64mm }
  let row-step = if compact { 8mm } else { 11mm }

  block(width: w, height: h)[
    #for col in range(3) {
      for row in range(4) {
        let question = col * 4 + row + 1

        at(
          col * col-step,
          row * row-step,
          tn-row(
            question,
            compact: compact,
          ),
        )
      }
    }

    #for i in range(2) {
      at(
        if compact {
          38mm + i * col-step
        } else {
          59mm + i * col-step
        },
        -1mm,
        line(
          start: (0mm, 0mm),
          end: (
            0mm,
            if compact { 30mm } else { 40mm },
          ),
          stroke: 0.3pt + rule-color,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// 11. CARD ĐÚNG / SAI
//
// 4 ý a, b, c, d.
// Mỗi ý có 2 ô Đ và S.
//
// Giữ kích thước ô và bước hàng như các mẫu trước.
// ------------------------------------------------------------

#let ds-card(question, w, compact: false) = {
  let d = if compact { 3.2mm } else { 4.2mm }

  let row-y = if compact { 10mm } else { 15mm }
  let row-step = if compact { 7mm } else { 11mm }

  let base-x = (w - 19mm) / 2
  let items = ("a", "b", "c", "d")

  block(
    width: w,
    height: if compact { 37mm } else { 56mm },
  )[
    #at(
      0mm,
      0mm,
      pill(
        [Câu #str(question)],
        w,
        if compact { 5mm } else { 7mm },
        size: if compact { 7pt } else { 9pt },
      ),
    )

    #for i in range(4) {
      let y = row-y + i * row-step

      at(
        base-x,
        y + 0.3mm,
        tx(
          items.at(i),
          size: if compact { 7.5pt } else { 9pt },
          weight: "bold",
        ),
      )

      at(
        base-x + 6mm,
        y,
        bubble("Đ", diameter: d),
      )

      at(
        base-x + 14mm,
        y,
        bubble("S", diameter: d),
      )
    }
  ]
}

// ------------------------------------------------------------
// 12. CARD TRẢ LỜI NGẮN
//
// Chỉ số row, col bắt đầu từ 0.
//
// row 0: dấu âm, chỉ col 0.
// row 1: dấu phẩy, chỉ col 1 và col 2.
// row 2–11: chữ số 0–9, cả 4 cột.
//
// Tổng: 43 ô hợp lệ mỗi câu.
// ------------------------------------------------------------

#let tln-valid(row, col) = {
  if row == 0 {
    col == 0
  } else if row == 1 {
    col == 1 or col == 2
  } else {
    true
  }
}

#let tln-card(question, compact: false) = {
  let w = if compact { 19.5mm } else { 30mm }

  let px = if compact { 4.4mm } else { 6mm }
  let py = if compact { 3.4mm } else { 5mm }
  let d = if compact { 3mm } else { 4mm }

  let grid-x = (w - 4 * px) / 2
  let grid-y = if compact { 10mm } else { 14mm }

  let box-y = if compact { 4.5mm } else { 6mm }
  let box-h = if compact { 4mm } else { 6mm }

  let symbols = (
    "−", ",",
    "0", "1", "2", "3", "4",
    "5", "6", "7", "8", "9",
  )

  block(
    width: w,
    height: if compact { 51mm } else { 74mm },
  )[
    #at(
      0mm,
      0mm,
      centered(
        w,
        tx(
          [Câu #str(question)],
          size: if compact { 6.8pt } else { 9pt },
          weight: "bold",
        ),
      ),
    )

    #for col in range(4) {
      at(
        grid-x + col * px + 0.2mm,
        box-y,
        write-box(
          px - 0.4mm,
          box-h,
        ),
      )

      for row in range(symbols.len()) {
        if tln-valid(row, col) {
          at(
            grid-x + col * px + (px - d) / 2,
            grid-y + row * py,
            bubble(
              symbols.at(row),
              diameter: d,
            ),
          )
        }
      }
    }
  ]
}

// ------------------------------------------------------------
// 13. HÀNG 4 CÂU Đ/S
//
// A5: card rộng 29 mm, bước 31 mm.
// A4: card rộng 46 mm, bước 48 mm.
// ------------------------------------------------------------

#let ds-grid(compact: false) = {
  let w = if compact { 122mm } else { 190mm }
  let card-w = if compact { 29mm } else { 46mm }
  let step = if compact { 31mm } else { 48mm }

  block(
    width: w,
    height: if compact { 37mm } else { 56mm },
  )[
    #for q in range(4) {
      at(
        q * step,
        0mm,
        ds-card(
          q + 1,
          card-w,
          compact: compact,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// 14. HÀNG 4 CÂU TLN
//
// Chia đều vùng trả lời thành 4 ô bố cục.
// Căn giữa mỗi card trong ô bố cục.
// ------------------------------------------------------------

#let tln-grid(compact: false) = {
  let w = if compact { 122mm } else { 190mm }
  let card-w = if compact { 19.5mm } else { 30mm }
  let slot-w = w / 4

  block(
    width: w,
    height: if compact { 51mm } else { 74mm },
  )[
    #for q in range(4) {
      at(
        q * slot-w + (slot-w - card-w) / 2,
        0mm,
        tln-card(
          q + 1,
          compact: compact,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// 15. KHUNG NHẮC CHO MẪU TN + Đ/S
// ------------------------------------------------------------

#let reminder(w, compact: false) = {
  let h = if compact { 12mm } else { 22mm }

  block(width: w, height: h)[
    #at(
      0mm,
      0mm,
      rect(
        width: w,
        height: h,
        inset: 0pt,
        radius: 1mm,
        fill: soft,
        stroke: none,
      ),
    )

    #at(
      2mm,
      1.5mm,
      block(width: w - 4mm)[
        #set text(
          size: if compact { 6.6pt } else { 8.5pt },
          fill: ink,
        )
        #set par(leading: 1.5pt)

        *KIỂM TRA TRƯỚC KHI NỘP* \
        TN: mỗi câu một ô; Đ/S: mỗi ý một ô Đ hoặc S. \
        Kiểm tra SBD, mã đề; tẩy sạch ô đã sửa.
      ],
    )
  ]
}

// ------------------------------------------------------------
// 16. CHÂN PHIẾU / MÃ TEMPLATE
//
// A5-12TN4DS-S6-V1
// A4-12TN4DS-S6-V1
// A5-12TN4TLN-S6-V1
// A4-12TN4TLN-S6-V1
//
// Nếu SBD 8 số thì S6 đổi thành S8.
// ------------------------------------------------------------

#let footer(
  sbd-digits,
  second: "ds",
  compact: false,
) = {
  let paper-id = if compact { "A5" } else { "A4" }

  let model-id = if second == "ds" {
    "12TN4DS"
  } else {
    "12TN4TLN"
  }

  let template-id = (
    paper-id
    + "-"
    + model-id
    + "-S"
    + str(sbd-digits)
    + "-V1"
  )

  block(
    width: 190mm,
    height: if compact { 3mm } else { 9mm },
  )[
    #at(
      0mm,
      0mm,
      line(
        length: 190mm,
        stroke: 0.45pt + rule-color,
      ),
    )

    #at(
      0mm,
      if compact { 0.8mm } else { 2mm },
      block(width: 135mm)[
        #set text(
          size: if compact { 5.6pt } else { 7.5pt },
          fill: muted,
        )
        #set par(leading: 1.2pt)

        #if second == "tln" [
          TLN: dấu âm cột 1; dấu phẩy cột 2 hoặc 3.
          Viết trái → phải; cột dư để trống.
        ] else [
          Không gấp phiếu, không viết hoặc tô vào mốc định vị.
          Tẩy sạch khi sửa đáp án.
        ]

        #if not compact [
          \
          Các phần đánh số câu riêng.
          Kiểm tra SBD và mã đề trước khi nộp.
        ]
      ],
    )

    #at(
      138mm,
      if compact { 0.8mm } else { 3mm },
      righted(
        52mm,
        tx(
          template-id,
          size: if compact { 5.6pt } else { 7pt },
          weight: "bold",
          fill: accent,
        ),
      ),
    )
  ]
}

// ------------------------------------------------------------
// 17. GHÉP PHIẾU
//
// TỌA ĐỘ SO VỚI VÙNG NỘI DUNG, CHƯA CỘNG LỀ 10 MM.
//
// A5:
// - Thông tin: x=0, y=14.
// - TN: x=68, y=23.
// - Tiêu đề phần II: x=68, y=62.
// - Đ/S hoặc TLN: x=68, y=71.
//
// A4:
// - Thông tin: x=0, y=22.
// - TN: x=0, y=107.
// - Tiêu đề phần II: x=0, y=166.
// - Đ/S hoặc TLN: x=0, y=180.
// ------------------------------------------------------------

#let sheet(
  sbd-digits: 6,
  second: "ds",
  compact: false,
) = {
  assert(
    sbd-digits == 6 or sbd-digits == 8,
    message: "SBD chỉ được cấu hình 6 hoặc 8 chữ số.",
  )

  assert(
    second == "ds" or second == "tln",
    message: "Phần II chỉ nhận ds hoặc tln.",
  )

  let h = if compact { 128mm } else { 277mm }

  block(width: 190mm, height: h)[
    #registration(h)

    #at(
      0mm,
      0mm,
      header(
        second: second,
        compact: compact,
      ),
    )

    #if compact {
      // ======================================================
      // A5 NGANG
      // ======================================================

      at(
        0mm,
        14mm,
        candidate-a5(
          sbd-digits,
          second: second,
        ),
      )

      at(
        64.5mm,
        14mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, 109mm),
          stroke: 0.4pt + rule-color,
        ),
      )

      // Phần I: 12 câu TN.
      at(
        68mm,
        14mm,
        section(
          [I. TRẮC NGHIỆM],
          [Mỗi câu chọn 1 ô A, B, C hoặc D],
          122mm,
          compact: true,
        ),
      )

      at(
        68mm,
        23mm,
        tn-grid(compact: true),
      )

      // Phần II: 4 Đ/S hoặc 4 TLN.
      at(
        68mm,
        62mm,
        section(
          if second == "ds" {
            [II. ĐÚNG / SAI]
          } else {
            [II. TRẢ LỜI NGẮN]
          },
          if second == "ds" {
            [Mỗi ý chọn 1 ô Đ hoặc S]
          } else {
            [Tối đa 4 ký tự / đáp án]
          },
          122mm,
          compact: true,
        ),
      )

      if second == "ds" {
        at(
          68mm,
          71mm,
          ds-grid(compact: true),
        )

        at(
          68mm,
          110mm,
          reminder(
            122mm,
            compact: true,
          ),
        )
      } else {
        at(
          68mm,
          71mm,
          tln-grid(compact: true),
        )
      }

      at(
        0mm,
        125mm,
        footer(
          sbd-digits,
          second: second,
          compact: true,
        ),
      )
    } else {
      // ======================================================
      // A4 DỌC
      // ======================================================

      at(
        0mm,
        22mm,
        candidate-a4(sbd-digits),
      )

      // Phần I: 12 câu TN.
      at(
        0mm,
        94mm,
        section(
          [I. TRẮC NGHIỆM],
          [Mỗi câu chỉ chọn một đáp án A, B, C hoặc D],
          190mm,
        ),
      )

      at(
        0mm,
        107mm,
        tn-grid(),
      )

      at(
        0mm,
        153mm,
        tx(
          [
            Tô kín một ô cho mỗi câu.
            Không tô hai đáp án trong cùng một câu.
          ],
          size: 8pt,
          fill: muted,
        ),
      )

      // Phần II: 4 Đ/S hoặc 4 TLN.
      at(
        0mm,
        166mm,
        section(
          if second == "ds" {
            [II. ĐÚNG / SAI]
          } else {
            [II. TRẢ LỜI NGẮN]
          },
          if second == "ds" {
            [Mỗi ý chọn một ô: Đ = đúng, S = sai]
          } else {
            [Tối đa 4 ký tự / đáp án · Viết từ trái sang phải]
          },
          190mm,
        ),
      )

      if second == "ds" {
        at(
          0mm,
          180mm,
          ds-grid(),
        )

        at(
          0mm,
          242mm,
          reminder(190mm),
        )
      } else {
        at(
          0mm,
          180mm,
          tln-grid(),
        )

        at(
          0mm,
          258mm,
          tx(
            [
              Mỗi cột sử dụng chỉ tô 1 ô.
              Cột dư để trống; không bỏ trống xen giữa đáp án.
            ],
            size: 8pt,
            fill: muted,
          ),
        )
      }

      at(
        0mm,
        268mm,
        footer(
          sbd-digits,
          second: second,
          compact: false,
        ),
      )
    }
  ]
}

// ============================================================
// TRANG 1 — 12 TN + 4 Đ/S — A5 NGANG
// ============================================================

#sheet(
  sbd-digits: sbd-12tn4ds-a5,
  second: "ds",
  compact: true,
)


]
