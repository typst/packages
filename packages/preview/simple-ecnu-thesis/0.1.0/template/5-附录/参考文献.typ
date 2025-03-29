#import "mod.typ": *
#show: style
/*
style: 可填入的值
"gb-7714-2005-numeric"
"gb-7714-2015-author-date"
"gb-7714-2015-note"
"gb-7714-2015-numeric"
*/
// 正常用这个就行，但是英文文献会出现等
// #bibliography(
//   ("ref1.bib", "ref2.bib"),
//   full: false,
//   style: "gb-7714-2015-numeric",
// )
#bilingual-bibliography(bibliography: bibliography.with(
  full: false,
  style: "gb-7714-2015-numeric",
  ("../参考文献/文献-1.bib", "../参考文献/文献-2.bib")))

