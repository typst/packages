/// 和文・欧文で異なるフォントを指定する
///
/// - jfont (string, array): 和文フォントの種類
/// - jweight (string, integer): 和文フォントの太さ
/// - efont (string, array): 欧文フォントの種類
/// - eweight (string, integer): 欧文フォントの太さ
/// - body (content): 本文
/// -> content
#let mixed(
  jfont,
  jweight: "regular",
  jsize: 1em,
  efont,
  eweight: "bold",
  esize: 1.05em,
  body,
) = {
  show regex("[\p{Latin}0-9]"): set text(
    font: efont,
    weight: eweight,
    size: esize,
  )
  show regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]"): set text(
    font: jfont,
    weight: jweight,
    size: jsize,
  )
  body
}
