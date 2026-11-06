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

#let 字体 = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「宋体（Windows）」、「Songti SC（macOS）」、「思源宋体」
  宋体: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimSun", "Songti SC", "Noto Serif CJK SC"),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「Arial（无衬线英文字体）」、「黑体（Windows）」、「Heiti SC（macOS）」、「思源黑体」
  黑体: ((name: "Arial", covers: "latin-in-cjk"), "SimHei", "Heiti SC", "Source Han Sans SC"),
  // 楷体
  楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "Noto Serif CJK SC"),
  // 仿宋
  仿宋: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong", "Noto Serif CJK SC"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Courier New（Windows 等宽英文字体）」、「Menlo（macOS 等宽英文字体）」、「IBM Plex Mono」
  等宽: ((name: "Courier New", covers: "latin-in-cjk"), (name: "Menlo", covers: "latin-in-cjk"), (name: "IBM Plex Mono", covers: "latin-in-cjk")),
)