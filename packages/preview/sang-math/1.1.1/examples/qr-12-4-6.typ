// Compile from the typst/packages checkout with Typst 0.15.0+:
// typst compile --root . --package-path packages packages/preview/sang-math/1.1.1/examples/qr-12-4-6.typ /tmp/qr-12-4-6.pdf
#import "@preview/sang-math:1.1.1": *

#let ma-de = "0101"
#set page(paper: "a4", margin: 18mm)
#show: sang-setup

= Đề minh họa 12–4–6

#exam-part([Phần I — Trắc nghiệm], count: 12)
#for i in range(12) {
  tn(
    [Câu minh họa #str(i + 1): tính #str(i + 1) + 1.],
    ([0], True([#str(i + 2)]), [20], [30]),
    loigiai: [Kết quả là #str(i + 2).],
  )
}

#exam-part([Phần II — Đúng/sai], count: 4)
#for i in range(4) {
  ds(
    [Câu minh họa đúng/sai #str(i + 1).],
    (True([$2$ là số chẵn.]), [$3$ là số chẵn.], True([$4$ là số chẵn.]), [$5$ là số chẵn.]),
  )
}

#exam-part([Phần III — Trả lời ngắn], count: 6)
#for i in range(6) {
  tln([Tính #str(i + 1) + 1.], [#str(i + 2)])
}

#pagebreak()
= QR đáp án cho giáo viên
#sang-omr-qr(ma-de: ma-de, profile: "12-4-6ngang", width: 3cm)

#pagebreak()
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "omr/12-4-6ngang.typ"
