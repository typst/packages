## こんにちは！

This is a small typst package that creates charts with selected kanji for practicing. Look is based on [@jensechu/kanji](https://github.com/jensechu/kanji).

#### Usage

```typ
#import "@preview/kanjimo:0.1.0": practice, set-font

#set page(margin: (x: 5em, y: 2em))
// Change fonts for info text
#set text(font: ("Shantell Sans", "Kiwi Maru"))

// Optional, change font for kanji preview in table
#set-font(draw: "Kiwi Maru")
// Or, also change fonts for stroke order
#set-font(draw: "Kiwi Maru", strokes: "KanjiStrokeOrders")

// Select kanjis. Spaces will be replaced with blank charts
#practice(kanji: "分日一国人年大")
```

Each selected kanji will look like:

![Kanji meaning, reading, strokes order and table for practicing (分)](docs/typst-screenshot.png)

## Extra requirements

Fonts (can be changed):

- [KanjiStrokeOrders](https://sites.google.com/site/nihilistorguk/)
    - Some distributions, like [Fedora](https://fedoraproject.org/wiki/KanjiStrokeOrders_fonts), packages it
- [Kiwi Maru](https://fonts.google.com/specimen/Kiwi+Maru)

You can also download first font from [fonts](https://github.com/istudyatuni/kanjimo/tree/master/fonts)

## Install package locally

First, you should download [kanjiapi data](https://kanjiapi.dev). Click on "API data download", and place downloaded .zip file to `data` directory. 

For converting you need Python [installed](https://www.python.org):

```py
pip install cbor2
python3 convert.py
```

Or, if you use Nix:

```sh
nix develop '.#python'
python3 convert.py
```

Then run:

```sh
just install
# install fonts for strokes order and for drawings preview
just install-fonts
```
