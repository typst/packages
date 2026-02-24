/*
 * style.typ
 *
 * @project: modern-ecnu-thesis
 * @author: Juntong Chen (dev@jtchen.io)
 * @created: 2025-07-04 15:11:20
 * @modified: 2025-07-04 15:11:32
 *
 * Copyright (c) 2025 Juntong Chen. All rights reserved.
 */
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

// 拼音
#let zihao = (
  chu: 字号.初号,
  xchu: 字号.小初,
  yi: 字号.一号,
  xyi: 字号.小一,
  er: 字号.二号,
  xer: 字号.小二,
  san: 字号.三号,
  xsan: 字号.小三,
  si: 字号.四号,
  zsi: 字号.中四,
  xsi: 字号.小四,
  wu: 字号.五号,
  xwu: 字号.小五,
  liu: 字号.六号,
  xliu: 字号.小六,
  qi: 字号.七号,
  xqi: 字号.小七,
)

#let 字体 = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  宋体: ("Times New Roman", "Songti SC", "STSongti", "Source Han Serif CN", "Source Han Serif", "Noto Serif CJK SC", "SimSun"),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  黑体: ("Helvetica", "Arial", "Heiti SC", "STHeiti", "SimHei", "Source Han Sans SC", "Source Han Sans", "Noto Sans CJK SC"),
  // 楷体
  楷体: ("Times New Roman", "KaiTi", "Kaiti SC", "STKaiti", "FZKai-Z03S", "Noto Serif CJK SC"),
  // 仿宋
  仿宋: ("Times New Roman", "FangSong", "FangSong SC", "STFangSong", "FZFangSong-Z02S", "Noto Serif CJK SC"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  等宽: ("Inconsolata", "Courier New", "Menlo", "IBM Plex Mono", "Source Han Sans HW SC", "Source Han Sans HW", "Noto Sans Mono CJK SC", "SimHei", "Heiti SC", "STHeiti"),
)

#let fonts = (
  song: 字体.宋体,
  hei: 字体.黑体,
  kai: 字体.楷体,
  fang: 字体.仿宋,
  mono: 字体.等宽,
)