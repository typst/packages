// src/heading.typ
// 標題編號與交互參照路徑（內部實作，供 styles.typ 使用）

// ============================================================
// § 標題編號
// ============================================================
// 大寫中文數字，如 3 →「參」、11 →「拾壹」、20 →「貳拾」。
// Typst 內建的 "壹" 數字採簡體字形（贰、叁、陆），故換回臺灣常用的貳、參、陸；
// 其餘字（壹肆伍柒捌玖拾佰仟零）兩種字形相同。
#let ch-big-number(n) = numbering("壹", n).replace("贰", "貳").replace("叁", "參").replace("陆", "陸")

// 單一標題的編號，如「(三) 」；n 為各層計數，例如 (1, 2, 3)。
// 六層依序為「壹、一、(一) 1.(1) ①」，各層數字超過十時依序進位，如「拾壹、」「十一、」；
// 超過六層者無編號（回傳 none）。
// large 為 true 時，於現有層級上方多加一層「章」，編號為「Ch. 1 」（阿拉伯數字）。
#let heading-number(n, large: false) = {
  let level-offset = if large { 1 } else { 0 }
  let level = n.len() - level-offset
  let val = n.last()
  if large and n.len() == 1 {
    "Ch. " + numbering("1", val) + " "
  } else if level == 1 {
    ch-big-number(val) + "、"
  } else if level == 2 {
    numbering("一、", ..n.slice(1 + level-offset))
  } else if level == 3 {
    numbering("(一) ", ..n.slice(2 + level-offset))
  } else if level == 4 {
    numbering("1.", ..n.slice(3 + level-offset))
  } else if level == 5 {
    numbering("(1) ", ..n.slice(4 + level-offset))
  } else if level == 6 {
    numbering("①", ..n.slice(5 + level-offset))
  }
}

// 交互參照用的完整路徑，如 (1, 2, 3) →「壹、二、(三)」、(1, 2) →「壹、二」。
// 各層編號去除空白後相連，並去掉結尾最後一個的「、」或「.」。
#let heading-path(n, large: false) = {
  let parts = range(1, n.len() + 1).map(i => heading-number(n.slice(0, i), large: large))
  parts.filter(p => p != none).map(p => p.trim()).join().trim(regex("[、.]"), at: end)
}
