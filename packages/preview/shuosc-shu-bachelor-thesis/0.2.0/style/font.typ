#let zihao = (
  chuhao: 42pt,
  xiaochu: 36pt,
  yihao: 26pt,
  xiaoyi: 24pt,
  erhao: 22pt,
  xiaoer: 18pt,
  sanhao: 16pt,
  xiaosan: 15pt,
  sihao: 14pt,
  zhongsi: 13pt,
  xiaosi: 12pt,
  wuhao: 10.5pt,
  xiaowu: 9pt,
  liuhao: 7.5pt,
  xiaoliu: 6.5pt,
  qihao: 5.5pt,
  xiaoqi: 5pt,
)

#let ziti = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「宋体（Windows）」、「宋体（MacOS）」、「华文宋体」
  songti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "SimSun",
    "Songti SC",
    "STSongti",
  ),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「黑体（Windows）」、「黑体（MacOS）」、「华文黑体」
  heiti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "SimHei",
    "Heiti SC",
    "STHeiti",
  ),
  // 楷体
  // 这一行分别是「新罗马体（有衬线英文字体）」、「锴体（Windows）」、「楷体（MacOS）」、「华文黑体」、「方正楷体」
  kaiti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "KaiTi",
    "Kaiti SC",
    "STKaiti",
    "KaiTi_GB2312",
  ),
  // 仿宋
  // 这一行分别是「新罗马体（有衬线英文字体）」、「方正仿宋」、「仿宋（Windows）」、「仿宋（MacOS）」、「华文仿宋」
  fangsong: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "FangSong_GB2312",
    "FangSong",
    "FangSong SC",
    "STFangSong",
  ),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Menlo(MacOS 等宽英文字体)」、「Courier New(等宽英文字体)」、「黑体（Windows）」、「黑体（MacOS）」、「华文黑体」
  dengkuan: ("Menlo", "Courier New", "SimHei", "Heiti SC", "STHeiti"),
)
