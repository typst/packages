// Original print geometry; identity fill only. See omr/README.md.
#let render(sbd: "", ma-de: "") = [
// ============================================================
// PHIẾU OMR A4 — MẪU 18–4–6 VÀ 24–4–0
//
// Trang 1: 18 TN + 4 Đ/S × 4 ý + 6 TLN.
// Trang 2: 24 TN + 4 Đ/S × 4 ý.
//
// SBD tùy chọn 6 hoặc 8 chữ số.
// Mã đề 4 chữ số.
//
// Không cần package, ảnh hoặc file phụ.
// ============================================================

// ------------------------------------------------------------
// CẤU HÌNH — CHỈ NHẬP 6 HOẶC 8
// ------------------------------------------------------------

#let sbd-mau-18 = 6
#let sbd-mau-24 = 6

// Ví dụ:
// Đổi sbd-mau-18 thành 8 để trang 18–4–6 dùng SBD 8 số.
// Đổi sbd-mau-24 thành 8 để trang 24–4–0 dùng SBD 8 số.

// ------------------------------------------------------------
// THIẾT LẬP CHUNG
// ------------------------------------------------------------

#set text(size: 9pt, fill: black)
#set par(leading: 0pt, spacing: 0pt)
#set block(spacing: 0pt)

// Vùng nội dung: 190 × 277 mm.
// Tất cả tọa độ nội dung tính từ góc trên trái vùng này.

// ------------------------------------------------------------
// BẢNG MÀU
// ------------------------------------------------------------

#let ink = rgb("#25344D")
#let accent = rgb("#485FA8")
#let muted = rgb("#637086")
#let soft = rgb("#F0F3FA")
#let rule-color = rgb("#C7D0E1")

// Ô tô và mốc định vị luôn đen/trắng.
// Không phủ nền màu lên vùng đọc OMR.

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

#let bubble(symbol, diameter: 3.8mm, marked: false) = {
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

#let section(number, title, note: []) = {
  block(width: 190mm, height: 8mm)[
    #at(
      0mm,
      0mm,
      pill(number, 8mm, 5.8mm, size: 8.5pt),
    )

    #at(
      10mm,
      1mm,
      tx(title, size: 10pt, weight: "bold"),
    )

    #at(
      105mm,
      1.4mm,
      righted(
        85mm,
        tx(note, size: 7.8pt, fill: muted),
      ),
    )

    #at(
      0mm,
      7.5mm,
      line(
        length: 190mm,
        stroke: 0.45pt + rule-color,
      ),
    )
  ]
}

#let field(title, w) = {
  block(width: w, height: 9mm)[
    #at(
      0mm,
      0mm,
      tx(title, size: 8.5pt, fill: muted),
    )

    #at(
      0mm,
      6mm,
      line(length: w, stroke: 0.3pt + rule-color),
    )
  ]
}

// ------------------------------------------------------------
// ĐỊNH VỊ — 12 MỐC CHÍNH + 1 MỐC PHỤ
//
// Tọa độ dưới đây tính từ góc trên trái vùng nội dung.
//
// Mỗi mốc chính: 4 × 4 mm.
// Tọa độ tâm mốc trên giấy:
// X = 10 mm + x + 2 mm
// Y = 10 mm + y + 2 mm
//
// Phần mềm cần đối chiếu bố trí nhiều mốc,
// không bắt buộc chỉ sử dụng 4 mốc góc.
// ------------------------------------------------------------

#let registration() = {
  let w = 190mm
  let h = 277mm

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

  // Mốc phụ nhận chiều: 2.5 × 2.5 mm.
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

