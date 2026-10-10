// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — 8 TN + 3 Đ/S + 3 TLN
//
// FILE ĐỘC LẬP.
// Không cần package, ảnh hoặc file phụ.
//
// Trang 1: A5 ngang.
// Trang 2: A4 dọc.
//
// PHẦN I:   8 câu TN, mỗi câu chọn A/B/C/D.
// PHẦN II:  3 câu Đ/S, mỗi câu có 4 ý a/b/c/d.
// PHẦN III: 3 câu TLN, tối đa 4 ký tự mỗi đáp án.
//
// Đánh số riêng từng phần.
//
// A5:
// - Thông tin bên trái.
// - TN phía trên bên phải.
// - Đ/S phía dưới, bên trái vùng trả lời.
// - TLN phía dưới, bên phải vùng trả lời.
// - Mỗi câu Đ/S có 4 ý nằm ngang.
//
// A4:
// - Thông tin phía trên.
// - TN, Đ/S, TLN lần lượt từ trên xuống.
// - Mỗi câu Đ/S có 4 ý theo chiều dọc.
//
// SBD: 6 hoặc 8 chữ số.
// Mã đề: 4 chữ số.
// ============================================================

// ------------------------------------------------------------
// 1. CẤU HÌNH
// ------------------------------------------------------------

#let sbd-a5 = 6
#let sbd-a4 = 6

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

// Tiêu đề phần:
// - Dòng 1: tên phần.
// - Dòng 2: hướng dẫn.
// - Dòng 3: đường kẻ.
#let section(
  title,
  note,
  w,
  compact: false,
) = {
  block(
    width: w,
    height: if compact { 10mm } else { 11mm },
  )[
    #at(
      0mm,
      0mm,
      tx(
        title,
        size: if compact { 7.3pt } else { 9.5pt },
        weight: "bold",
        fill: accent,
      ),
    )

    #at(
      0mm,
      if compact { 3.7mm } else { 4.5mm },
      tx(
        note,
        size: if compact { 5.9pt } else { 7.5pt },
        fill: muted,
      ),
    )

    #at(
      0mm,
      if compact { 7.4mm } else { 8.5mm },
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
// Lề giấy 10 mm.
// Vùng nội dung rộng 190 mm.
//
// A5: cao 128 mm.
// A4: cao 277 mm.
//
// 12 mốc chính: 4 × 4 mm.
// 1 mốc nhận chiều: 2.5 × 2.5 mm.
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

#let header(compact: false) = {
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
        [08 câu TN · 03 câu Đ/S × 4 ý · 03 câu TLN],
        size: if compact { 7pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      144mm,
      0.5mm,
      pill(
        [8 TN + 3 Đ/S + 3 TLN],
        46mm,
        if compact { 5mm } else { 6.5mm },
        size: if compact { 7pt } else { 8.5pt },
      ),
    )

    #at(
      144mm,
      if compact { 6.5mm } else { 10mm },
      righted(
        46mm,
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
        write-box(digit: code.at(col, default: ""),
          px - 0.6mm,
          box-h,
        ),
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
// 7. THÔNG TIN THÍ SINH A5
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
      85.5mm,
      block(width: 57mm)[
        #set text(size: 6.1pt, fill: ink)
        #set par(leading: 1.1pt)

        *HƯỚNG DẪN* \
        SBD #str(sbd-digits) số; mã đề 4 số. \
        Tô đủ các chữ số 0 ở đầu, nếu có. \
        TN: mỗi câu chọn 1 ô A, B, C hoặc D. \
        Đ/S: mỗi ý chọn 1 ô Đ hoặc S. \
        TLN: viết trái → phải; cột dư để trống. \
        Tô bằng bút chì 2B; tẩy sạch khi sửa.
      ],
    )
  ]
}

// ------------------------------------------------------------
// 8. THÔNG TIN THÍ SINH A4
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
// 9. MỘT DÒNG TN
//
// A5:
// - Rộng 58 mm.
// - Đường kính ô 3.2 mm.
// - Ô A tại x=13 mm.
// - Bước lựa chọn 9 mm.
//
// A4:
// - Rộng 46 mm.
// - Đường kính ô 4.2 mm.
// - Ô A tại x=10 mm.
// - Bước lựa chọn 9 mm.
// ------------------------------------------------------------

