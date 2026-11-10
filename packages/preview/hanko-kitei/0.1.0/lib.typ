// SPDX-License-Identifier: MIT-0
// 日本語の規程文書をTypstらしく記述するための小さなテンプレートです。
//
// 本文では標準の見出し、列挙、用語リスト、参照を使用します。
// 書式は `default-config` にまとめ、文書ごとの差分だけを
// `regulation(config: (...))` で上書きします。

/// 行送りのプリセットです。`config: (line-spacing: "compact")` のように選びます。
///
/// 縦方向の間隔は2種類の値で決まります。段落内の折り返しは `body-leading`、
/// 項・号・条名などの区切りはブロック間隔（`enum-spacing` ほか）です。両者が
/// ずれると、段落内の行より段落どうしのほうが詰まって見えます。各プリセットは
/// 両者を揃え、10.5ptの本文で次のベースライン間隔になります。
///
/// - `roomy`：約18.2pt（本文の1.73倍）。Word原本の18pt送りに最も近い設定です。
/// - `normal`：約16.6pt（1.58倍）。既定値です。
/// - `compact`：約15.0pt（1.43倍）。
///
/// 個別の値は `config` で直接上書きでき、プリセットより優先されます。
#let line-spacing-presets = (
  roomy: (
    body-leading: 1.0em,
    enum-spacing: 1.0em,
    article-below: 1.0em,
    described-item-above: 1.0em,
    described-item-below: 1.0em,
    item-group-below: 0.35em,
  ),
  normal: (
    body-leading: 0.85em,
    enum-spacing: 0.85em,
    article-below: 0.9em,
    described-item-above: 0.85em,
    described-item-below: 0.85em,
    item-group-below: 0.35em,
  ),
  compact: (
    body-leading: 0.7em,
    enum-spacing: 0.7em,
    article-below: 0.75em,
    described-item-above: 0.7em,
    described-item-below: 0.7em,
    item-group-below: 0.35em,
  ),
)

/// `regulation` が使用する書式の既定値です。
///
/// 変更する値だけを `regulation` の `config` 引数へ渡します。
/// 例：`config: (toc-depth: 2, short-chapter-gap: 1em)`
///
/// 一部の値だけを簡単に上書きできるよう、辞書は意図的に
/// 入れ子にせずフラットな構造にしています。
///
/// 行送り関連の値は `line-spacing-presets.normal` から取り込みます。
#let default-config = (
  body-font: "Noto Serif CJK JP",
  heading-font: "Noto Sans CJK JP",
  cover: true,
  toc: true,
  line-spacing: "normal",

  paper: "a4",
  page-margin: (top: 30mm, bottom: 22mm, left: 28mm, right: 28mm),
  page-numbering: "1",
  page-number-align: center + bottom,

  body-size: 10.5pt,
  body-justify: true,
  heading-weight: "regular",
  title-size: 20pt,
  chapter-size: 14pt,
  section-size: 12pt,
  article-size: 10.5pt,

  chapter-above: 1.8em,
  chapter-below: 1.2em,
  section-above: 1.5em,
  section-below: 0.8em,
  article-above: 1.8em,
  heading-title-gap: 1em,

  // この文字数と一致する題名にだけ、短い題名用の字間を挿入します。
  short-title-length: 2,
  short-chapter-gap: 2em,
  short-section-gap: 2em,
  short-article-gap: 1em,

  paragraph-indent: 1em,
  enum-indent: 1em,
  enum-body-indent: 1em,
  omit-single-paragraph-number: true,

  described-item-label-width: 3em,
  described-item-gap: 0pt,
  described-item-indent: 1em,

  toc-title: [目次],
  toc-title-size: 14pt,
  toc-depth: 3,
  toc-indent: 1em,
  toc-entry-indent: 1em,
  toc-column-gap: 0.5em,
  toc-label-gap: 0.5em,

  ..line-spacing-presets.normal,
)

// 条と用語リストの補助関数は本文内で評価されます。各呼び出しに設定引数を
// 追加せず文書全体の設定を参照できるよう、stateを介して共有します。
#let _config-state = state("hanko-kitei-config", default-config)

