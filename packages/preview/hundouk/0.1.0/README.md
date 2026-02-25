# hundouk

漢文訓読レンダリングツール。

`hundouk` (訓讀) is a [Typst](https://typst.app) package for rendering _Kanbun Kundoku_ (漢文訓読) texts, by which Classical Chinese texts are rendered with annotations to be translated mechanically into Classical Japanese, which is still used in modern Japanese education.

## Usage / 使い方

Detailed usage and documentation can be seen in the released PDF manual in the [Release page](https://github.com/mkpoli/hundouk/releases).

```typst
#import "@preview/hundouk:0.1.0": kanbun

#kanbun(
  "蓋(けだ)シ時ニ有リ[二]古=今[一]，地ニ有リ[二]南=北[一]；字ニ有リ[二]更(かう)=革（かく)[一]，音ニ有リ[二]轉=移[一]，亦タ勢(いきほ)ヒノ所ナリ[二]必ズ至ル[一]。",
  use-unicode-kanbun: true, // Set to false to use normalized CJK characters (e.g. レ) instead of Kanbun Block characters (e.g. ㆑),
  tight: true, // Default to true, tight layout is without inter-character space (ベタ組) and when false (non-tight layout) is with fixed inter-character space (アキ組),
  height: 10em, // For `ttb` writing-direction it's the height limit for point to break line automatically, for `ltr` it's the width
  writing-direction: ttb, // Default to `ttb`, can be `ttb` (縦組) or `ltr` (横組),
)
```

![Rendered usage example](example.png)

## What is hundouk? / 名称由来

`hundouk` comes from the Middle Chinese reconstruction of the character "訓讀" (訓読 Kundoku) written in [TUPA (切韻拼音)](https://phesoca.com/tupa/) .

## References / 参照

- 漢文HTML https://phesoca.com/kanbun-html/
- The `kanbun` package
    - https://github.com/yuanhao-chen-nyoeghau/kanbun
    - https://ctan.org/pkg/kanbun

## Developments / 開発


### フォント / Fonts

以下のコマンドを実行することにより、必要なフォントをダウンロードすることができます。

You can download the required fonts by running the following command:

```
wget -O fonts/PlanschriftP1-Regular.ttf https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Planschrift_Project/releases/download/V0.0.2007-pre/PlanschriftP1-Regular.ttf
wget -O fonts/PlanschriftP2-Regular.ttf https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Planschrift_Project/releases/download/V0.0.2007-pre/PlanschriftP2-Regular.ttf
wget -O fonts/HaranoAjiMincho-Regular.otf https://github.com/trueroad/HaranoAjiFonts/raw/refs/heads/master/HaranoAjiMincho-Regular.otf
wget -O fonts/HaranoAjiMincho-Bold.otf https://github.com/trueroad/HaranoAjiFonts/raw/refs/heads/master/HaranoAjiMincho-Bold.otf
wget -O fonts/HaranoAjiGothic-Regular.otf https://github.com/trueroad/HaranoAjiFonts/raw/refs/heads/master/HaranoAjiGothic-Regular.otf
wget -O fonts/HaranoAjiGothic-Bold.otf https://github.com/trueroad/HaranoAjiFonts/raw/refs/heads/master/HaranoAjiGothic-Bold.otf
```

### ドキュメント / Document

```sh
typst compile docs/doc.typ --font-path fonts --root .
```

### スライド / Slides

```sh
typst compile slides/main.typ --font-path fonts --root .
```

## License / ライセンス

[MIT License](LICENSE) (c) 2025 mkpoli
