// factory {{{
#let get-csort-name(i, lang: "zh") = {
  let hi = i / 2
  let s = calc.floor(hi)
  let small = s < hi

  if lang == "zh" {
    let prefix = if small { "小" } else { none }
    let postfix = if small { none } else { "号" }
    if s == 0 {
      return prefix + "初" + postfix
    } else {
      return prefix + numbering("一", s) + postfix
    }
  }
  if lang == "en" {
    let prefix = if small { "s" } else { "S" }
    return prefix + str(s)
  }
}

#let csort-names-zh = range(0, 16).map(get-csort-name)

#let csort-names-en = range(0, 16).map(get-csort-name.with(lang: "en"))

#let csort-sizes = (
  14.82mm,
  12.70mm,
  9.17mm,
  8.47mm,
  7.76mm,
  6.35mm,
  5.64mm,
  5.29mm,
  4.94mm,
  4.23mm,
  3.70mm,
  3.18mm,
  2.56mm,
  2.29mm,
  1.94mm,
  1.76mm,
)
// }}}

/// Chinese sort name-size pairs.
#let csort = csort-names-en.zip(csort-sizes).to-dict()

/// 汉字字号，名称对大小。
#let 字号 = csort-names-zh.zip(csort-sizes).to-dict()

/// Font groups.
#let group = (
  song: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "Source Han Serif SC",
    "Source Han Serif",
    "Noto Serif CJK SC",
    // "SimSun",
    // "Songti SC", // Windows
    // "STSongti", // Darwin
  ),
  hei: (
    (name: "Arial", covers: "latin-in-cjk"),
    "Source Han Sans SC",
    "Source Han Sans",
    "Noto Sans CJK SC",
    // "SimHei",
    // "Heiti SC", // Windows
    // "STHeiti", // Darwin
  ),
  hei-latin-song: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "Source Han Sans SC",
    "Source Han Sans",
    "Noto Sans CJK SC",
    // "SimHei",
    // "Heiti SC", // Windows
    // "STHeiti", // Darwin
  ),
  kai: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "KaiTi",
    "Kaiti SC",
    // "STKaiti",
    // "FZKai-Z03S",
  ),
  fsong: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "FangSong",
    "FangSong SC",
    // "STFangSong",
    // "FZFangSong-Z02S",
  ),
  mono: (
    (name: "Courier New", covers: "latin-in-cjk"),
    (name: "Menlo", covers: "latin-in-cjk"),
    (name: "IBM Plex Mono", covers: "latin-in-cjk"),
    "Source Han Sans HW SC",
    "Source Han Sans HW",
    "Noto Sans Mono CJK SC",
    // "SimHei",
    // "Heiti SC", // Windows
    // "STHeiti", // Darwin
  ),
  song-math: (
    "XITS Math", // Like Times New Roman
    "Cambria Math",
    "Source Han Serif SC",
    "Source Han Serif",
    "Noto Serif CJK SC",
    // "SimSun",
  ),
)

