#import "../lib.typ": setup

/*
 * WARN:
 * this file should not contain any contents of the thesis/dissertation
 * this file should be imported by other files with the contents of thesis/dissertation
 */
#let (
  make_cover,
  make_abstract_en,
  make_abstract_zh_tw,
  make_acknowledge_en,
  make_acknowledge_zh_tw,
  make_outline,
  make_ref,
  whole,
  extended_abstract_en,
  mainmatter_or_appendix,
  begin_of_roman_page_num,
  begin_of_arabic_page_num,
) = setup(
  in_degree: (master: false, doctor: true),
  in_institute: "Department of Electrical Engineering",
  in_title: (
    en: "A Thesis/Dissertation Template written in Typst for National Cheng Kung University",
    zh_tw: "以 Typst 撰寫之國立成功大學碩博士論文模板論文模板",
  ),
  in_student: (en: "Chun-Hao Chang", zh_tw: "張峻豪"),
  in_advisor: (en: "Dr. Chia-Chi Tsai", zh_tw: "蔡家齊 博士"),
  in_coadvisor: (
    (en: "Dr. Ha-Ha Lin", zh_tw: "林哈哈 博士"),
  ), // must make this argument be a array which contains one or many dict, so the trailing comma is important for the scenario with only one co-advisor
  in_main_lang: (en: true, zh_tw: false),
)
