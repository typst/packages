# Cuti

Cuti (/kjuːti/) is a package that simulates fake bold / fake italic / fake small captials. This package is typically used on fonts that do not have a `bold` weight, such as "SimSun".

## Usage

Please refer to the [Documentation](https://csimide.github.io/cuti-docs/en/).

本 Package 提供中文文档： [中文文档](https://csimide.github.io/cuti-docs/zh-CN/)。

### Getting Started Quickly (For Chinese User)

Please add the following content at the beginning of the document:

```typst
#import "@preview/cuti:0.3.0": show-cn-fakebold
#show: show-cn-fakebold
```

Then, the bolding for SimHei, SimSun, and KaiTi fonts should work correctly.

## Changelog

### `0.3.0`

- feat: Add fake small caps feature by Tetragramm.
- fix: `show-fakebold` may crash on Typst version 0.12.0.

### `0.2.1`

- feat: The stroke of fake bold will use the same color as the text.
- fix: Attempted to fix the issue with the spacing of punctuation in fake italic (#2), but there are still problems.

### `0.2.0`

- feat: Added fake italic functionality.

### `0.1.0`

- Basic fake bold functionality.

## License

MIT License

This package refers to the following content:

- [TeX and Chinese Character Processing: Fake Bold and Fake Italic](https://zhuanlan.zhihu.com/p/19686102)
- Typst issue [#394](https://github.com/typst/typst/issues/394)
- Typst issue [#2749](https://github.com/typst/typst/issues/2749) (The function `_skew` comes from Enivex's code.)

Thanks to Enter-tainer for the assistance.
