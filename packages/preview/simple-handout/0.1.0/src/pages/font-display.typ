#import "../utils/font.typ": use-size

#let font-display(
  // from entry
  twoside: false,
  font: (:),
  // options
  size: "小四",
  cjk-text: "落霞与孤鹜齐飞，秋水共长天一色。",
  latin-text: "The fanfare of birds announces the morning.",
) = {
  let display-font(cjk-name, latin-name) = [
    #line(length: 100%, stroke: .5pt)

    #set text(font: font.at(latin-name))

    #cjk-name (#latin-name CJK Regular)：#cjk-text

    #cjk-name (#latin-name Latin Regular): #latin-text

    *#cjk-name (#latin-name CJK Bold)：#cjk-text*

    *#cjk-name (#latin-name Latin Bold): #latin-text*
  ]

  /// Render the page
  set page(margin: (y: 2.5cm))

  // use the built-in font Libertinus Serif to display the message
  text(font: "Libertinus Serif", orange, style: "italic")[
    Hint: If you cannot render the below text correctly or if there are discrepancies with what's expected, you should pay attention to the error message and read the instructions on font configuration in the README.
  ]

  line(length: 100%)

  set text(size: use-size(size), font: font.SongTi)

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
