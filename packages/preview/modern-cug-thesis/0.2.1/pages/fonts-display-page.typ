#import "../utils/style.typ": 字号, 字体, show-cn-fakebold
#import "../utils/hline.typ": hline

// 字体显示测试页
#let fonts-display-page(
  twoside: false,
  fonts: (:),
  size: 字号.小四,
  lang: "zh",
) = {
  // 1. 默认参数
  show: show-cn-fakebold
  fonts = 字体 + fonts

  // 2. 辅助函数
  let display-font(cjk-name, latin-name) = [
    #set text(font: fonts.at(cjk-name))

    #cjk-name (#latin-name CJK Regular): 落霞与孤鹜齐飞，秋水共长天一色。

    #cjk-name (#latin-name Latin Regular): The fanfare of birds announces the morning.

    *#cjk-name (#latin-name CJK Bold): 落霞与孤鹜齐飞，秋水共长天一色。*

    *#cjk-name (#latin-name Latin Bold): The fanfare of birds announces the morning.*
  ]

  // 3. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })
  set text(size: size, lang: lang)

  [
    *Fonts Display Page:*

    #hline()

    #display-font("宋体", "SongTi")

    #hline()

    #display-font("黑体", "HeiTi")

    #hline()

    #display-font("楷体", "KaiTi")

    #hline()

    #display-font("仿宋", "FangSong")

    #hline()

    #display-font("等宽", "Mono")
  ]
  pagebreak()
}

#show: fonts-display-page()