// 1コンパイル単位でregulationが何回使われたかを数えます。
#let _instance-state = state("hanko-kitei-instances", 0)

/// 章、節、条、号の番号を表示用に整形します。
///
/// 1桁は全角数字、2桁以上はASCII数字で表示します。
#let _display-number(
  /// 整形する整数です。
  value,
) = {
  let value = int(value)
  if value < 10 {
    ("０", "１", "２", "３", "４", "５", "６", "７", "８", "９").at(value)
  } else {
    str(value)
  }
}

#let _spaced-if-short(value, gap, length: 2) = {
  let glyphs = value.clusters()
  if glyphs.len() == length and length > 1 {
    // 指定した字間を各文字の間へ挿入します。既定値は2文字の日本語見出しを
    // 対象にしていますが、設定を変えれば3文字以上にも対応できます。
    for (index, glyph) in glyphs.enumerate() {
      if index > 0 { h(gap) }
      glyph
    }
  } else {
    value
  }
}

/// 自動採番される条見出しと、その本文を作成します。
///
/// 条は目次に掲載され、Typst標準の `@ラベル` 記法で参照できます。
/// 条番号はソースに現れる順序で採番されます。
#let article(
  /// `<目的>` のような、参照に使用する安定したTypstラベルです。
  /// `title` を省略した場合は表示上の条名にも使用します。
  id,

  /// 表示上の条名です。ラベルと異なる条名を表示する場合や、
  /// 自動字間調整を適用しない場合に指定します。
  title: none,

  /// 条の本文です。項と号には通常の `+` 列挙を使用します。
  body,
) = {
  // Typst本体には引数の型注釈がないため、実行時検証でラベルに限定します。
  // この制約はTinymistの型推論が `str(id)` から型を広げることも抑えます。
  assert(type(id) == label, message: "article の id にはTypstラベルを指定してください")
  counter("article").step()
  counter("described-item").update(0)
  context {
    let config = _config-state.get()
    let number = counter("article").get().first()
    let display = "第" + _display-number(number) + "条"
    let resolved-title = if title == none {
      _spaced-if-short(
        str(id),
        config.short-article-gap,
        length: config.short-title-length,
      )
    } else {
      title
    }
    [#metadata((kind: "article", display: display))#id]
    heading(
      level: 3,
      numbering: none,
      outlined: true,
      supplement: [条],
    )[#display#h(config.heading-title-gap)#resolved-title]
  }
  body
}

#let _heading-numbering(..numbers) = {
  let values = numbers.pos()
  if values.len() == 1 {
    [第#_display-number(values.first())章]
  } else if values.len() == 2 {
    [第#_display-number(values.last())節]
  }
}

#let _enum-numbering(..numbers) = {
  let values = numbers.pos()
  if values.len() == 1 {
    str(values.last())
  } else {
    "（" + _display-number(values.last()) + "）"
  }
}

// 別の関数として定義し、列挙のshowルールが自身の出力へ再適用されるのを防ぎます。
#let _rendered-enum-numbering(..numbers) = _enum-numbering(..numbers)

// 項が1つだけの条で、その項番号を省略します。判定は「列挙の深さ」で行います。
// `full: true` により numbering は親からの番号すべてを受け取るため、引数が1つなら
// 最上位＝項、2つ以上なら入れ子＝号です。号は項数にかかわらず採番を維持します。
// `full` を変更するとこの判別が壊れます。
// 番号を空にすると列挙が番号欄を詰めてしまい、単一項の条だけ本文が左へ寄ります。
// `hide` は描画せず幅だけ残すため、条をまたいで本文の左端が揃います。
// 表示中の数字とは差が残りますが（Typst 0.15.1・既定フォントでの観測で 0.91pt）、
// これは実測値であって仕様ではありません。版やフォントが変われば変動します。
#let _singleton-paragraph-numbering(..numbers) = {
  let values = numbers.pos()
  if values.len() == 1 { hide(_enum-numbering(..numbers)) } else { _enum-numbering(..numbers) }
}

// 号リストを含む項かどうかを判定します。Typstのマークアップでは、入れ子の列挙は
// 親項の本文へ `enum.item` の並びとして現れ、`enum` へまとまるのは後段のため、
// 両方を確認します。
#let _has-nested-enum(body) = {
  if body.func() == enum or body.func() == enum.item {
    true
  } else if body.has("children") {
    body.children.any(child => child.func() == enum or child.func() == enum.item)
  } else {
    false
  }
}

