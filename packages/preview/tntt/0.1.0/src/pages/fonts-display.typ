#import "../font.typ": font-size, font-family

#import "../imports.typ": show-cn-fakebold

// 字体显示测试页
#let fonts-display(
  twoside: false,
  fonts: (:),
  size: font-size.小四,
  lang: "zh",
) = {
  // 1. 默认参数
  fonts = font-family + fonts

  // 2. 辅助函数
  let display-font(cjk-name, latin-name) = [
    #set text(font: fonts.at(latin-name))

    #cjk-name (#latin-name CJK Regular): 落霞与孤鹜齐飞，秋水共长天一色。

    #cjk-name (#latin-name Latin Regular): The fanfare of birds announces the morning.

    *#cjk-name (#latin-name CJK Bold): 落霞与孤鹜齐飞，秋水共长天一色。*

    *#cjk-name (#latin-name Latin Bold): The fanfare of birds announces the morning.*
  ]

  // 3. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })
  show: show-cn-fakebold
  set text(size: size, lang: lang, font: fonts.SongTi)

  [
    *Fonts Display Page | Adjust the font configuration to render correctly in the PDF*

    *字体展示页 | 请调整字体配置至正确在 PDF 中渲染*
  ]

  line(length: 100%)

  display-font("宋体", "SongTi")

  line(length: 100%)

  display-font("黑体", "HeiTi")

  line(length: 100%)

  display-font("楷体", "KaiTi")

  line(length: 100%)

  display-font("仿宋", "FangSong")

  line(length: 100%)

  display-font("等宽", "Mono")
}
