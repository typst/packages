Unshrink full-width punctuation marks. And optionally 汉字, ひらがな, カタカナ, and 한글.

Demo: [demo.pdf](https://github.com/neruthes/typstpkg-cjk-unshrink/blob/master/_bincache/0.1.0/demo.pdf).


## Basic Usage

```typ
#show: cjk-unshrink
```


## Customization

Add options using `#show: cjk-unshrink.with()`.

- `debug` (bool): Determines whether to show hinting strokes.
- `aggregate-punctuation` (bool): Determines whether to group matched full-width punctuation marks with the leading non-punctuation character, if any, into a box.
- `alignment-table` (dictionary): A dictionary that specifies in-box alignment from character literal value. The default behavior is to center everything except `，。：；？！`.
- `plain-汉字` (bool): Determines whether to put every `\p{Han}` inside a 1em-wide box.
- `plain-ひらがな` (bool): Determines whether to put every `\p{Hiragana}` inside a 1em-wide box.
- `plain-カタカナ` (bool): Determines whether to put every `\p{Katakana}` inside a 1em-wide box.
- `plain-한글` (bool): Determines whether to put every `\p{Hangul}` inside a 1em-wide box.


## Notes

### Should I enable aggregate-punctuation?
The default value is `false` for best multi-script documents.
But if the document is purely in 汉字, ひらがな, and カタカナ, setting it to `true` will produce better line edge avoidance.
