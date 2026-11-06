#let font-size = (
  "0": 42pt, // 初号
  "-0": 36pt, // 小初
  "1": 26pt, // 一号
  "-1": 24pt, // 小一
  "2": 22pt, // 二号
  "-2": 18pt, // 小二
  "3": 16pt, // 三号
  "-3": 15pt, // 小三
  "4": 14pt, // 四号
  "-4": 12pt, // 小四
  "5": 10.5pt, // 五号
  "-5": 9pt, // 小五
  "6": 7.5pt, // 六号
  "-6": 6.5pt, // 小六
  "7": 5.5pt, // 七号
  "-7": 5pt, // 小七
)

#let times-new-roman = "Times New Roman"
#let normal-font = "TeX Gyre Termes"
#let math-font = "TeX Gyre Termes Math"
#let mono-font = "Fira Code"

#let font-family = (
  fangsong: (normal-font, "FZFangSong-Z02"),
  song: (normal-font, "FZShuSong-Z01"),
  hei: (normal-font, "FZHei-B01"),
  kai: (normal-font, "FZKai-Z03"),
  xiaobiaosong: (normal-font, "FZXiaoBiaoSong-B05"),
  xihei: (normal-font, "FZXiHeiI-Z08"),
  code: (mono-font, "FZFangSong-Z02"),
  math: (math-font, "FZKai-Z03"),
)

#let ii = math.class("normal", $mono(i)$)
#let jj = math.class("normal", $mono(j)$)
#let ee = math.class("normal", $mono(e)$)

#let songti = font-family.song
#let heiti = font-family.hei
#let fangsong = font-family.fangsong
#let kaiti = font-family.kai
#let xiaobiaosong = font-family.xiaobiaosong
#let xihei = font-family.xihei

#let LaTeX = {
  [L];box(move(dx: -4.2pt, dy: -1.2pt, box(scale(65%)[A])));box(move(dx: -5.7pt, dy: 0pt, [T]));box(move(dx: -7.0pt, dy: 2.7pt, box(scale(100%)[E])));box(move(dx: -8.0pt, dy: 0pt, [X]));h(-8.0pt)
}

#let TeX = {
  [T];box(move(dx: -1.3pt, dy: 2.7pt, box(scale(100%)[E])));box(move(dx: -2.3pt, dy: 0pt, [X]));h(-2.3pt)
}

#set pagebreak(weak: true)
