// MIT No Attribution
// Copyright 2025 Shunsuke Kimura

#import "@preview/jabiz:0.1.2": jabiz
// #import "../lib.typ": jabiz  // for development

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
  // 位置は右のまま文字のみを左寄せしたい場合にはboxで記述
  from: box(align(left,
    [
      株式会社△△\
      営業部　佐藤 花子\
      〒000-0000　東京都港区赤坂0-0-0\
      TEL: 03-0000-0000
    ]
  )),
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
