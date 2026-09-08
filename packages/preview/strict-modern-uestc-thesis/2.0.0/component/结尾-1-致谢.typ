#import "../consts.typ": *

#let 致谢(info: (:)) = [
  = 致谢
  #if (info.at(info-keys.匿名)) {
    "*****"
    return
  }
  #if (info.at(info-keys.致谢) == none) {
    return
  }
  #info.at(info-keys.致谢)
]
