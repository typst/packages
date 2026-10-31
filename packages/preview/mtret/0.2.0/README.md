# MTReT

Modular Typst REport Template for ja students.

日本の大学のレポート等での利用を想定したTypst向けのスタイル．

## 機能

- **シンプルなレポートフォーマット**: 設定項目のないスタイルを提供します．
- **ヘッダー記述の簡略化**: `titles`, `name`, `date-info`関数を用いて必要に応じてタイトルの要素を挿入できます．
- **便利な図表ラッパー**: 素早く余計なことを考えずに図表を挿入できます．
  - `fimg`: 画像を挿入する
  - `fcode`: ソースコードを挿入する．`codly`パッケージを利用
  - `ftext`: 実行結果などを示すテキストブロックを挿入する

## 使い方

テンプレートからプロジェクトを作成できます．

```sh
typst init @preview/mtret
```

または，以下のように`main.typ`ファイルを作成します．

````typ
// パッケージを読み込み
#import "@preview/mtret:0.2.0": *

// 基本スタイルを適用
#show: style

// タイトル関連
#titles(
  "カハンの加算アルゴリズムの実装と考察", // 表題
  subtitle: "数値計算法 第一回レポート" // 副題
)
#name(
  id: "hinshiba", // 学籍番号など
  name: "瀕死", // 氏名
)
// 共著なら組を並べる
// #name((id: "a", name: "甲"), (id: "b", name: "乙"))
#date-info(
  // 課題の出題日 (任意)
  qdate: datetime(year: 2025, month: 10, day: 2)
)

// --- 本文 ---

= 概要

本レポートでは...

= 実装

@code:impl に実装を示す．

#fcode(
  caption: [Pythonによる実装],
  label: <code:impl>
)[
  ```py
  def kahan_add(vals: NDArray[np.float32]) -> np.float32:
      ans = np.float32(0)
      comp: np.float32 = np.float32(0)
      for x in vals:
          x -= comp
          temp: np.float32 = ans + x
          comp = (temp - ans) - x
          ans = temp
      return ans
  ```
]

= 参考文献
// 参考文献の処理...
````

より詳細な使い方は[`example/my_report.typ`](https://github.com/hinshiba/MTReT/blob/v0.2.0/example/my_report.typ)を参照してください．

## 必要なフォント

以下のフォントをインストールしてください．未インストールの場合は，括弧内のフォールバックが使われます．

| 用途                   | フォント                                                                         | フォールバック   |
| ---------------------- | -------------------------------------------------------------------------------- | ---------------- |
| 本文(明朝)             | [原ノ味明朝](https://github.com/trueroad/HaranoAjiFonts) (Harano Aji Mincho)     | なし             |
| 見出し・表題(ゴシック) | [原ノ味ゴシック](https://github.com/trueroad/HaranoAjiFonts) (Harano Aji Gothic) | なし             |
| ソースコード           | [Moralerspace](https://github.com/yuru7/moralerspace) Argon HW                   | DejaVu Sans Mono |

欧文にはTypst同梱のNew Computer Modernを使うため，追加のインストールは不要です．
原ノ味フォントが無いと日本語がTypst同梱のフォントに含まれず，表示されません．

## 図表ラッパー

`fimg`, `fcode`, `ftext`は共通して`caption`, `label`, `placement`を受け付けます．

- `label`は`<code:impl>`のほか`"code:impl"`のような文字列でも指定できます．
- `placement`の既定値は`bottom`です．1ページに収まらない図は`placement`を無視して本文中に置かれ，ページを跨いで分割されます．

### ファイルの指定

パッケージ内で文字列のパスを使うとパッケージを基準に解決されるため，ファイルは`path`で渡します．
`path`は呼び出したファイルを基準に解決されます．

```typ
// 画像の挿入．PDF/UA(--pdf-standard ua-1)ではaltが必須
#fimg(path("img/result.png"), caption: [実行結果], label: <fig:res>, alt: "誤差の推移")

// ファイルからのコード挿入．言語はlangで指定
#fcode(path("src/kahan.py"), lang: "py", caption: [Pythonによる実装])

// ファイルからのテキスト挿入
#ftext(path("out.txt"), caption: [実行結果])
```

`fimg`に文字列を渡すとエラーになります．

## ライセンス

`template`ディレクトリは[MIT-0](https://spdx.org/licenses/MIT-0.html)，それ以外は[MIT](LICENSE)です．
テンプレートから作成したファイルは著作権表示なしで自由に利用・再配布できます．

## 変更履歴

### [Unreleased]

### [0.2.0]

#### Added

- `name`に複数人の組を渡せるように
- `fimg`に代替テキストを指定する`alt`を追加
- `fcode`と`ftext`にファイルのパスを渡せるように
- `fcode`には言語を指定する`lang`を追加
- 図表の`label`に文字列を渡せるように
- 1ページに収まらない図表を`placement`を無視して本文中で分割するように
- 見出しの下に2ptの余白を追加
- パッケージのメタデータに`compiler`と`keywords`を追加
- 必要なフォントをREADMEに明記
- `typst init`で使えるテンプレートを追加

#### Changed

- ソースコードの装飾を`zebraw`から`codly`に変更
- `fimg`の画像はパスの文字列ではなく`path`で渡すように
- 公開APIを`style`, `titles`, `name`, `date-info`, `fimg`, `fcode`, `ftext`に限定
- 図表のキャプションの区切りのコロンの両側に空白を入れるように
- フォントの優先順位を調整し，ソースコードのフォントをMoralerspaceにした
- サブタイトルがないときに表題と名前の間を空けるように
- `readme.md`を`README.md`に改名
- `example`をローカルの`src/lib.typ`から読み込むように

#### Removed

- うまく実現できなかった関数`repl-full-en-punctuation`を削除

#### Fixed

- `remove-cjk-break-space`が効かない問題を修正
- 誤ったフォント名と設定漏れを修正
- `example/my_report.typ`の誤った記述を修正
- READMEでコードブロック内のコードブロックが正しく表示されない問題を修正
- READMEの誤った`date-info`の記述を削除

### [0.1.0] - 2026-08-31

- 図表の後に改段落しない処理の追加
- `fastfig`の`placement`修正

### [0.0.2] - 2026-04-06

`fastfig`機能の追加．

### [0.0.1] - 2025-10-09

初版．

[Unreleased]: https://github.com/hinshiba/MTReT/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/hinshiba/MTReT/releases/tag/v0.2.0
[0.1.0]: https://github.com/hinshiba/MTReT/tree/d1912536d2bbc6304a6bfa0ab257bb38c5edeae8
[0.0.2]: https://github.com/hinshiba/MTReT/tree/eaadc85fd9f4526e655f7fef1b34c980e08ecb64
[0.0.1]: https://github.com/hinshiba/MTReT/tree/80dcd978845048dba2610af5e68cb1f0df3593e9