#let header(tn-count, tln-count) = {
  let model = (
    str(tn-count) + "–4–" + str(tln-count)
  )

  let subtitle = if tln-count > 0 {
    (
      str(tn-count)
      + " câu trắc nghiệm  ·  04 câu đúng / sai  ·  "
      + str(tln-count)
      + " câu trả lời ngắn"
    )
  } else {
    (
      str(tn-count)
      + " câu trắc nghiệm  ·  04 câu đúng / sai"
    )
  }

  block(width: 190mm, height: 17mm)[
    #at(
      0mm,
      0.5mm,
      tx(
        [PHIẾU TRẢ LỜI TRẮC NGHIỆM],
        size: 17pt,
        weight: "bold",
      ),
    )

    #at(
      0mm,
      9mm,
      tx(subtitle, size: 8.8pt, fill: muted),
    )

    #at(
      158mm,
      1mm,
      pill(model, 32mm, 6.5mm, size: 10pt),
    )

    #at(
      145mm,
      10mm,
      righted(
        45mm,
        tx(
          [A4 DỌC / OMR],
          size: 7.5pt,
          fill: muted,
        ),
      ),
    )

    #at(
      0mm,
      15.5mm,
      line(
        length: 190mm,
        stroke: 0.5pt + rule-color,
      ),
    )

    #at(
      0mm,
      15.5mm,
      line(length: 25mm, stroke: 1.1pt + accent),
    )
  ]
}

// ------------------------------------------------------------
// SBD / MÃ ĐỀ
//
// Pitch cố định cho cả SBD 6 và 8 số.
// Khối SBD nằm trong vùng rộng 58 mm, căn giữa.
//
// Đổi số chữ số sẽ đổi tọa độ khởi đầu các cột;
// phải chọn đúng template OMR tương ứng.
// ------------------------------------------------------------