// 章・節見出しの採番と題名を組み立てます。markup で書くと要素の間の改行が空白として
// 入り込み、`heading-title-gap` が指定値より広くなるため、コードモードで連結します。
// `counter(heading)` を読むので、呼び出し側は context 内である必要があります。
#let _heading-content(it, size, gap, config) = text(
  font: config.heading-font,
  size: size,
  weight: config.heading-weight,
)[#{
  if it.numbering != none {
    numbering(it.numbering, ..counter(heading).get())
    h(config.heading-title-gap)
  }
  if it.body.func() == text {
    _spaced-if-short(it.body.text, gap, length: config.short-title-length)
  } else {
    it.body
  }
}]

#let _described-items(items) = {
  for item in items.children {
    counter("described-item").step()
    context {
      let config = _config-state.get()
      let number = counter("described-item").get().first()
      // 列挙は自身のラベルの前に `enum-indent` を挿入します。見出し型の号も同じ
      // 字下げを与えることで、入れ子の深さにかかわらず通常の号と同じ位置へ並びます。
      block(
        above: config.described-item-above,
        below: config.described-item-below,
        inset: (left: config.enum-indent),
      )[
        #grid(
          columns: (config.described-item-label-width, 1fr),
          column-gutter: config.described-item-gap,
          [（#_display-number(number)）],
          block[
            #item.term\
            #h(config.described-item-indent)#item.description
          ],
        )
      ]
    }
  }
}

