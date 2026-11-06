#import "@preview/hanko-kitei:0.1.0": article, regulation

#show: regulation.with(
  title: "○○規程",
  author: "○○株式会社",
  // 既定値からの差分だけを指定します。設定の一覧はパッケージのREADMEを参照してください。
  config: (
    line-spacing: "normal",
    toc-depth: 3,
  ),
)

#include "rules/01-general.typ"
#include "rules/02-procedure.typ"
