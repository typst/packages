# roremu

日本語のダミーテキスト（Lipsum）生成ツール。

Blind text (Lorem ipsum) generator for Japanese.

## 用法 / Usage

```typst
#import "@preview/roremu:0.1.0": roremu

#roremu(8) # 吾輩は猫である。

#roremu(8, offset: 8) #名前はまだ無い。

#roremu(17, custom-text: "私はその人を常に先生と呼んでいた。")
```

## テキスト / Text Source 

夏目漱石『[吾輩は猫である](https://ja.wikipedia.org/wiki/%E5%90%BE%E8%BC%A9%E3%81%AF%E7%8C%AB%E3%81%A7%E3%81%82%E3%82%8B)』（[青空文庫版](https://www.aozora.gr.jp/cards/000148/card789.html)より抜粋、ルビ抜き）

## 名称由来 / Why “roremu”?
lorem「ロレム」のローマ字表記。

“roremu” is the romanization of ロレム (lorem).

## ライセンス / License

Unlicense
