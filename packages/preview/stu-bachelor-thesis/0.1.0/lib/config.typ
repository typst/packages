#import "algo.typ": algo, code, comment, d, i

//定义字体对应字号
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

//定义字体对应名称,这里先尝试用 Times New Roman 渲染拉丁字符，其余字符自动回退到中文定义的字体
#let 字体 = (
  宋体: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimSun"), //表示先用 Times New Roman 渲染拉丁字符，再用 SimSun 渲染中文字符
  黑体: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimHei"),
  楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi"),
  // // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // // 这一行分别是「Courier New（Windows 等宽英文字体）」、「思源等宽黑体（简体）」、「思源等宽黑体」、「黑体（Windows）」、「黑体（MacOS）」
  // 等宽: ((name: "Courier New", covers: "latin-in-cjk"), (name: "Menlo", covers: "latin-in-cjk"), (name: "IBM Plex Mono", covers: "latin-in-cjk"), "Source Han Sans HW SC", "Source Han Sans HW", "Noto Sans Mono CJK SC", "SimHei", "Heiti SC", "STHeiti"),
)
