#import "../consts.typ": *

#let 附录(info: (:)) = [
  #if info.at(info-keys.附录) == none {
    return
  }
  #for item in info.at(info-keys.附录) {
    item
  }
]
