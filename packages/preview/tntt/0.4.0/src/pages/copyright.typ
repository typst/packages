#import "../utils/font.typ": use-size

/// Copyright Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool): Whether to use two-sided layout.
/// - fonts (dictionary): The font family to use, should be a dictionary.
/// - title (content): The title of the copyright page.
/// - title-size (length | str): The size of the title font.
/// - body (content): The body content of the copyright page.
/// - grid-columns (array): The widths of the grid columns for signatures.
/// - back (array): The back text for signatures, should be an array of strings.
/// -> content
#let copyright(
  // from entry
  anonymous: false,
  twoside: false,
  fonts: (:),
  // options
  title: [关于论文使用授权的说明],
  title-size: "二号",
  body: [
    本人完全了解清华大学有关保留、使用综合论文训练论文的规定，即：学校有权保留论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。
  ],
  grid-columns: (2.99cm, 3.29cm, 2.96cm, 3.66cm),
  back: ("作者签名： ", "导师签名：", "日　　期： ", "日　　期："),
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  v(42.9pt)

  align(
    center,
    text(
      font: fonts.HeiTi,
      size: use-size(title-size),
      title,
    ),
  )

  v(32.2pt)

  par(leading: 16.4pt, text(size: use-size("四号"), body))

  v(69.3pt)

  align(
    center,
    block(
      width: grid-columns.sum(),
      grid(
        columns: grid-columns,
        column-gutter: (-3pt, -2pt, 2pt),
        row-gutter: 21.2pt,
        align: center,
        ..back.intersperse("")
      ),
    ),
  )
}
