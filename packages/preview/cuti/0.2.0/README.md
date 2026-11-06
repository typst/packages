# Cuti

Cuti is a package that simulates fake bold / fake italic. This package is typically used on fonts that do not have a `bold` weight, such as "SimSun".

## Usage

Please refer to the [English Demo & Doc](./demo-and-doc/demo-and-doc.pdf) located in the `demo-and-doc` directory for details.

本 Package 提供中文文档： [中文 Demo 与文档](./demo-and-doc/demo-and-doc-cn.pdf)。

### Getting Started Quickly (For Chinese User)

Please add the following content at the beginning of the document:

```typst
#import "@preview/cuti:0.2.0": show-cn-fakebold
#show: show-cn-fakebold
```

Then, the bolding for SimHei, SimSun, and KaiTi fonts should work correctly.

## License

MIT License

This package refers to the following content:

- [TeX and Chinese Character Processing: Fake Bold and Fake Italic](https://zhuanlan.zhihu.com/p/19686102)
- Typst issue [#394](https://github.com/typst/typst/issues/394)
- Typst issue [#2749](https://github.com/typst/typst/issues/2749) (The function `_skew` comes from Enivex's code.)

Thanks to Enter-tainer for the assistance.
