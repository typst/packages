#import "@preview/rirekisho-ofa:0.1.0": rirekisho

#let data = (
  document-date: "YYYY年MM月DD日現在",
  name-kana: "シメイ（フリガナ）",
  name: "氏名",
  birth-date: "YYYY年MM月DD日（満XX歳）",
  address: "都道府県・市区町村・番地",
  phone: "電話番号",
  history: (
    (year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),
    (year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),
    (year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),
    (year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),
    (year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),
  ),
  qualifications: (
    (year: "YYYY", month: "MM", detail: "免許・資格"),
    (year: "YYYY", month: "MM", detail: "免許・資格"),
    (year: "YYYY", month: "MM", detail: "免許・資格"),
  ),
  motivation: "応募先に合わせて、志望動機・アピールポイントを記入します。",
  preferences: "希望条件がある場合のみ記入します。",
)

#rirekisho(data)
