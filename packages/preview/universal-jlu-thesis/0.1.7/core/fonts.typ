// 字体定义 - 基于您系统的实际可用字体
#let fonts = (
  // 英文字体
  main: ("Times New Roman", "Arial", "Calibri"),
  
  // 中文字体 - 使用您系统中确实存在的字体
  cjk: (
    "SimSun",           // 宋体
    "Microsoft YaHei",  // 微软雅黑
    "SimHei",           // 黑体
    "KaiTi",           // 楷体
    "Microsoft YaHei UI",
    "Noto Sans SC",     // 您系统中有的Noto字体
    "Noto Serif SC",
    "Arial Unicode MS", // 作为最后的回退
  ),
  
  // 宋体系列
  song: (
    "SimSun",           // 新宋体
    "NSimSun",          // 新宋体
    "STSong",           // 华文宋体
    "Microsoft YaHei"   // 作为回退
  ),
  
  // 黑体系列  
  hei: (
    "SimHei",           // 黑体
    "STXihei",          // 华文细黑
    "Microsoft YaHei",  // 微软雅黑
    "Microsoft YaHei UI"
  ),
  
  // 楷体系列
  kai: (
    "KaiTi",            // 楷体
    "STKaiti",          // 华文楷体
    "Microsoft YaHei"   // 作为回退
  ),
  
  // 仿宋系列
  fang: (
    "FangSong",         // 仿宋
    "STFangsong",       // 华文仿宋
    "Microsoft YaHei"
  )
)

// 全局字体设置
#let font-setup() = {
  set text(
    font: fonts.main + fonts.cjk,
    size: 12pt,
    lang: "zh",
    region: "cn"
  )
  
  // 1.75倍行距 (对应LaTeX的1.75)
  set par(
    leading: 0.75em,
    justify: true,
    first-line-indent: 2em
  )
}

// 字体快捷函数
#let songti(content) = text(font: fonts.song, content)
#let heiti(content) = text(font: fonts.hei, content)
#let kaiti(content) = text(font: fonts.kai, content)
#let fangsong(content) = text(font: fonts.fang, content)