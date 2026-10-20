#import "@preview/hadronic-rirekisho:0.1.0": *

#show: 履歴書設定.with(
  paper: "a4",
  margin: 1.5cm,
  date_style: "和暦", // or "西暦"
  // Default fonts assume Harano Aji (bundled with TeX Live) and DejaVu Sans Mono.
  // On typst.app, upload your own font files to the project root, then override
  // font / sans_font / mono_font below. See the package README for details.
)

#基本情報(
  姓: "山田", 名: "太郎",
  姓読み: "やまだ", 名読み: "たろう",
  生年月日: "平成2年1月1日",
  年齢: 36,
  現住所: (
    郵便番号: "100-0001",
    住所: "東京都 千代田区 千代田 1番1号",
    ふりがな: "とうきょうと ちよだく ちよだ",
    電話: "090-0000-0000",
    メール: "taro.yamada@example.com",
  ),
  連絡先: "同上",
  写真: none, // image("photo.jpg") で証明写真を挿入
)

#学歴職歴(
  学歴: (
    (年: "平成21", 月: "4", 内容: "○○大学 △△学部 入学"),
    (年: "平成25", 月: "3", 内容: "○○大学 △△学部 卒業"),
  ),
  職歴: (
    (年: "平成25", 月: "4", 内容: "株式会社○○ 入社"),
    (年: "",       月: "",  内容: [以上#h(8em)], align: end),
  ),
)

#資格欄(
  資格: (
    (年: "平成24", 月: "11", 内容: "普通自動車第一種運転免許 取得"),
  ),
)

#志望動機(height: 5cm)[
  貴社の事業内容に強く興味を持ち、これまでの経験を活かして貢献したいと考え志望しました。
]

#本人希望(height: 2.5cm)[
  貴社の規程に従います。
]

#署名欄(signature: none) // image("signature.png", height: 1.0cm) で署名を挿入
