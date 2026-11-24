// frontpages/my-names.typ
// 填入你的論文題目、姓名等資料
// Fill in your thesis title, name, and other information
//
// All bilingual fields use (zh: ..., en: ...) pairs.
// If you have fewer advisors, leave extra entries out of the array.

#let thesis-info = (
  // 論文題目 / Thesis title
  title: (
    zh: "揭開貓的秘密",
    en: "RSC: Revealing the Secret of Cats",
  ),
  // 作者姓名 / Author name
  author: (
    zh: "李貓貓",
    en: "Meow Li",
  ),
  // 學號 / Student ID
  student-id: "Meow12345678",
  // 指導教授 / Advisors (array of bilingual dicts)
  advisors: (
    (zh: "楊龍龍 博士", en: "Dr. Dragon Yang"),
    (zh: "第二位 教授", en: "Dr. Second Advisor"),
  ),
  // 校名 / University name
  university: (
    zh: "國立臺灣科技大學",
    en: "National Taiwan University of Science and Technology",
  ),
  // 系所名 / Department name
  department: (
    zh: "資訊工程系",
    en: "CSIE",
  ),
  // 學位 / Degree
  degree: (
    zh: "碩士",
    en: "Master ",
  ),
  // 口試日期 / Defense date
  date: (
    year: "一一二",
    month: "六",
  ),
  // 畢業級別 (用於書背) / Graduation class (for spine)
  graduation-class: "112",
)
