# zhconv-typst

zhconv-typst converts Chinese text between Traditional, Simplified and regional variants in typst, utilizing [zhconv-rs](https://github.com/Gowee/zhconv-rs).

## Usage

To use the `zhconv` plugin in your Typst project, import it as follows:

```typst
#import "@preview/zhconv:0.3.1": zhconv
```

### Text Conversion

The primary function provided by this package is `zhconv`, which converts strings or nested contents to a target Chinese variant.

```typst
#zhconv(content, "target-variant", wikitext: false)
```

- `content`: The text or content to be converted.
- `target-variant`: The target Chinese variant (e.g., `"zh-hant"` , `"zh-hans"`, `"zh-cn"`, `"zh-tw"`, `"zh-hk"`).
- `wikitext`: An optional boolean flag to specify if the text should be processed as wikitext (default is `false`).

#### Example

##### Convert a string

```typst
#let text = "互联网"
Original: #text
- #emph([zh-HK]): #zhconv(text, "zh-hk")
- #emph([zh-TW]): #zhconv(text, "zh-tw")
```

##### Convert nested contents

```typst
#zhconv([
柳外輕雷池上雨 \
雨聲滴碎荷聲 \

小樓西角斷虹明 \
闌干倚處 \
待得月華生 \
], "zh-hans")
```