#let identity(title, columns) = {
  let code = if columns == 4 { ma-de } else { sbd }
  let px = 6.8mm
  let py = 5.1mm
  let d = 3.8mm

  let box-y = 6mm
  let box-h = 5.5mm
  let grid-y = 13mm

  let w = columns * px

  block(width: w, height: 64mm)[
    #at(
      0mm,
      0mm,
      centered(
        w,
        tx(
          title,
          size: 9pt,
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

#let candidate(sbd-digits) = {
  let fw = 79mm

  let titles = (
    [Họ và tên:],
    [Lớp / Trường:],
    [Môn thi / Kỳ thi:],
    [Ngày thi / Phòng thi:],
  )

  // Vùng SBD bắt đầu tại x = 88 mm, rộng 58 mm.
  let sbd-area-x = 88mm
  let sbd-area-w = 58mm
  let sbd-width = sbd-digits * 6.8mm
  let sbd-x = sbd-area-x + (sbd-area-w - sbd-width) / 2

  block(width: 190mm, height: 66mm)[
    #for i in range(titles.len()) {
      at(
        0mm,
        i * 9.5mm,
        field(titles.at(i), fw),
      )
    }

    #at(
      0mm,
      40mm,
      rect(
        width: fw,
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
      block(width: fw - 4mm)[
        #set text(size: 8pt, fill: ink)
        #set par(leading: 2pt)

        *LƯU Ý KHI LÀM BÀI* \
        Tô kín ô bằng bút chì 2B; tẩy sạch khi sửa. \
        SBD: #str(sbd-digits) chữ số. Mã đề: 4 chữ số. \
        Ghi và tô đủ các chữ số 0 ở đầu, nếu có.
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
// PHẦN I — TRẮC NGHIỆM
//
// 18 câu: 3 nhóm × 6 câu.
// 24 câu: 4 nhóm × 6 câu.
//
// Đọc hết mỗi nhóm từ trên xuống, sau đó sang nhóm kế.
// ------------------------------------------------------------

#let multiple-choice(count, spacious: false) = {
  let groups = if count == 18 { 3 } else { 4 }

  let group-step = if count == 18 {
    64mm
  } else {
    48mm
  }

  let option-x = if count == 18 { 12mm } else { 9mm }
  let option-step = if count == 18 { 10mm } else { 8mm }

  let row-step = if spacious { 10mm } else { 6.5mm }
  let d = if spacious { 4.2mm } else { 3.8mm }

  let options = ("A", "B", "C", "D")

  block(
    width: 190mm,
    height: if spacious { 68mm } else { 49mm },
  )[
    #section(
      [01],
      [TRẮC NGHIỆM],
      note: [Mỗi câu chỉ chọn một phương án A, B, C hoặc D],
    )

    #for group in range(groups) {
      for row in range(6) {
        let q = group * 6 + row + 1
        let y = 11mm + row * row-step

        at(
          group * group-step,
          y + 0.4mm,
          tx(
            str(q),
            size: 9pt,
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
// PHẦN II — 4 CÂU ĐÚNG / SAI
// Mỗi câu có 4 ý a, b, c, d.
// ------------------------------------------------------------

#let true-false(spacious: false) = {
  let group-step = 48mm
  let row-step = if spacious { 11mm } else { 6mm }
  let row-y = if spacious { 22mm } else { 18mm }
  let d = if spacious { 4.2mm } else { 3.6mm }

  let items = ("a", "b", "c", "d")
  let options = ("Đ", "S")

  block(
    width: 190mm,
    height: if spacious { 62mm } else { 41mm },
  )[
    #section(
      [02],
      [ĐÚNG / SAI],
      note: [Mỗi ý chỉ tô một ô: Đ = đúng, S = sai],
    )

    #for q in range(4) {
      at(
        q * group-step,
        11mm,
        tx(
          [Câu #str(q + 1)],
          size: 8.5pt,
          weight: "bold",
        ),
      )

      for item in range(4) {
        let y = row-y + item * row-step

        at(
          q * group-step,
          y + 0.3mm,
          tx(
            items.at(item),
            size: 9pt,
            weight: "bold",
          ),
        )

        for option in range(2) {
          at(
            q * group-step + 13mm + option * 12mm,
            y,
            bubble(options.at(option), diameter: d),
          )
        }
      }
    }
  ]
}

// ------------------------------------------------------------
// PHẦN III — TLN
//
// 6 câu đặt trên 1 hàng, mỗi câu rộng 30 mm.
// Mỗi đáp án có tối đa 4 ký tự.
//
// Chỉ số trong code bắt đầu từ 0:
//
// row 0: dấu âm, chỉ col 0.
// row 1: dấu phẩy, chỉ col 1 và col 2.
// row 2–11: chữ số 0–9, cả 4 cột.
//
// Mỗi câu có 43 ô hợp lệ.
// Không vẽ ô và không đọc OMR tại vị trí không hợp lệ.
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

#let short-card(question) = {
  let w = 30mm
  let px = 6mm
  let py = 4.1mm
  let d = 3.3mm

  let grid-x = 3mm
  let grid-y = 12mm

  let symbols = (
    "−", ",",
    "0", "1", "2", "3", "4",
    "5", "6", "7", "8", "9",
  )

  block(width: w, height: 61mm)[
    #at(
      0mm,
      0mm,
      centered(
        w,
        tx(
          [Câu #str(question)],
          size: 8pt,
          weight: "bold",
        ),
      ),
    )

    #for col in range(4) {
      at(
        grid-x + col * px + 0.25mm,
        5mm,
        write-box(px - 0.5mm, 5mm),
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

#let short-answers() = {
  block(width: 190mm, height: 72mm)[
    #section(
      [03],
      [TRẢ LỜI NGẮN],
      note: [Tối đa 4 ký tự / đáp án · Viết từ trái sang phải],
    )

    #for q in range(6) {
      at(
        q * 32mm,
        10mm,
        short-card(q + 1),
      )
    }
  ]
}

// ------------------------------------------------------------
// KHUNG NHẮC NHẸ CHO MẪU KHÔNG CÓ TLN
// ------------------------------------------------------------

#let final-reminder() = {
  block(width: 190mm, height: 14mm)[
    #rect(
      width: 190mm,
      height: 14mm,
      inset: 0pt,
      radius: 1.2mm,
      fill: soft,
      stroke: none,
    )

    #at(
      3mm,
      2mm,
      tx(
        [TRƯỚC KHI NỘP BÀI],
        size: 8pt,
        weight: "bold",
        fill: accent,
      ),
    )

    #at(
      3mm,
      7mm,
      tx(
        [
          Kiểm tra SBD, mã đề và các ô đã tô.
          Không tô nhiều phương án trong cùng một câu hoặc một ý.
        ],
        size: 8pt,
      ),
    )
  ]
}

// ------------------------------------------------------------
// CHÂN PHIẾU VÀ MÃ TEMPLATE
//
// Mã template tự đổi theo số chữ số SBD.
// Mã này là nhãn văn bản, không phải mã vạch.
// ------------------------------------------------------------

#let footer(tn-count, tln-count, sbd-digits) = {
  let template-id = (
    "A4-"
      + str(tn-count)
      + "-4-"
      + str(tln-count)
      + "-S"
      + str(sbd-digits)
      + "-V1"
  )

  block(width: 190mm, height: 9mm)[
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
      2mm,
      block(width: 140mm)[
        #set text(size: 7pt, fill: muted)
        #set par(leading: 1.2pt)

        #if tln-count > 0 [
          TLN: dấu âm ở cột 1; dấu phẩy ở cột 2 hoặc 3.
          Cột dư để trống. \
          Không bỏ trống xen giữa đáp án.
          Không gấp phiếu hoặc làm bẩn mốc đen.
        ] else [
          Tẩy sạch khi sửa; không đánh dấu chéo vào ô đáp án. \
          Không gấp phiếu, không viết hoặc tô vào các mốc đen.
        ]
      ],
    )

    #at(
      141mm,
      3mm,
      righted(
        49mm,
        tx(
          template-id,
          size: 7.2pt,
          weight: "bold",
          fill: accent,
        ),
      ),
    )
  ]
}

