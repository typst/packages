// Typst テンプレートに i18n/l10n 対応を組み込む方法を、iarticle 自身の
// 仕組みを例に説明するガイドです。他のサンプル (article-{en,ja}.typ /
// report-{en,ja}.typ) が「埋めて使う本文テンプレート」であるのに対し、
// このファイルはリファレンスドキュメントです。テーマがテーマなので、
// このファイル自体も iarticle.with(lang: "ja") の上に書かれていて、
// 説明している仕組みそのものの実例にもなっています。
//
// コンパイルする前に、ローカルのチェックアウトを
// @preview/iarticle:0.1.1 として登録するため、一度だけ
// ../install_for_test.sh を実行してください。
#import "@preview/iarticle:0.1.1": iarticle, appendix

#show: iarticle.with(
  lang: "ja",
  title: [i18n/l10n 対応テンプレートの作り方 --- iarticle を例に],
  authors: ("Hideo Takahashi",),
  abstract: [
    Typst テンプレートに `lang` に応じた見出しラベルやキャプションの翻訳を組み込む方法を、iarticle (`@preview/iarticle:0.1.1`) の実装を例に説明します。
    仕組みは「文字列テーブル」「ロケール解決」「ルックアップ関数」の3部品だけで、テンプレート本体はそれらを `set`/`show` ルールから呼び出すだけで済みます。
  ],
)

= はじめに

このドキュメントは、iarticle がどうやって `lang: "en"` / `lang: "ja"` で見出しラベル (Section / Chapter / Appendix)、図表のキャプション (Figure / Table)、目次・要約・参考文献の見出しを切り替えているかを説明し、同じ仕組みを自分のテンプレートに移植する手順をまとめたものです。
対象読者は、既に何らかの Typst テンプレート (`#let mytemplate(...) = (...)`) を持っていて、そこに複数言語対応を足したい方を想定しています。

このドキュメント自体が `iarticle.with(lang: "ja")` の上に書かれているため、以下の見出し・図表キャプションはすべて iarticle の局所化機構によって日本語化されています。
つまりこのファイルは「説明」であると同時に「実例」でもあります。

= 全体設計：3つの部品

iarticle の局所化は `lib.typ` の中で完結しており、次の3つの部品に分かれます。

#figure(
  table(
    columns: 2,
    [*部品*], [*役割*],
    [ロケール解決], [`lang`/`region` からどの文字列テーブルを使うか決める],
    [文字列テーブル], [ロケールごとの訳語を持つ `l10n/<locale>.typ`],
    [ルックアップ関数 `t()`], [現在のロケールでキーを引き、テンプレート側から呼び出す],
  ),
  caption: [
    テンプレート本体 (`iarticle`/`ireport` に相当する builder) はこの3つを組み合わせて `set`/`show` ルールを書くだけで、ロケールごとの分岐を自分で書く必要がありません。
  ],
)

以下、この3部品を順に見ていきます。

= ロケール解決：`lang` と `region`

Typst の `text` 要素はもともと `lang`/`region` を持っています (例: `set text(lang: "ja")`)。
iarticle はこれをそのまま「どの言語で書かれた文書か」の入力として使い、内部的な「ロケール」に解決します。

```typst
#let _locale-for(lang, region) = lang
```

現時点では `region` を使わず `lang` をそのままロケールとして返しているだけですが、関数として切り出してあるのがポイントです。
`en`/`ja` はどちらも `lang` だけで一意に決まる言語ですが、例えば中国語簡体字/繁体字のように `lang: "zh"` だけでは区別できず `region` (`"CN"` / `"TW"` など) が必要になる言語を将来追加するときは、この関数の中身を書き換えるだけで済みます。
呼び出し側 (`t()` や `_font-stack` の呼び出し元) を一切変更せずに済むように、最初から「ロケール解決」を独立した関数にしておくのが移植のコツです。

対応ロケールとフォールバック先も、それぞれ1箇所にまとめておきます。

```typst
#let _supported-locales = ("en", "ja")
#let _fallback-locale = "en"
```

未対応の `lang` が渡された場合は `_fallback-locale` に落ちるようにしています (存在しないロケールで文書が壊れるより、フォールバック言語で出力される方が安全という判断です)。

= 文字列テーブル：`l10n/<locale>.typ`

ロケールごとの訳語は、ロケール名と同じファイル名の `.typ` に1つの辞書としてまとめます。

```typst
// l10n/en.typ
#let strings = (
  abstract: [Abstract],
  contents: [Contents],
  chapter: n => [Chapter #n],
  section: n => [Section #n],
  table: [Table],
  figure: [Figure],
  appendix: n => [Appendix #n],
  references: [References],
)
```

