#import "../styles/fonts.typ": fonts, fontsize
#import "@preview/cuti:0.3.0": show-cn-fakebold, fakebold

#let abstract-page(
  body: text,
  keywords: (),
  body-en: "",
  keywords-en: (),
) = {
  set page(header: none)

  set text(font: fonts.宋体)
  {
    set par(first-line-indent: 2em, justify: true)
    // 中文摘要标题
    {
      set par(spacing: 1em)
      set text(font: fonts.黑体, size: fontsize.小二)
      v(15pt)
      align(center)[#fakebold()[摘#h(2em)要]]
    }
    // 中文摘要正文
    {
      set par(spacing: 0.65em, leading: .65em)
      set text(font: fonts.宋体, size: fontsize.小四)
      body
    }
    // 中文关键字
    {
      set par(first-line-indent: 0em)
      v(1em)
      [#fakebold()[关键词]：#(("",)+ keywords.intersperse("；")).sum()]
      pagebreak(weak: true)
    }
  }
  // 英文摘要
  {
    set par(first-line-indent: 2em, justify: true)
    // 英文摘要标题
    {
      set par(spacing: 1em)
      v(15pt)
      align(center)[#text(size: fontsize.小二, font: "Times New Roman", weight: "bold")[ABSTRACT]]
    }
    // 英文摘要正文
    {
      set par(spacing: 0.65em, leading: 1em)
      set text(font: fonts.宋体, size: fontsize.小四)
      body-en
    }
    // 英文关键字
    {
      set par(first-line-indent: 0em)
      [*Key Words*: #(("",)+ keywords-en.intersperse("; ")).sum()]
      pagebreak(weak: true)
    }
  }
}
