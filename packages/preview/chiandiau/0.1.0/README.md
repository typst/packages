<p align="center">
<img width="640" height="320" alt="logo" src="https://github.com/user-attachments/assets/12d22e0c-ee02-4425-b4d1-d8c95dccf5a2" />
</p>

# chiandiau

**`chiandiau`** ([腔調](https://en.wiktionary.org/wiki/%E8%85%94%E8%AA%BF#Chinese), Chinese _tone of voice_; Shanghainese _model behavior_) is a [Typst](https://github.com/typst/typst) package to generate [Jumpy Pronunciation](https://test.hambaanglaang.hk/) (跳跳紮注音) for any [Chinese variaties](https://en.wikipedia.org/wiki/Varieties_of_Chinese) or any other toned languages using [Chao tone letters](https://en.wikipedia.org/wiki/Tone_letter).

## Quick start

```typ
#import "@preview/chiandiau:0.1.0": *
#wuu-wugniu(
  "新冠防护勿放松，上海市民有腔调",
  "1shin-kuoe 6vaon-wu 6veq8-faon-son 6zaon-he 6zy-min 6yeu 1chian-diau",

  // optional parameters
  pron-font: ..., // custom font (name / list) for pronunciation
  // see below for more
)
```

![](https://github.com/user-attachments/assets/50bcec4c-c0f3-41b7-867e-3aca45999423)

## Examples

… of all available pre-defined writing systems. Check the [repo](https://github.com/OverflowCat/chiandiau) on GitHub for `demo.typ`.

![](https://github.com/user-attachments/assets/5bccb6b6-a94c-4ae3-ae43-abc3cef57182)
![](https://github.com/user-attachments/assets/fdf172e2-3bac-4027-b392-eccbeb050803)
![](https://github.com/user-attachments/assets/8cca2287-b4b4-4266-9fb8-a31a7fad11b1)
![](https://github.com/user-attachments/assets/f6fd050d-e16c-41d8-80cc-1ccbb1d01c42)


## Built-in schemes

- **`cmn`**:
    - [成都話拼音](https://zh.wikipedia.org/wiki/%E5%9B%9B%E5%B7%9D%E8%AF%9D%E6%8B%BC%E9%9F%B3) `cmn-cyuc-sicuan`
    - [四川話通用拼音](https://zhuanlan.zhihu.com/p/34562639) `cmn-xghu-tongyong`
        - `scheme`: `"Guiyang" | "Anshun" | "Liuzhi" | "Xingyi" | "Hanyin" | "Zhenba" | "Shiqian" | "Chengdu" | "Tongren" | "Guanyuan" | "Nanchong" | "Mianyang" | "Wanzhou"`, default `"Chengdu"`
- **`nan`**: [臺灣台語羅馬字](https://en.wikipedia.org/wiki/Taiwanese_Romanization_System) `nan-tailo` (compatible with [Pe̍h-ōe-jī](https://en.wikipedia.org/wiki/Pe%CC%8Dh-%C5%8De-j%C4%AB))
- **`wuu`**: [吳語學堂拼音](https://en.m.wiktionary.org/wiki/Wiktionary:About_Chinese/Wu) `wuu-wugniu`
    - append `\` and tone after a syllable, like `8geh-soh7\55` to make `soh` become `55`
    - `scheme`: see `wuu.typ` on how to pass custom schemes
- **`yue`**: [粤拼](https://en.wikipedia.org/wiki/Jyutping) `yue-jyutping`

Additionally, all schemes accepts `..attrs` that will be passed to `cd()` (see below).

## Advanced usage

### Write a new scheme

```typ
#let cmn-pinyin-scheme = (
  none,
  55,
  35,
  214, // unimplemented; use 14
  53,
)

#let cmn-pinyin(zh, pron, ..attrs) = {
  let pairs = to-pairs(zh, pron)
  cd(
    pairs,
    scheme: to-scheme(cmn-pinyin-scheme),
    ..attrs
  )
}
```

`to-scheme` and `to-pairs` cannot handle those with tone sandhi, so this sample will not deal with morphemes like 不 (bù; 'not') and 一 (yī; 'one'). in Standard Chinese. Use `to-sandhi-pairs` instead.

### Use `cd()`

`cd` accepts either:
- `pairs: (zi: str, pron: str)` + `scheme: (pron: str) => conter`, or
- `pairs: (zi: str, pron: str, conter: int)`.

Here conter means the Chao tone number like $1$, $35$, $42$, etc.

#### Optional parameters

```typ
  dir: direction.btt, // note that zi is before pron
  pron-font: context text.font, // or font name / list
  pron-size: .4em, // of zi font size which is .4em of 2em = .8em
  width: "monospace", // or `auto` or fixed value like `1.2em`
  pron-style: none, // or a function
  debug: false, // show border of boxes
```

## Roadmap

- [ ] 3-digit tone numbers
- [ ] Tone sandhi by character
- [ ] More built-in schemes
- [ ] Backgrounds for tone boxes

### Contributing

Feedback, bugfix, or new scheme support are all welcome!

## Acknowledgement

* [Hambaanglaang Cantonese](https://hambaanglaang.hk/about-us-2/) and [粵典](https://words.hk/base/about/) for Graphical Jyutping.
* [Subaru ad Astra Pø](https://github.com/subaruphoe) (@subaruphoe) for providing and checking Wugniu.
* [Wiktionary wuu-pron data](https://en.wiktionary.org/wiki/Module:wuu-pron/data), CC BY-SA 4.0.
* justfont for [jf open-huninn](https://github.com/justfont/open-huninn-font/), which supports Pe̍h-ōe-jī letters.

## License

The source code is released under the Apache 2.0 License.
