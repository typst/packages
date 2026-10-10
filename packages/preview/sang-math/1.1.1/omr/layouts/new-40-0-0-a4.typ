// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR — 40 CÂU TRẮC NGHIỆM A–D
//
// Trang 1: A5 ngang.
// Trang 2: A4 dọc.
//
// SBD: tùy chọn 6 hoặc 8 chữ số.
// Mã đề: 4 chữ số.
//
// 4 nhóm câu:
// Nhóm 1: 01–10.
// Nhóm 2: 11–20.
// Nhóm 3: 21–30.
// Nhóm 4: 31–40.
//
// Không dùng package, ảnh hoặc file phụ.
// ============================================================

// ------------------------------------------------------------
// CẤU HÌNH SBD — CHỈ NHẬP 6 HOẶC 8
// ------------------------------------------------------------

#let sbd-a5 = 6
#let sbd-a4 = 6

// ------------------------------------------------------------
// THIẾT LẬP CHUNG
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
        size: if compact { 7.3pt } else { 8.5pt },
        fill: muted,
      ),
    )

    #at(
      0mm,
      if compact { 5.4mm } else { 6mm },
      line(length: w, stroke: 0.3pt + rule-color),
    )
  ]
}

// ------------------------------------------------------------
// ĐỊNH VỊ
//
// 12 mốc chính, mỗi mốc 4 × 4 mm.
// 1 mốc phụ nhận chiều, kích thước 2.5 × 2.5 mm.
//
// Vùng nội dung cách mép giấy 10 mm.
// Tọa độ dưới đây tính từ góc trên trái vùng nội dung.
//
// Tâm mốc chính trên giấy:
// X = 10 mm + x + 2 mm
// Y = 10 mm + y + 2 mm
//
// A5: vùng nội dung 190 × 128 mm.
// A4: vùng nội dung 190 × 277 mm.
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
        [PHIẾU TRẢ LỜI TRẮC NGHIỆM],
        size: if compact { 13.3pt } else { 17pt },
        weight: "bold",
      ),
    )

    #at(
      0mm,
      if compact { 6mm } else { 9mm },
      tx(
        [40 câu trắc nghiệm  ·  4 phương án A–D  ·  Mỗi câu chọn 1 đáp án],
        size: if compact { 6.8pt } else { 8.8pt },
        fill: muted,
      ),
    )

    #at(
      158mm,
      0.5mm,
      pill(
        [40 CÂU TN],
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
      line(
        length: 190mm,
        stroke: 0.5pt + rule-color,
      ),
    )

    #at(
      0mm,
      if compact { 10mm } else { 15.5mm },
      line(length: 25mm, stroke: 1.1pt + accent),
    )
  ]
}

// ------------------------------------------------------------
// SBD VÀ MÃ ĐỀ
// ------------------------------------------------------------

#let identity(title, columns, compact: false) = {
  let code = if columns == 4 { ma-de } else { sbd }
  let px = if compact { 6mm } else { 6.8mm }
  let py = if compact { 3.8mm } else { 5.1mm }
  let d = if compact { 3mm } else { 3.8mm }

  let box-y = if compact { 5mm } else { 6mm }
  let box-h = if compact { 4.2mm } else { 5.5mm }
  let grid-y = if compact { 10.2mm } else { 13mm }

  let w = columns * px

  block(
    width: w,
    height: if compact { 48mm } else { 64mm },
  )[
    #at(
      0mm,
      0mm,
      centered(
        w,
        tx(
          title,
          size: if compact { 7.5pt } else { 9pt },
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
//
// SBD căn giữa trong vùng x = 88 mm, rộng 58 mm.
// Thay đổi 6/8 số sẽ thay đổi vị trí bắt đầu cột SBD.
// ------------------------------------------------------------

#let candidate(sbd-digits, compact: false) = {
  let fw = 79mm
  let step = if compact { 8mm } else { 9.5mm }

  let titles = (
    [Họ và tên:],
    [Lớp / Trường:],
    [Môn thi / Kỳ thi:],
    [Ngày thi / Phòng thi:],
  )

  let px = if compact { 6mm } else { 6.8mm }
  let sbd-w = sbd-digits * px
  let sbd-x = 88mm + (58mm - sbd-w) / 2

  let note-y = if compact { 34mm } else { 40mm }
  let note-h = if compact { 13mm } else { 21mm }

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
      0mm,
      note-y,
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
      2mm,
      note-y + 1.5mm,
      block(width: fw - 4mm)[
        #set text(
          size: if compact { 6.4pt } else { 8pt },
          fill: ink,
        )
        #set par(leading: if compact { 1pt } else { 2pt })

        *LƯU Ý KHI LÀM BÀI* \
        Tô kín ô bằng bút chì 2B; tẩy sạch khi sửa. \
        SBD #str(sbd-digits) số, mã đề 4 số; tô cả số 0 ở đầu.
      ],
    )

    #at(
      sbd-x,
      0mm,
      identity(
        [SỐ BÁO DANH],
        sbd-digits,
        compact: compact,
      ),
    )

    #at(
      160mm,
      0mm,
      identity(
        [MÃ ĐỀ],
        4,
        compact: compact,
      ),
    )
  ]
}

