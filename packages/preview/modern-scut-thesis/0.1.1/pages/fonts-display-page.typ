// SCUT 字体显示测试页
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字号, 字体
#import "../utils/hline.typ": hline

#let fonts-display-page(
  open-right: false,
  fonts: (:),
  size: 字号.小四,
  lang: "zh",
) = {
  fonts = 字体 + fonts

  let display-font(cjk-name, latin-name) = [
    #set text(font: fonts.at(cjk-name))

    #cjk-name (#latin-name CJK Regular): 落霞与孤鹜齐飞，秋水共长天一色。

    #cjk-name (#latin-name Latin Regular): The fanfare of birds announces the morning.
    
    *#cjk-name (#latin-name CJK Bold): 落霞与孤鹜齐飞，秋水共长天一色。*

    *#cjk-name (#latin-name Latin Bold): The fanfare of birds announces the morning.*
  ]

  section-break(open-right: open-right)
  set text(size: size, lang: lang)

  [
    *SCUT 字体显示测试页：*

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
}
