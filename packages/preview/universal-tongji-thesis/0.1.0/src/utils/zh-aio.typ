#import "@preview/zh-kit:0.1.0":*
#import "@preview/zh-format:0.1.0":*
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.2": zh, zihao
#import "@preview/a2c-nums:0.0.1":int-to-cn-simple-num
// #let 字体 = (
//   // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
//   宋体: (
//     "Times New Roman",
//     "SimSun",
//     // "Songti SC",
//     // "STSongti",
//     // "Source Han Serif CN",
//     // "Source Han Serif",
//     // "Noto Serif CJK SC",
//   ),
//   // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
//   黑体: (
//     "SimHei",
//     "SimSun",
//     // "Times New Roman",
//     // "Helvetica",
//     // "Arial",
//     // "Heiti SC",
//     // "STHeiti",
//     // "Source Han Sans SC",
//     // "Source Han Sans",
//     // "Noto Sans CJK SC",
//   ),
//   // 楷体
//   楷体: (
//     "KaiTi",
//     //  "Times New Roman",
//     //  "Kaiti SC", "STKaiti", "FZKai-Z03S", "Noto Serif CJK SC"
//   ),
//   // 仿宋
//   仿宋: ("FangSong", "Times New Roman", "FangSong SC", "STFangSong", "FZFangSong-Z02S", "Noto Serif CJK SC"),
//   // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
//   等宽: (
//     "Inconsolata",
//     "Courier New",
//     "Menlo",
//     "IBM Plex Mono",
//     "Source Han Sans HW SC",
//     "Source Han Sans HW",
//     "Noto Sans Mono CJK SC",
//     "SimHei",
//     "Heiti SC",
//     "STHeiti",
//   ),
//   隶书: ("LiSu", "FangSong"),
// )

// #let fonts = (
//   song: 字体.宋体,
//   hei: 字体.黑体,
//   kai: 字体.楷体,
//   fang: 字体.仿宋,
//   mono: 字体.等宽,
//   lisu: 字体.隶书,
//   tnrfs: ("Times New Roman", "FangSong"),
//   tnrs: ("Times New Roman", "SimSun"),
//   tnr: ("Times New Roman"),
//   arial: ("Arial"),
// )
// #let fts = fonts

#let default-line-width = 15.6pt
#let two-line-width = default-line-width * 2
#let hangjv()= context {
  let a = text.size
  // text.size * 1.36
}
#let ld(line-number: 1.0)= context{
  text.size * 1.36 * line-number
}
#let vld(line-number)= context{
  v(text.size * 1.36 * line-number)
}
#let hld(line-number)= context{
  h(text.size * 1.36 * line-number)
}
#let vlds()= context{
  v((text.size * .36) / 2)
}
#let vld5(line-number)= {
  v(15.6pt * 1.36 * line-number)
}
#let vld5s()= context{
  v((15.6pt * .36) / 2)
}
#let hfl() = {
  default-line-width / 2
}
#let vhfl() = {
  v(default-line-width / 2)
}
#let vh1l() = {
  v(6pt)
}
#let vl() = context{
  let text-size = text.size
  let line-width = text-size
  if line-width > default-line-width {
    line-width = default-line-width * 2
  }
  if line-width > two-line-width {
    line-width = default-line-width * 3
  }
  v((line-width - text-size) / 2)
}

#let v3l() = context{
  let line-width = default-line-width * 3
  v((line-width - text.size) / 2)
}

#let v2l() = context{
  let line-width = default-line-width * 3
  v((line-width - text.size) / 2)
}
