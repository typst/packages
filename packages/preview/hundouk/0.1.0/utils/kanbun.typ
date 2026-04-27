
#import "./parsing.typ": parse-kanbun

/// 漢文ノードツリーより白文を返す
///
/// - text (str | array): 漢文ノードツリーまたは文字列
/// -> str: 白文
#let hakubun(text) = {
  if type(text) == str {
    hakubun(parse-kanbun(text))
  } else if type(text) == array {
    text
      .map(node => if node.type == "character" or node.type == "punctuation" {
        node.surface
      } else if node.type == "newline" { "\n" })
      .join("")
  }
}

// Series constants
#let SERIES_ICHI = 1
#let SERIES_JO = 2
#let SERIES_KOU = 3
#let SERIES_TEN = 4

/// Map _kaeritens_ from Unicode Kanbun Block characters to CJK Unified Ideographs. e.g. ㆑ -> レ, ㆒ -> 一, etc.
/// - k (str): Input string with Unicode Kanbun Block characters
/// -> str: normalized string with normalized Unified CJK Ideographs
#let unicode-kaeriten-to-normalized(k) = {
  if k == none { return none }
  let s = k
  s = s.replace("㆑", "レ")
  s = s.replace("㆒", "一")
  s = s.replace("㆓", "二")
  s = s.replace("㆔", "三")
  s = s.replace("㆕", "四")

  s = s.replace("㆖", "上")
  s = s.replace("㆗", "中")
  s = s.replace("㆘", "下")

  s = s.replace("㆙", "甲")
  s = s.replace("㆚", "乙")
  s = s.replace("㆛", "丙")
  s = s.replace("㆜", "丁")

  s = s.replace("㆝", "天")
  s = s.replace("㆞", "地")
  s = s.replace("㆟", "人")
  s
}

/// Normalize Kaeriten characters to standard form (e.g., Unicode Kanbun Block/Katakana -> Standard CJK)
/// - k (str): Input string with Kaeriten characters
/// -> str: normalized string with normalized Unified CJK Ideographs
#let normalize-kaeriten(k) = {
  if k == none { return none }
  let s = k
  // Kanbun Block --> Standard
  s = unicode-kaeriten-to-normalized(s)

  // Katakana brackets
  s = s.replace("[レ]", "レ")
  s = s.replace("[一]", "一")
  s = s.replace("[二]", "二")
  s = s.replace("[ニ]", "二") // Katakana Ni for robustness
  s = s.replace("ニ", "二") // Bare Katakana Ni (post-parsing) for robustness
  s = s.replace("[三]", "三")
  s = s.replace("[四]", "四")
  s = s.replace("[五]", "五")

  s
}

/// Helper to identify markers from a Kaeriten string
#let get-kaeriten-info(k) = {
  let info = (has-re: false, series: 0, rank: 0)
  if k == none { return info }

  let kn = normalize-kaeriten(k)

  if kn.contains("レ") { info.has-re = true }

  if kn.contains("一") {
    info.series = SERIES_ICHI
    info.rank = 1
  } else if kn.contains("二") {
    info.series = SERIES_ICHI
    info.rank = 2
  } else if kn.contains("三") {
    info.series = SERIES_ICHI
    info.rank = 3
  } else if kn.contains("四") {
    info.series = SERIES_ICHI
    info.rank = 4
  } else if kn.contains("五") {
    info.series = SERIES_ICHI
    info.rank = 5
  } else if kn.contains("上") {
    info.series = SERIES_JO
    info.rank = 1
  } else if kn.contains("中") {
    info.series = SERIES_JO
    info.rank = 2
  } else if kn.contains("下") {
    info.series = SERIES_JO
    info.rank = 3
  } else if kn.contains("甲") {
    info.series = SERIES_KOU
    info.rank = 1
  } else if kn.contains("乙") {
    info.series = SERIES_KOU
    info.rank = 2
  } else if kn.contains("丙") {
    info.series = SERIES_KOU
    info.rank = 3
  } else if kn.contains("天") {
    info.series = SERIES_TEN
    info.rank = 1
  } else if kn.contains("地") {
    info.series = SERIES_TEN
    info.rank = 2
  } else if kn.contains("人") {
    info.series = SERIES_TEN
    info.rank = 3
  }

  return info
}

/// 漢文ノードツリーより読み下しを返す
///
/// - text (str | array): 漢文ノードツリーまたは文字列
/// -> str: 読み下し
#let yomikudasi(text) = {
  if type(text) == str {
    yomikudasi(parse-kanbun(text))
  } else if type(text) == array {
    let result = ()
    let stack = () // Array of (node, type, series, rank)

    let format-node(node) = {
      let content = node.surface
      if node.at("reading", default: none) != none {
        content += "（" + node.reading + "）"
      }
      if node.at("okurigana", default: none) != none {
        content += node.okurigana
      }
      content
    }

    for node in text {
      if node.type == "character" {
        let k = node.at("kaeriten", default: none)
        let info = get-kaeriten-info(k)

        if info.has-re {
          // Push as Re type
          stack.push((node: node, type: "re", series: info.series, rank: info.rank))
        } else if info.rank > 1 {
          // Push as Rank type
          // Note: If Series is 0 (Rank > 1 but no series?), logic shouldn't happen, but get-kaeriten-info ensures consistency.
          stack.push((node: node, type: "rank", series: info.series, rank: info.rank))
        } else {
          // Leaf (Rank 1 or No Rank)
          result.push(format-node(node))

          let sig-series = info.series
          let sig-rank = info.rank

          while stack.len() > 0 {
            let top = stack.last()
            let match = false

            if top.type == "re" {
              match = true
            } else if top.type == "rank" {
              if top.series == sig-series and sig-rank < top.rank {
                match = true
              }
            }

            if match {
              let popped = stack.pop()
              result.push(format-node(popped.node))
              sig-series = popped.series
              sig-rank = popped.rank
            } else {
              break
            }
          }
        }
      } else if node.type == "punctuation" {
        result.push(node.surface)
      } else if node.type == "newline" {
        result.push("\n")
      }
    }

    // Flush remaining stack
    while stack.len() > 0 {
      let p = stack.pop()
      result.push(format-node(p.node))
    }

    result.join("")
  }
}
