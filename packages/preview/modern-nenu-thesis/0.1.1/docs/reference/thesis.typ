#import "../book.typ": *
#import "../style.typ": module, ref-fn, tidy

#show: book-page.with(title: "lib.typ 参数解释")

#let page-self = "/reference/thesis.typ"
#let page-info = "/reference/info.typ"

#mynotify[
  有关 `info` 的相关说明，请参考 #cross-link(page-info, reference: <info>)[info的各个选项说明]
]

#module(
  read("../../lib.typ"),
  name: "Lib",
)