// ------------------------------------------------------------
// GHÉP PHIẾU A4
//
// 18–4–6:
// Header     y = 0
// Thông tin  y = 22
// TN         y = 94
// Đ/S        y = 144
// TLN        y = 191
// Footer     y = 268
//
// 24–4–0:
// Header     y = 0
// Thông tin  y = 22
// TN         y = 98
// Đ/S        y = 179
// Nhắc bài   y = 249
// Footer     y = 268
// ------------------------------------------------------------

#let answer-sheet(tn-count, tln-count, sbd-digits: 6) = {
  assert(
    sbd-digits == 6 or sbd-digits == 8,
    message: "SBD chỉ được cấu hình 6 hoặc 8 chữ số.",
  )

  assert(
    (tn-count == 18 and tln-count == 6)
      or (tn-count == 24 and tln-count == 0),
    message: "Mẫu hỗ trợ: 18–4–6 hoặc 24–4–0.",
  )

  let has-tln = tln-count > 0

  block(width: 190mm, height: 277mm)[
    #registration()

    #at(
      0mm,
      0mm,
      header(tn-count, tln-count),
    )

    #at(
      0mm,
      22mm,
      candidate(sbd-digits),
    )

    #if has-tln {
      at(
        0mm,
        94mm,
        multiple-choice(tn-count, spacious: false),
      )

      at(
        0mm,
        144mm,
        true-false(spacious: false),
      )

      at(
        0mm,
        191mm,
        short-answers(),
      )
    } else {
      at(
        0mm,
        98mm,
        multiple-choice(tn-count, spacious: true),
      )

      at(
        0mm,
        179mm,
        true-false(spacious: true),
      )

      at(
        0mm,
        249mm,
        final-reminder(),
      )
    }

    #at(
      0mm,
      268mm,
      footer(tn-count, tln-count, sbd-digits),
    )
  ]
}

// ============================================================
// TRANG 1 — MẪU 18–4–6
// ============================================================



// ============================================================
// TRANG 2 — MẪU 24–4–0
// ============================================================

#answer-sheet(
  24,
  0,
  sbd-digits: sbd-mau-24,
)
]
