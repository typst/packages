#import "../utils/font.typ": font-size, use-size

// 字体显示测试页
#let fonts-display(
  // from entry
  twoside: false,
  fonts: (:),
  // options
  size: "小四",
) = {
  let display-font(cjk-name, latin-name) = [
    #line(length: 100%, stroke: .5pt)

    #set text(font: fonts.at(latin-name))

    #cjk-name (#latin-name CJK Regular): 落霞与孤鹜齐飞，秋水共长天一色。

    #cjk-name (#latin-name Latin Regular): The fanfare of birds announces the morning.

    *#cjk-name (#latin-name CJK Bold): 落霞与孤鹜齐飞，秋水共长天一色。*

    *#cjk-name (#latin-name Latin Bold): The fanfare of birds announces the morning.*
  ]

  /// Render the page
  // use the built-in font Libertinus Serif to display the message
  text(font: "Libertinus Serif", orange, style: "italic")[
    Hint: If you cannot render the below text correctly or if there are discrepancies with what's expected, you should pay attention to the error message and read the instructions on font configuration in the README.
  ]

  line(length: 100%)

  set text(size: use-size(size), font: fonts.SongTi)

  [
    *Fonts Display Page | Adjust the font configuration to render correctly in the PDF*

    *字体展示页 | 请调整字体配置至正确在 PDF 中渲染*
  ]

  let font-list = (
    ("宋体", "SongTi"),
    ("黑体", "HeiTi"),
    ("楷体", "KaiTi"),
    ("仿宋", "FangSong"),
    ("等宽", "Mono"),
  )

  for it in font-list { display-font(..it) }

  line(length: 100%)

  [_*Now you can remove the `fonts-display` page from the document.*_]

  // Always break to odd page
  pagebreak(to: "odd")
}
