// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — 10 CÂU TRẢ LỜI NGẮN
//
// Trang 1: A5 ngang.
// Trang 2: A4 dọc.
//
// SBD: 6 hoặc 8 chữ số.
// Mã đề: 4 chữ số.
// Mỗi đáp án TLN: tối đa 4 ký tự.
//
// TLN:
// Hàng 1: dấu âm, chỉ cột 1.
// Hàng 2: dấu phẩy, chỉ cột 2 và 3.
// Hàng 3–12: chữ số 0–9, cả 4 cột.
//
// Không sử dụng package, ảnh hoặc file phụ.
// ============================================================

// ------------------------------------------------------------
// CẤU HÌNH — CHỈ NHẬP 6 HOẶC 8
// ------------------------------------------------------------

#let sbd-a5 = 6
#let sbd-a4 = 6

// ------------------------------------------------------------
// THIẾT LẬP
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
// HÀM CƠ BẢN
// ------------------------------------------------------------

#let at(x, y, body) = {
  place(top + left, dx: x, dy: y, body)
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
      line(length: w, stroke: 0.3pt + rule-color),
    )
  ]
}

// ------------------------------------------------------------
// MỐC ĐỊNH VỊ
//
// Vùng nội dung cách mép giấy 10 mm.
// Mốc chính: 4 × 4 mm.
// Mốc phụ nhận chiều: 2.5 × 2.5 mm.
//
// Tọa độ tâm mốc chính trên giấy:
// X = 10 mm + x + 2 mm
// Y = 10 mm + y + 2 mm
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
      fill: black,
      stroke: none,
    ),
  )
}

// ------------------------------------------------------------
// TIÊU ĐỀ
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
        [PHIẾU TRẢ LỜI NGẮN],
        size: if compact { 14pt } else { 19pt },
        weight: "bold",
      ),
    )

    #at(
      0mm,
      if compact { 6mm } else { 9.5mm },
      tx(
        [10 câu trả lời ngắn · Tối đa 4 ký tự mỗi đáp án],
        size: if compact { 7pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      158mm,
      0.5mm,
      pill(
        [10 CÂU TLN],
        32mm,
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
      line(length: 190mm, stroke: 0.5pt + rule-color),
    )

    #at(
      0mm,
      if compact { 10mm } else { 15.5mm },
      line(length: 25mm, stroke: 1.1pt + accent),
    )
  ]
}

// ------------------------------------------------------------
// SBD / MÃ ĐỀ
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
// THÔNG TIN A5 — CỘT TRÁI
// Khối này đặt tại x = 0, y = 14 mm.
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

    // SBD căn giữa trong vùng rộng 36 mm.
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
        #set text(size: 6.6pt, fill: ink)
        #set par(leading: 1.4pt)

        *HƯỚNG DẪN* \
        SBD #str(sbd-digits) số; mã đề 4 số. \
        Tô đủ các chữ số 0 ở đầu, nếu có. \
        TLN: viết trái → phải; cột dư để trống. \
        Tô kín bằng bút chì 2B; tẩy sạch khi sửa.
      ],
    )
  ]
}

// ------------------------------------------------------------
// THÔNG TIN A4 — PHÍA TRÊN
// Khối này đặt tại x = 0, y = 22 mm.
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
        Tô kín ô bằng bút chì 2B; tẩy sạch khi sửa. \
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
// CẤU TRÚC TLN
//
// Chỉ số trong code bắt đầu từ 0.
//
// row = 0: dấu âm, chỉ col = 0.
// row = 1: dấu phẩy, chỉ col = 1 hoặc 2.
// row >= 2: chữ số 0–9, cả 4 cột.
//
// Mỗi câu có 43 ô tô hợp lệ.
// Vị trí không hợp lệ để trắng hoàn toàn.
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

#let short-card(question, compact: false) = {
  let w = if compact { 22.8mm } else { 36mm }

  let px = if compact { 4.7mm } else { 7mm }
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
          size: if compact { 7pt } else { 9pt },
          weight: "bold",
        ),
      ),
    )

    #for col in range(4) {
      at(
        grid-x + col * px + 0.25mm,
        box-y,
        write-box(px - 0.5mm, box-h),
      )

      for row in range(symbols.len()) {
        if tln-valid(row, col) {
          at(
            grid-x + col * px + (px - d) / 2,
            grid-y + row * py,
            bubble(symbols.at(row), diameter: d),
          )
        }
      }
    }
  ]
}

