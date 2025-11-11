# TnTT: Typst & Tsinghua University Template

<p align="center"><a href="https://nightly.link/chillcicada/tntt/workflows/build/main/thesis.zip"><img alt="Nightly Built PDF" src="https://custom-icon-badges.demolab.com/badge/-Nightly_Built_PDF-C9CBFF?style=for-the-badge&logo=view&logoColor=D9E0EE&labelColor=302D41" /></a></p>

> **TnTT** is **N**ot a **T**ex **T**hesis **T**emplate for **T**singhua university...

简体中文 | [English](#tntt-typst--tsinghua-university-template-1)

## 介绍

TnTT 是 Tntt is Not a Tex Thesis Template for Tsinghua university 的递归缩写。一个基于 [Typst][Typst] 的**非官方**清华大学学位论文模板。

> **目前仅支持本科生的综合论文训练。请使用 Typst 最新版进行编辑。**

## 使用

您可以在 [Typst Web][Typst] 应用程序中使用此模板，方法是单击仪表板上的「**Start from template**」并搜索 `tntt` 来创建项目，或单击 [此处][Quick Start] 来快速创建。

或者，您也可以使用 `typst` 命令行工具来创建一个带有模板的新项目：

```bash
typst init @preview/tntt
```

当然，您也可以在任意 typst 文件中添加如下内容来导入此模板。

```typst
#import "@preview/tntt:0.4.0"
#import tntt: define-config
```

此外，您可以通过克隆本仓库来使用夜间版本：

```bash
git clone https://github.com/chillcicada/tntt.git --depth 1
```

然后修改 `template/thesis.typ` 来编辑您的论文，如在使用中遇到字体渲染问题，请参阅 [导引](#导引) 部分。

## 导引

如果您对 [Typst 语法][Typst Docs] 并不熟悉，请参阅 [中文社区导航][Typst CN] 获得快速指引。推荐使用 [Tinymist][Tinymist] 或 [Typst Webapp][Typst] 来编辑项目。**对于重要的论文及其材料，您应该及时备份并进行版本管理来避免内容丢失。**

在开始编辑之前，请简单阅读如下的字体配置说明：

### 字体配置

本模板主要服务于中文排版，因而内置了常用的中文字族信息，即：

- SongTi: 宋体，正文字体，通常对应西文中的衬线字体
- HeiTi: 黑体，标题字体，通常对应西文中的无衬线字体
- KaiTi: 楷体，用于说明性文本和主观性的表达
- FangSong: 仿宋，通常用于注释、引文及权威性阐述
- Mono: 等宽字体，对于代码，会优先使用此项，推荐中文字体使用黑体或楷体，或者一些流行的中文等宽字体
- Math: 数学字体，中文字体默认使用楷体

对于 win10/11 用户或安装了对应字体的 Linux 用户，相应的字体配置为 `SimSun/NSimSun`、`SimHei`、`KaiTi`、`FangSong`，对于 macOS 用户，建议的字体配置为 `Songti SC`、`Heiti SC`、`Kaiti SC`、`Fangsong SC`，此外，您也可以用 `Source Han Serif`、`Source Han Sans` 等来替代宋体和黑体（**由于目前 Typst 不支持可变字体，请不要使用 Noto 系列字体（如 `Noto Sans CJK SC`）！**）。

本模板内置了对 Win10/11 字体的相关字体配置，相关的字体位于 [release][Release]，Windows 中文系统会默认提供上述字体，下载后可通过指定字体路径来使用，如：

```bash
# 下载字体到当前目录并解压到 fonts 目录
curl -sSLf https://github.com/chillcicada/tntt/releases/latest/download/fonts.zip -o fonts.zip
unzip -q fonts.zip && rm fonts.zip

# 在 typst 编译时中指定字体路径
typst compile thesis.typ --font-path fonts
# 或（对于克隆本仓库的用户）
typst compile template/thesis.typ --root . thesis.pdf --font-path fonts
```

对于使用 VSCode + Tinymist 的用户（更多选项参见 [Tinymist 文档][Tinymist Docs]）：

```jsonc
// .vscode/settings.json
{
  "tinymist.fontPaths": [
    "${workspaceFolder}/fonts"
  ]
}
```

对于使用 webapp 的用户，由于其默认不提供中文字体，需要手动将字体文件上传到 webapp 中，您可以在 [release][Release] 下找到提供的字体包并解压上传到您的项目中，webapp 会自动识别字体文件。

---

对于更多的使用说明和示例，已经内置于 [模板][Template] 中，推荐从模板创建，获得更好的使用体验。

## 预览

![preview][Preview]

## 致谢

非常感谢 [OrangeX4][OrangeX4] 为南京大学学位论文 Typst 模板 [modern-nju-thesis][NJU Thesis] 所做的贡献，本项目移植自由 OrangeX4 及 nju-lug 维护的 modern-nju-thesis 模板，感谢他们所作工作。

移植过程中主要参考了 [清华大学学位论文 Word 模板][THU Word Thesis] 和 [清华大学学位论文 LaTeX 模板][THU LaTeX Thesis]，在此表达感谢。

感谢 [纸夜~~姐姐~~][Myriad-Dreamin] 开发的 [Tinymist][Tinymist] 工具。

## 相关资源

- [清华大学学位论文 Word 模板][THU Word Thesis]
- [清华大学学位论文 LaTeX 模板][THU LaTeX Thesis]

## 许可证

模板源代码采用 [MIT][LICENSE] 许可证分发，您可以自由使用、修改和分发，但不提供任何担保。

> 本项目中包含清华大学校徽与校名的图形文件，用于制作制作本科生综合论文训练封面。这些图形取自 [清华大学视觉形象系统][THU VI System]，项目维护者未进行任何修改。
>
> **请注意：相关图形与文字都是清华大学的注册商标，除此模板外，请勿用于任何其他用途。**

---

# TnTT: Typst & Tsinghua University Template

English | [简体中文](#tntt-typst--tsinghua-university-template)

## Introduction

TnTT is a recursive acronym for "Tntt is Not a Tex Thesis Template for Tsinghua University". An unofficial Tsinghua University thesis template based on [Typst][Typst].

> **Currently, it only supports the Comprehensive Thesis Training for undergraduates. Please use the latest version of Typst for editing.**

## Usage

You can use this template in the [Typst Web][Typst] application by clicking "Start from template" on the dashboard and searching for `tntt` to create a project, or click [here][Quick Start] to quickly start.

Alternatively, you can use the `typst` command-line tool to create a new project with template:

```bash
typst init @preview/tntt
```

Of course, you can also import this template in any Typst file by adding:

```typst
#import "@preview/tntt:0.4.0"
#import tntt: define-config
```

Besides, you can clone this repository to use the nightly version:

```bash
git clone https://github.com/chillcicada/tntt.git --depth 1
```

Then modify `template/thesis.typ` to edit your thesis. If you encounter font rendering issues, please refer to the [Instructions](#instructions) section.

## Instructions

If you are unfamiliar with [Typst Syntax][Typst Docs], please refer to the [Chinese Community Navigation][Typst CN] for quick guidance. It is recommended to use [Tinymist][Tinymist] or the [Typst Webapp][Typst] to edit you project. **For important thesis and its materials, you should promptly back up and implement version control to avoid content loss.**

Before starting your edits, please briefly read the following font configuration instructions:

### Font Configuration

This template primarily serves Chinese typesetting and includes built-in configurations for common Chinese font families:

- **SongTi**: SongTi (serif), the main body font, typically corresponding to Western serif fonts.
- **HeiTi**: HeiTi (sans-serif), used for headings, analogous to Western sans-serif fonts.
- **KaiTi**: KaiTi, used for explanatory text and subjective expressions.
- **FangSong**: FangSong, typically used for annotations, citations, and authoritative explanations.
- **Mono**: Monospace font, prioritized for code. It is recommended to use Hei or Kai typefaces for Chinese characters, or popular Chinese monospace fonts.
- **Math**: Math font, with the default Chinese font set to KaiTi.

For Windows 10/11 users or Linux users with corresponding fonts installed, the font configurations are `SimSun/NSimSun`, `SimHei`, `KaiTi`, and `FangSong`. For macOS users, the configurations are `Songti SC`, `Heiti SC`, `Kaiti SC`, and `Fangsong SC`. Additionally, you may use `Source Han Serif` or `Source Han Sans` as alternatives for Song and Hei typefaces (**Note: Typst currently does not support variable fonts, so please do not use Noto series fonts, `Noto Sans CJK SC` for example!**).

This template includes built-in font configurations for Windows 10/11 systems, and the relevant fonts can be found in the [release][Release]. Windows Chinese systems will typically provide these fonts by default. After downloading, you can specify the font path for Typst, such as:

```bash
# Download the fonts to the current directory and unzip them to the fonts directory
curl -sSLf https://github.com/chillcicada/tntt/releases/latest/download/fonts.zip -o fonts.zip
unzip -q fonts.zip && rm fonts.zip

# Specify the font path for Typst compilation
typst compile thesis.typ --font-path fonts
# Or (for users who cloned this repository)
typst compile template/thesis.typ --root . thesis.pdf --font-path fonts
```

For users of VSCode with Tinymist (see more options in the [Tinymist Documentation][Tinymist Docs]):

```jsonc
// .vscode/settings.json
{
  "tinymist.fontPaths": [
    "${workspaceFolder}/fonts"
  ]
}
```

For users of the Typst webapp, since it does not provide the above fonts by default, you need to manually upload the font files to your project. You can find the provided font package in the [release][Release], extract and upload it to your project. The webapp will automatically recognize the font files.

---

For further usage instructions and examples, please refer to the [template][Template]. It is recommended to start from the template for an improved using experience.

## Preview

![preview][Preview]

## Acknowledgements

Special thanks to [OrangeX4][OrangeX4] for their contributions to the Nanjing University thesis template [modern-nju-thesis][NJU Thesis]. This project is adapted from the modern-nju-thesis template maintained by OrangeX4 and [nju-lug][nju-lug]. We appreciate their work.

During the porting process, we mainly referenced the [Tsinghua University Thesis Word Template][THU Word Thesis] and [Tsinghua University Thesis LaTeX Template][THU LaTeX Thesis]. Our gratitude goes to their contributors.

Thanks to [Myriad-Dreamin][Myriad-Dreamin] for developing the [Tinymist][Tinymist] tool.

## Relevant Resources

- [Tsinghua University Thesis Word Template][THU Word Thesis]
- [Tsinghua University Thesis LaTeX Template][THU LaTeX Thesis]

## License

The template source code is distributed under the [MIT][LICENSE] license. You are free to use, modify, and distribute it without any warranty.

> This project contains the Tsinghua University emblem and name graphics for creating the Comprehensive Thesis Training cover for undergraduates. These graphics are obtained from the [Tsinghua University Visual Identity System][THU VI System] without any modification by the maintainers.
>
> **Please note: The related graphics and text are registered trademarks of Tsinghua University. Except for this template, they should not be used for any other purposes.**

<!-- Markdown Links -->

[Typst]: https://typst.app
[Quick Start]: https://typst.app/app?template=tntt&version=0.4.0
[Typst Docs]: https://typst.app/docs
[Typst CN]: https://typst.dev
[Tinymist]: https://github.com/Myriad-Dreamin/tinymist
[Release]: https://github.com/chillcicada/tntt/releases/
[Tinymist Docs]: https://myriad-dreamin.github.io/tinymist/
[OrangeX4]: https://github.com/OrangeX4
[NJU Thesis]: https://typst.app/universe/package/modern-nju-thesis
[nju-lug]: https://github.com/nju-lug
[THU Word Thesis]: https://github.com/fatalerror-i/ThuWordThesis
[THU LaTeX Thesis]: https://github.com/tuna/thuthesis
[Myriad-Dreamin]: https://github.com/Myriad-Dreamin
[THU VI System]: https://vi.tsinghua.edu.cn/

[Template]: template/thesis.typ
[Preview]: thumbnail.png
[LICENSE]: LICENSE
