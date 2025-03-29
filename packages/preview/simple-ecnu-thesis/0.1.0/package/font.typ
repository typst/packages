// --------------------- 字号 ---------------------
#let 初号 = 42pt
#let 小初 = 36pt
#let 一号 = 26pt
#let 小一 = 24pt
#let 二号 = 22pt
#let 小二 = 18pt
#let 三号 = 16pt
#let 小三 = 15pt
#let 四号 = 14pt
#let 中四 = 13pt
#let 小四 = 12pt
#let 五号 = 10.5pt
#let 小五 = 9pt
#let 六号 = 7.5pt
#let 小六 = 6.5pt
#let 七号 = 5.5pt
#let 小七 = 5pt

// --------------------- 具体的字体 ---------------------
// 英文字体
#let Times-New-Roman = "Times New Roman"
// 宋体
#let 方正宋体 = "FZShuSong-Z01S"
#let 华文宋体 = "STSong"
#let 华文宋体-2 = "Songti SC" // Mac 上的华文宋体
#let 中易宋体 = "SimSun" // Windows 上的宋体
// 仿宋
#let 方正仿宋 = "FZFangSong-Z02S"
#let 华文仿宋 = "STFangSong"
#let 华文仿宋-2 = "FangSong SC"
#let 仿宋 = "FangSong"
#let 仿宋-2 = "FangSong_GB2312"
// 中宋
#let 华文中宋 = "STZhongsong"
// 黑体
#let 方正黑体 = "FZHei-B01S"
#let 华文黑体 = "STHeiti"
#let 华文黑体-2 = "Heiti SC"
#let 中易黑体 = "SimHei"
#let 微软雅黑 = "Microsoft YaHei"
#let 阿里巴巴普惠体 = "Alibaba PuHuiTi 2.0"
// 楷体
#let 方正楷体 = "FZKai-Z03S"
#let 华文楷体 = "STKaiti"
#let 华文楷体-2 = "Kaiti SC"
#let 中易楷体 = "SimKai"
#let 楷体 = "Kaiti"
#let 楷体-2 = "Kaiti_GB2312"
// 等宽
#let JetBrains-Mono = "JetBrains Mono"
#let JetBrains-Mono-NL = "JetBrains Mono NL"
#let Consolas = "Consolas"
#let Inconsolata = "Inconsolata"
#let Courier-New = "Courier New"

// ---------------------- Fallback 字体 ------------------------
// 从左到右依次查找，直到找不到
#let 宋体 = (Times-New-Roman, 方正宋体, 华文宋体, 华文宋体-2, 中易宋体)
#let 仿宋 = (Times-New-Roman, 方正仿宋, 华文仿宋, 华文仿宋-2, 仿宋, 仿宋-2)
#let 中宋 = (Times-New-Roman, 华文中宋, 中易宋体)
#let 黑体 = (Times-New-Roman, 方正黑体, 华文黑体, 华文黑体-2, 中易黑体)
#let 楷体 = (Times-New-Roman, 方正楷体, 华文楷体, 华文楷体-2, 楷体, 楷体-2)
#let 封面字体 = (Times-New-Roman, 华文宋体-2, 方正宋体, 中易宋体)
#let 等宽 = (
  JetBrains-Mono,
  JetBrains-Mono-NL,
  Consolas,
  Inconsolata,
  Courier-New,
  阿里巴巴普惠体,
  微软雅黑,
  方正黑体,
  华文黑体-2,
)