// ------------------------------------------------------------
// TIÊU ĐỀ VÙNG TRẢ LỜI
// ------------------------------------------------------------

#let answer-heading(compact: false) = {
  let w = if compact { 122mm } else { 190mm }

  block(width: w, height: 8mm)[
    #at(
      0mm,
      0mm,
      tx(
        [PHẦN TRẢ LỜI],
        size: if compact { 7.4pt } else { 10pt },
        weight: "bold",
        fill: accent,
      ),
    )

    #at(
      if compact { 37mm } else { 70mm },
      0.2mm,
      righted(
        if compact { 85mm } else { 120mm },
        tx(
          [Mỗi cột sử dụng chỉ tô 1 ô · Không bỏ trống xen giữa],
          size: if compact { 6pt } else { 8pt },
          fill: muted,
        ),
      ),
    )

    #at(
      0mm,
      if compact { 4mm } else { 6mm },
      line(length: w, stroke: 0.45pt + rule-color),
    )
  ]
}

// ------------------------------------------------------------
// CHÂN PHIẾU
// ------------------------------------------------------------

#let footer(sbd-digits, compact: false) = {
  let paper-id = if compact { "A5" } else { "A4" }

  let template-id = (
    paper-id
    + "-10TLN-S"
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
      block(width: 143mm)[
        #set text(
          size: if compact { 5.8pt } else { 7.5pt },
          fill: muted,
        )
        #set par(leading: 1.2pt)

        #if compact [
          Dấu âm: cột 1. Dấu phẩy: cột 2 hoặc 3.
          Không gấp phiếu hoặc làm bẩn mốc đen.
        ] else [
          Dấu âm chỉ ở cột 1; dấu phẩy chỉ ở cột 2 hoặc 3.
          Cột không dùng để trống. \
          Kiểm tra SBD và mã đề trước khi nộp.
          Không gấp phiếu hoặc làm bẩn mốc đen.
        ]
      ],
    )

    #at(
      145mm,
      if compact { 0.8mm } else { 3mm },
      righted(
        45mm,
        tx(
          template-id,
          size: if compact { 5.8pt } else { 7.5pt },
          weight: "bold",
          fill: accent,
        ),
      ),
    )
  ]
}

// ------------------------------------------------------------
// GHÉP PHIẾU
//
// A5:
// Thông tin bên trái: x = 0, y = 14.
// Vùng TLN: x = 68.
// Câu 1–5: y = 20.
// Câu 6–10: y = 73.
//
// A4:
// Thông tin phía trên: x = 0, y = 22.
// Câu 1–5: y = 106.
// Câu 6–10: y = 186.
//
// Tâm ô TLN trong mỗi card:
// X = grid-x + col * px + px / 2
// Y = grid-y + row * py + d / 2
//
// Để có tọa độ trên giấy:
// cộng vị trí card và lề giấy 10 mm.
// ------------------------------------------------------------

#let sheet(sbd-digits: 6, compact: false) = {
  assert(
    sbd-digits == 6 or sbd-digits == 8,
    message: "SBD chỉ được cấu hình 6 hoặc 8 chữ số.",
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
      at(
        0mm,
        14mm,
        candidate-a5(sbd-digits),
      )

      // Đường phân tách thông tin và vùng trả lời.
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
        13mm,
        answer-heading(compact: true),
      )

      for col in range(5) {
        at(
          68mm + col * 24.8mm,
          20mm,
          short-card(col + 1, compact: true),
        )

        at(
          68mm + col * 24.8mm,
          73mm,
          short-card(col + 6, compact: true),
        )
      }

      at(
        0mm,
        125mm,
        footer(sbd-digits, compact: true),
      )
    } else {
      at(
        0mm,
        22mm,
        candidate-a4(sbd-digits),
      )

      at(
        0mm,
        94mm,
        answer-heading(compact: false),
      )

      for col in range(5) {
        at(
          col * 38.5mm,
          106mm,
          short-card(col + 1, compact: false),
        )

        at(
          col * 38.5mm,
          186mm,
          short-card(col + 6, compact: false),
        )
      }

      // Phân tách nhẹ giữa hai hàng câu.
      at(
        0mm,
        182mm,
        line(
          length: 190mm,
          stroke: 0.35pt + rule-color,
        ),
      )

      at(
        0mm,
        268mm,
        footer(sbd-digits, compact: false),
      )
    }
  ]
}

// ============================================================
// TRANG 1 — A5 NGANG
// ============================================================

#sheet(
  sbd-digits: sbd-a5,
  compact: true,
)


]
