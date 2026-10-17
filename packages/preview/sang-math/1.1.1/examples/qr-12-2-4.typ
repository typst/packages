#import "@preview/sang-math:1.1.1": *
#set page(paper: "a4", margin: 10mm)
#show: sang-setup
#let ma-de = "0101"

= Đề minh họa 12–2–4
#exam-part([Phần I — Trắc nghiệm], count: 12)
#for i in range(12) {
  tn([Tính #str(i + 1) + 1.], ([0], True([#str(i + 2)]), [20], [30]))
}
#exam-part([Phần II — Đúng/sai], count: 2)
#for i in range(2) {
  ds([Xét các phát biểu.], (True([$2$ là số chẵn.]), [$3$ là số chẵn.], True([$4$ là số chẵn.]), [$5$ là số chẵn.]))
}
#exam-part([Phần III — Trả lời ngắn], count: 4)
#for answer in ([-1,5], [0,05], [1234], [0]) {
  tln([Câu minh họa.], answer)
}
#pagebreak()
= QR đáp án cho giáo viên
#sang-omr-qr(ma-de: ma-de, profile: "new-12-2-4-a5")
#v(5mm)
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "omr/12-2-4.typ"
