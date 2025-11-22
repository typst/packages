#import "../utils/font.typ": use-size

/// Declaration Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool): Whether to use two-sided layout.
/// - title (content): The title of the declaration page.
/// - back-vspace (length): The vertical space after the body.
/// - outlined (bool): Whether to outline the page.
/// - body (content): The body content of the declaration page.
/// - back (content): The back text for signatures.
/// -> content
#let declaration(
  // from entry
  anonymous: false,
  twoside: false,
  // options
  title: [声　明],
  back-vspace: 38pt,
  outlined: true,
  body: [
    本人郑重声明：所呈交的综合论文训练论文，是本人在导师指导下，独立进行研究工作所取得的成果。尽我所知，除文中已经注明引用的内容外，本论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
  ],
  back: "签  名：____________  日  期：____________",
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: true, title)

  body

  v(back-vspace)

  text(size: use-size(13pt), align(right, back))
}
