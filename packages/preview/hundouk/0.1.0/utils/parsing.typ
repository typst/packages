#import "./unicode.typ": is-hiragana, is-kanji, is-katakana

// Kanbun nodes:
//    - (type: "newline"): Represents a line break.
//    - (type: "punctuation", surface: string): Represents a punctuation character.
//    - (type: "connector"): Represents a connector line (=).
//    - (type: "character", surface: string, ...): Represents a kanji/character with optional attachments:
//        - reading (string): Ruby (furigana/kun-reading).
//        - okurigana (string): Okurigana (standard/right-side).
//        - kaeriten (string): Normalized kaeriten unicode character.
//        - left-ruby (string): Sidenote (left-side ruby / Sa-kun).
//        - left-okurigana (string): Left-side okurigana (Sa-okuri).

#let kaeriten-map = (
  "0": "\u{3191}", // レ
  "1": "\u{3192}", // 一
  "2": "\u{3193}", // 二
  "3": "\u{3194}", // 三
  "4": "\u{3195}", // 四
  "レ": "\u{3191}",
  "一": "\u{3192}",
  "二": "\u{3193}",
  "三": "\u{3194}",
  "四": "\u{3195}",
  "上": "\u{3196}",
  "中": "\u{3197}",
  "下": "\u{3198}",
  "甲": "\u{3199}",
  "乙": "\u{319A}",
  "丙": "\u{319B}",
  "丁": "\u{319C}",
  "天": "\u{319D}",
  "地": "\u{319E}",
  "人": "\u{319F}",
)

#let normalize-kaeriten(k) = {
  let res = ""
  for c in k.clusters() {
    res += kaeriten-map.at(c, default: c)
  }
  res
}

/// Yhëhtozr体（`wenyan-book-ja`）テキスト形式の漢文表記をノードツリーに解析
/// cf. https://wenyan-book-ja.netlify.app
/// cf. https://gitlab.com/yheuhtozr/book-ja-kanbun
///
/// - sentence (string): 漢文
/// ->
#let parse-wenyan(sentence) = {
  let nodes = ()
  let i = 0
  let clusters = str(sentence).clusters()

  while i < clusters.len() {
    let c = clusters.at(i)
    if c == "\n" {
      nodes.push((type: "newline"))
      i += 1
      continue
    }
    if c == "，" or c == "。" or c == "、" {
      nodes.push((type: "punctuation", surface: c))
      i += 1
      continue
    }
    if c == " " or c == "\u{3000}" {
      i += 1
      continue
    }

    if c == "=" {
      nodes.push((type: "connector"))
      i += 1
    } else {
      let surface = c
      let reading = none
      let okurigana = none
      let kaeriten = none
      let left-ruby = none
      i += 1

      if i < clusters.len() {
        let next = clusters.at(i)
        if next == "（" {
          i += 1
          let buf = ""
          while i < clusters.len() and clusters.at(i) != "）" {
            buf += clusters.at(i)
            i += 1
          }
          reading = buf
          if i < clusters.len() and clusters.at(i) == "）" {
            i += 1
          }
        } else if is-hiragana(next) or next == "ー" {
          let buf = ""
          while (
            i < clusters.len() and (is-hiragana(clusters.at(i)) or clusters.at(i) == "ー")
          ) {
            buf += clusters.at(i)
            i += 1
          }
          reading = buf
        }
      }

      if i < clusters.len() {
        let next = clusters.at(i)
        if is-katakana(next) or next == "ー" {
          let buf = ""
          while (
            i < clusters.len() and (is-katakana(clusters.at(i)) or clusters.at(i) == "ー")
          ) {
            buf += clusters.at(i)
            i += 1
          }
          okurigana = buf
        }
      }

      if i < clusters.len() {
        let next = clusters.at(i)
        if next.match(regex("\d")) != none {
          kaeriten = next
          i += 1
        }
      }

      if i < clusters.len() {
        let next = clusters.at(i)
        if next == "〔" {
          i += 1
          let buf = ""
          while i < clusters.len() and clusters.at(i) != "〕" {
            buf += clusters.at(i)
            i += 1
          }
          left-ruby = buf
          if i < clusters.len() and clusters.at(i) == "〕" {
            i += 1
          }
        }
      }

      let node = (type: "character", surface: surface)
      if reading != none {
        node.insert("reading", reading)
      }
      if okurigana != none {
        node.insert("okurigana", okurigana)
      }
      if kaeriten != none {
        node.insert("kaeriten", normalize-kaeriten(kaeriten))
      }
      if left-ruby != none {
        node.insert("left-ruby", left-ruby)
      }
      nodes.push(node)
    }
  }
  nodes
}