```typst
// l10n/ja.typ
#let strings = (
  abstract: [概要],
  contents: [目次],
  chapter: n => [第#(n)章],
  section: n => [#n],
  table: [表],
  figure: [図],
  appendix: n => [付録#n],
  references: [参考文献],
)
```

== キーは英語の原語に基づいて決めます

`abstract`・`contents`・`table` のように、キーは英語の原語に基づいて、その位置に何が入るかを表す名前にしましょう。
これによって `l10n/ja.typ` を書くときに `l10n/en.typ` と1対1で見比べながら埋めていけますし、新しいロケールを追加するときも「どのキーが未実装か」がひと目でわかります。

== 値が関数になる理由

`chapter`/`section`/`appendix` は plain content ではなく `n => [...]` という関数になっています。
理由は、番号とラベルの組み合わせ方が言語によって違うからです。
英語は "Chapter 3" のようにラベルが前置されますが、`l10n/ja.typ` の `section` は `n => [#n]` --- 日本語の技術文書では「3.1 導入」のように番号だけを置き、「Section」に相当する語自体を出さないことが多いためです。
ローカライズは単語を置き換えるだけでは済まず、「その言語では何も出さない」という選択肢も含めて設計する必要がある、という一例です。

= ルックアップ関数：`t()`

```typst
#let t(key, ..args) = context {
  let locale = _locale-for(text.lang, text.region)
  let dict = _strings-for(locale)
  let entry = dict.at(key, default: _strings-for(_fallback-locale).at(key))
  if type(entry) == function {
    entry(..args)
  } else {
    entry
  }
}
```

ここでのポイントは次の3つです。

+ `context` の中で `text.lang`/`text.region` を読みます。
  Typst の `text` の状態は文書中の位置によって変わりうる (`set text(lang: ..)` を局所的に上書きした範囲など) ので、`t()` は「どこから呼ばれたか」に応じたロケールを見なければなりません。
  これはつまり `t()` は markup content が評価できる場所 (`context` が使える場所) でしか意味を持たない、ということでもあります。
+ キーが現在のロケールの辞書に無ければ、フォールバックロケールの辞書から探します。
  これにより、新しいロケールを追加する際に全キーを一度に揃えなくても、未実装のキーだけ `_fallback-locale` (iarticle では英語) の訳で表示されます。
+ エントリが `function` ならそのまま呼び出し、そうでなければ content をそのまま返します --- これで呼び出し側は `t("abstract")` と `t("chapter", n)` のどちらの形も気にせず、同じ `t(key, ..args)` の形で呼べます。

= テンプレート本体への組み込み

文字列テーブルと `t()` ができたら、テンプレート本体はそれを `set`/`show` ルールの中で呼ぶだけになります。

== 見出しラベル

```typst
show heading.where(level: 1): it => {
  let label = context {
    if it.numbering == none { none } else {
      let n = numbering(it.numbering, ..counter(heading).at(it.location()))
      t(if _in-appendix.get() { "appendix" } else { top-level-key }, n)
    }
  }
  block(above: 1.8em, below: 1em)[#label #it.body]
}
```

見出し番号 `n` を先に `numbering()` で組み立て、それを `t(key, n)` に渡します --- 「番号を作る処理」と「番号をどうラベルに組み込むか (前置/後置/省略)」を分離しているので、言語ごとの見た目の違いは文字列テーブル側だけに閉じ込められます。
`top-level-key` は `iarticle` では `"section"`、`ireport` では `"chapter"` を渡すことで、1つの builder 関数から2つのテンプレートを生成しています (詳細は `lib.typ` の `_document` を参照してください)。

== 図表キャプション

```typst
show figure.where(kind: table): set figure(supplement: t("table"))
show figure.where(kind: image): set figure(supplement: t("figure"))
```

`figure()` の `supplement` を `kind` ごとに上書きするだけで、以降の `#figure(table(...), caption: [...])` は自動的にロケールに応じた「表 1」「Table 1」に切り替わります。
実際、このドキュメント中の表・図のキャプションもこの仕組みで日本語化されています。

== 目次・要約・参考文献の見出し

```typst
set bibliography(title: t("references"))
// ...
outline(title: t("contents"))
// ...
text(weight: "bold")[#t("abstract")]
```

いずれも `t(key)` を Typst 組み込みのパラメータ (`bibliography(title: ..)`、`outline(title: ..)`) にそのまま渡すだけで済みます --- 局所化のために組み込み要素を書き換える必要はありません。

= フォントの扱い

文字だけでなく、フォントもロケールに応じて切り替える必要があります。
iarticle は「Latin 用フォントスタック」と「ロケールごとの CJK 追加スタック」を分けて持ち、実際に使う文字だけに応じて連結します。

