# [text-dirr] (Typst package)

[text-dirr]: https://codeberg.org/Andrew15-5/text-dirr

This package is made to work around https://github.com/typst/typst/issues/6181,
as `text.dir` by default returns `auto` instead of `ltr`/`rtl`. When this issue
will be resolved, there will be no need to use this package.

Note that Typst currently doesn't support (ISO 639) set 2 and 3 language codes:
https://github.com/typst/typst/issues/6182.

## Usage

```typ
#import "@preview/text-dirr:1.0.0": text-dir, rtl-languages

ISO 639 language codes for RTL languages that Typst can detect:
#rtl-languages.map(list.item).join()

#context assert.eq(text-dir(), ltr)

#set text(lang: "ar")
#context assert.eq(text-dir(), rtl)

#set text(dir: ltr)
#context assert.eq(text-dir(), ltr)
```

- `text-dir()` — returns either `ltr` or `rtl` and must be used inside `context`
- `rtl-languages` — array of strings (language codes for RTL languages)

## License

This Typst package is licensed under AGPL-3.0-only license. You can view the
license in the LICENSE file in the root of the project or at
<https://www.gnu.org/licenses/agpl-3.0.txt>.
