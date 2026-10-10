// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — BẢN ĐẦY ĐỦ, KHÔNG CẦN PACKAGE HAY FILE PHỤ
//
// Trang 1: 10 Đ/S           — A5 ngang.
// Trang 2: 10 Đ/S           — A4 dọc.
// Trang 3: 4 Đ/S + 6 TLN    — A5 ngang.
// Trang 4: 4 Đ/S + 6 TLN    — A4 dọc.
// Trang 5: 5 Đ/S + 5 TLN    — A5 ngang.
// Trang 6: 5 Đ/S + 5 TLN    — A4 dọc.
// Trang 7: 6 Đ/S + 4 TLN    — A5 ngang.
// Trang 8: 6 Đ/S + 4 TLN    — A4 dọc.
//
// Mỗi câu Đ/S: 4 ý a, b, c, d.
// Mỗi câu TLN: tối đa 4 ký tự.
// SBD: 6 hoặc 8 chữ số.
// Mã đề: 4 chữ số.
//
// Đánh số riêng từng phần Đ/S và TLN.
// ============================================================

// ------------------------------------------------------------
// 1. CẤU HÌNH SBD — CHỈ NHẬP 6 HOẶC 8
// ------------------------------------------------------------

#let sbd-10ds-a5 = 6
#let sbd-10ds-a4 = 6

#let sbd-4ds6tln-a5 = 6
#let sbd-4ds6tln-a4 = 6

#let sbd-5ds5tln-a5 = 6
#let sbd-5ds5tln-a4 = 6

#let sbd-6ds4tln-a5 = 6
#let sbd-6ds4tln-a4 = 6

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

// Đặt nội dung tại tọa độ x, y trong khối chứa.
#let at(x, y, body) = {
  place(
    top + left,
    dx: x,
    dy: y,
    body,
  )
}

// Chữ.
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

// Căn giữa trong một chiều rộng xác định.
#let centered(w, body) = {
  block(width: w)[
    #align(center, body)
  ]
}

// Căn phải trong một chiều rộng xác định.
#let righted(w, body) = {
  block(width: w)[
    #align(right, body)
  ]
}

// Nhãn nền nhạt.
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

// Ô tô tròn.
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

// Ô viết tay.
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

// Trường thông tin có dòng kẻ.
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

// Tiêu đề phần.
#let section(title, note, w, compact: false) = {
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
      w - 76mm,
      0.2mm,
      righted(
        76mm,
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
// 12 mốc chính: 4 × 4 mm.
// 1 mốc phụ nhận chiều: 2.5 × 2.5 mm.
//
// Vùng nội dung:
// A5 ngang: 190 × 128 mm.
// A4 dọc:   190 × 277 mm.
//
// Lề giấy: 10 mm.
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
// ------------------------------------------------------------

#let two-digit(n) = {
  if n < 10 {
    "0" + str(n)
  } else {
    str(n)
  }
}

#let header(
  ds-count,
  tln-count,
  compact: false,
) = {
  let mixed = tln-count > 0

  let subtitle = if mixed {
    (
      two-digit(ds-count)
      + " câu đúng / sai × 4 ý  ·  "
      + two-digit(tln-count)
      + " câu trả lời ngắn"
    )
  } else {
    "10 câu đúng / sai × 4 ý  ·  Mỗi ý chọn Đ hoặc S"
  }

  let badge = if mixed {
    str(ds-count) + " Đ/S + " + str(tln-count) + " TLN"
  } else {
    "10 CÂU Đ/S"
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
        size: if compact { 8pt } else { 10pt },
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
          bubble(marked: code.at(col, default: "") == str(digit), str(digit), diameter: d),
        )
      }
    }
  ]
}

// ------------------------------------------------------------
// 7. THÔNG TIN THÍ SINH — A5
// ------------------------------------------------------------

#let candidate-a5(sbd-digits) = {
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
        field(titles.at(i), 61mm, compact: true),
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
      identity([MÃ ĐỀ], 4, compact: true),
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
        #set text(size: 6.6pt, fill: ink)
        #set par(leading: 1.4pt)

        *HƯỚNG DẪN* \
        SBD #str(sbd-digits) số; mã đề 4 số. \
        Tô cả chữ số 0 ở đầu, nếu có. \
        Đ/S: mỗi ý chỉ chọn 1 ô Đ hoặc S. \
        Tô kín bằng bút chì 2B; tẩy sạch khi sửa.
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
      identity([SỐ BÁO DANH], sbd-digits),
    )

    #at(
      160mm,
      0mm,
      identity([MÃ ĐỀ], 4),
    )
  ]
}

