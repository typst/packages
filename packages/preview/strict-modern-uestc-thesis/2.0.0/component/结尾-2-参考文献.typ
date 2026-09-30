#import "../consts.typ": *
#import "../utils/lib.typ": *

#let 参考文献(info: (:)) = [
  #if info.at(info-keys.参考文献) == none {
    return
  }

  #set pagebreak(weak: true)

  #let bibs = info.at(info-keys.参考文献)

  #assert(
    type(bibs) == path or (type(bibs) == array and bibs.all(b => type(b) == path)),
    message: "参考文献必须为 path 类型或 array(path) 类型，当前类型为 ",
  )

  #set text(size: font-size.五号)
  #bilingual-bibliography(body: bibs, full: false)
]
