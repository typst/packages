#import "@preview/auto-jrubby:0.3.4": tokenize

#let gana = (
  // 拗音を先に処理
  "きゃ": "Kya",
  "きゅ": "Kyu",
  "きょ": "Kyo",
  "ぎゃ": "Gya",
  "ぎゅ": "Gyu",
  "ぎょ": "Gyo",
  "しゃ": "Sha",
  "しゅ": "Shu",
  "しょ": "Sho",
  "じゃ": "Ja",
  "じゅ": "Ju",
  "じょ": "Jo",
  "ちゃ": "Cha",
  "ちゅ": "Chu",
  "ちょ": "Cho",
  "にゃ": "Nya",
  "にゅ": "Nyu",
  "にょ": "Nyo",
  "ひゃ": "Hya",
  "ひゅ": "Hyu",
  "ひょ": "Hyo",
  "びゃ": "Bya",
  "びゅ": "Byu",
  "びょ": "Byo",
  "ぴゃ": "Pya",
  "ぴゅ": "Pyu",
  "ぴょ": "Pyo",
  "みゃ": "Mya",
  "みゅ": "Myu",
  "みょ": "Myo",
  "りゃ": "Rya",
  "りゅ": "Ryu",
  "りょ": "Ryo",

  // 特殊な拗音
  "てぃ": "Ti",
  "でぃ": "Di",
  "とぅ": "Tu",
  "どぅ": "Du",
  "ふぁ": "Fa",
  "ふぃ": "Fi",
  "ふぇ": "Fe",
  "ふぉ": "Fo",
  "うぃ": "Wi",
  "うぇ": "We",
  "うぉ": "Wo",
  "ゔぁ": "Va",
  "ゔぃ": "Vi",
  "ゔぇ": "Ve",
  "ゔぉ": "Vo",

  // 清音
  "あ": "A",
  "い": "I",
  "う": "U",
  "え": "E",
  "お": "O",
  "か": "Ka",
  "き": "Ki",
  "く": "Ku",
  "け": "Ke",
  "こ": "Ko",
  "さ": "Sa",
  "し": "Shi",
  "す": "Su",
  "せ": "Se",
  "そ": "So",
  "た": "Ta",
  "ち": "Chi",
  "つ": "Tsu",
  "て": "Te",
  "と": "To",
  "な": "Na",
  "に": "Ni",
  "ぬ": "Nu",
  "ね": "Ne",
  "の": "No",
  "は": "Ha",
  "ひ": "Hi",
  "ふ": "Fu",
  "へ": "He",
  "ほ": "Ho",
  "ま": "Ma",
  "み": "Mi",
  "む": "Mu",
  "め": "Me",
  "も": "Mo",
  "や": "Ya",
  "ゆ": "Yu",
  "よ": "Yo",
  "ら": "Ra",
  "り": "Ri",
  "る": "Ru",
  "れ": "Re",
  "ろ": "Ro",
  "わ": "Wa",
  "を": "Wo",

  // 濁音
  "が": "Ga",
  "ぎ": "Gi",
  "ぐ": "Gu",
  "げ": "Ge",
  "ご": "Go",
  "ざ": "Za",
  "じ": "Ji",
  "ず": "Zu",
  "ぜ": "Ze",
  "ぞ": "Zo",
  "だ": "Da",
  "ぢ": "Ji",
  "づ": "Zu",
  "で": "De",
  "ど": "Do",
  "ば": "Ba",
  "び": "Bi",
  "ぶ": "Bu",
  "べ": "Be",
  "ぼ": "Bo",

  // 半濁音
  "ぱ": "Pa",
  "ぴ": "Pi",
  "ぷ": "Pu",
  "ぺ": "Pe",
  "ぽ": "Po",

  // 小書き母音
  "ぁ": "a",
  "ぃ": "i",
  "ぅ": "u",
  "ぇ": "e",
  "ぉ": "o",

  // その他
  "ゎ": "wa",
)

