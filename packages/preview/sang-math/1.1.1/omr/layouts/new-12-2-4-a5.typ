// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — MINIMAL V3
//
// Trang 1: A5 ngang.
// Trang 2: A4 dọc.
//
// 12 TN / 2 ĐS × 4 ý / 4 TLN.
// SBD 6 chữ số / Mã đề 4 chữ số.
//
// TLN — 4 cột:
// Hàng 1: dấu âm CHỈ ở cột 1.
// Hàng 2: dấu phẩy CHỈ ở cột 2, 3.
// Hàng 3–12: số 0–9 ở cả 4 cột.
//
// Vị trí không hợp lệ: để trắng, không vẽ vòng tròn.
//
// Không dùng package, ảnh hay file phụ.
// ============================================================

#set text(size: 9pt, fill: black)
#set par(leading: 0pt, spacing: 0pt)
#set block(spacing: 0pt)

// ------------------------------------------------------------
// MÀU SẮC
// Màu chỉ dùng cho nội dung ngoài vùng đọc ô tô.
// ------------------------------------------------------------

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

#let pill(body, w, h, size: 8pt) = {
  rect(
    width: w,
    height: h,
    inset: 0pt,
    radius: 1.1mm,
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

#let section(number, title, w, compact: false) = {
  let badge-w = if compact { 6mm } else { 8mm }
  let badge-h = if compact { 4.3mm } else { 5.8mm }
  let line-y = if compact { 5.5mm } else { 7.5mm }

  block(width: w, height: line-y)[
    #at(
      0mm, 0mm,
      pill(
        number,
        badge-w,
        badge-h,
        size: if compact { 6.8pt } else { 8.5pt },
      ),
    )

    #at(
      badge-w + 1.5mm,
      if compact { 0.7mm } else { 1mm },
      tx(
        title,
        size: if compact { 7.2pt } else { 9.6pt },
        weight: "bold",
      ),
    )

    #at(
      0mm, line-y,
      line(length: w, stroke: 0.45pt + rule-color),
    )
  ]
}

#let field(title, w, compact: false) = {
  block(width: w, height: 8mm)[
    #at(
      0mm, 0mm,
      tx(
        title,
        size: if compact { 7.3pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      0mm,
      if compact { 5.4mm } else { 6.2mm },
      line(length: w, stroke: 0.3pt + rule-color),
    )
  ]
}

// ------------------------------------------------------------
// ĐỊNH VỊ — 12 MỐC CHÍNH + 1 MỐC PHỤ
//
// Vùng nội dung cách mép giấy 10 mm.
// Tọa độ sau tính từ góc trên trái vùng nội dung.
//
// Mỗi mốc chính: 4 × 4 mm.
// Tâm trên giấy:
// X = 10 mm + tọa độ x + 2 mm
// Y = 10 mm + tọa độ y + 2 mm
//
// A5: w = 190 mm, h = 128 mm.
// A4: w = 190 mm, h = 277 mm.
//
// Không đặt trang trí trong vùng mốc.
// ------------------------------------------------------------

#let registration(w, h) = {
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
      p.at(0), p.at(1),
      rect(
        width: 4mm,
        height: 4mm,
        fill: black,
        stroke: none,
      ),
    )
  }

  // Mốc phụ nhận biết chiều.
  at(
    3mm, -5mm,
    rect(
      width: 2.5mm,
      height: 2.5mm,
      fill: black,
      stroke: none,
    ),
  )
}

// ------------------------------------------------------------
// HEADER — NỀN TRẮNG, CHỮ CHÀM, KHÔNG MẢNG MÀU LỚN
// ------------------------------------------------------------

