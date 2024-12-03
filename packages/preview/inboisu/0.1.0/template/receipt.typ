#import "@preview/inboisu:0.1.0": doc

#set page(margin: (x: 25mm, y: 20mm))
#show: doc.with(
  title: "領収書",
  client: "ねこかわ踊り株式会社　御中",
  client-details: [
    〒765-4321 \
    大阪府ねこ市ねこ町7-8-9 \
    ねこハイツ309号室 \
    TEL 888-888-8888
  ],

  vendor: "根古　猫音",
  vendor-details: [
    〒123-4567 \
    東京都千代田区丸の内1-23-45 \
    にゃんにゃんハイツ209号室 \
    TEL 123-4567-8901
  ],
  vendor-details-below: "変なところにねこがいるにゃ～",
  invoice-details: [
    ねこねこにゃんにゃん \
    らんらんるー \
    吾輩は猫である
  ],
  invoice-number: "NEKO-1234-5678",
  date: datetime.today(),
  due-date: datetime.today(),
  due-date-title: "入金確認日",
  total-title: "合計金額",
  total-box-style: (
    stroke: 0.5pt + gray,
    fill: gray,
  ),
  billing-text: "どうぞよろしくにゃ～",
  billing-text-below: [但し、上記金額正に領収致しました。#v(2em)],
  invoice-properties: (
    猫愛: "高め",
    犬愛: "なし",
  ),
  fonts: (
    title-ja: "Noto Sans CJK JP",
    title-en: "Noto Sans",
    body-ja: "Noto Sans CJK JP",
    body-en: "Noto Sans",
  ),
  transfer-destination: none,
  notes: [
    今後とも何卒よろしくお願いいたしますにゃ～。
  ],
  notes-outside: [
    #v(1em)
    #h(1fr) 発行日時　#datetime.today().display("[year]年[month]月[day]日")

    以上
  ],
  items: (
    (
      name: "ねこまんま",
      price: 290000,
      amount: 23,
    ),
    (
      name: "またたび",
      price: 390000,
      amount: 99,
    ),
  ),
  tax-rate: 10%,
)

