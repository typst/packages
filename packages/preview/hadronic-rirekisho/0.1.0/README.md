# typst-hadronic-rirekisho

[Typst](https://typst.app/) で書く日本語履歴書テンプレートです。[Typst Universe](https://typst.app/universe/) パッケージとして配布予定です（`@preview/hadronic-rirekisho`）。

## インストール・使い方

新規プロジェクトをテンプレートから作成します:

```sh
typst init @preview/hadronic-rirekisho:0.1.0
```

または既存プロジェクトから直接インポートします:

```typst
#import "@preview/hadronic-rirekisho:0.1.0": *
```

記入例（湯川秀樹）のソースと出力は [`example/example.typ`](example/example.typ) と [`example/example.pdf`](example/example.pdf) にあります。

---

## 設定（`履歴書設定`）

フォントや文字サイズなどの定数はすべて `履歴書設定` で一括指定でき、各ブロックに反映されます。

```typst
#show: 履歴書設定.with(
  margin: 2.0cm,
  date: datetime(year: 1950, month: 3, day: 1),
  date_style: "和暦",
)
```

| パラメータ    | 型         | デフォルト             | 説明                                     |
|---------------|------------|------------------------|------------------------------------------|
| `lang`        | `str`      | `"ja"`                 | 文書言語（禁則処理・グリフ選択に影響）  |
| `paper`       | `str`      | `"a4"`                 | 用紙サイズ                               |
| `margin`      | `length`   | `1.5cm`                | ページ余白                               |
| `font`        | `array`    | 明朝体 (`font-serif`)   | 本文フォント                             |
| `sans_font`   | `array`    | ゴシック体 (`font-san`) | 見出し用フォント                         |
| `mono_font`   | `array`    | 等幅 (`font-mono`)      | 郵便番号・電話・メール用フォント         |
| `system_size` | `length`   | `8pt`                  | ラベル・枠見出しの文字サイズ             |
| `name_size`   | `length`   | `16pt`                 | 氏名の文字サイズ                         |
| `input_size`  | `length`   | `10pt`                 | 記入値の文字サイズ                       |
| `base_size`   | `length`   | `system_size`          | 本文の基本文字サイズ                     |
| `date`        | `datetime` | 今日                   | 履歴書の作成日                           |
| `date_style`  | `str`      | `"和暦"`               | 日付表示形式（`"和暦"` または `"西暦"`） |

---

## ブロック

### `#基本情報(...)`

氏名・生年月日・住所・写真を出力します。

```typst
#基本情報(
  姓: "山田", 名: "太郎",
  姓読み: "やまだ", 名読み: "たろう",
  生年月日: "昭和50年1月1日",
  年齢: 50,
  現住所: (
    郵便番号: "100-0001",
    住所: "東京都 千代田区 千代田 1番1号",
    ふりがな: "とうきょうと ちよだく ちよだ",
    電話: "090-0000-0000",
    メール: "taro@example.com",
  ),
  連絡先: "同上",  // または現住所と同じ形式の辞書
  写真: image("photo.jpg"),  // none で空欄
)
```

### `#学歴職歴(学歴: (...), 職歴: (...))`

学歴と職歴を一つのテーブルに出力します。

```typst
#学歴職歴(
  学歴: (
    (年: "平成10", 月: "4", 内容: "○○大学 △△学部 入学"),
    (年: "平成14", 月: "3", 内容: "○○大学 △△学部 卒業"),
  ),
  職歴: (
    (年: "平成14", 月: "4", 内容: "株式会社○○ 入社"),
    (年: "",       月: "",  内容: [以上#h(8em)], align: end),
  ),
)
```

### `#資格欄(資格: (...))`

免許・資格を出力します。エントリー形式は学歴職歴と同じです。

### `#志望動機(height: 5cm)[...]`

志望動機欄を出力します。`height` で欄の高さを指定します。

### `#本人希望(height: 5cm)[...]`

本人希望欄を出力します。`height` で欄の高さを指定します。

### `#賞罰(エントリー: (...))`

賞罰欄を出力します。エントリー形式は学歴職歴と同じです。

### `#署名欄(signature: none)`

署名欄を出力します。`signature` に画像を渡すと署名として表示します。

```typst
#署名欄(signature: image("signature.png", height: 1.0cm))
```

---

## ユーティリティ

テンプレートには以下の関数が含まれており、本文中でも使用できます。

| 関数 | 説明 |
|---|---|
| `和暦date(d)` | `datetime` → 和暦文字列（明治〜令和、それ以前は西暦） |
| `西暦date(d)` | `datetime` → 西暦文字列 |
| `日付(d)` | `date_style` 設定に従いどちらかで表示 |
| `kintou(width, s)` | 文字列 `s` を幅 `width` に均等割付（例: `kintou(4em, "氏名")`） |

```typst
// 和暦モード（デフォルト）
#日付(datetime(year: 1949, month: 10, day: 3))
// → 昭和24年10月3日

// 西暦モード（履歴書設定で date_style: "西暦" を指定した場合）
// → 1949年10月3日
```

---

## フォントについて

デフォルトフォントは [okumuralab/typst-js](https://github.com/okumuralab/typst-js) にならい、役割ごとに 1 書体を指定しています。

| 用途               | フォント                                        |
|--------------------|-------------------------------------------------|
| 本文（明朝）       | 欧文: New Computer Modern、和文: 原ノ味明朝     |
| 見出し（ゴシック） | 原ノ味角ゴシック                                |
| 等幅               | DejaVu Sans Mono                                |

New Computer Modern と DejaVu Sans Mono は Typst 本体に同梱されています。原ノ味フォントは TeX Live に同梱されているので、Typst が見つけられない場合はフォント検索パスに加えてください:

```sh
export TYPST_FONT_PATHS=/usr/local/texlive/2026/texmf-dist/fonts/opentype
```

TeX Live がない場合は [原ノ味フォントを直接インストール](https://github.com/trueroad/HaranoAjiFonts)するか、`履歴書設定` の `font`・`sans_font`・`mono_font` パラメータで手元のフォント（ヒラギノ、游書体、Noto など）を指定してください。

```typst
#show: 履歴書設定.with(
  font: ((name: "New Computer Modern", covers: latin-covers), "Hiragino Mincho ProN"),
  sans_font: "Hiragino Kaku Gothic ProN",
)
```

[typst.app](https://typst.app/) 上で使う場合、原ノ味フォントはシステムに存在しないため、フォントファイルをプロジェクトのルートにアップロードすると自動的に認識されます。

本文フォントのように `(欧文フォント, 和文フォント)` を組にする場合は、上の例のように `covers` で欧文の受け持ち範囲を指定します（`latin-covers` はテンプレートが公開している定数です）。

---

## 謝辞

このテンプレートは以下のプロジェクトを参考にして作成しました。

- [Nikudanngo/typst-ja-resume-template](https://github.com/Nikudanngo/typst-ja-resume-template)
- [okumuralab/typst-js](https://github.com/okumuralab/typst-js) — 和欧混植（`covers`）、均等割付（`kintou`）、和文組版の設定

---

## 記入例の画像について

`example/photo.jpg` と `example/signature.png` は Wikimedia Commons の [File:Yukawa.jpg](https://commons.wikimedia.org/wiki/File:Yukawa.jpg)（PD Sweden）と [File:Hideki Yukawa signature.jpg](https://commons.wikimedia.org/wiki/File:Hideki_Yukawa_signature.jpg)（PD ineligible）に基づくパブリックドメイン画像です。

---

## ライセンス

[MIT No Attribution](LICENSE) です。記入済みの履歴書を配布・提出する際にライセンス表記を残す必要はありません。

---

## ファイル構成

```text
typst-hadronic-rirekisho/
├── typst.toml         # パッケージマニフェスト
├── rirekisho.typ      # テンプレート本体（パッケージのエントリーポイント）
├── LICENSE
├── thumbnail.png      # Typst Universe 掲載用サムネイル
├── template/
│   └── main.typ       # `typst init` で複製される記入例
└── example/
    ├── example.typ    # 記入例（湯川秀樹）
    ├── example.pdf    # 記入例の出力
    ├── photo.jpg      # 証明写真（各自用意）
    └── signature.png  # 署名画像（各自用意）
```
