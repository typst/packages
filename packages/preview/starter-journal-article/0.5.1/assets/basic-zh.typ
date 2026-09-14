#import "@preview/starter-journal-article:0.5.1": article, author-meta
#import "@preview/kouhu:0.2.0": kouhu
#import "@local/ctyp:0.1.0": ctyp

#let (theme, ..) = ctyp()
#show: theme

#set text(lang: "zh")
#set page(margin: 12pt, width: 6in, height: 5in)

#show: article.with(
  title: "论文标题",
  authors: (
    "作者一": author-meta("UCL", email: "author.one@inst.ac.uk"),
    "作者二": author-meta("TSU")
  ),
  affiliations: (
    "UCL": "作者单位，省市，邮编",
    "TSU": "作者单位，省市，邮编"
  ),
  abstract: [#kouhu(length: 100)。],
  keywords: (kouhu(length: 4),) * 4
)

= 简介

#kouhu(length: 100)。
