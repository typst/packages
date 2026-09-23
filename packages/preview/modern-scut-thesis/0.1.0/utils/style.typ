// SCUT 学位论文字体与字号配置

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

// SCUT 规范：全文拉丁字符均使用 Times New Roman
#let 拉丁字体 = (name: "Times New Roman", covers: "latin-in-cjk")

#let 字体 = (
  宋体: (拉丁字体, "SimSun"),
  黑体: (拉丁字体, "SimHei"),
  楷体: (拉丁字体, "KaiTi"),
  仿宋: (拉丁字体, "FangSong"),
  等宽: ((name: "Courier New", covers: "latin-in-cjk"), "SimSun"),
)

// ===== 正文共享样式 =====
#let 正文字体 = 字体.宋体
#let 正文字号 = 字号.小四
#let 正文行距 = 1.4em
#let 正文段间距 = 正文行距
#let 正文缩进 = 2em
#let 首行缩进 = (amount: 正文缩进, all: true)

// ===== 辅助样式：页眉 / 页脚 / 脚注 / 图表标题 =====
#let 辅助字体 = 字体.宋体
#let 辅助字号 = 字号.五号

// ===== 标题样式 =====
#let 章标题字体 = 字体.黑体
#let 章标题字号 = 字号.小二
#let 节一级标题字号 = 字号.小三
#let 节二级标题字号 = 字号.四号
#let 节三级标题字号 = 字号.小四
#let 节标题字体 = 字体.黑体