#let header(compact: false) = {
  block(
    width: 190mm,
    height: if compact { 11mm } else { 17mm },
  )[
    #at(
      0mm,
      if compact { 0.2mm } else { 0.5mm },
      tx(
        [PHIẾU TRẢ LỜI TRẮC NGHIỆM],
        size: if compact { 13.3pt } else { 17.5pt },
        weight: "bold",
      ),
    )

    #at(
      0mm,
      if compact { 6mm } else { 9mm },
      tx(
        [12 câu trắc nghiệm  ·  02 câu đúng / sai  ·  04 câu trả lời ngắn],
        size: if compact { 6.8pt } else { 9pt },
        fill: muted,
      ),
    )

    #at(
      161mm,
      if compact { 0.4mm } else { 1mm },
      pill(
        if compact { [A5 NGANG] } else { [A4 DỌC] },
        29mm,
        if compact { 5mm } else { 6.5mm },
        size: if compact { 7pt } else { 9pt },
      ),
    )

    #at(
      148mm,
      if compact { 6.5mm } else { 10mm },
      righted(
        42mm,
        tx(
          [OMR / MINIMAL 03],
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
  let px = if compact { 5.5mm } else { 6.8mm }
  let py = if compact { 3.8mm } else { 5.3mm }
  let d = if compact { 3mm } else { 3.8mm }

  let box-y = if compact { 5mm } else { 6mm }
  let box-h = if compact { 4.2mm } else { 5.5mm }
  let grid-y = if compact { 10.2mm } else { 13mm }

  let w = columns * px

  block(
    width: w,
    height: if compact { 48mm } else { 65mm },
  )[
    #at(
      0mm, 0mm,
      centered(
        w,
        tx(
          title,
          size: if compact { 7.5pt } else { 9.5pt },
          weight: "bold",
        ),
      ),
    )

    #for col in range(columns) {
      at(
        col * px + 0.4mm,
        box-y,
        write-box(digit: code.at(col, default: ""), px - 0.8mm, box-h),
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
// THÔNG TIN THÍ SINH
// ------------------------------------------------------------

#let candidate(compact: false) = {
  let fw = if compact { 83mm } else { 82mm }
  let step = if compact { 8mm } else { 10mm }

  let titles = (
    [Họ và tên:],
    [Lớp / Trường:],
    [Môn thi / Kỳ thi:],
    [Ngày thi / Phòng thi:],
  )

  let note-y = if compact { 34mm } else { 43mm }
  let note-h = if compact { 13mm } else { 20mm }

  block(
    width: 190mm,
    height: if compact { 49mm } else { 66mm },
  )[
    #for i in range(titles.len()) {
      at(
        0mm,
        i * step,
        field(titles.at(i), fw, compact: compact),
      )
    }

    #at(
      0mm, note-y,
      rect(
        width: fw,
        height: note-h,
        inset: 0pt,
        radius: 1.2mm,
        fill: soft,
        stroke: none,
      ),
    )

    #at(
      2mm, note-y + 1.5mm,
      block(width: fw - 4mm)[
        #set text(
          size: if compact { 6.4pt } else { 8.5pt },
          fill: ink,
        )
        #set par(leading: if compact { 1pt } else { 2pt })

        *LƯU Ý KHI LÀM BÀI* \
        Tô kín ô bằng bút chì 2B; tẩy sạch khi sửa. \
        SBD / mã đề: tô đủ chữ số, kể cả số 0 ở đầu.
      ],
    )

    #at(
      if compact { 98mm } else { 95mm },
      0mm,
      identity([SỐ BÁO DANH], 6, compact: compact),
    )

    #at(
      if compact { 153mm } else { 151mm },
      0mm,
      identity([MÃ ĐỀ], 4, compact: compact),
    )
  ]
}

// ------------------------------------------------------------
// I. TRẮC NGHIỆM
// ------------------------------------------------------------