// ------------------------------------------------------------
// 40 CÂU TRẮC NGHIỆM
//
// 4 nhóm × 10 câu, đọc từ trên xuống theo từng nhóm.
//
// A5:
// - Ô tô 3 mm.
// - Khoảng cách hàng 5 mm.
//
// A4:
// - Ô tô 4.2 mm.
// - Khoảng cách hàng 15 mm.
//
// Tâm ô tương đối so với khối answers:
// X = group * 48 mm + 10 mm + option * 8 mm + d / 2
// Y = start-y + row * row-step + d / 2
//
// group = 0..3
// row = 0..9
// option = 0..3 tương ứng A, B, C, D
// ------------------------------------------------------------

#let answers(compact: false) = {
  let group-step = 48mm
  let option-x = 10mm
  let option-step = 8mm

  let row-step = if compact { 5mm } else { 15mm }
  let start-y = if compact { 8mm } else { 13mm }
  let d = if compact { 3mm } else { 4.2mm }

  let group-w = 46mm
  let options = ("A", "B", "C", "D")

  block(
    width: 190mm,
    height: if compact { 57mm } else { 154mm },
  )[
    #for group in range(4) {
      let first = group * 10 + 1
      let last = first + 9

      let group-title = (
        "CÂU "
        + str(first)
        + "–"
        + str(last)
      )

      at(
        group * group-step,
        0mm,
        pill(
          group-title,
          group-w,
          if compact { 5mm } else { 7mm },
          size: if compact { 7pt } else { 9pt },
        ),
      )

      for row in range(10) {
        let q = group * 10 + row + 1
        let q-label = if q < 10 {
          "0" + str(q)
        } else {
          str(q)
        }

        let y = start-y + row * row-step

        at(
          group * group-step,
          y + 0.25mm,
          tx(
            q-label,
            size: if compact { 7.5pt } else { 10pt },
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
  ]
}

// ------------------------------------------------------------
// CHÂN PHIẾU
//
// Nhãn template tự đổi theo khổ giấy và độ dài SBD.
// Đây là nhãn văn bản, không phải mã vạch.
// ------------------------------------------------------------

#let footer(sbd-digits, compact: false) = {
  let paper-id = if compact { "A5" } else { "A4" }

  let template-id = (
    paper-id
    + "-40TN-S"
    + str(sbd-digits)
    + "-V1"
  )

  block(
    width: 190mm,
    height: if compact { 5mm } else { 9mm },
  )[
    #at(
      0mm,
      0mm,
      line(
        length: 190mm,
        stroke: 0.5pt + rule-color,
      ),
    )

    #at(
      0mm,
      0mm,
      line(length: 25mm, stroke: 1pt + accent),
    )

    #at(
      0mm,
      1.8mm,
      block(width: 145mm)[
        #set text(
          size: if compact { 6pt } else { 8pt },
          fill: muted,
        )
        #set par(leading: 1.2pt)

        #if compact [
          Mỗi câu chỉ tô 1 ô. Tẩy sạch khi sửa.
          Không gấp phiếu hoặc làm bẩn mốc định vị.
        ] else [
          Kiểm tra SBD, mã đề và các ô đã tô trước khi nộp bài. \
          Mỗi câu chỉ tô 1 ô. Không gấp phiếu hoặc làm bẩn mốc định vị.
        ]
      ],
    )

    #at(
      147mm,
      if compact { 1.8mm } else { 3mm },
      righted(
        43mm,
        tx(
          template-id,
          size: if compact { 6.2pt } else { 7.8pt },
          weight: "bold",
          fill: accent,
        ),
      ),
    )
  ]
}

// ------------------------------------------------------------
// GHÉP PHIẾU
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

    #at(
      0mm,
      if compact { 12mm } else { 22mm },
      candidate(sbd-digits, compact: compact),
    )

    #at(
      0mm,
      if compact { 62mm } else { 96mm },
      answers(compact: compact),
    )

    #if not compact {
      at(
        0mm,
        256mm,
        centered(
          190mm,
          tx(
            [— HẾT PHẦN TRẢ LỜI —],
            size: 8pt,
            fill: muted,
          ),
        ),
      )
    }

    #at(
      0mm,
      if compact { 123mm } else { 268mm },
      footer(sbd-digits, compact: compact),
    )
  ]
}

// ============================================================
// TRANG 1 — A5 NGANG
// ============================================================



// ============================================================
// TRANG 2 — A4 DỌC
// ============================================================

#sheet(
  sbd-digits: sbd-a4,
  compact: false,
)
]
