// Preview-safe Typst – math standard layout
#set page(
  paper: "a4",
  flipped: false,
  fill: white,
  margin: (top: 5mm, bottom: 5mm, left: 6mm, right: 6mm),
)
#set text(size: 8pt, font: "Times New Roman")

#let marker = box(fill: black, width: 12pt, height: 12pt)
#let tracking-marker = box(fill: black, width: 10pt, height: 10pt)
#let qb = box(width: 1.15pt, height: 1.15pt, fill: black)
#let qw = box(width: 1.15pt, height: 1.15pt, fill: white)


// Optional: #state("sbd").update("1001") and #state("made").update("0101")
// before #include. Blank states leave the student bubbles unmarked.
#let omr-code(value, digits) = {
  if value == none { return "" }
  let code = str(value)
  if code.len() == 0 or code.len() > digits { panic("sang-math OMR: invalid code length") }
  for i in range(code.len()) { if not "0123456789".contains(code.at(i)) { panic("sang-math OMR: codes must contain digits only") } }
  while code.len() < digits { code = "0" + code }
  code
}
#let omr-marked(name, digits, column, row) = {
  let code = omr-code(state(name).get(), digits)
  code != "" and code.at(column) == str(row)
}

#let bubble(label, marked: false) = {
  circle(
    radius: if false { 4.3pt } else { 5pt },
    stroke: 0.5pt + rgb("#333333"),
    fill: if marked { black } else { white },
    align(center + horizon)[#text(size: if false { 6.0pt } else { 7pt }, weight: "regular", fill: if marked { white } else { rgb("#888888") })[#label]],
  )
}

