// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — 8 TN + 4 Đ/S + 2 TLN
//
// FILE ĐỘC LẬP.
// Không cần package, ảnh hoặc file phụ.
//
// Trang 1: A5 ngang.
// Trang 2: A4 dọc.
//
// PHẦN I:   8 câu TN, mỗi câu chọn A/B/C/D.
// PHẦN II:  4 câu Đ/S, mỗi câu có 4 ý a/b/c/d.
// PHẦN III: 2 câu TLN, tối đa 4 ký tự mỗi đáp án.
//
// Đánh số riêng từng phần.
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

// Tiêu đề một phần:
// Dòng 1: tên phần.
// Dòng 2: hướng dẫn.
// Dòng 3: đường kẻ.
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
// 12 mốc chính 4 × 4 mm.
// 1 mốc nhận chiều 2.5 × 2.5 mm.
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
        [08 câu TN · 04 câu Đ/S × 4 ý · 02 câu TLN],
        size: if compact { 7pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      144mm,
      0.5mm,
      pill(
        [8 TN + 4 Đ/S + 2 TLN],
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
// 6. SBD / MÃ ĐỀ
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
// 7. THÔNG TIN A5
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
// 8. THÔNG TIN A4
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
// - Đường kính 3.2 mm.
// - Ô A tại x=13 mm.
// - Bước lựa chọn 9 mm.
//
// A4:
// - Rộng 46 mm.
// - Đường kính 4.2 mm.
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
// A5: 2 cột × 4 hàng.
// - Cột 1: câu 1–4.
// - Cột 2: câu 5–8.
// - Bước cột 64 mm.
// - Bước hàng 7 mm.
//
// A4: 4 cột × 2 hàng.
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
// 11. CARD Đ/S
//
// A5:
// - Card rộng 35 mm, cao 26 mm.
// - Nhãn cao 4.5 mm.
// - Hàng a tại y=7 mm.
// - Bước hàng 5 mm.
// - Đường kính 3.2 mm.
//
// A4:
// - Card rộng 46 mm, cao 43 mm.
// - Nhãn cao 6 mm.
// - Hàng a tại y=10 mm.
// - Bước hàng 9 mm.
// - Đường kính 4.2 mm.
// ------------------------------------------------------------

#let ds-card(question, compact: false) = {
  let w = if compact { 35mm } else { 46mm }

  let d = if compact { 3.2mm } else { 4.2mm }
  let row-y = if compact { 7mm } else { 10mm }
  let row-step = if compact { 5mm } else { 9mm }

  let base-x = (w - 19mm) / 2
  let items = ("a", "b", "c", "d")

  block(
    width: w,
    height: if compact { 26mm } else { 43mm },
  )[
    #at(
      0mm,
      0mm,
      pill(
        [Câu #str(question)],
        w,
        if compact { 4.5mm } else { 6mm },
        size: if compact { 7pt } else { 9pt },
      ),
    )

    #for i in range(4) {
      let y = row-y + i * row-step

      at(
        base-x,
        y + 0.2mm,
        tx(
          items.at(i),
          size: if compact { 7.2pt } else { 9pt },
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
// 12. LƯỚI 4 CÂU Đ/S
//
// A5:
// 2 cột × 2 hàng.
// Hàng trên: câu 1, 2.
// Hàng dưới: câu 3, 4.
// Bước cột: 38 mm.
// Bước hàng: 28 mm.
//
// A4:
// 1 hàng × 4 câu.
// Bước cột: 48 mm.
// ------------------------------------------------------------

#let ds-grid(compact: false) = {
  block(
    width: if compact { 73mm } else { 190mm },
    height: if compact { 54mm } else { 43mm },
  )[
    #if compact {
      for row in range(2) {
        for col in range(2) {
          at(
            col * 38mm,
            row * 28mm,
            ds-card(
              row * 2 + col + 1,
              compact: true,
            ),
          )
        }
      }
    } else {
      for q in range(4) {
        at(
          q * 48mm,
          0mm,
          ds-card(q + 1),
        )
      }
    }
  ]
}

// ------------------------------------------------------------
// 13. CARD TLN
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
// - Đường kính 3 mm.
// - Lưới bắt đầu y=10 mm.
//
// A4:
// - Card rộng 34 mm.
// - Bước cột 6.5 mm.
// - Bước hàng 4.2 mm.
// - Đường kính 3.6 mm.
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
// 14. HƯỚNG DẪN TLN TRÊN A4
// ------------------------------------------------------------

#let tln-guide() = {
  block(width: 81mm, height: 44mm)[
    #at(
      0mm,
      0mm,
      rect(
        width: 81mm,
        height: 44mm,
        inset: 0pt,
        radius: 1.2mm,
        fill: soft,
        stroke: none,
      ),
    )

    #at(
      3mm,
      3mm,
      block(width: 75mm)[
        #set text(size: 8pt, fill: ink)
        #set par(leading: 3pt)

        *HƯỚNG DẪN TRẢ LỜI NGẮN* \
        Mỗi đáp án tối đa 4 ký tự. \
        Viết từ trái sang phải, rồi tô ô tương ứng. \
        Dấu âm chỉ dùng ở cột 1. \
        Dấu phẩy dùng ở cột 2 hoặc cột 3. \
        Mỗi cột sử dụng chỉ tô một ô. \
        Cột dư để trống; không bỏ trống xen giữa. \
        Ví dụ: −1,5 hoặc 0,25.
      ],
    )
  ]
}

