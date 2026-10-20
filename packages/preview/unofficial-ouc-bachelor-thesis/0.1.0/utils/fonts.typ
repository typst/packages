#let fonts = (
  // 宋体
  宋体: "SimSun",
  // 黑体
  黑体: "SimHei",
  // 楷体
  楷体: "KaiTi",
  // 仿宋
  仿宋: "FangSong",
  // 纯西文字体
  西文: "Times New Roman",
  // 纯数学字体
  数学: "New Computer Modern Math",
  // 等宽字体
  等宽: ("Consolas", "Courier New", "Liberation Mono", "Noto Sans Mono CJK SC", "Noto Sans Mono", "SimSun"),
)

#let setup-fonts(fonts) = (
  宋体: ((name: fonts.西文, covers: "latin-in-cjk"), fonts.宋体),
  黑体: ((name: fonts.西文, covers: "latin-in-cjk"), fonts.黑体),
  楷体: ((name: fonts.西文, covers: "latin-in-cjk"), fonts.楷体),
  仿宋: ((name: fonts.西文, covers: "latin-in-cjk"), fonts.仿宋),
  西文: fonts.西文,
  数学: (fonts.数学, fonts.西文, fonts.宋体),
  等宽: fonts.等宽,
)
