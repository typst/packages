# MTReT

Modular Typst REport Template for ja students.

日本の大学のレポート等での利用を想定したTypst向けのスタイル．

## 機能

- **シンプルなレポートフォーマット**: 設定項目のないスタイルを提供します．
- **ヘッダー記述の簡略化**: `titles`, `name`, `date_info`関数を用いて必要に応じてタイトルの要素を挿入できます．
- **便利な図表ラッパー**: 素早く余計なことを考えずに図表を挿入できます．
  - `fimg`: 画像を挿入する
  - `fcode`: ソースコードを挿入する．`zebraw`パッケージを利用
  - `ftext`: 実行結果などを示すテキストブロックを挿入する
- **句読点のカスタマイズ**: 和文句読点「、」「。」を全角の「，」「．」に置換します．

## 使い方

以下のように`main.typ`ファイルを作成します．

```typ
// パッケージを読み込み
#import "@preview/mtret:0.1.0": *

// 基本スタイルを適用
#show: style

// タイトル関連
#titles(
  "カハンの加算アルゴリズムの実装と考察", // 表題
  subtitle: "数値計算法 第一回レポート" // 副題
)
#name(
  id: "hinshiba", // 学籍番号など
  "瀕死" // 氏名
)
#date_info(
  // 課題の出題日 (任意)
  qdate: datetime(year: 2025, month: 10, day: 2)
)

// --- 本文 ---

= 概要

本レポートでは...

= 実装

@code:impl に実装を示す．

#fcode(
  caption: [Pythonによる実装],
  label: <code:impl>
)[
  \`\`\`py
  def kahan_add(vals: NDArray[np.float32]) -> np.float32:
      ans = np.float32(0)
      comp: np.float32 = np.float32(0)
      for x in vals:
          x -= comp
          temp: np.float32 = ans + x
          comp = (temp - ans) - x
          ans = temp
      return ans
  \`\`\`
]

= 参考文献
// 参考文献の処理...
```

より詳細な使い方は`example/my_report.typ`を参照してください．

## 変更履歴

- 0.0.1: 初版．
- 0.0.2: `fastfig`機能の追加．
- 0.1.0: 図表の後に改段落しない処理の追加．`fastfig`の`placement`修正．