// ------------------------------------------------------------
// 9. CARD ĐÚNG / SAI
//
// Mỗi câu có 4 ý a, b, c, d.
// Mỗi ý có 2 ô Đ và S.
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
// 10. CARD TRẢ LỜI NGẮN
//
// Chỉ số row, col bắt đầu từ 0.
//
// row 0: dấu âm, chỉ cột 0.
// row 1: dấu phẩy, chỉ cột 1 và 2.
// row 2–11: chữ số 0–9, cả 4 cột.
//
// Tổng: 43 ô tô hợp lệ / câu.
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
        write-box(px - 0.4mm, box-h),
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
// 11. KHUNG NHẮC CHO MẪU 10 Đ/S
// ------------------------------------------------------------

#let reminder(w, compact: false) = {
  let h = if compact { 16mm } else { 22mm }

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
      2mm,
      block(width: w - 4mm)[
        #set text(
          size: if compact { 7pt } else { 8.5pt },
          fill: ink,
        )
        #set par(leading: 2pt)

        *KIỂM TRA TRƯỚC KHI NỘP* \
        Mỗi ý chỉ tô một ô: Đ = đúng, S = sai. \
        Kiểm tra SBD, mã đề; tẩy sạch các ô đã sửa.
      ],
    )
  ]
}

// ------------------------------------------------------------
// 12. CHÂN PHIẾU / MÃ TEMPLATE
// ------------------------------------------------------------

#let footer(
  sbd-digits,
  ds-count,
  tln-count,
  compact: false,
) = {
  let mixed = tln-count > 0
  let paper-id = if compact { "A5" } else { "A4" }

  let model-id = if mixed {
    str(ds-count) + "DS" + str(tln-count) + "TLN"
  } else {
    "10DS"
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
      block(width: 138mm)[
        #set text(
          size: if compact { 5.8pt } else { 7.5pt },
          fill: muted,
        )
        #set par(leading: 1.2pt)

        #if mixed [
          TLN: dấu âm ở cột 1; dấu phẩy ở cột 2 hoặc 3.
          Viết trái → phải; cột dư để trống.
        ] else [
          Không gấp phiếu, không viết hoặc tô vào mốc định vị.
          Tẩy sạch khi sửa đáp án.
        ]

        #if not compact [
          \
          Kiểm tra SBD và mã đề trước khi nộp bài.
          Giữ phiếu sạch, phẳng.
        ]
      ],
    )

    #at(
      140mm,
      if compact { 0.8mm } else { 3mm },
      righted(
        50mm,
        tx(
          template-id,
          size: if compact { 5.8pt } else { 7.2pt },
          weight: "bold",
          fill: accent,
        ),
      ),
    )
  ]
}

// ------------------------------------------------------------
// 13. HÀNG ĐÚNG / SAI CHO CÁC MẪU HỖN HỢP
//
// Giữ tọa độ mẫu 4 Đ/S như code gốc.
// Mẫu 5 và 6 Đ/S: chia đều chiều rộng.
// ------------------------------------------------------------

