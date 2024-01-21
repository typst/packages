/// 日本語ダミーテキスト生成
///
/// - words (int): 生成するテキストの長さ（文字数）
/// - offset (int): テキストの開始位置（文字数）
/// - custom-text (str, none): デフォルト『吾輩は猫である』の代わりに使用する文字列
/// -> str
#let roremu(words, offset: 0, custom-text: none) = {
  let text = if custom-text == none { read("../texts/neko.txt") } else { custom-text }
  let length = text.clusters().len()
  let times = calc.div-euclid(offset + words, length) + 1
  (text * times).clusters().slice(offset, offset + words).join("")
}
