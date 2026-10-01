// Chạy từ thư mục gói: typst compile --root . examples/exam-variant-omr.typ
#import "@preview/sang-math:1.1.0": *

#let (tn, ds, tln, tl) = bank-mode()
#let mcq-bank = range(12).map(i => tn(
  [Câu minh họa số #str(i + 1). Chọn đáp án đúng.],
  ([A], True([B]), [C], [D]), id: "2D1N1-1",
))
#let tf-bank = range(4).map(i => ds(
  [Câu đúng/sai minh họa số #str(i + 1).],
  (True([Đúng]), [Sai], True([Đúng]), [Sai]), id: "2D1H1-1",
))
#let short-bank = range(6).map(i => tln(
  [Tính #str(i + 1) + 1.], i + 2, id: "2D1V1-1",
))
#let bank = mcq-bank + tf-bank + short-bank
#let blueprint = (
  (kind: QUESTION_MC, count: 12, title: [Phần I. Trắc nghiệm]),
  (kind: QUESTION_TF, count: 4, title: [Phần II. Đúng sai]),
  (kind: QUESTION_SA, count: 6, title: [Phần III. Trả lời ngắn]),
)
#let ma-de = "0101"
#let variant = exam-variant(bank, blueprint, seed: 2026, ma-de: ma-de)

#set page(paper: "a4", margin: 18mm)
#show: sang-setup
= Đề kiểm tra — Mã #ma-de
#render-exam-variant(variant)

#pagebreak()
= Dành cho giáo viên — QR đáp án mã #ma-de
#exam-variant-qr(variant)

#pagebreak()
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "omr/12-4-6ngang.typ"
