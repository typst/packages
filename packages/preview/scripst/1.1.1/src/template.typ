#import "configs.typ": *
#import "styling.typ": *
#import "components.typ": *

#let mkarticle(title, info, author, time, abstract, keywords, contents, content-depth, lang, body) = {
  show: stynumbering.with(numbering: "1")
  if title != none and title != "" { (article.mktitle)(title) }
  if info != none and info != "" { (article.mkinfo)(info) }
  if author != none and author != () { (article.mkauthor)(author) }
  if time != none and time != "" { (article.mktime)(time) }
  if abstract != none and abstract != "" { (article.mkabstract)(abstract, keywords, lang: lang) }
  if contents != false { (article.mkcontent)(content-depth) }
  body
}

#let mkbook(title, info, author, time, abstract, keywords, preface, contents, content-depth, lang, body) = {
  if title != none and title != "" { (book.mktitle)(title) }
  if info != none and info != "" { (book.mkinfo)(info) }
  if author != none and author != () { (book.mkauthor)(author) }
  if time != none and time != "" { (book.mktime)(time) }
  pagebreak()
  if abstract != none and abstract != "" {
    newpara()
    (book.mkabstract)(abstract, keywords, lang: lang)
    pagebreak()
  }
  show: stynumbering.with(numbering: "a")
  counter(page).update(1)
  if preface != none and preface != "" {
    newpara()
    (book.mkpreface)(preface)
    pagebreak()
  }
  show: stynumbering.with(numbering: "I")
  counter(page).update(1)
  if contents != false {
    newpara()
    (book.mkcontent)(content-depth)
    pagebreak()
  }
  show: stynumbering.with(numbering: "1")
  counter(page).update(1)
  newpara()
  body
}

#let mkreport(title, info, author, time, abstract, keywords, preface, contents, content-depth, lang, body) = {
  if title != none and title != "" { (report.mktitle)(title) }
  if info != none and info != "" { (report.mkinfo)(info) }
  if author != none and author != () { (report.mkauthor)(author) }
  if time != none and time != "" { (report.mktime)(time) }
  pagebreak()
  show: stynumbering.with(numbering: "I")
  counter(page).update(1)
  if abstract != none and abstract != "" {
    newpara()
    (article.mkabstract)(abstract, keywords, lang: lang)
  }
  if contents != false {
    newpara()
    (article.mkcontent)(content-depth)
    pagebreak()
  }
  show: stynumbering.with(numbering: "1")
  counter(page).update(1)
  if preface != none and preface != "" {
    newpara()
    (report.mkpreface)(preface)
  }
  newpara()
  body
}