#let multiple-choice(compact: false) = {
  let w = if compact { 51mm } else { 91mm }
  let group-step = if compact { 26mm } else { 47mm }
  let option-x = if compact { 6mm } else { 9mm }
  let option-step = if compact { 4.5mm } else { 7.1mm }
  let row-step = if compact { 7mm } else { 8mm }
  let d = if compact { 3mm } else { 3.8mm }
  let start-y = if compact { 9mm } else { 11mm }

  let options = ("A", "B", "C", "D")

  block(
    width: w,
    height: if compact { 59mm } else { 57mm },
  )[
    #section([01], [TRẮC NGHIỆM], w, compact: compact)

    #for group in range(2) {
      for row in range(6) {
        let q = group * 6 + row + 1
        let y = start-y + row * row-step

        at(
          group * group-step,
          y + 0.2mm,
          tx(
            str(q),
            size: if compact { 7.5pt } else { 9pt },
            weight: "bold",
          ),
        )

        for option in range(4) {
          at(
            group * group-step
              + option-x
              + option * option-step,
            y,
            bubble(options.at(option), diameter: d),
          )
        }
      }
    }

    #if compact {
      at(
        0mm, 52mm,
        tx(
          [Mỗi câu chỉ tô 1 phương án.],
          size: 6.4pt,
          fill: muted,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// II. ĐÚNG / SAI
// ------------------------------------------------------------

#let true-false(compact: false) = {
  let w = if compact { 38mm } else { 91mm }
  let group-step = if compact { 20mm } else { 47mm }
  let option-x = if compact { 4.2mm } else { 9mm }
  let option-step = if compact { 5.3mm } else { 11mm }
  let row-step = if compact { 8mm } else { 9mm }
  let d = if compact { 3mm } else { 3.8mm }

  let heading-y = if compact { 8mm } else { 11mm }
  let row-y = if compact { 15mm } else { 19mm }

  let items = ("a", "b", "c", "d")
  let options = ("Đ", "S")

  block(
    width: w,
    height: if compact { 59mm } else { 57mm },
  )[
    #section([02], [ĐÚNG / SAI], w, compact: compact)

    #for q in range(2) {
      at(
        q * group-step,
        heading-y,
        tx(
          [Câu #str(q + 1)],
          size: if compact { 7pt } else { 9pt },
          weight: "bold",
        ),
      )

      for item in range(4) {
        let y = row-y + item * row-step

        at(
          q * group-step,
          y + 0.2mm,
          tx(
            items.at(item),
            size: if compact { 7.3pt } else { 9pt },
            weight: "bold",
          ),
        )

        for option in range(2) {
          at(
            q * group-step
              + option-x
              + option * option-step,
            y,
            bubble(options.at(option), diameter: d),
          )
        }
      }
    }

    #if compact {
      at(
        0mm, 48mm,
        block(width: w)[
          #set text(size: 6.4pt, fill: muted)
          #set par(leading: 1pt)
          Đ: đúng · S: sai. \
          Mỗi ý chỉ tô 1 ô.
        ],
      )
    }
  ]
}

// ------------------------------------------------------------
// III. TRẢ LỜI NGẮN
//
// Chỉ số row, col trong code bắt đầu từ 0.
//
// row = 0: chỉ col = 0 có dấu âm.
// row = 1: chỉ col = 1 hoặc 2 có dấu phẩy.
// row >= 2: cả 4 cột có chữ số.
//
// Không nén hàng khi bỏ ô:
// Giữ nguyên hệ tọa độ 12 hàng cho cả 4 cột.
// ------------------------------------------------------------

#let tln-cell-valid(row, col) = {
  if row == 0 {
    col == 0
  } else if row == 1 {
    col == 1 or col == 2
  } else {
    true
  }
}

