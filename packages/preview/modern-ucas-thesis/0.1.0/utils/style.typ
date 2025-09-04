#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 等宽字体 = (
  "Courier New",
  "Menlo",
  "IBM Plex Mono",
  "Source Han Sans HW SC",
  "Source Han Sans HW",
  "Noto Sans Mono CJK SC",
  "SimHei",
  "Heiti SC",
  "STHeiti",
)

#let 字体组 = (
  windows: (
    宋体: ("Times New Roman", "SimSun"),
    黑体: ("Times New Roman", "SimHei"),
    楷体: ("Times New Roman", "KaiTi"),
    仿宋: ("Times New Roman", "FangSong"),
    等宽: 等宽字体,
  ),
  mac: (
    宋体: ("Times New Roman", "Songti SC"),
    黑体: ("Times New Roman", "Heiti SC"),
    楷体: ("Times New Roman", "Kaiti SC"),
    仿宋: ("Times New Roman", "STFangSong"),
    等宽: 等宽字体,
  ),
  fandol: (
    宋体: ("Times New Roman", "FandolSong"),
    黑体: ("Times New Roman", "FandolHei"),
    楷体: ("Times New Roman", "FandolKai"),
    仿宋: ("Times New Roman", "FandolFang R"),
    等宽: 等宽字体,
  ),
  adobe: (
    宋体: ("Times New Roman", "Adobe Song Std"),
    黑体: ("Times New Roman", "Adobe Heiti Std"),
    楷体: ("Times New Roman", "Adobe Kaiti Std"),
    仿宋: ("Times New Roman", "Adobe Fangsong Std"),
    等宽: 等宽字体,
  ),
)

#let get-fonts(fontset) = {
  if fontset == "windows" {
    字体组.windows
  } else if fontset == "mac" {
    字体组.mac
  } else if fontset == "adobe" {
    字体组.adobe
  } else {
    字体组.fandol
  }
}