#let mixed-ds-row(count, compact: false) = {
  let w = if compact { 122mm } else { 190mm }
  let gap = if compact { 1mm } else { 2mm }

  let card-w = if count == 4 {
    if compact { 29mm } else { 46mm }
  } else {
    (w - (count - 1) * gap) / count
  }

  let step = if count == 4 {
    if compact { 31mm } else { 48mm }
  } else {
    card-w + gap
  }

  block(
    width: w,
    height: if compact { 37mm } else { 56mm },
  )[
    #for q in range(count) {
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
// 14. HÀNG TLN CHO CÁC MẪU HỖN HỢP
//
// Giữ tọa độ mẫu 6 TLN như code gốc.
// Mẫu 5 và 4 TLN: căn giữa trong từng ô bố cục.
// ------------------------------------------------------------

#let mixed-tln-row(count, compact: false) = {
  let w = if compact { 122mm } else { 190mm }
  let card-w = if compact { 19.5mm } else { 30mm }
  let slot-w = w / count

  block(
    width: w,
    height: if compact { 51mm } else { 74mm },
  )[
    #for q in range(count) {
      let x = if count == 6 {
        q * (if compact { 20.5mm } else { 32mm })
      } else {
        q * slot-w + (slot-w - card-w) / 2
      }

      at(
        x,
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
// 15. GHÉP PHIẾU
//
// ds-count = 10: 10 Đ/S.
// ds-count = 4:  4 Đ/S + 6 TLN.
// ds-count = 5:  5 Đ/S + 5 TLN.
// ds-count = 6:  6 Đ/S + 4 TLN.
//
// compact = true:  A5 ngang.
// compact = false: A4 dọc.
// ------------------------------------------------------------

#let sheet(
  sbd-digits: 6,
  ds-count: 10,
  compact: false,
) = {
  assert(
    sbd-digits == 6 or sbd-digits == 8,
    message: "SBD chỉ được cấu hình 6 hoặc 8 chữ số.",
  )

  assert(
    ds-count == 4
    or ds-count == 5
    or ds-count == 6
    or ds-count == 10,
    message: "Số câu Đ/S chỉ nhận 4, 5, 6 hoặc 10.",
  )

  let tln-count = 10 - ds-count
  let mixed = tln-count > 0
  let h = if compact { 128mm } else { 277mm }

  block(width: 190mm, height: h)[
    #registration(h)

    #at(
      0mm,
      0mm,
      header(
        ds-count,
        tln-count,
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
        candidate-a5(sbd-digits),
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

      at(
        68mm,
        14mm,
        section(
          if mixed {
            [I. ĐÚNG / SAI]
          } else {
            [ĐÚNG / SAI]
          },
          [Mỗi ý chọn một ô Đ hoặc S],
          122mm,
          compact: true,
        ),
      )

      if mixed {
        // Đ/S: một hàng gồm 4, 5 hoặc 6 câu.
        at(
          68mm,
          23mm,
          mixed-ds-row(
            ds-count,
            compact: true,
          ),
        )

        at(
          68mm,
          62mm,
          section(
            [II. TRẢ LỜI NGẮN],
            [Tối đa 4 ký tự / đáp án],
            122mm,
            compact: true,
          ),
        )

        // TLN: một hàng gồm 6, 5 hoặc 4 câu.
        at(
          68mm,
          71mm,
          mixed-tln-row(
            tln-count,
            compact: true,
          ),
        )
      } else {
        // 10 Đ/S: 2 hàng × 5 câu.
        for q in range(5) {
          at(
            68mm + q * 24.8mm,
            23mm,
            ds-card(
              q + 1,
              22.8mm,
              compact: true,
            ),
          )

          at(
            68mm + q * 24.8mm,
            67mm,
            ds-card(
              q + 6,
              22.8mm,
              compact: true,
            ),
          )
        }

        at(
          68mm,
          106mm,
          reminder(
            122mm,
            compact: true,
          ),
        )
      }

      at(
        0mm,
        125mm,
        footer(
          sbd-digits,
          ds-count,
          tln-count,
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

      at(
        0mm,
        94mm,
        section(
          if mixed {
            [I. ĐÚNG / SAI]
          } else {
            [ĐÚNG / SAI]
          },
          [Mỗi ý chọn một ô: Đ = đúng, S = sai],
          190mm,
        ),
      )

      if mixed {
        // Đ/S: một hàng gồm 4, 5 hoặc 6 câu.
        at(
          0mm,
          107mm,
          mixed-ds-row(ds-count),
        )

        at(
          0mm,
          166mm,
          section(
            [II. TRẢ LỜI NGẮN],
            [Tối đa 4 ký tự / đáp án · Viết từ trái sang phải],
            190mm,
          ),
        )

        // TLN: một hàng gồm 6, 5 hoặc 4 câu.
        at(
          0mm,
          180mm,
          mixed-tln-row(tln-count),
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
      } else {
        // 10 Đ/S: 2 hàng × 5 câu.
        for q in range(5) {
          at(
            q * 38.5mm,
            109mm,
            ds-card(q + 1, 36mm),
          )

          at(
            q * 38.5mm,
            182mm,
            ds-card(q + 6, 36mm),
          )
        }

        at(
          0mm,
          173mm,
          line(
            length: 190mm,
            stroke: 0.35pt + rule-color,
          ),
        )

        at(
          0mm,
          242mm,
          reminder(190mm),
        )
      }

      at(
        0mm,
        268mm,
        footer(
          sbd-digits,
          ds-count,
          tln-count,
          compact: false,
        ),
      )
    }
  ]
}

// ============================================================
// TRANG 1 — 10 Đ/S — A5 NGANG
// ============================================================



// ============================================================
// TRANG 7 — 6 Đ/S + 4 TLN — A5 NGANG
// ============================================================

#sheet(
  sbd-digits: sbd-6ds4tln-a5,
  ds-count: 6,
  compact: true,
)


]