/// 青空文庫形式テキスト形式の漢文表記をノードツリーに解析
///
/// - sentence (string): 漢文
/// ->
#let parse-aozora(sentence) = {
  if sentence == none {
    return none
  }
  let nodes = ()
  let i = 0
  let clusters = str(sentence).clusters()

  while i < clusters.len() {
    let c = clusters.at(i)

    if c == "\n" {
      nodes.push((type: "newline"))
      i += 1
      continue
    }

    // Punctuation
    if c == "，" or c == "。" or c == "、" or c == "〻" {
      nodes.push((type: "punctuation", surface: c))
      i += 1
      continue
    }
    if c == " " or c == "\u{3000}" {
      i += 1
      continue
    }

    // Connector (竪点)
    if c == "‐" {
      let node = (type: "connector")
      i += 1

      // Check for attached kaeriten [＃...] (without parenthesis)
      // e.g. ‐［＃二］
      if (
        i + 2 < clusters.len() and clusters.at(i) == "［" and clusters.at(i + 1) == "＃"
      ) {
        // Look ahead to check if it's kaeriten (not okurigana with parens)
        // User spec says Kaeriten is ［＃...］, Okurigana is ［＃（...）］
        if i + 2 < clusters.len() and clusters.at(i + 2) != "（" {
          i += 2 // skip ［＃
          let buf = ""
          while i < clusters.len() and clusters.at(i) != "］" {
            buf += clusters.at(i)
            i += 1
          }
          node.insert("kaeriten", normalize-kaeriten(buf))
          if i < clusters.len() { i += 1 } // consume ］
        }
      }

      nodes.push(node)
      continue
    }

    let surface = c
    let reading = none
    let okurigana = none
    let kaeriten = none
    let left-ruby = none
    i += 1

    let continue_parsing_attachments = true
    while continue_parsing_attachments and i < clusters.len() {
      let next = clusters.at(i)

      if next == "《" {
        // Ruby
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "》" {
          buf += clusters.at(i)
          i += 1
        }
        reading = buf
        if i < clusters.len() { i += 1 }
      } else if next == "〈" {
        // Left Ruby / Re-reading (or Okiji if empty)
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "〉" {
          buf += clusters.at(i)
          i += 1
        }
        // If left-ruby already exists, append? Or overwrite? Usually one per char.
        if left-ruby == none { left-ruby = buf } else { left-ruby += buf }
        if i < clusters.len() { i += 1 }
      } else if is-hiragana(next) or is-katakana(next) or next == "ー" {
        // Direct Okurigana (Kana)
        let buf = ""
        while (
          i < clusters.len()
            and (
              is-hiragana(clusters.at(i))
                or is-katakana(clusters.at(i))
                or clusters.at(
                  i,
                )
                  == "ー"
            )
        ) {
          buf += clusters.at(i)
          i += 1
        }
        if okurigana == none { okurigana = buf } else { okurigana += buf }
      } else if next == "［" {
        // Potential Kaeriten or Okurigana ［＃...］
        if i + 1 < clusters.len() and clusters.at(i + 1) == "＃" {
          // It is an Aozora tag
          if i + 2 < clusters.len() and clusters.at(i + 2) == "（" {
            // ［＃（...）］ -> Okurigana
            i += 3 // skip ［＃（
            let buf = ""
            while i < clusters.len() and clusters.at(i) != "）" {
              buf += clusters.at(i)
              i += 1
            }
            if okurigana == none { okurigana = buf } else { okurigana += buf }
            if i < clusters.len() { i += 1 } // skip ）
            if i < clusters.len() and clusters.at(i) == "］" { i += 1 } // skip ］
          } else {
            // ［＃...］ -> Kaeriten
            i += 2 // skip ［＃
            let buf = ""
            while i < clusters.len() and clusters.at(i) != "］" {
              buf += clusters.at(i)
              i += 1
            }
            kaeriten = buf
            if i < clusters.len() { i += 1 } // skip ］
          }
        } else {
          // Just a regular bracket? Or malformed?
          // Treat as separate char or break?
          // For now, assume it's next char.
          continue_parsing_attachments = false
        }
      } else {
        continue_parsing_attachments = false
      }
    }

    let node = (type: "character", surface: surface)
    if reading != none { node.insert("reading", reading) }
    if okurigana != none { node.insert("okurigana", okurigana) }
    if kaeriten != none {
      node.insert("kaeriten", normalize-kaeriten(kaeriten))
    }
    if left-ruby != none {
      node.insert("left-ruby", left-ruby)
    }

    nodes.push(node)
  }
  nodes
}


