#import "layouts/whole.typ": whole
#import "layouts/mainmatter-or-appendix.typ": mainmatter_or_appendix
#import "layouts/extended-abstract-en.typ": extended_abstract_en
#import "pages/cover.typ": *
// #import "pages/approved-by.typ": *
#import "pages/abstract.typ": *
#import "pages/acknowledge.typ": make_acknowledge_en, make_acknowledge_zh_tw
#import "pages/outline.typ": make_outline
#import "pages/ref.typ": make_ref
#import "utils/page-numb.typ": begin_of_roman_page_num, begin_of_arabic_page_num

#let setup(
  in_degree: (master: false, doctor: false),
  in_institute: "",
  in_student: (en: "", zh_tw: ""),
  in_advisor: (en: "", zh_tw: ""),
  in_coadvisor: (), // it should be a list with one or many two-key dicts which is (en: "", zh_tw: "")
  in_title: (en: "", zh_tw: ""),
  in_main_lang: (en: false, zh_tw: false),
  in_date: (en: "", zh_tw: ""),
) = {
  // assertions
  assert(
    in_degree.master or in_degree.doctor,
    message: "You should set degree correctly!",
  )
  assert(in_institute != "", message: "You should set institute correctly!")
  assert(
    in_student.en != "" and in_student.zh_tw != "",
    message: "You should set student name correctly!",
  )
  assert(
    in_advisor.en != "" and in_advisor.zh_tw != "",
    message: "You should set advisor name correctly!",
  )
  assert(
    in_title.en != "" and in_title.zh_tw != "",
    message: "You should set title of the thesis/dissertation correctly!",
  )
  assert(
    in_main_lang.en or in_main_lang.zh_tw,
    message: "You should set the main language type correctly!",
  )
  // return functions the author need
  return (
    // NOTE: pages
    make_cover: () => {
      make_cover(
        degree: in_degree,
        institute: in_institute,
        title: in_title,
        student: in_student,
        advisor: in_advisor,
        coadvisor: in_coadvisor,
      )
    },
    make_abstract_en: (keywords: (), doc) => {
      make_abstract_en(keywords: keywords, doc)
    },
    make_abstract_zh_tw: (keywords: (), doc) => {
      make_abstract_zh_tw(keywords: keywords, doc)
    },
    make_acknowledge_en: doc => {
      make_acknowledge_en(doc)
    },
    make_acknowledge_zh_tw: doc => {
      make_acknowledge_zh_tw(doc)
    },
    make_outline: () => {
      make_outline()
    },
    make_ref: ref => {
      make_ref(ref: ref)
    },
    // NOTE: layouts
    whole: doc => {
      whole(main_lang: in_main_lang, doc)
    },
    extended_abstract_en: (summary: [], keywords: (), doc) => {
      extended_abstract_en(
        title_en: in_title.en,
        institute: in_institute,
        student_en: in_student.en,
        advisor_en: in_advisor.en,
        summary: summary,
        keywords: keywords,
        doc,
      )
    },
    mainmatter_or_appendix: (mode: (:), doc) => {
      mainmatter_or_appendix(mode: mode, doc)
    },
    begin_of_roman_page_num: doc => {
      begin_of_roman_page_num(doc)
    },
    begin_of_arabic_page_num: doc => {
      begin_of_arabic_page_num(doc)
    },
  )
}