#align(top + center)[
  #scale(x: if false { 88% } else { 95% }, y: if false { 88% } else { 95% }, origin: top)[
    #block(width: 100%, height: 0pt)[
      #place(left, dx: -5mm, dy: -5mm, marker)
      #place(right, dx: 5mm, dy: -5mm, marker)
    ]

    #v(if false { 1pt } else { 2pt })

    #let sbd-box = block(
      inset: (left: if false { 6pt } else { 4pt }, right: if false { 3pt } else { 2pt }, top: if false { 1pt } else { 2pt }, bottom: if false { 1pt } else { 2pt }),
      [
        #place(top + left, dx: -2pt, dy: -2pt)[#tracking-marker]
        #align(center)[#text(weight: "bold", size: 8pt)[SBD #context omr-code(state("sbd").get(), 6)]]
        #v(if false { 1pt } else { 2pt })
        #grid(
          columns: (12pt,) * 6, gutter: if false { 1.2pt } else { 1.5pt },
          ..range(6).map(i => align(center, box(stroke: 0.8pt + black, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt })))
        )
        #v(if false { 1pt } else { 2pt })
        #grid(
          columns: (12pt,) * 6, row-gutter: if false { 0.8pt } else { 1.5pt }, column-gutter: 1.5pt,
          ..range(10).map(r => range(6).map(c => context align(center, bubble(str(r), marked: omr-marked("sbd", 6, c, r))))).flatten()
        )
      ],
    )

    #let made-box = block(
      inset: (left: if false { 3pt } else { 2pt }, right: if false { 3pt } else { 2pt }, top: if false { 1pt } else { 2pt }, bottom: if false { 1pt } else { 2pt }),
      [
        #place(top + left, dx: -2pt, dy: -2pt)[#tracking-marker]
        #align(right)[#text(weight: "bold", size: 8pt)[Mã đề #context omr-code(state("made").get(), 4)]]
        #v(if false { 1pt } else { 2pt })
        #grid(
          columns: (12pt,) * 4,
          gutter: if false { 1.2pt } else { 1.5pt },
          align(center, box(stroke: 0.8pt + black, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt })),
          align(center, box(stroke: 0.8pt + black, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt })),
          align(center, box(stroke: 0.8pt + black, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt })),
          align(center, box(stroke: 0.8pt + black, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt })),
        )
        #v(if false { 1pt } else { 2pt })
        #grid(
          columns: (12pt,) * 4, row-gutter: if false { 0.8pt } else { 1.5pt }, column-gutter: 1.5pt,
          ..range(10).map(r => range(4).map(c => context align(center, bubble(str(r), marked: omr-marked("made", 4, c, r))))).flatten()
        )
      ],
    )

    #let mcq-row(num) = {
      grid(
        columns: (13pt, 12pt, 12pt, 12pt, 12pt),
        align(center + horizon)[*#num*],
        align(center + horizon, bubble("")),
        align(center + horizon, bubble("")),
        align(center + horizon, bubble("")),
        align(center + horizon, bubble("")),
      )
    }

    #let info-phan1-box = block(
      [
        #block(
          inset: (left: 4pt, right: 4pt, top: 2pt, bottom: 2pt),
          [
            #place(top + right, dx: 0pt, dy: -2pt)[
              #box(width: 1.65cm, height: 1.65cm, stroke: 0.6pt, radius: 2pt)[
                #align(center + horizon)[#grid(columns: 33, column-gutter: 0pt, row-gutter: 0pt,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qb, qb, qw, qb, qw, qb, qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qw, qw, qw, qw, qb, qw, qw, qb, qb, qw, qb, qw, qb, qw, qb, qw, qb, qw, qw, qw, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qb, qw, qw, qb, qw, qb, qb, qb, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qb, qw, qb, qb, qb, qb, qb, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qw, qw, qw, qb, qw, qb, qw, qb, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qw, qw, qw, qw, qb, qw, qb, qb, qw, qw, qw, qb, qb, qw, qb, qw, qb, qw, qw, qw, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qb, qw, qb, qw, qb, qw, qb, qw, qb, qw, qb, qb, qb, qb, qb, qb, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qb, qw, qw, qw, qb, qb, qb, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qw, qw, qw, qb, qb, qw, qb, qb, qb, qw, qw, qw, qb, qb, qw, qw, qb, qw, qw, qb, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qw, qb, qb, qb, qb, qb, qb, qw, qw, qb, qb, qb, qb, qw, qw, qb, qb, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qb, qb, qw, qw, qw, qw, qw, qb, qb, qb, qw, qb, qw, qb, qb, qw, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qw, qw, qw, qw, qb, qw, qb, qw, qw, qb, qw, qw, qw, qb, qw, qw, qb, qw, qb, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qw, qb, qb, qw, qw, qb, qb, qw, qb, qw, qw, qb, qw, qw, qb, qw, qb, qb, qb, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qb, qw, qw, qb, qw, qb, qw, qw, qw, qb, qw, qb, qb, qb, qb, qb, qw, qb, qb, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qw, qw, qw, qw, qb, qb, qw, qw, qw, qb, qw, qw, qw, qb, qb, qw, qb, qb, qw, qw, qb, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qb, qb, qb, qw, qw, qw, qw, qw, qw, qw, qb, qw, qw, qw, qb, qw, qw, qw, qb, qb, qw, qb, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qb, qb, qw, qw, qb, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qb, qb, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qb, qw, qb, qb, qw, qb, qw, qb, qb, qw, qw, qw, qb, qw, qw, qb, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qb, qw, qb, qb, qb, qb, qw, qw, qb, qw, qb, qw, qb, qb, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qw, qw, qw, qw, qb, qw, qw, qb, qw, qb, qw, qw, qb, qb, qb, qw, qw, qw, qb, qw, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qw, qw, qb, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qw, qb, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qw, qb, qw, qb, qw, qw, qb, qw, qw, qb, qw, qb, qb, qw, qb, qb, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qb, qb, qb, qw, qb, qw, qb, qb, qb, qb, qb, qw, qb, qb, qb, qb, qw, qb, qb, qb, qw, qb, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qw, qw, qw, qw, qw, qb, qw, qw, qb, qb, qw, qw, qw, qw, qb, qb, qw, qb, qb, qb, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qb, qb, qb, qb, qb, qb, qb, qw, qb, qw, qb, qb, qw, qw, qb, qw, qb, qb, qb, qb, qb, qw, qw, qw, qb, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw,
  qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw, qw
)]
              ]
            ]
            #align(left)[#text(size: 10pt, weight: "bold")[PHIẾU TRẢ LỜI TRẮC NGHIỆM]]
            #v(2pt)
            #text(size: 7.5pt)[*SANG MATH OMR*]
            #v(2pt)
            Họ và tên: ..............................................................
            #v(4pt)
            Lớp: .................... Môn: Kiểm tra – Môn Toán .................... Điểm: .......
          ],
        )
        #line(length: 100%, stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"))
        #block(
          inset: (left: 4pt, right: 4pt, top: 2pt, bottom: 2pt),
          [ *PHẦN I – TRẮC NGHIỆM (Chọn 1 đáp án)* ],
        )
        #line(length: 100%, stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"))
        #grid(
          columns: (1fr, 1fr, 1fr),
          // Col 1
          block(
            stroke: (right: (paint: rgb("#666666"), thickness: 0.5pt, dash: "dashed")),
            inset: 2pt,
            [
              #grid(
                columns: (13pt, 12pt, 12pt, 12pt, 12pt),
                align(center)[#tracking-marker], align(center)[*A*], align(center)[*B*], align(center)[*C*], align(center)[*D*],
              )
              #v(2pt)
              #grid(columns: 1, row-gutter: if false { 0.8pt } else { 1.5pt }, ..range(1, 5).map(i => mcq-row(i)))
            ]
          ),
          // Col 2
          block(
            stroke: (right: (paint: rgb("#666666"), thickness: 0.5pt, dash: "dashed")),
            inset: 2pt,
            [
              #grid(
                columns: (13pt, 12pt, 12pt, 12pt, 12pt),
                align(center)[#tracking-marker], align(center)[*A*], align(center)[*B*], align(center)[*C*], align(center)[*D*],
              )
              #v(2pt)
              #grid(columns: 1, row-gutter: if false { 0.8pt } else { 1.5pt }, ..range(5, 9).map(i => mcq-row(i)))
            ]
          ),
          // Col 3
          block(
            inset: 2pt,
            [
              #grid(
                columns: (13pt, 12pt, 12pt, 12pt, 12pt),
                align(center)[#tracking-marker], align(center)[*A*], align(center)[*B*], align(center)[*C*], align(center)[*D*],
              )
              #v(2pt)
              #grid(columns: 1, row-gutter: if false { 0.8pt } else { 1.5pt }, ..range(9, 13).map(i => mcq-row(i)))
            ]
          )
        )
      ]
    )

    #let tf-q(num) = {
      grid(
        columns: (12pt, 14pt, 14pt),
        row-gutter: if false { 0.8pt } else { 1.5pt },
        grid.cell(rowspan: 2, align: center + horizon)[#tracking-marker],
        grid.cell(colspan: 2, align: center + bottom)[#text(size: 7pt, weight: "bold")[Câu #num]],
        align(center)[#text(size: 7pt, weight: "bold")[Đ]], align(center)[#text(size: 7pt, weight: "bold")[S]],
        [a)], bubble(""), bubble(""),
        [b)], bubble(""), bubble(""),
        [c)], bubble(""), bubble(""),
        [d)], bubble(""), bubble(""),
      )
    }

    #let phan2-box = block(
      [
        #block(inset: (left: 4pt, top: 2pt, bottom: 2pt), [ *PHẦN II – ĐÚNG / SAI* ])
        #line(length: 100%, stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"))
        #block(
          inset: (top: 2pt, bottom: 2pt, left: 4pt, right: if false { 6pt } else { 2pt }),
          grid(
            columns: (1fr, 1fr),
            gutter: 4pt,
            tf-q(1), tf-q(2),
          ),
        )
        #line(length: 100%, stroke: (paint: rgb("#666666"), thickness: 0.5pt, dash: "dashed"))
        #block(
          inset: (top: 2pt, bottom: 2pt, left: 4pt, right: if false { 6pt } else { 2pt }),
          grid(
            columns: (1fr, 1fr),
            gutter: 4pt,
            tf-q(3), tf-q(4),
          ),
        )
      ]
    )

    // TOP BLOCK (SBD, Mã đề, Phần I, Phần II)
    #block(
      width: 100%,
      stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"),
      radius: 4pt,
      clip: true,
      grid(
        columns: (auto, auto, 2.2fr, 1.2fr),
        sbd-box,
        block(stroke: (left: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"), right: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed")), made-box),
        info-phan1-box,
        block(stroke: (left: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed")), phan2-box)
      )
    )

    #v(if false { -2pt } else { 4pt })

    // BOTTOM BLOCK (Phần III) — keep the calibrated legacy offset.
    #let tln-col(num) = {
      block(
        stroke: (right: if num < 6 { (paint: rgb("#666666"), thickness: 0.5pt, dash: "dashed") } else { 0pt }),
        width: 100%,
        inset: (bottom: if false { 2pt } else { 4pt }),
        [
          #align(left)[#text(size:8pt)[*Câu #num*]]
          #v(if false { 1pt } else { 2pt })
          #grid(
            columns: (12pt, 12pt, 12pt, 12pt, 12pt),
            align: center + horizon,
            tracking-marker,
            box(stroke: 0.5pt, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt }),
            box(stroke: 0.5pt, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt }),
            box(stroke: 0.5pt, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt }),
            box(stroke: 0.5pt, width: if false { 10pt } else { 11pt }, height: if false { 10pt } else { 11pt }),
          )
          #v(if false { 1pt } else { 2pt })
          #grid(
            columns: (12pt, 12pt, 12pt, 12pt, 12pt),
            rows: (if false { 9.8pt } else { 12.5pt },) * 13,
            align: center + horizon,
            [#text(size: 6.5pt, fill: rgb("#666666"))[-]], bubble(""), [], [], [],
            [#text(size: 6.5pt, fill: rgb("#666666"))[,]], [], bubble(""), bubble(""), [],
            [#text(size: 6.5pt, fill: rgb("#666666"))[0]], bubble(""), bubble(""), bubble(""), bubble(""),
            ..range(1, 10).map(r => (
              [#text(size: 6.5pt, fill: rgb("#666666"))[#r]],
              bubble(""),
              bubble(""),
              bubble(""),
              bubble("")
            )).flatten(),
          )
        ],
      )
    }

    #block(
      stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"),
      radius: 4pt,
      clip: true,
      width: 100%,
      [
        #block(inset: 3pt, [*PHẦN III – TỰ LUẬN NGẮN*])
        #line(length: 100%, stroke: (paint: rgb("#666666"), thickness: 0.8pt, dash: "dashed"))
        #block(
          inset: (left: 10pt, right: 10pt, top: if false { 3pt } else { 0pt }, bottom: if false { 5pt } else { 6pt }),
          grid(
            columns: (1fr,) * 6,
            ..range(1, 7).map(i => tln-col(i))
          )
        )
      ],
    )

    #if "a4" == "a4" and true [
      #v(6pt)
      #block(width: 100%, stroke: 0.8pt, radius: 4pt, clip: true, [
        #rect(width: 100%, height: 16pt, [#align(center+horizon)[#text(8pt, weight: "bold")[✍ PHẦN TỰ LUẬN – Viết bên dưới]]])
        #v(4pt)
        #for _ in range(12) [
          #line(length: 100%, stroke: (thickness: 0.3pt, dash: "dashed", paint: luma(200)))
          #v(14pt)
        ]
      ])
    ]
    #block(width: 100%, height: 0pt)[
      #place(left, dx: -5mm, dy: 5mm, marker)
      #place(right, dx: 5mm, dy: 5mm, marker)
    ]
  ]
]

#if "a4" == "a5" and true [
  #pagebreak()
  #align(center + horizon)[
    #scale(x: 95%, y: 95%, origin: center)[
      #block(width: 100%, stroke: 0.8pt, radius: 4pt, clip: true, [
        #rect(width: 100%, height: 16pt, [#align(center+horizon)[#text(8pt, weight: "bold")[✍ PHẦN TỰ LUẬN – Viết bên dưới]]])
        #v(4pt)
        #for _ in range(8) [
          #line(length: 100%, stroke: (thickness: 0.3pt, dash: "dashed", paint: luma(200)))
          #v(14pt)
        ]
      ])
    ]
  ]
]