#let tn-row(question, compact: false) = {
  let w = if compact { 58mm } else { 46mm }
  let d = if compact { 3.2mm } else { 4.2mm }
  let option-x = if compact { 13mm } else { 10mm }

  let symbols = ("A", "B", "C", "D")

  block(
    width: w,
    height: if compact { 6mm } else { 8mm },
  )[
    #at(
      0mm,
      0.2mm,
      righted(
        7mm,
        tx(
          str(question),
          size: if compact { 8pt } else { 10pt },
          weight: "bold",
        ),
      ),
    )

    #for i in range(4) {
      at(
        option-x + i * 9mm,
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
// 10. LƯỚI 8 CÂU TN
//
// A5:
// - 2 cột × 4 hàng.
// - Cột 1: câu 1–4.
// - Cột 2: câu 5–8.
// - Bước cột 64 mm.
// - Bước hàng 7 mm.
//
// A4:
// - 4 cột × 2 hàng.
// - Cột 1: câu 1–2.
// - Cột 2: câu 3–4.
// - Cột 3: câu 5–6.
// - Cột 4: câu 7–8.
// - Bước cột 48 mm.
// - Bước hàng 12 mm.
// ------------------------------------------------------------

#let tn-grid(compact: false) = {
  let columns = if compact { 2 } else { 4 }
  let rows = if compact { 4 } else { 2 }

  let col-step = if compact { 64mm } else { 48mm }
  let row-step = if compact { 7mm } else { 12mm }

  block(
    width: if compact { 122mm } else { 190mm },
    height: if compact { 28mm } else { 20mm },
  )[
    #for col in range(columns) {
      for row in range(rows) {
        at(
          col * col-step,
          row * row-step,
          tn-row(
            col * rows + row + 1,
            compact: compact,
          ),
        )
      }
    }
  ]
}

// ------------------------------------------------------------
// 11. CARD Đ/S A5 — 4 Ý NẰM NGANG
//
// Card: 57 × 16 mm.
// Nhãn câu: cao 4 mm.
//
// Mỗi ý nằm trong một ô bố cục rộng 14.25 mm:
// - Tên ý tại y=5.2 mm.
// - Hai ô Đ/S tại y=10 mm.
// - Đường kính 3.2 mm.
// - Bước giữa ô Đ và S: 5 mm.
//
// Góc trái ô Đ trong ô bố cục:
// (14.25 - 8.2) / 2 = 3.025 mm.
// ------------------------------------------------------------

#let ds-card-a5(question) = {
  let w = 57mm
  let slot-w = w / 4
  let d = 3.2mm
  let pair-w = 5mm + d
  let pair-x = (slot-w - pair-w) / 2

  let items = ("a", "b", "c", "d")

  block(width: w, height: 16mm)[
    #at(
      0mm,
      0mm,
      pill(
        [Câu #str(question)],
        w,
        4mm,
        size: 6.8pt,
      ),
    )

    #for i in range(4) {
      let x = i * slot-w

      at(
        x,
        5.2mm,
        centered(
          slot-w,
          tx(
            items.at(i),
            size: 7pt,
            weight: "bold",
          ),
        ),
      )

      at(
        x + pair-x,
        10mm,
        bubble("Đ", diameter: d),
      )

      at(
        x + pair-x + 5mm,
        10mm,
        bubble("S", diameter: d),
      )
    }
  ]
}

// ------------------------------------------------------------
// 12. CARD Đ/S A4 — 4 Ý THEO CHIỀU DỌC
//
// Card: 62 × 43 mm.
// Nhãn câu cao 6 mm.
// Hàng a tại y=10 mm.
// Bước hàng 9 mm.
// Đường kính 4.2 mm.
// ------------------------------------------------------------

