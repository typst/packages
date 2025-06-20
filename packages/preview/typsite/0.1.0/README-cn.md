# Typsite
[ [English](./README.md) | **中文** ]

<div style="text-align: center;">
<img src="https://typ.rowlib.com/icon.png" width="37.5%"/>
</div>

## 1. 项目介绍

[Typsite](https://github.com/Glomzzz/typsite) 是一个使用纯 `Typst` 进行内容创作的静态网站生成器（SSG）。它处理这些 `Typst` 文件来生成完整的静态网站。

这个 typst 包是 typsite 的标准库，提供了以下功能：
- Typsite 的重写功能、MetaContent、MetaOption、MetaGraph 支持
- HTML 绑定函数
- Typst 数学公式 -> MathML 转换
- 自动调整尺寸的内联元素（修复 typst svg 的 viewBox 问题）

## 2. 安装方法

1. 使用 `import "@preview/typsite:0.1.0"`
2. 安装 [typsite](https://github.com/Glomzzz/typsite) 二进制文件，推荐使用 [typsite-template](https://github.com/Glomzzz/typsite-template)
3. 开始你的 typst 静态网站之旅吧！


## 致谢
- [Myriad-Dreamin](https://github.com/Myriad-Dreamin) ：[typ](https://github.com/Myriad-Dreamin/typ)
- [mathyml](https://codeberg.org/akida/mathyml/)
