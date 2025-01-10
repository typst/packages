#import "layouts/whole.typ": whole
#import "layouts/mainmatter-or-appendix.typ": mainmatter-or-appendix
#import "layouts/extended-abstract-en.typ": extended-abstract-en
#import "pages/cover.typ": *
// #import "pages/approved-by.typ": *
#import "pages/abstract.typ": *
#import "pages/acknowledge.typ": make-acknowledge-en, make-acknowledge-zh-tw
#import "pages/outline.typ": make-outline
#import "pages/ref.typ": make-ref
#import "utils/page-numb.typ": begin-of-roman-page-num, begin-of-arabic-page-num

#let setup(
  in-degree: (master: false, doctor: false),
  in-institute: "",
  in-student: (en: "", zh-tw: ""),
  in-advisor: (en: "", zh-tw: ""),
  in-coadvisor: (), // it should be a list with one or many two-key dicts which is (en: "", zh-tw: "")
  in-title: (en: "", zh-tw: ""),
  in-main-lang: (en: false, zh-tw: false),
  in-date: (en: "", zh-tw: ""),
) = {
  // assertions
  assert(
    in-degree.master or in-degree.doctor,
    message: "You should set degree correctly!",
  )
  assert(in-institute != "", message: "You should set institute correctly!")
  assert(
    in-student.en != "" and in-student.zh-tw != "",
    message: "You should set student name correctly!",
  )
  assert(
    in-advisor.en != "" and in-advisor.zh-tw != "",
    message: "You should set advisor name correctly!",
  )
  assert(
    in-title.en != "" and in-title.zh-tw != "",
    message: "You should set title of the thesis/dissertation correctly!",
  )
  assert(
    in-main-lang.en or in-main-lang.zh-tw,
    message: "You should set the main language type correctly!",
  )
  // return functions the author need
  return (
    // NOTE: pages
    make-cover: () => {
      make-cover(
        degree: in-degree,
        institute: in-institute,
        title: in-title,
        student: in-student,
        advisor: in-advisor,
        coadvisor: in-coadvisor,
      )
    },
    make-abstract-en: (keywords: (), doc) => {
      make-abstract-en(keywords: keywords, doc)
    },
    make-abstract-zh-tw: (keywords: (), doc) => {
      make-abstract-zh-tw(keywords: keywords, doc)
    },
    make-acknowledge-en: doc => {
      make-acknowledge-en(doc)
    },
    make-acknowledge-zh-tw: doc => {
      make-acknowledge-zh-tw(doc)
    },
    make-outline: () => {
      make-outline()
    },
    make-ref: ref => {
      make-ref(ref: ref)
    },
    // NOTE: layouts
    whole: doc => {
      whole(main-lang: in-main-lang, doc)
    },
    extended-abstract-en: (summary: [], keywords: (), doc) => {
      extended-abstract-en(
        title-en: in-title.en,
        institute: in-institute,
        student-en: in-student.en,
        advisor-en: in-advisor.en,
        summary: summary,
        keywords: keywords,
        doc,
      )
    },
    mainmatter-or-appendix: (mode: (:), doc) => {
      mainmatter-or-appendix(mode: mode, doc)
    },
    begin-of-roman-page-num: doc => {
      begin-of-roman-page-num(doc)
    },
    begin-of-arabic-page-num: doc => {
      begin-of-arabic-page-num(doc)
    },
  )
}