// ------------------------------------------------------------
// 15. CHÂN PHIẾU
// ------------------------------------------------------------

#let footer(sbd-digits, compact: false) = {
  let paper-id = if compact { "A5" } else { "A4" }

  let template-id = (
    paper-id
    + "-8TN4DS2TLN-S"
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
// 16. GHÉP PHIẾU
//
// Tất cả tọa độ dưới đây tính từ góc trái vùng nội dung.
// Khi chuyển sang tọa độ trên giấy, cộng lề 10 mm.
//
// A5:
// - Thông tin: (0, 14).
// - TN:        (68, 24).
// - Đ/S:       (68, 68).
// - TLN 1:     (148.75, 71).
// - TLN 2:     (169.75, 71).
//
// A4:
// - Thông tin: (0, 22).
// - TN:        (0, 106).
// - Đ/S:       (0, 142).
// - TLN 1:     (8, 202).
// - TLN 2:     (58, 202).
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

      // Phân cách thông tin và đáp án.
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
          73mm,
          compact: true,
        ),
      )

      at(
        68mm,
        68mm,
        ds-grid(compact: true),
      )

      // Phân cách Đ/S và TLN.
      at(
        145mm,
        56mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, 66mm),
          stroke: 0.35pt + rule-color,
        ),
      )

      // PHẦN III — TLN.
      at(
        148mm,
        56mm,
        section(
          [III. TRẢ LỜI NGẮN],
          [Tối đa 4 ký tự / đáp án],
          42mm,
          compact: true,
        ),
      )

      // Mỗi card được căn giữa trong ô rộng 21 mm.
      for q in range(2) {
        at(
          148mm + q * 21mm + 0.75mm,
          71mm,
          tln-card(
            q + 1,
            compact: true,
          ),
        )
      }

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
          [Tối đa 4 ký tự / đáp án · Viết từ trái sang phải],
          190mm,
        ),
      )

      for q in range(2) {
        at(
          8mm + q * 50mm,
          202mm,
          tln-card(q + 1),
        )
      }

      at(
        109mm,
        207mm,
        tln-guide(),
      )

      at(
        109mm,
        256mm,
        tx(
          [Kiểm tra đủ cả 3 phần trước khi nộp bài.],
          size: 8pt,
          weight: "bold",
          fill: accent,
        ),
      )

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
// TRANG 1 — 8 TN + 4 Đ/S + 2 TLN — A5 NGANG
// ============================================================

#sheet(
  sbd-digits: sbd-a5,
  compact: true,
)


]
