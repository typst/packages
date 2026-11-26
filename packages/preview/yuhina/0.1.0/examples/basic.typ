// yuhina 的最小完整範例
// 編譯：typst compile examples/basic.typ --input USE_WIN=1（Windows）
//       typst compile examples/basic.typ --input USE_LINUX=1（Linux）
#import "@preview/yuhina:0.1.0": *

// 注意：中文句子請勿在原始碼中換行，否則 Typst 會在換行處插入空白。

#show: common-style.with(
  title: "論比例原則之審查密度",
  authors: ((name: "王小明", thanks: [國立臺灣大學法律學研究所碩士生。]),),
)

#title-block(
  "論比例原則之審查密度",
  subtitle: "以釋字第 584 號解釋為例",
  authors: normalize-authors((name: "王小明", thanks: [國立臺灣大學法律學研究所碩士生。])),
)

= 緒論 <intro>

本文討論比例原則#footnote[比例原則包含適當性、必要性與衡平性三個子原則。]之審查密度，並於@density[見]說明不同審查標準的差異。#keyword[審查密度]的選擇，往往決定違憲審查的結果。

= 比例原則之內涵

== 三個子原則

=== 適當性

手段須有助於目的之達成。

=== 必要性 <necessity>

在相同有效的手段中，應選擇侵害最小者。

=== 衡平性

手段所造成的損害，不得與欲達成目的之利益顯失均衡。

== 審查密度 <density>

學說上常區分寬鬆、中度與嚴格三種審查基準：

+ 寬鬆審查
+ 中度審查
  + 目的須為重要公益
  + 手段與目的間須有實質關聯
+ 嚴格審查

解釋文開宗明義指出：#inquote[人民之工作權為憲法第十五條規定所保障]。

#quote(block: true)[
  人民之工作權為憲法第十五條規定所保障，其內涵包括人民選擇職業之自由。
]

= 結論

// @label 之後緊接中文時，請改用 #ref(<label>)，以免 Typst 把後面的中文當成標籤的一部分。
適當性與#ref(<necessity>)的審查，均應依#ref(<density>)所述之基準調整其密度（參照@intro）。
