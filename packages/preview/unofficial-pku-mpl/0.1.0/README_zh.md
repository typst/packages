<div align="center">

# pkumpl-typst

### 北京大学近代物理实验 Typst 报告模板

*非官方模板。移植自基于 [`revtex4-2`] 的 [`PKUMpLtX`] (v2.1.6)*

[![Built with Typst](https://img.shields.io/badge/built%20with-Typst-239dad.svg)](https://typst.app/)
[![Supported platforms: macOS, Linux, Windows](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](#)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/license-CC%20BY--SA%204.0-blue.svg)](./LICENSE)

[English](./README.md) | 中文

</div>

## 概述

北京大学《近代物理实验》课程的 Typst 报告模板，由 LaTeX 模板 [`PKUMpLtX`] 移植而来。本项目是独立的非官方 Typst 实现。

## 功能特性

- **对齐 revtex 版式** — 正文 12pt、行距、标题间距与编号均按 `revtex4-2` 的 preprint 样式校准
- **中文排版** — Roman/Sans/Mono 映射到宋体/黑体/仿宋，斜体回退正确；提供 `macos`、`windows`、`noto`、`notofandol`、`fandol` 五套字体预设
- **APS 参考文献** — 通过内置 CSL 文件近似复现 `apsrev4-2`，Typst 原生读取 `.bib`
- **双横线表格** — `ruled-table` 复现 `ruledtabular` 的首尾双横线风格
- **首页标题区** — 一个 `frontmatter(..)` 调用渲染标题/作者/单位/日期/摘要/关键词；摘要按 `mpltx.cls` 的 11pt、400pt 宽度、首行 2em 和约 16.9pt 基线间距实现
- **彩色链接** — 交叉引用、文献引用、URL 按 LaTeX `hyperref` 默认值区分颜色

## 快速开始

**前置依赖：** 已安装 [Typst](https://github.com/typst/typst#installation)。

通过包初始化（发布到 Typst Universe 后）：

```bash
typst init @preview/unofficial-pku-mpl:0.1.0
```

从源码预览完整示例：

```bash
git clone https://github.com/xjsongphy/pkumpl-typst && cd pkumpl-typst
typst compile demo.typ
```

如需实时预览，运行 `typst watch demo.typ`。所有源文件请用 UTF-8 保存。

## Typst 快速入门

如果刚开始使用 Typst，建议先阅读[官方 Typst 教程](https://typst.app/docs/tutorial/)，也可以阅读[中文 Typst 教程](https://typst.dev/docs/tutorial/)。如果希望让 Agent 辅助处理 Typst 文档，可参考 [Claude Typst skill](https://github.com/lucifer1004/claude-skill-typst)。

### 包结构

两个 Typst 文件的职责如下：

- `mplts.typ` 是包入口，包含可复用的版式、字体、编号、图表、参考文献和工具函数实现。
- `template/main.typ` 是初始化后得到的用户文档，导入已发布的包并提供报告正文示例。
- `template/bibli.bib` 与 `template/american-physics-society.csl` 会随初始化复制到用户项目。

### 字体选项

`font={macos|windows|noto|notofandol|fandol}`（默认 `macos`）：

|         | Roman  | Sans Serif | Monospace |
| :-----: | :----: | :--------: | :-------: |
| Upright | 宋体类 |   黑体类   |  仿宋类   |
| Italic  | 仿宋类 |   楷体类   |  楷体类   |

英文字体使用 New Computer Modern。根据 Typst Universe 的要求，本包不捆绑字体；请在本机安装所选预设需要的中文字库：

- `macos`：Songti SC、PingFang SC、STFangsong、Kaiti SC（macOS）
- `windows`：SimSun/STSong、Microsoft YaHei/DengXian、FangSong、KaiTi（Windows）
- `noto`：Noto Serif CJK SC、Noto Sans CJK SC
- `fandol`：FandolSong、FandolHei、FandolFang、FandolKai
- `notofandol`：Noto Serif/Sans CJK SC 与 FandolFang/FandolKai

需要跨平台、可复现的排版时，建议选择 `noto` 或 `fandol`；默认 `macos` 是为了尽量保持上游 LaTeX 模板在 macOS 上的视觉效果。可运行 `typst fonts` 查看当前 Typst 能识别的字体名称。

## 反馈

使用中发现问题或有建议？请到[项目主页](https://github.com/xjsongphy/pkumpl-typst/issues)提 issue。也欢迎提交 PR 改进本模板。

---

## 参考项目

- [`PKUMpLtX`] — 原 LaTeX 模板（基于 revtex4-2），由北京大学近代物理实验课程维护
- [`pkuthss-typst`](https://github.com/pku-typst/pkuthss-typst) — 北京大学学位论文 Typst 模板，可参考其包结构和发布实践
- [`revtex4-2`] — APS revtex 文档类
- [CSL styles](https://github.com/citation-style-language/styles) — APS 参考文献样式来源
- [`fandol`] — Fandol 中文字体

## 版权

+ Copyright (C) 2013–2026. Modern Phys. Lab, School of Phys., Peking Univ.
+ Copyright (C) 2013–2014. Sun Sibai <niasw@pku.edu.cn>
+ Copyright (C) 2013. Cao Chuanwu
+ Copyright (C) 2021–2026. Lin Xuchen <linxc@pku.edu.cn>
+ Copyright (C) 2026. Song Xinjie <xjsongphy@stu.pku.edu.cn>

## 第三方材料与授权

本项目是独立的 Typst 实现，版式和示例材料源自北京大学《近代物理实验》的
LaTeX 模板 [`PKUMpLtX`](https://github.com/CastleStar14654/PKUMpLtX)。移植和改编
的上游材料以 Creative Commons Attribution-ShareAlike 4.0 International 许可证
发布；上游版权声明已保留在上文和 [`LICENSE`] 中。

以下文件源自或复制自上游材料：

- `fig/instruments.png`
- `fig/figsample.pdf`
- `figgen.py`
- `fig.mplstyle`
- `bibli.bib`（为本 Typst 示例补充了部分条目）

APS CSL 文件及其 `template/` 下的副本保留自身的版权和授权信息，使用 Creative
Commons Attribution-ShareAlike 3.0 许可证；它们仍受上游许可证约束，并不因本项目
使用 CC BY-SA 4.0 而被重新授权。

本项目不包含北京大学官方校徽、印章、字体或其他校方品牌资源。

## 许可证

以 [Creative Commons Attribution-ShareAlike 4.0 International](./LICENSE) (CC BY-SA 4.0) 许可发布。

[`mplts.typ`]: ./mplts.typ
[`demo.typ`]: ./demo.typ
[`PKUMpLtX`]: https://github.com/CastleStar14654/PKUMpLtX
[`revtex4-2`]: https://www.ctan.org/pkg/revtex
[`fandol`]: https://www.ctan.org/pkg/fandol
[`image`]: https://typst.app/docs/reference/visualize/image/
