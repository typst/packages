#import "util.typ": cd, to-sandhi-pairs

#let tone-map = (
  // Acute Accent (e.g., á) - U+0301
  "á": 2,
  "é": 2,
  "í": 2,
  "ó": 2,
  "ú": 2,
  "ḿ": 2,
  "ń": 2,
  "Á": 2,
  "É": 2,
  "Í": 2,
  "Ó": 2,
  "Ú": 2,
  "Ḿ": 2,
  "Ń": 2,
  // Grave Accent (e.g., à) - U+0300
  "à": 3,
  "è": 3,
  "ì": 3,
  "ò": 3,
  "ù": 3,
  "m̀": 3,
  "ǹ": 3,
  "À": 3,
  "È": 3,
  "Ì": 3,
  "Ò": 3,
  "Ù": 3,
  "M̀": 3,
  "Ǹ": 3,
  // Circumflex (e.g., â) - U+0302
  "â": 5,
  "ê": 5,
  "î": 5,
  "ô": 5,
  "û": 5,
  "m̂": 5,
  "n̂": 5,
  "Â": 5,
  "Ê": 5,
  "Î": 5,
  "Ô": 5,
  "Û": 5,
  "M̂": 5,
  "N̂": 5,
  // Macron (e.g., ā) - U+0305
  "ā": 7,
  "ē": 7,
  "ī": 7,
  "ō": 7,
  "ū": 7,
  "m̄": 7,
  "n̄": 7,
  "Ā": 7,
  "Ē": 7,
  "Ī": 7,
  "Ō": 7,
  "Ū": 7,
  "M̄": 7,
  "N̄": 7,
  // Variat: Breve (e.g., ă) - U+0306
  "ă": 6,
  "ĕ": 6,
  "ĭ": 6,
  "ŏ": 6,
  "ŭ": 6,
  "m̆": 6,
  "n̆": 6,
  "Ă": 6,
  "Ĕ": 6,
  "Ĭ": 6,
  "Ŏ": 6,
  "Ŭ": 6,
  "M̆": 6,
  "N̆": 6,
)

#for char in "A̋E̋I̋ŐŰM̋N̋a̋e̋i̋őűm̋n̋" {
  tone-map.insert(char, 9)
}

// #let r = "|'aaaa-bbb-ccc--ddd--eee.".matches(regex("(^\P{L}+)?-?\p{L}+-?(\P{L}+$)?"))

#let nan-tone-extractor = pron => {
  // if pron.ends-with("-") {
  //   pron = pron.slice(0, -1)
  //   last-char = false
  // }
  if pron.contains("\u{030D}") {
    return 5
  } else if pron.match(regex("[hH](\b|-|$)")) != none {
    return 4
  }

  for char in pron /* .clusters() */ {
    if char in tone-map {
      return tone-map.at(char)
    }
  }
  return 1
}

#let nan-tone-map = (
  none, // 0 不定
  (44, 33), // 1 阴平
  (53, 44), // 2 阴上
  (11, 53), // 3 阴去
  (32, 4), // 4 阴入
  (24, 11), // 5 阳平
  (33, 11), // 6 阳上
  (33, 11), // 7 阴入
  (4, 32), // 8 阳入
  (35, 35), // 9
)

#let nan-tone-sandhi = tone => {}

// #assert(nan-tone-extractor("pe̍h-") == 5)
#let nan-sandhi-converter = pron => {
  if (pron == none) {
    return ((none, none),)
  }
  // \p{L} is not working for POJ
  let prons = ()
  let i = 0
  for (j, char) in pron.clusters().enumerate() {
    if char == "-" and j > i + 1 {
      prons.push(pron.clusters().slice(i, j + 1).join(""))
      i = j + 1
    }
  }
  prons.push(pron.clusters().slice(i).join(""))
  let res = (
    prons
      .enumerate()
      .find(((i, p)) => {
        if p.starts-with("-") {
          return true
        }
        false
      })
  )

  let tone-index = (
    if none == res {
      prons.len() // Last one, index is len() - 1
    } else {
      res.at(0) // Last one before the item that starts with "-"
    }
      - 1
  )

  prons
    .enumerate()
    .map(((i, p)) => {
      let tone = nan-tone-extractor(p)
      let sandhi = i < tone-index
      let conter = nan-tone-map.at(tone).at(if sandhi { 1 } else { 0 })
      (p, conter)
    })
}

#let nan-tailo = (zh, pron, ..attrs) => {
  let pairs = to-sandhi-pairs(zh, pron).map(pair /* (zh, pron) */ => {
    let characters = pair.at(0).clusters()
    if pair.at(1) != none {
      let prons = nan-sandhi-converter(pair.at(1))
      characters.zip(prons).map(((zi, (p, q))) => (zi, p, q))
    } else {
      pair.at(0)
    }
  })
  for ci in pairs {
    cd(ci, ..attrs)
  }
}
