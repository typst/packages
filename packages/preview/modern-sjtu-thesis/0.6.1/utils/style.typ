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

#let preset-ziti = (
  en-serif: ("Times New Roman", "TeX Gyre Termes"),
  en-sans: ("Arial", "TeX Gyre Heros"),
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「TeX Gyre Termes（Web App 有衬线英文字体）」、「宋体（MacOS）」、「宋体（Windows）」、「华文宋体」、「思源宋体」
  songti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    (name: "TeX Gyre Termes", covers: "latin-in-cjk"),
    "Songti SC",
    "SimSun",
    "STSongti",
    "Noto Serif CJK SC",
  ),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「TeX Gyre Termes（Web App 有衬线英文字体）」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」、「思源黑体」
  heiti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    (name: "TeX Gyre Heros", covers: "latin-in-cjk"),
    "Heiti SC",
    "SimHei",
    "STHeiti",
    "Noto Sans CJK SC",
  ),
  // 楷体
  // 这一行分别是「新罗马体（有衬线英文字体）」、「TeX Gyre Termes（Web App 有衬线英文字体）」、「楷体（MacOS）」、「楷体（Windows）」、「华文楷体」、「方正楷体」
  kaiti: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    (name: "TeX Gyre Termes", covers: "latin-in-cjk"),
    "Kaiti SC",
    "KaiTi",
    "STKaiti",
    "KaiTi_GB2312",
  ),
  // 仿宋
  // 这一行分别是「新罗马体（有衬线英文字体）」、「TeX Gyre Termes（Web App 有衬线英文字体）」、「仿宋（MacOS）」、「仿宋（Windows）」、「华文仿宋」、「方正仿宋」
  fangsong: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    (name: "TeX Gyre Termes", covers: "latin-in-cjk"),
    "FangSong SC",
    "FangSong",
    "STFangSong",
    "FangSong_GB2312",
  ),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Menlo(MacOS 等宽英文字体)」、「Consolas(Windows 等宽英文字体)」、「Fira Mono(Web App 等宽英文字体」、「黑体（MacOS）」、「黑体（Windows）」、「华文黑体」、「思源黑体」
  dengkuan: (
    "Menlo",
    "Consolas",
    "Fira Mono",
    (name: "Heiti SC", covers: regex("\p{script=Han}")),
    (name: "SimHei", covers: regex("\p{script=Han}")),
    (name: "STHeiti", covers: regex("\p{script=Han}")),
    (name: "Noto Sans CJK SC", covers: regex("\p{script=Han}")),
  ),
  math: (
    "Cambria Math",
    "New Computer Modern Math",
    "Libertinus Math",
    (name: "Songti SC", covers: regex("\p{script=Han}")),
    (name: "SimSun", covers: regex("\p{script=Han}")),
    (name: "STSongti", covers: regex("\p{script=Han}")),
    (name: "Noto Serif CJK SC", covers: regex("\p{script=Han}")),
  ),
)
