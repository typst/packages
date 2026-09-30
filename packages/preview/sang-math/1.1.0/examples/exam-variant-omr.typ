// Chạy từ thư mục gói: typst compile --root . examples/exam-variant-omr.typ
#import "../lib.typ": *

#let mcq-bank = range(12).map(i => question(
  id: "MC-" + str(i + 1), kind: QUESTION_MC,
  prompt: [Câu trắc nghiệm số #str(i + 1). Chọn đáp án đúng.],
  choices: (choice([A]), choice([B], correct: true), choice([C]), choice([D])),
  answer: answer("choice", 2),
  grade: 12, topic: "on-tap", difficulty: 1,
))
#let tf-bank = range(4).map(i => question(
  id: "TF-" + str(i + 1), kind: QUESTION_TF,
  prompt: [Câu đúng sai số #str(i + 1).],
  choices: (choice([Đúng], correct: true), choice([Sai]), choice([Đúng], correct: true), choice([Sai])),
  grade: 12, topic: "on-tap", difficulty: 2,
))
#let short-bank = range(6).map(i => question(
  id: "SA-" + str(i + 1), kind: QUESTION_SA,
  prompt: [Tính #str(i + 1) + 1.],
  answer: answer("numeric", i + 2),
  grade: 12, topic: "on-tap", difficulty: 3,
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
