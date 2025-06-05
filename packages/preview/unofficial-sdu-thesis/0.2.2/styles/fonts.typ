#let fontsize = (
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

#let fonts = (
  // 方正大黑简体，用于标题(无力吐槽。)
  方正大黑简体: "FZDaHei-B02",
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「宋体（MacOS）」、「宋体（Windows）」、「华文宋体」
  // 宋体: ("Times New Roman", "Songti SC", "SimSun", "STSongti"),
  宋体: ("Times New Roman", "SimSun", "STSong", "SongTi SC"),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」
  黑体: ("Times New Roman", "SimHei", "Heiti SC", "STHeiti"),
  // 楷体
  // 这一行分别是「新罗马体（有衬线英文字体）」、「楷体（MacOS）」、「锴体（Windows）」、「华文黑体」、「方正楷体」
  楷体: ("Times New Roman", "KaiTi_GB2312", "Kaiti SC", "KaiTi", "STKaiti"),
  // 仿宋
  // 这一行分别是「新罗马体（有衬线英文字体）」、「方正仿宋」、「仿宋（MacOS）」、「仿宋（Windows）」、「华文仿宋」
  仿宋: ("Times New Roman", "FangSong_GB2312", "FangSong SC", "FangSong", "STFangSong"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Menlo(MacOS 等宽英文字体)」、「Courier New(等宽英文字体)」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」
  等宽: ("Menlo", "Courier New", "Heiti SC", "SimHei", "STHeiti"),
)
