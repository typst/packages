#import "../consts.typ": *
#import "../utils/lib.typ": *

#let 参考文献(info: (:)) = [
  #if info.at(info-keys.参考文献) == none {
    return
  }

  #set pagebreak(weak: true)

  #let prefix-path = "../../../"
  #let bibs = info.at(info-keys.参考文献)
  #let path = if type(bibs) == str {
    prefix-path + bibs
  } else if type(bibs) == array {
    bibs = bibs.map(item => { prefix-path + item })
  }

  #set text(size: font-size.五号)
  #bilingual-bibliography(body: path, full: false)
]