```typst
#let default-latin-serif-font = ("New Computer Modern",)
#let default-cjk-serif-font = (
  ja: ("Noto Serif JP", "Noto Serif CJK JP"),
)

#let _font-stack(locale, latin, cjk-by-locale) = {
  latin + cjk-by-locale.at(locale, default: ())
}
```

これには2つの理由があります。

+ Typst はフォントを文書全体でなく *文字ごと* に解決します (リストを先頭から見て、その文字を含む最初のフォントを使います) ので、「Latin ベース + CJK 追加」という1本のスタックにしておけば、日本語文中の英単語やコードも正しいフォントで表示されます。
  `lang` ごとにスタック全体を丸ごと差し替える必要はありません。
+ Typst は `set text(font: ..)` に渡したフォント名が1つでも未インストールだと警告を出します。
  CJK フォントを常に足しておくと、英語文書をコンパイルするだけで「日本語フォントが見つからない」という無関係な警告が出てしまいます。
  ロケールごとに追加スタックを引く (`cjk-by-locale.at(locale, default: ())`) ようにしておけば、`lang: "en"` の文書は何も警告を出さず、`lang: "ja"` の文書だけ必要なフォントを探しにいきます。

#figure(
  rect(width: 5cm, height: 2.5cm, stroke: 0.5pt)[
    #align(center + horizon)[
      Latin base #sym.arrow.r + CJK addition\
      (ロケールでキー引き)
    ]
  ],
  caption: [
    フォントスタックの結合イメージです。
    `serif-font`/`sans-font` 引数を `auto` のままにすると、この結合済みスタックが使われます。
    呼び出し側が明示的にフォントを渡した場合は、この自動結合は行われません (ロケール由来の CJK フォントを混ぜたい場合は、呼び出し側で自分から足してください)。
  ],
)

= 新しいロケールを追加する

以上を踏まえると、自分のテンプレートに新しいロケール (例えば `fr`) を1つ追加する手順は次のようになります。

+ `l10n/fr.typ` を作り、`l10n/en.typ` と同じキー一式を埋めた `#let strings = (...)` を書きます。
  ラベルと番号の組み合わせ方が英語と違う言語なら、該当キーを plain content ではなく関数 (`n => [...]`) にします。
+ `_supported-locales` に `"fr"` を追加します。
+ その言語が CJK のようにラテン文字だけでは表示できない文字を使うなら、`default-*-font` の CJK テーブルに `fr: (...)` を追加します (ラテン文字だけで足りる言語なら、何もしなくてかまいません)。
+ その言語が `lang` だけでは決まらない script を持つ場合 (例: 中国語の簡体字/繁体字) は、`_locale-for` を拡張して `region` も見るようにします。
  `lang`/`region` だけで一意に決まる普通の言語なら、この手順は不要です。
+ `#show: mytemplate.with(lang: "fr", ...)` で1文書コンパイルして確認します。
  フォールバックの仕組みのおかげで、キーを1つ2つ埋め忘れても英語の訳で表示されるだけで文書全体は壊れません --- ただし、そのままでは未訳のまま公開してしまうことになるので、最終的には全キー埋まっていることを確認しましょう。

新しいロケールを追加する作業が「文字列テーブルを1ファイル足して、一覧に1行追加する」だけで完結し、`t()` 自体やテンプレート本体の `show`/`set` ルールには一切手を入れなくてよい、というのがこの設計のねらいです。

#appendix[
  = 移植チェックリスト

  自分のテンプレートに同じ仕組みを移植する際の要点をまとめます。

  - ロケール解決 (`lang`/`region` → ロケール名) を1つの関数に切り出し、テンプレート本体からはそれ経由でのみ参照します。
  - 文字列は英語の原語に基づいたキーの辞書に集約し、ロケールごとに1ファイルに分けます。
  - ラベル+番号の組み方が言語によって変わりうる項目は、最初から plain content ではなく関数として設計しておきます。
  - ルックアップ関数は `context` の中で `text.lang`/`text.region` を読み、未対応キーはフォールバックロケールに落とします。
  - フォントはロケールで丸ごと差し替えず、「共通の Latin ベース + ロケールごとの追加」という1本のスタックにします。
  - 新しいロケールの追加は「ファイルを1つ足して一覧に登録する」だけで完結させ、ルックアップ関数・テンプレート本体には手を入れずに済む形を保ちます。

  実装の全体は `lib.typ`、文字列テーブルは `l10n/en.typ` / `l10n/ja.typ`、実際に翻訳された見出し・キャプションを含む完成文書の例は `samples/article-{en,ja}.typ` / `samples/report-{en,ja}.typ` を参照してください。
]