/// UntPhesoca体（`kanbunHTML`）テキスト形式の漢文表記をノードツリーに解析
/// cf. https://github.com/untunt/kanbunHTML
/// cf. https://github.com/yuanhao-chen-nyoeghau/kanbun
/// cf. https://phesoca.com/kanbun-html/
///
/// - sentence (string): 漢文
/// ->
#let parse-kanbun(sentence) = {
  if sentence == none {
    return none
  }

  let nodes = ()
  let i = 0
  let clusters = str(sentence).clusters()

  while i < clusters.len() {
    let c = clusters.at(i)

    // Ignore single quotes
    if c == "‘" or c == "’" {
      i += 1
      continue
    }

    if c == "「" or c == "」" or c == "『" or c == "』" {
      nodes.push((type: "quotation", surface: c))
      i += 1
      continue
    }

    // Check for special node types first
    if c == "\n" {
      nodes.push((type: "newline"))
      i += 1
      continue
    }
    if c == "，" or c == "。" or c == "、" or c == "〻" {
      nodes.push((type: "punctuation", surface: c))
      i += 1
      continue
    }
    if c == " " or c == "\u{3000}" {
      i += 1
      continue
    }

    if c == "=" or c == "―" {
      let node = (type: "connector")
      i += 1

      // Check for attached kaeriten [..]
      if i < clusters.len() and clusters.at(i) == "[" {
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "]" {
          buf += clusters.at(i)
          i += 1
        }
        node.insert("kaeriten", normalize-kaeriten(buf))
        if i < clusters.len() { i += 1 }
      }

      nodes.push(node)
      continue
    }

    let surface = c
    let reading = none
    let okurigana = none
    let kaeriten = none
    let left-ruby = none
    let left-okurigana = none
    i += 1

    // Loop to consume attached properties (reading, okurigana, kaeriten)
    // Order in text: Kanji(surface) -> (Reading)? -> Okurigana? -> [Kaeriten]?
    // But they can be intermixed or come in different orders depending on style?
    // "濺(そそ)ギ[レ]" -> Surface: 濺, Reading: (そそ), Okurigana: ギ, Kaeriten: [レ]

    let continue_parsing_attachments = true
    while continue_parsing_attachments and i < clusters.len() {
      let next = clusters.at(i)

      if next == "‘" or next == "’" {
        i += 1
        continue
      }

      if next == "(" or next == "（" {
        // Reading in parens
        i += 1
        let buf = ""
        while (
          i < clusters.len() and clusters.at(i) != ")" and clusters.at(i) != "）"
        ) {
          buf += clusters.at(i)
          i += 1
        }
        reading = buf
        if i < clusters.len() { i += 1 } // skip closing paren
      } else if next == "[" {
        // Kaeriten in brackets
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "]" {
          buf += clusters.at(i)
          i += 1
        }
        kaeriten = buf
        if i < clusters.len() { i += 1 }
      } else if next == "‹" {
        // Left ruby (UntPhesoca style)
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "›" {
          buf += clusters.at(i)
          i += 1
        }
        if left-ruby == none { left-ruby = buf } else { left-ruby += buf }
        if i < clusters.len() { i += 1 }
      } else if next == "«" {
        // Left okurigana per user request
        i += 1
        let buf = ""
        while i < clusters.len() and clusters.at(i) != "»" {
          buf += clusters.at(i)
          i += 1
        }
        if left-okurigana == none { left-okurigana = buf } else { left-okurigana += buf }
        if i < clusters.len() { i += 1 }
      } else if is-katakana(next) or next == "ー" {
        // Katakana okurigana
        let buf = ""
        while (
          i < clusters.len() and (is-katakana(clusters.at(i)) or clusters.at(i) == "ー")
        ) {
          buf += clusters.at(i)
          i += 1
        }
        if okurigana == none { okurigana = buf } else { okurigana += buf }
      } else if is-hiragana(next) {
        // Hiragana okurigana? (Rare in this style but possible)
        // The example uses Katakana for main okurigana, but let's be safe or just assume Katakana per prompt "Katakana / Hiragana / Kanji functions" usage expectation.
        // Actually in "tjhwin-muangh.txt": "感ジテハ" -> Katakana.
        // Let's assume Hiragana is also Okurigana if it appears unparenthesized attached to Kanji?
        // But usually this style uses Katakana.
        // Let's stick to Katakana for now based on file content.
        continue_parsing_attachments = false
      } else {
        continue_parsing_attachments = false
      }
    }

    let node = (type: "character", surface: surface)
    if reading != none { node.insert("reading", reading) }
    if okurigana != none { node.insert("okurigana", okurigana) }
    if kaeriten != none {
      node.insert("kaeriten", normalize-kaeriten(kaeriten))
    }
    if left-ruby != none {
      node.insert("left-ruby", left-ruby)
    }
    if left-okurigana != none {
      node.insert("left-okurigana", left-okurigana)
    }

    nodes.push(node)
  }
  nodes
}

/// ノードツリーを漢文テキスト形式にシリアライズ
///
/// - nodes (array): 漢文ノードリスト
/// -> string
#let serialize-kanbun(nodes) = {
  if nodes == none { return "" }
  let res = ""
  for node in nodes {
    if node.type == "newline" {
      res += "\n"
    } else if node.type == "punctuation" or node.type == "quotation" {
      res += node.surface
    } else if node.type == "connector" {
      res += "="
    } else if node.type == "character" {
      res += node.surface
      if node.at("reading", default: none) != none {
        res += "（" + node.reading + "）"
      }
      if node.at("left-ruby", default: none) != none {
        res += "‹" + node.left-ruby + "›"
      }
      if node.at("okurigana", default: none) != none {
        res += node.okurigana
      }
      if node.at("left-okurigana", default: none) != none {
        res += "«" + node.left-okurigana + "»"
      }
      if node.at("kaeriten", default: none) != none {
        res += "[" + node.kaeriten + "]"
      }
    }
  }
  res
}

