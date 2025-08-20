#import "@preview/ncku-later:0.1.0": setup

/*
 * WARN:
 * this file should not contain any contents of the thesis/dissertation
 * this file should be imported by other files with the contents of thesis/dissertation
 */
#let (
  make-cover,
  make-abstract-en,
  make-abstract-zh-tw,
  make-acknowledge-en,
  make-acknowledge-zh-tw,
  make-outline,
  make-ref,
  whole,
  extended-abstract-en,
  mainmatter-or-appendix,
  begin-of-roman-page-num,
  begin-of-arabic-page-num,
) = setup(
  in-degree: (master: false, doctor: true),
  in-institute: "Department of Electrical Engineering",
  in-title: (
    en: "A Thesis/Dissertation Template written in Typst for National Cheng Kung University",
    zh-tw: "以 Typst 撰寫之國立成功大學碩博士論文模板論文模板",
  ),
  in-student: (en: "Chun-Hao Chang", zh-tw: "張峻豪"),
  in-advisor: (en: "Dr. Chia-Chi Tsai", zh-tw: "蔡家齊 博士"),
  in-coadvisor: (
    (en: "Dr. Ha-Ha Lin", zh-tw: "林哈哈 博士"),
  ), // must make this argument be a array which contains one or many dict, so the trailing comma is important for the scenario with only one co-advisor
  in-main-lang: (en: true, zh-tw: false),
)
