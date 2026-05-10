# 情報処理学会テンプレート (IPSJ Typst Templates)

情報処理学会（Information Processing Society of Japan, IPSJ）で利用される各種文書のための Typst テンプレート集です。現時点では **研究報告（Technical Report）** のみをサポートしています。今後、論文誌・全国大会など他の文書形式への対応も予定しています。

## ⚠️ プレビュー段階のテンプレートです

動作はしますが、組版細部や検証は十分ではありません。**学会への正式な提出には[公式テンプレート](https://www.ipsj.or.jp/journal/submit/style.html)を必ずご利用ください。** 本テンプレートは下書き・プレビュー用途に留めることを強く推奨します。

## サポート状況

| ドキュメント種別 | 状態 | 備考 |
|---|---|---|
| 研究報告（Technical Report） | ✅ プレビュー | 本リポジトリで提供 |
| 論文誌・全国大会・その他 | ⏳ 未対応 | 今後対応予定 |

## 注意事項

* 本テンプレートは **非公式** であり、情報処理学会と一切関係ありません。
* 開発中につき、仕様・出力は予告なく変更される可能性があります。
* 学会から承認されたものではないため、利用は自己責任となります。本テンプレートを利用したことによる一切の損害について責任を負いません。
* 正式な提出時は必ず[公式テンプレート](https://www.ipsj.or.jp/journal/submit/style.html)で再組版・確認してください。

## クイックスタート

新しい原稿ディレクトリを作成（Typst Universe にて公開後）:

```bash
typst init @preview/joho-ipsj:0.1.0 my-report
cd my-report
typst compile main.typ
```

## 基本的な使い方

`techrep` を `#show` ルールで適用するだけで、研究報告のレイアウト・書式が自動で組まれます。

```typst
#import "@preview/joho-ipsj:0.1.0": techrep, acknowledgement, fake-bibliography

#show: techrep.with(
  title: [Typstによる情報処理研究報告の作成法],
  title-en: "How to write IPSJ SIG Technical Report with Typst",
  affiliations: (
    "IPSJ": [情報処理学会 \ IPSJ, Chiyoda, Tokyo 101–0062, Japan],
  ),
  authors: (
    (
      name: "情報 太郎",
      name-en: "Taro Joho",
      affiliations: ("IPSJ",),
      email: "joho.taro@ipsj.or.jp",
    ),
  ),
  abstract: [本稿では，情報処理学会研究報告のスタイルを Typst で再現するテンプレートを示す．],
  abstract-en: [This paper presents a Typst template ...],
  keywords: ("情報処理学会", "研究報告", "Typst"),
  keywords-en: ("IPSJ", "Technical Report", "Typst"),
  bibliography: bibliography("refs.yml", title: "参考文献"),
)

= はじめに

本文をここに書きます．

= おわりに

#acknowledgement[本研究は ... の支援を受けた．]
```

`typst init` で生成された `main.typ` には上記と同等の雛形が含まれています。`refs.yml` を参考文献として編集してください。

### `techrep` の主な引数

| 引数 | 型 | 説明 |
|---|---|---|
| `title` | content | 和文タイトル |
| `title-en` | string \| content | 英文タイトル |
| `affiliations` | dictionary | 所属（キー → 表示名） |
| `paffiliations` | dictionary | 現所属 |
| `authors` | array of dict | 著者情報（`name` / `name-en` / `affiliations` / `email`） |
| `abstract` | content | 和文概要 |
| `abstract-en` | content | 英文概要 |
| `keywords` | array | 和文キーワード |
| `keywords-en` | array | 英文キーワード |
| `volume` / `number` | string / int | 巻号 |
| `date` | datetime \| auto | 発行日（既定 `auto` で本日） |
| `bibliography` | content | 参考文献ブロック |
| `appendix` | content | 付録 |
| `fonts` | dictionary | 和文／欧文フォントの上書き |

引数の詳細やデフォルト値は [`lib.typ`](./lib.typ) のドキュメントコメントを参照してください。

### その他の公開関数

* `acknowledgement(body)` — 「謝辞」セクションを組む
* `fake-bibliography(yaml-data, show-unused: false)` — 参考文献の見た目だけを組む補助関数
* `table(..)` — IPSJ 風の罫線・スタイルを当てた表

## 開発・ローカルインストール（Tyler）

本リポジトリは [Tyler](https://github.com/mkpoli/tyler) で管理されています。手元で改変したテンプレートを試す場合は、Universe ではなくローカルパッケージとしてインストールできます。

### 1. Tyler を導入

```bash
bun i -g @mkpoli/tyler
# または
npm install -g @mkpoli/tyler
```

### 2. ローカルにビルド & インストール

リポジトリのルートで:

```bash
tyler build -i
```

これでビルド成果物が `@local/joho-ipsj:0.1.0` としてローカル Typst パッケージに登録され、`typst init @local/joho-ipsj:0.1.0 my-report` で利用できます。

## 参照用ファイル

* [情報処理学会研究報告テンプレート](https://www.ipsj.or.jp/journal/submit/style.html)
* [研究報告原稿（PDFファイル）作成について](https://www.ipsj.or.jp/kenkyukai/genko.html)
* [ken1row/IPSJ-techrep-xelatex](https://github.com/ken1row/IPSJ-techrep-xelatex/)