/// 文書全体に日本語規程用のレイアウトを適用します。
///
/// 章と節にはTypst標準の見出し（`=` と `==`）、条には `article`、
/// 項と号には入れ子の `+` 列挙、相互参照には標準のラベルと参照を使用します。
#let regulation(
  /// 表紙に表示し、PDFのメタデータにも格納する文書名です。
  title: "就業規則",

  /// PDFメタデータに格納する文書作成者です。
  author: "Employment Rules Typst PoC",

  /// `default-config` に対する上書きです。指定しない値は既定値を維持します。
  config: (:),

  /// 規程本文全体です。
  body,
) = {
  // 後方の辞書が前方を上書きします。行送りプリセットは既定値の上に重ね、
  // 利用側が個別に指定した値はプリセットより優先されます。
  let preset-name = config.at("line-spacing", default: default-config.line-spacing)
  assert(
    preset-name in line-spacing-presets,
    message: "line-spacing は "
      + line-spacing-presets.keys().join("、")
      + " のいずれかを指定してください（指定値: "
      + repr(preset-name)
      + "）",
  )
  let config = default-config + line-spacing-presets.at(preset-name) + config

  // regulationごとに独立した採番を開始します。outline自体はコンパイル単位全体を
  // 走査するため、1コンパイル単位につきregulationは1回だけ使用してください。
  counter("article").update(0)
  counter("described-item").update(0)
  counter(heading).update(0)

  set document(title: title, author: author)
  set page(
    paper: config.paper,
    margin: config.page-margin,
    numbering: config.page-numbering,
    number-align: config.page-number-align,
  )
  set text(font: config.body-font, lang: "ja", size: config.body-size, cjk-latin-spacing: none)
  set par(justify: config.body-justify, leading: config.body-leading)
  set heading(numbering: _heading-numbering)
  set enum(
    full: true,
    numbering: _enum-numbering,
    indent: config.enum-indent,
    body-indent: config.enum-body-indent,
    spacing: config.enum-spacing,
  )
  show enum.where(numbering: _enum-numbering): it => enum(
    full: true,
    numbering: if config.omit-single-paragraph-number and it.children.len() == 1 {
      _singleton-paragraph-numbering
    } else {
      _rendered-enum-numbering
    },
    indent: config.enum-indent,
    body-indent: config.enum-body-indent,
    spacing: config.enum-spacing,
    start: it.start,
    tight: it.tight,
    reversed: it.reversed,
    number-align: it.number-align,
    ..it.children.map(item => {
      let body = [#h(config.paragraph-indent)#item.body]
      // 号リストの直後に次の項が続く場合、リストの境界を明示します。入れ子列挙側へ
      // `below` を与えても親列挙の項間スペーシングへ吸収されるため、親項の本文末尾
      // へ実体のある空きを挿入します。
      if _has-nested-enum(item.body) {
        body = [#body#v(config.item-group-below, weak: false)]
      }
      let number = item.at("number", default: none)
      if number == none { enum.item(body) } else { enum.item(number, body) }
    }),
  )
  show terms: _described-items
  show ref: it => context {
    let matches = query(it.target)
    // 未定義ラベルはそのままTypstへ返します。ここでpanicすると、エラー位置が
    // 参照を書いたソース行ではなくこのライブラリ内を指してしまいます。
    if matches.len() == 0 { return it }
    let target = matches.first()
    if target.func() == metadata and target.value.at("kind", default: none) == "article" {
      target.value.display
    } else {
      it
    }
  }

  show heading: set text(font: config.heading-font, weight: config.heading-weight)
  show heading.where(level: 3): set text(size: config.article-size)
  show heading.where(level: 3): set block(
    above: config.article-above,
    below: config.article-below,
  )

  // 章・節の独自描画は、短い題名の自動字間調整にだけ使用します。
  // 採番には引き続きTypst標準の見出しカウンタを使用します。
  show heading.where(level: 1): it => context block(
    above: config.chapter-above,
    below: config.chapter-below,
    _heading-content(it, config.chapter-size, config.short-chapter-gap, config),
  )
  show heading.where(level: 2): it => context block(
    above: config.section-above,
    below: config.section-below,
    _heading-content(it, config.section-size, config.short-section-gap, config),
  )

  // 題名の字間、字下げ、リーダー、ページ番号を本文を変更せず調整できるよう、
  // 目次のレイアウトを1つのルールにまとめます。
  show outline.entry: it => {
    let element = it.element
    if element.func() != heading { return it }
    let short-gap = if it.level == 1 {
      config.short-chapter-gap
    } else {
      config.short-section-gap
    }
    let entry-body = if it.level <= 2 and element.body.func() == text {
      _spaced-if-short(
        element.body.text,
        short-gap,
        length: config.short-title-length,
      )
    } else {
      element.body
    }
    let prefix = if it.level <= 2 and element.numbering != none {
      context [#numbering(element.numbering, ..counter(heading).at(element.location()))#h(config.toc-label-gap)]
    } else {
      []
    }
    block(inset: (left: (it.level - 1) * config.toc-entry-indent))[
      #grid(
        columns: (auto, 1fr, auto),
        column-gutter: config.toc-column-gap,
        text(font: config.heading-font)[#prefix#entry-body],
        it.fill,
        link(element.location(), it.page()),
      )
    ]
  }

  // 確定した設定を、後続する本文内の補助関数から参照可能にします。
  _config-state.update(config)

  // 目次はコンパイル単位全体の見出しを検索するため、1つの文書に複数の
  // regulationがあると互いの条が混ざります。黙って誤った目次を出すより
  // 早期に失敗させます。
  _instance-state.update(count => count + 1)
  context {
    if _instance-state.get() > 1 {
      panic("regulation は1つのコンパイル単位につき1回だけ使用してください。目次が文書全体を検索するため、複数の文書は結合できません。")
    }
  }

  if config.cover {
    // 表紙にはページ番号を表示しません。ページ数の計上は継続するため、
    // 目次のページ番号は表紙を含めた通し番号になります。
    page(numbering: none, align(center, text(
      font: config.heading-font,
      size: config.title-size,
      weight: config.heading-weight,
      title,
    )))
  }
  if config.toc {
    outline(
      title: text(
        font: config.heading-font,
        size: config.toc-title-size,
        weight: config.heading-weight,
        config.toc-title,
      ),
      depth: config.toc-depth,
      indent: config.toc-indent,
    )
    pagebreak()
  }
  body
}
