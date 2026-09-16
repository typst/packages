// Font size table — matching LaTeX Chinese font size system
#let font-size = (
  "0": 42pt,
  "-0": 36pt,
  "1": 26pt,
  "-1": 24pt,
  "2": 22pt,
  "-2": 18pt,
  "3": 16pt,
  "-3": 15pt,
  "4": 14pt,
  "-4": 12pt,
  "5": 10.5pt,
  "-5": 9pt,
  "6": 7.5pt,
  "-6": 6.5pt,
  "7": 5.5pt,
  "-7": 5pt,
)

// Named font size constants — matching LaTeX template's \tjfont* macros.
#let TJFONT_COVER         = font-size.at("-0")  // 封面大标题：小初号 36pt
#let TJFONT_TITLE         = font-size.at("-2")  // 课题名称：小二号 18pt
#let TJFONT_CHAPTER       = font-size.at("-3")  // 章标题：小三号 15pt
#let TJFONT_HEADING       = font-size.at("4")   // 摘要/目录/参考/谢辞标题：四号 14pt
#let TJFONT_INFO          = font-size.at("3")   // 信息说明页标题：三号 16pt
#let TJFONT_BODY          = font-size.at("-4")  // 正文：小四号 12pt
#let TJFONT_CAPTION       = font-size.at("5")   // 表题/图题：五号 10.5pt
#let TJFONT_TABLE         = font-size.at("-5")  // 表内文字：小五号 9pt
#let TJFONT_COVER_FIELD   = font-size.at("-2")  // 封面表格字段：小二号 18pt
#let TJFONT_ABSTRACT      = font-size.at("-2")  // 摘要标题：小二号 18pt
#let TJFONT_ABSTRACT_SUB  = font-size.at("3")   // 摘要副标题：三号 16pt

// Font presets — exactly matching LaTeX template's fontset options.
// All presets use TeX Gyre Termes as Latin cover (free, open-source TNR clone).
// Each defines the core four CJK families: song, hei, kai, fang.
// TGT is available via: Typst Web App (built-in), TeX Live, apt install fonts-texgyre.

#let font-presets = (
  fandol: (
    song: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FandolSong"),
    hei:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FandolHei"),
    kai:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FandolKai"),
    fang: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FandolFang"),
  ),
  windows: (
    song: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "SimSun"),
    hei:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "SimHei"),
    kai:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "KaiTi"),
    fang: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FangSong"),
  ),
  mac: (
    song: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Songti SC"),
    hei:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Heiti SC"),
    kai:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "Kaiti SC"),
    fang: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "STFangsong"),
  ),
  adobe: (
    song: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "AdobeSongStd-Light"),
    hei:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "AdobeHeitiStd-Regular"),
    kai:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "AdobeKaitiStd-Regular"),
    fang: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "AdobeFangsongStd-Regular"),
  ),
  founder: (
    song: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FZShuSong-Z01"),
    hei:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FZHei-B01"),
    kai:  ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FZKai-Z03"),
    fang: ((name: "TeX Gyre Termes", covers: "latin-in-cjk"), "FZFangSong-Z02"),
  ),
)

// Default font-family — overridden by thesis() based on fontset
#let font-family = (
  song: font-presets.fandol.song,
  hei: font-presets.fandol.hei,
  kai: font-presets.fandol.kai,
  fangsong: font-presets.fandol.fang,
  xiaobiaosong: font-presets.fandol.song,
  xihei: font-presets.fandol.hei,
  code: ("DejaVu Sans Mono", "Fira Code"),
  math: ("New Computer Modern Math",),
)

#let songti = font-family.song
#let heiti = font-family.hei
#let fangsong = font-family.fangsong
#let kaiti = font-family.kai
#let xiaobiaosong = font-family.xiaobiaosong
#let xihei = font-family.xihei

// Math symbols
#let ii = math.class("normal", $mono(i)$)
#let jj = math.class("normal", $mono(j)$)
#let ee = math.class("normal", $mono(e)$)

#let LaTeX = {
  [L];box(move(dx: -4.2pt, dy: -1.2pt, box(scale(65%)[A])));box(move(dx: -5.7pt, dy: 0pt, [T]));box(move(dx: -7.0pt, dy: 2.7pt, box(scale(100%)[E])));box(move(dx: -8.0pt, dy: 0pt, [X]));h(-8.0pt)
}

#let TeX = {
  [T];box(move(dx: -1.3pt, dy: 2.7pt, box(scale(100%)[E])));box(move(dx: -2.3pt, dy: 0pt, [X]));h(-2.3pt)
}
