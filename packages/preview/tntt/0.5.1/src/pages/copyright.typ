/// Copyright Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - degree (str): The degree.
/// - title (content): The title of the copyright page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - body (content): The body content of the copyright page.
/// - back (content): The back content of the copyright page.
/// -> content
#let copyright(
  // from entry
  anonymous: false,
  twoside: false,
  degree: "bachelor",
  // options
  title: [],
  outlined: false,
  bookmarked: false,
  body: [],
  back: [],
) = {
  if anonymous { return }

  import "../utils/font.typ": use-size
  import "../utils/util.typ": is-not-empty, twoside-pagebreak

  title = if is-not-empty(title) { title } else {
    if degree == "bachelor" [关于论文使用授权的说明] else [关于学位论文使用授权的说明]
  }

  let preset-body = (
    bachelor: [
      本人完全了解清华大学有关保留、使用综合论文训练论文的规定，即：学校有权保留论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。
    ],
    master: [
      本人完全了解清华大学有关保留、使用学位论文的规定，即：

      清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）按照上级教育主管部门督导、抽查等要求，报送相应的学位论文。

      本人保证遵守上述规定。
    ],
    doctor: [
      本人完全了解清华大学有关保留、使用学位论文的规定，即：

      清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）根据《中华人民共和国学位法》及上级教育主管部门具体要求，向国家图书馆报送相应的学位论文。

      本人保证遵守上述规定。
    ],
    postdoc: [TODO],
  )

  let back-items = ("作者签名： ", "导师签名： ", "日　　期： ", "日　　期： ")

  let preset-back = (
    bachelor: {
      v(5.4em)
      align(center, grid(
        rows: 1.03cm, columns: (2.99cm, 3.29cm, 2.96cm, 3.66cm),
        ..back-items.intersperse("")
      ))
    },
    graduate: {
      v(2.7em)
      align(right, grid(
        rows: 1.04cm, columns: (2.54cm, 4.55cm, 2.43cm, 4.00cm), align: left,
        ..back-items.map(it => (it, "_" * 13)).flatten()
      ))
    },
  )

  /// Render the page
  twoside-pagebreak(twoside)

  set page(header: none)
  v(3.6em)
  show heading.where(level: 1): it => align(center, block(text(size: use-size("二号"), it.body)))
  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)
  v(3.7em)
  set par(leading: 1.17em, spacing: 1.17em)
  text(size: use-size("四号"), preset-body.at(degree, default: body))

  if is-not-empty(back) { back } else {
    if degree == "bachelor" { preset-back.bachelor } else { preset-back.graduate }
  }
}