#let short-card(question, compact: false) = {
  let w = if compact { 22.5mm } else { 44.5mm }
  let px = if compact { 4.6mm } else { 8.5mm }
  let py = if compact { 3.7mm } else { 6.3mm }
  let d = if compact { 3mm } else { 4.2mm }

  let grid-w = 4 * px
  let grid-x = (w - grid-w) / 2

  let box-y = if compact { 4mm } else { 6mm }
  let box-h = if compact { 4mm } else { 6mm }
  let grid-y = if compact { 9mm } else { 14mm }

  let symbols = (
    "−", ",",
    "0", "1", "2", "3", "4",
    "5", "6", "7", "8", "9",
  )

  block(
    width: w,
    height: if compact { 53mm } else { 89mm },
  )[
    #at(
      0mm, 0mm,
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
        grid-x + col * px + 0.25mm,
        box-y,
        write-box(px - 0.5mm, box-h),
      )

      for row in range(symbols.len()) {
        if tln-cell-valid(row, col) {
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

#let short-answers(compact: false) = {
  let w = if compact { 93mm } else { 190mm }
  let step = if compact { 23.5mm } else { 48.5mm }
  let card-y = if compact { 7mm } else { 11mm }

  block(
    width: w,
    height: if compact { 60mm } else { 105mm },
  )[
    #section([03], [TRẢ LỜI NGẮN], w, compact: compact)

    #at(
      if compact { 65mm } else { 145mm },
      if compact { 0.9mm } else { 1.4mm },
      tx(
        [4 ký tự / đáp án],
        size: if compact { 6.2pt } else { 8pt },
        fill: muted,
      ),
    )

    #for q in range(4) {
      at(
        q * step,
        card-y,
        short-card(q + 1, compact: compact),
      )
    }

    #if not compact {
      at(
        0mm, 102mm,
        tx(
          [
            Viết từ trái sang phải.
            Dấu âm chỉ ở cột 1; dấu phẩy ở cột 2 hoặc 3.
            Cột dư để trống.
          ],
          size: 8pt,
          fill: muted,
        ),
      )
    }
  ]
}

// ------------------------------------------------------------
// GHÉP PHIẾU
// ------------------------------------------------------------

#let sheet(compact: false) = {
  let w = 190mm
  let h = if compact { 128mm } else { 277mm }

  block(width: w, height: h)[
    #registration(w, h)

    #at(0mm, 0mm, header(compact: compact))

    #at(
      0mm,
      if compact { 12mm } else { 20mm },
      candidate(compact: compact),
    )

    #if compact {
      // A5 ngang.
      at(0mm, 62mm, multiple-choice(compact: true))
      at(55mm, 62mm, true-false(compact: true))
      at(97mm, 62mm, short-answers(compact: true))

      at(
        0mm, 123mm,
        line(length: 190mm, stroke: 0.45pt + rule-color),
      )

      at(
        0mm, 124.8mm,
        tx(
          [
            TLN: viết trái → phải; mỗi cột dùng chỉ tô 1 ô;
            cột dư để trống. Không gấp phiếu hoặc làm bẩn mốc đen.
          ],
          size: 6pt,
          fill: muted,
        ),
      )

      at(
        165mm, 124.8mm,
        righted(
          25mm,
          tx(
            [VN-A5-M3],
            size: 6pt,
            weight: "bold",
            fill: accent,
          ),
        ),
      )
    } else {
      // A4 dọc.
      at(0mm, 94mm, multiple-choice(compact: false))
      at(99mm, 94mm, true-false(compact: false))
      at(0mm, 157mm, short-answers(compact: false))

      at(
        0mm, 266mm,
        line(length: 190mm, stroke: 0.5pt + rule-color),
      )

      at(
        0mm, 266mm,
        line(length: 25mm, stroke: 1pt + accent),
      )

      at(
        0mm, 270mm,
        block(width: 160mm)[
          #set text(size: 8pt, fill: muted)
          #set par(leading: 1.5pt)

          TN: mỗi câu 1 ô. Đ/S: mỗi ý 1 ô.
          TLN: mỗi cột sử dụng chỉ tô 1 ô. \
          Tẩy sạch khi sửa; không gấp phiếu,
          không viết hoặc tô vào các mốc đen.
        ],
      )

      at(
        164mm, 271mm,
        righted(
          26mm,
          tx(
            [VN-A4-M3],
            size: 8pt,
            weight: "bold",
            fill: accent,
          ),
        ),
      )
    }
  ]
}

// ============================================================
// TRANG 1 — A5 NGANG
// ============================================================

#sheet(compact: true)

// ============================================================
// TRANG 2 — A4 DỌC
// ============================================================


]
