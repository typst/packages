# jabiz

This is a template for **business documents in Japanese**.

日本語のビジネス文書テンプレート。

## 使い方

- Typst CLIを使用する方法：Typstをインストールして以下のコマンドを実行。

   ```
   typst init @preview/jabiz
   ```

- Typst Appを使用する方法：Typst Appでアカウントを作成してログイン。`Start from template`からテンプレート名を検索して`Project Title`を記入して`Create`をクリック。

日本語でより詳細な情報をお求めの方は[Zennの記事](https://zenn.dev/kimushun1101/articles/typst-template)をご覧ください。

## 関数

このテンプレートが提供する `jabiz` 関数は、以下の名前付き引数を持ちます。
`none`とするとその項目を削除できます。

### 基本情報

| 引数名 | 型 | 説明 | デフォルト値 |
| --- | --- | --- | --- |
| date | `content`, `string`, or `datetime` | 日付 | datetime.today() |
| to | `content` or `string` | 宛先 | [宛先] |
| from | `content` or `string` | 発信者 | [発信者] |
| title | `content` or `string` | タイトル | [タイトル] |
| tougo | `content` or `string` | 頭語 | [拝啓] |
| ketsugo | `content` or `string` | 結語 | [敬具] |
| kigaki | `content` or `string` | 記書き | none |
| contact | `content` or `string` | 連絡先、担当者など | none |

### フォント

| 引数名 | 型 | 説明 | デフォルト値 |
| --- | --- | --- | --- |
| font-title | `string`, `array`, or `dictionary` | タイトルのフォント。サンセリフ体、ゴシック体などの指定を推奨。 | "Noto Sans CJK JP" |
| font-main | `string`, `array`, or `dictionary` | 本文のフォント。セリフ体、明朝体などの指定を推奨。 | "Noto Serif CJK JP" |
| size-title | `length` | タイトルのフォントサイズ | 18pt |
| size-main | `length` | 本文のフォントサイズ | 10pt |

Notoフォントがインストールされていない場合には、インストールしてください。
Ubuntuなどの場合にはNotoフォントは以下のコマンドでインストールできます。

```
sudo apt install fonts-noto-cjk
```

### 外観

| 引数名 | 型 | 説明 | デフォルト値 |
| --- | --- | --- | --- |
| page-number | `string` | ページ番号のフォーマット | none |

## 呼び出し例

以下のように、showルールで呼び出してください。
引数を省略した場合には、デフォルト値で設定されます。

```typ
#import "@preview/jabiz:0.1.1": jabiz

// この文書特有の関数を定義
// 赤字で警告する
#let warn(it) = text(it, fill: rgb(red), weight: "bold")
// リンクを青文字にする
#show link: set text(fill: blue)

// デフォルト値でよい引数は省略可能
#show: jabiz.with(
  date: [
    2025年6月 10日 初版\
    2025年6月13日 更新
  ],
  to: [株式会社〇〇 \ 営業部　山田 太郎 様],
  from: [
    株式会社△△\
    営業部　佐藤 花子\
    〒000-0000　東京都港区赤坂0-0-0\
    TEL: 03-0000-0000\
  ],
  title: [ビジネス文書テンプレートjabizのご案内],
  tougo: [拝啓],
  ketsugo: [敬具],
  kigaki: [
    1. 開催日時：2025年6月30日（火）14:00～
    2. 開催場所：△△ホール 3階 会議室
    3. 参加方法：#warn[別紙申込用紙にてお申し込みください]
    4. 詳細情報： https://github.com/kimushun1101/typst-jabiz
  ],
  contact: [
    お問い合わせ先:\
    株式会社△△\
    営業部 第1課　鈴木 一郎\
    TEL: 03-0000-0000\
    E-MAIL: suzuki-ichiro\@example.com\
    ],
  // font-title: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  // font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  // size-title: 18pt,
  // size-main: 10pt,
  // page-number: none,  // e.g. "1/1"
)

初夏の候、貴社ますますご清栄のこととお慶び申し上げます。
平素は格別のご高配を賜り、厚く御礼申し上げます。

さて、このたび下記の通り新製品発表会を開催する運びとなりました。
つきましてはご多用の折、誠に恐縮ではございますが、ぜひご出席賜りますようお願い申し上げます。
```