#let kana = (
  // 拗音を先に処理
  "キャ": "Kya",
  "キュ": "Kyu",
  "キョ": "Kyo",
  "ギャ": "Gya",
  "ギュ": "Gyu",
  "ギョ": "Gyo",
  "シャ": "Sha",
  "シュ": "Shu",
  "ショ": "Sho",
  "ジャ": "Ja",
  "ジュ": "Ju",
  "ジョ": "Jo",
  "チャ": "Cha",
  "チュ": "Chu",
  "チョ": "Cho",
  "ニャ": "Nya",
  "ニュ": "Nyu",
  "ニョ": "Nyo",
  "ヒャ": "Hya",
  "ヒュ": "Hyu",
  "ヒョ": "Hyo",
  "ビャ": "Bya",
  "ビュ": "Byu",
  "ビョ": "Byo",
  "ピャ": "Pya",
  "ピュ": "Pyu",
  "ピョ": "Pyo",
  "ミャ": "Mya",
  "ミュ": "Myu",
  "ミョ": "Myo",
  "リャ": "Rya",
  "リュ": "Ryu",
  "リョ": "Ryo",

  // 特殊な拗音
  "ティ": "Ti",
  "ディ": "Di",
  "トゥ": "Tu",
  "ドゥ": "Du",
  "ファ": "Fa",
  "フィ": "Fi",
  "フェ": "Fe",
  "フォ": "Fo",
  "ウィ": "Wi",
  "ウェ": "We",
  "ウォ": "Wo",
  "ヴァ": "Va",
  "ヴィ": "Vi",
  "ヴェ": "Ve",
  "ヴォ": "Vo",

  // 清音
  "ア": "A",
  "イ": "I",
  "ウ": "U",
  "エ": "E",
  "オ": "O",
  "カ": "Ka",
  "キ": "Ki",
  "ク": "Ku",
  "ケ": "Ke",
  "コ": "Ko",
  "サ": "Sa",
  "シ": "Shi",
  "ス": "Su",
  "セ": "Se",
  "ソ": "So",
  "タ": "Ta",
  "チ": "Chi",
  "ツ": "Tsu",
  "テ": "Te",
  "ト": "To",
  "ナ": "Na",
  "ニ": "Ni",
  "ヌ": "Nu",
  "ネ": "Ne",
  "ノ": "No",
  "ハ": "Ha",
  "ヒ": "Hi",
  "フ": "Fu",
  "ヘ": "He",
  "ホ": "Ho",
  "マ": "Ma",
  "ミ": "Mi",
  "ム": "Mu",
  "メ": "Me",
  "モ": "Mo",
  "ヤ": "Ya",
  "ユ": "Yu",
  "ヨ": "Yo",
  "ラ": "Ra",
  "リ": "Ri",
  "ル": "Ru",
  "レ": "Re",
  "ロ": "Ro",
  "ワ": "Wa",
  "ヲ": "Wo",

  // 濁音
  "ガ": "Ga",
  "ギ": "Gi",
  "グ": "Gu",
  "ゲ": "Ge",
  "ゴ": "Go",
  "ザ": "Za",
  "ジ": "Ji",
  "ズ": "Zu",
  "ゼ": "Ze",
  "ゾ": "Zo",
  "ダ": "Da",
  "ヂ": "Ji",
  "ヅ": "Zu",
  "デ": "De",
  "ド": "Do",
  "バ": "Ba",
  "ビ": "Bi",
  "ブ": "Bu",
  "ベ": "Be",
  "ボ": "Bo",

  // 半濁音
  "パ": "Pa",
  "ピ": "Pi",
  "プ": "Pu",
  "ペ": "Pe",
  "ポ": "Po",

  // 小書き母音
  "ァ": "a",
  "ィ": "i",
  "ゥ": "u",
  "ェ": "e",
  "ォ": "o",

  // その他
  "ヮ": "wa",
)

#let gana-to-romaji(text) = {
  let result = text

  result = result.replace("ー", "-")

  for pair in gana.pairs() {
    result = result.replace(pair.at(0), pair.at(1))
  }

  result = result.replace(regex("っ([KSTCPFBGHJMR])"), m => {
    let c = m.captures.at(0)
    c + c
  })

  result = result.replace("っ", "")
  result = result.replace("ん", "N")
  result = result.replace("-", "ー")

  lower(result)
}

#let kana-to-romaji(text) = {
  let result = text

  result = result.replace("ー", "-")

  for pair in kana.pairs() {
    result = result.replace(pair.at(0), pair.at(1))
  }

  result = result.replace(regex("ッ([KSTCPFBGHJMR])"), m => {
    let c = m.captures.at(0)
    c + c
  })

  result = result.replace("ッ", "")

  result = result.replace("ン", "N")

  result = result.replace("-", "")

  lower(result)
}

#let romaji(text) = {
  text = gana-to-romaji(text)
  text = kana-to-romaji(text)
  return text
}

#let auto-make-yomi(biblist, bib_str) = {
  if biblist.fields.lang == "ja" {
    let name = biblist.parsed_names.values().sum().map(x => x.at("family") + x.at("given")).join(",")
    let ruby = tokenize(name).map(x => {
      let details = x.details
      if details == ("UNK",) {
        x.surface
      } else if details.at(8) == "*" {
        x.surface
      } else {
        details.at(8)
      }
    })
    return romaji(ruby.sum())
  } else {
    return bib_str
  }
}