#let ds-card-a4(question) = {
  let w = 62mm
  let d = 4.2mm
  let base-x = (w - 19mm) / 2

  let items = ("a", "b", "c", "d")

  block(width: w, height: 43mm)[
    #at(
      0mm,
      0mm,
      pill(
        [Câu #str(question)],
        w,
        6mm,
        size: 9pt,
      ),
    )

    #for i in range(4) {
      let y = 10mm + i * 9mm

      at(
        base-x,
        y + 0.2mm,
        tx(
          items.at(i),
          size: 9pt,
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
// 13. LƯỚI 3 CÂU Đ/S
//
// A5:
// - 3 card từ trên xuống.
// - Bước card 18 mm.
// - Mỗi card có các ý a–d nằm ngang.
//
// A4:
// - 3 card từ trái sang phải.
// - Bước card 64 mm.
// - Mỗi card có các ý a–d theo chiều dọc.
// ------------------------------------------------------------

#let ds-grid(compact: false) = {
  block(
    width: if compact { 57mm } else { 190mm },
    height: if compact { 52mm } else { 43mm },
  )[
    #for q in range(3) {
      if compact {
        at(
          0mm,
          q * 18mm,
          ds-card-a5(q + 1),
        )
      } else {
        at(
          q * 64mm,
          0mm,
          ds-card-a4(q + 1),
        )
      }
    }
  ]
}

// ------------------------------------------------------------
// 14. CARD TLN
//
// 4 cột ký tự.
//
// row 0: dấu âm, chỉ cột 0.
// row 1: dấu phẩy, chỉ cột 1 hoặc 2.
// row 2–11: số 0–9, cả 4 cột.
//
// Mỗi câu có 43 ô hợp lệ.
//
// A5:
// - Card rộng 19.5 mm.
// - Bước cột 4.4 mm.
// - Bước hàng 3.4 mm.
// - Đường kính ô 3 mm.
// - Lưới bắt đầu y=10 mm.
//
// A4:
// - Card rộng 34 mm.
// - Bước cột 6.5 mm.
// - Bước hàng 4.2 mm.
// - Đường kính ô 3.6 mm.
// - Lưới bắt đầu y=12 mm.
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
  let w = if compact { 19.5mm } else { 34mm }

  let px = if compact { 4.4mm } else { 6.5mm }
  let py = if compact { 3.4mm } else { 4.2mm }
  let d = if compact { 3mm } else { 3.6mm }

  let grid-x = (w - 4 * px) / 2
  let grid-y = if compact { 10mm } else { 12mm }

  let box-y = if compact { 4.5mm } else { 5mm }
  let box-h = if compact { 4mm } else { 5mm }

  let symbols = (
    "−", ",",
    "0", "1", "2", "3", "4",
    "5", "6", "7", "8", "9",
  )

  block(
    width: w,
    height: if compact { 51mm } else { 62mm },
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
// 15. LƯỚI 3 CÂU TLN
//
// A5:
// - Vùng rộng 61 mm.
// - Card rộng 19.5 mm.
// - Khoảng cách giữa các card 1.25 mm.
// - Vị trí card: 0; 20.75; 41.5 mm.
//
// A4:
// - Vùng rộng 190 mm.
// - Chia thành 3 ô bố cục bằng nhau.
// - Card rộng 34 mm, căn giữa từng ô.
// ------------------------------------------------------------

#let tln-grid(compact: false) = {
  let w = if compact { 61mm } else { 190mm }

  block(
    width: w,
    height: if compact { 51mm } else { 62mm },
  )[
    #for q in range(3) {
      let x = if compact {
        q * 20.75mm
      } else {
        q * (190mm / 3) + (190mm / 3 - 34mm) / 2
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
// 16. CHÂN PHIẾU / MÃ TEMPLATE
//
// A5-8TN3DS3TLN-S6-V1
// A4-8TN3DS3TLN-S6-V1
//
// SBD 8 chữ số: S6 đổi thành S8.
// ------------------------------------------------------------

#let footer(sbd-digits, compact: false) = {
  let paper-id = if compact { "A5" } else { "A4" }

  let template-id = (
    paper-id
    + "-8TN3DS3TLN-S"
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
      block(width: 130mm)[
        #set text(
          size: if compact { 5.5pt } else { 7.5pt },
          fill: muted,
        )
        #set par(leading: 1.2pt)

        TLN: dấu âm cột 1; dấu phẩy cột 2 hoặc 3.
        Cột dư để trống. Các phần đánh số riêng.

        #if not compact [
          \
          Không gấp phiếu hoặc tô vào mốc định vị.
          Kiểm tra SBD và mã đề trước khi nộp.
        ]
      ],
    )

    #at(
      132mm,
      if compact { 0.8mm } else { 3mm },
      righted(
        58mm,
        tx(
          template-id,
          size: if compact { 5.5pt } else { 7pt },
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
// Tọa độ tính từ góc trái vùng nội dung.
// Cộng 10 mm để chuyển sang tọa độ trên giấy.
//
// A5:
// - Thông tin: (0, 14).
// - TN:        (68, 24).
// - Đ/S:       (68, 69).
//   Card câu 1: y=69.
//   Card câu 2: y=87.
//   Card câu 3: y=105.
// - TLN:       (129, 71).
//   Card câu 1: x=129.
//   Card câu 2: x=149.75.
//   Card câu 3: x=170.5.
//
// A4:
// - Thông tin: (0, 22).
// - TN:        (0, 106).
// - Đ/S:       (0, 142).
//   Card tại x=0, 64, 128.
// - TLN:       (0, 202).
//   Card căn giữa trong từng vùng rộng 190/3 mm.
// ------------------------------------------------------------

#let sheet(
  sbd-digits: 6,
  compact: false,
) = {
  assert(
    sbd-digits == 6 or sbd-digits == 8,
    message: "SBD chỉ nhận 6 hoặc 8 chữ số.",
  )

  let h = if compact { 128mm } else { 277mm }

  block(width: 190mm, height: h)[
    #registration(h)

    #at(
      0mm,
      0mm,
      header(compact: compact),
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

      // Phân cách thông tin / đáp án.
      at(
        64.5mm,
        14mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, 109mm),
          stroke: 0.4pt + rule-color,
        ),
      )

      // PHẦN I — TN.
      at(
        68mm,
        14mm,
        section(
          [I. TRẮC NGHIỆM],
          [Mỗi câu chọn một ô A, B, C hoặc D],
          122mm,
          compact: true,
        ),
      )

      at(
        68mm,
        24mm,
        tn-grid(compact: true),
      )

      // PHẦN II — Đ/S.
      at(
        68mm,
        56mm,
        section(
          [II. ĐÚNG / SAI],
          [Mỗi ý chọn một ô Đ hoặc S],
          57mm,
          compact: true,
        ),
      )

      at(
        68mm,
        69mm,
        ds-grid(compact: true),
      )

      // Phân cách Đ/S / TLN.
      at(
        127mm,
        56mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, 66mm),
          stroke: 0.35pt + rule-color,
        ),
      )

      // PHẦN III — TLN.
      at(
        129mm,
        56mm,
        section(
          [III. TRẢ LỜI NGẮN],
          [Tối đa 4 ký tự / đáp án],
          61mm,
          compact: true,
        ),
      )

      at(
        129mm,
        71mm,
        tln-grid(compact: true),
      )

      // Chân phiếu.
      at(
        0mm,
        125mm,
        footer(
          sbd-digits,
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

      // PHẦN I — TN.
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
        106mm,
        tn-grid(),
      )

      // PHẦN II — Đ/S.
      at(
        0mm,
        130mm,
        section(
          [II. ĐÚNG / SAI],
          [Mỗi ý chọn một ô: Đ = đúng, S = sai],
          190mm,
        ),
      )

      at(
        0mm,
        142mm,
        ds-grid(),
      )

      // PHẦN III — TLN.
      at(
        0mm,
        190mm,
        section(
          [III. TRẢ LỜI NGẮN],
          [Tối đa 4 ký tự; viết trái → phải; mỗi cột sử dụng chỉ tô 1 ô],
          190mm,
        ),
      )

      at(
        0mm,
        202mm,
        tln-grid(),
      )

      // Chân phiếu.
      at(
        0mm,
        268mm,
        footer(
          sbd-digits,
          compact: false,
        ),
      )
    }
  ]
}

// ============================================================
// TRANG 1 — 8 TN + 3 Đ/S + 3 TLN — A5 NGANG
// ============================================================



// ============================================================
// TRANG 2 — 8 TN + 3 Đ/S + 3 TLN — A4 DỌC
// ============================================================

#sheet(
  sbd-digits: sbd-a4,
  compact: false,
)
]
