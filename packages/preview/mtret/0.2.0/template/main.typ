#import "@preview/mtret:0.2.0": *

#show: style

#titles("表題", subtitle: "副題")
#name(id: "学籍番号", name: "氏名")

#date-info(qdate: datetime.today())

= 概要

本レポートでは...

= 実装

@code:impl に実装を示す．

#fcode(caption: [実装], label: <code:impl>)[
  ```py
  def add(a: int, b: int) -> int:
      return a + b
  ```
]

= 結果

@txt:res に実行結果を示す．

#ftext(caption: [実行結果], label: <txt:res>)[
  ```txt
  3
  ```
]

= 考察

= 参考文献
