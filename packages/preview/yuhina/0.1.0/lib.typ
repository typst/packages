// lib.typ
// yuhina: a shared typesetting base for zh-Hant-TW docs
//
// 本檔只決定公開名稱，實作位於 src/。以 `#import "@preview/yuhina:0.1.0": *`
// 匯入時，使用者只會取得下列名稱；src/ 內的其他名稱為內部實作，可隨時更動。
// 增加公開名稱屬向前相容；移除或修改公開名稱及其參數則為破壞性變更。

// 字型清單
#import "src/fonts.typ": font-fsong, font-hei, font-kai, font-song, font-yuan

// 行內樣式
#import "src/inline.typ": inquote, keyword

// 作者與標題區塊
#import "src/title.typ": normalize-authors, title-block

// 排版規則：可個別套用，或以 common-style 全部套用
#import "src/styles.typ": (
  common-style,
  document-style,
  figure-style,
  footnote-style,
  heading-style,
  list-style,
  page-style,
  par-style,
  plain-links,
  quote-style,
  ref-style,
  text-style,
)
