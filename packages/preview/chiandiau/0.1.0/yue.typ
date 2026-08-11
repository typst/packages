#import "util.typ": to-pairs, to-scheme, cd

#let yue-jyutping = (zh, pron, ..attrs) => {
  let pairs = to-pairs(zh, pron)
  cd(
    pairs,
    scheme: to-scheme((none, 55, 35, 33, 21, 23, 22)),
    ..attrs,
  )
}
