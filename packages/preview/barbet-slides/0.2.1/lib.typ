// lib.typ — 套件入口
//   #import "@preview/barbet-slides:<版本>": *（本機安裝則為 @local）
// 只逐名匯出公開名稱；以 `_` 開頭的內部名稱（如 `_icons`、`_tone`）不匯出。
// typslides 版本只在此檔與 src/deck.typ 釘選；slide、title-slide、focus-slide 等由此轉出。

#import "@preview/typslides:1.4.0": *
#import "src/palette.typ": c
#import "src/icons.typ": ic
#import "src/components.typ": (
  achip, banner, card, case, chip, darr, excerpt, hd, hl, maybe, mute, no, node, note, num-badge, partly, rarr,
  small, src, step, timeline, tl-node, yes,
)
#import "src/deck.typ": deck, hidden-bibliography
