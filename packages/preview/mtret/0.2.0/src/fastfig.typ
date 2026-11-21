#import "@preview/codly:2.0.0" as codly

// --------------------------------
// 共通処理
// --------------------------------

/// 直近の図が置かれた本文領域の大きさ.
#let region = state("mtret-fastfig-region", none)

/// 中身を`figure`で包み, ラベルを付ける.
///
/// フロートはページを跨げないため,
/// 1ページに収まらない図は`placement`を無視して本文中で分割させる.
///
/// - body (content): 図の中身
/// - label (label, str, none): 図のラベル.文字列は`label`に変換する
/// - placement (alignment, auto, none): 図の配置
/// - args (arguments): `figure`に渡す残りの引数
/// -> content
#let place-figure(body, label, placement, ..args) = {
  let label = if type(label) == str { std.label(label) } else { label }
  show figure: set block(breakable: true)
  let fig(placement) = [#figure(body, placement: placement, ..args)#label]
  // place/layout要素はHTML出力で中身ごと捨てられる
  context if placement == none or target() == "html" { fig(placement) } else {
    // layoutの中のフロートは本文でなくlayout内に配置されるため, 大きさだけを外へ持ち出す
    place(layout(size => region.update(size)))
    context {
      let size = region.get()
      let fits = size == none or measure(fig(none), width: size.width).height <= size.height
      fig(if fits { placement } else { none })
    }
  }
}

/// `path`ならファイルを読み込み`raw`ブロックにする.
///
/// - src (content, path): 中身またはファイルのパス
/// - lang (str, none): ファイルの言語
/// -> content
#let as-raw(src, lang) = if type(src) == path { raw(read(src), lang: lang, block: true) } else { src }

/// 左寄せの枠付きブロック.
///
/// - body (content): 中身
/// - args (arguments): `block`に渡す残りの引数
/// -> content
#let frame(body, ..args) = block(
  // align要素はHTML出力で中身ごと捨てられるため, set ruleでalign
  {
    set align(left)
    body
  },
  breakable: true,
  stroke: 0.7pt,
  width: 99%,
  ..args,
)

// --------------------------------
// Figureラッパー
// --------------------------------

/// 画像を挿入する.
///
/// - src (path, bytes): 画像.文字列のパスはパッケージ基準で解決されるため受け付けない
/// - caption (content, none): キャプション
/// - label (label, str, none): ラベル
/// - alt (str, none): 代替テキスト.PDF/UAでは必須
/// - width (relative, auto): 画像の幅
/// - placement (alignment, auto, none): 図の配置
/// -> content
#let fimg(
  src,
  caption: none,
  label: none,
  alt: none,
  width: 100%,
  placement: bottom,
) = {
  assert(type(src) != str, message: "fimg: パスは`path(\"...\")`のように`path`で渡してください")
  place-figure(image(src, width: width, alt: alt), label, placement, caption: caption)
}

/// ソースコードを挿入する.
///
/// - code (content, path): `raw`ブロックまたはファイルのパス
/// - lang (str, none): ファイルから読み込む場合の言語
/// - caption (content, none): キャプション
/// - label (label, str, none): ラベル
/// - placement (alignment, auto, none): 図の配置
/// -> content
#let fcode(
  code,
  lang: none,
  caption: none,
  label: none,
  placement: bottom,
) = place-figure(
  frame(as-raw(code, lang), inset: 0.3em),
  label,
  placement,
  caption: caption,
  kind: "src",
  supplement: "ソースコード",
)

/// 実行結果などのテキストを挿入する.
///
/// - txt (content, path): `raw`ブロックまたはファイルのパス
/// - caption (content, none): キャプション
/// - label (label, str, none): ラベル
/// - placement (alignment, auto, none): 図の配置
/// -> content
#let ftext(
  txt,
  caption: none,
  label: none,
  placement: bottom,
) = {
  show: codly.set_(number-enabled: false)
  place-figure(
    frame(as-raw(txt, none), inset: 0.5em, radius: 0.5em),
    label,
    placement,
    caption: caption,
    kind: "txt",
    supplement: "テキスト",
  )
}
