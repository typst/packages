#import "util.typ": cd, to-pairs, to-scheme

#let cmn-pinyin-scheme = (
  none,
  55,
  35,
  214,
  53,
)

#let cmn-pinyin(zh, pron, ..attrs) = {
  let pairs = to-pairs(zh, pron)
  cd(
    pairs,
    scheme: to-scheme(cmn-pinyin-scheme),
    ..attrs
  )
}

#let cmn-cyuc-scheme = (
  none,
  55,
  21,
  42,
  14,
)

#let cmn-xghu-schemes = (
  "Guiyang": (45, 21, 43, 24),
  "Anshun": (44, 31, 54, 13),
  "Liuzhi": (55, 21, 42, 13),
  "Xingyi": (44, 21, 53, 24),
  "Hanyin": (33, 42, 45, 214),
  "Zhenba": (35, 31, 52, 213),
  "Shiqian": (45, 31, 53, 214),
  "Chengdu": (45, 21, 53, 213),
  "Tongren": (45, 22, 42, 24),
  "Guanyuan": (34, 21, 52, 14),
  "Nanchong": (45, 21, 53, 14),
  "Mianyang": (45, 31, 52, 13),
  "Wanzhou": (45, 213, 42, 215),
)

/* Chongqing dialect, Sicuanhua Pinyin */
#let cmn-cyuc-sicuan = (zh, pron, ..attrs) => {
  let pairs = to-pairs(zh, pron)
  cd(
    pairs,
    scheme: to-scheme(cmn-cyuc-scheme),
    ..attrs
  )
}

/* Southwestern Mandarin, Síchuānhuá tōngyóng pīnyīn */
#let cmn-xghu-tongyong = (zh, pron, scheme: "Chengdu", ..attrs) => {
  if type(scheme) == str {
    scheme = cmn-xghu-schemes.at(scheme)
  }
  let pairs = to-pairs(zh, pron)
  cd(
    pairs,
    scheme: to-scheme((none, ..scheme)),
    ..attrs
  )
}
