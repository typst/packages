# TnTT: Typst & Tsinghua University Template

<p align="center"><a href="https://nightly.link/chillcicada/tntt/workflows/build/main/thesis.zip"><img alt="Nightly Built PDF" src="https://custom-icon-badges.demolab.com/badge/Preview-Nightly_Built_PDF-C9CBFF?style=for-the-badge&logo=view&logoColor=D9E0EE&labelColor=302D41" /></a></p>

> **TnTT** is **N**ot a **T**ex **T**hesis **T**emplate for **T**singhua university...

简体中文 | [English](#Introduction)

## 介绍

TnTT 是“Tntt is Not a Tex Thesis Template for Tsinghua university”的递归缩写，一个基于 [Typst][Typst] 的**非官方**清华大学（THU）综合性论文模板。

> **目前已基本支持所有学位的论文。由于 Typst 尚未稳定，本模板会持续追踪最新发布版本。因此，推荐使用 Typst 的最新版进行编辑，以确保能使用上新的特性并避免兼容性问题。**

**更新说明和迁移指南请参阅[版本发布页][Latest Release]。**

## 使用

您可以在 [Typst Web][Typst] 应用中使用此模板：仪表板上单击「**Start from template**」，搜索 `tntt` 即可创建项目；或直接单击[此处][Quick Start]来快速创建。

您也可以使用 `typst` 命令行工具来创建基于此模板的新项目：

```sh
typst init @preview/tntt
```

当然，您也可以在任意 typst 文件中添加如下内容来导入此模板。

```typ
#import "@preview/tntt:0.5.0"
#import tntt: define-config
```

此外，由于模板更新较为频繁，您也可以通过克隆源仓库代码来使用最新的夜间版本，随后修改 `template/thesis.typ` 开始编辑您的论文。

> 夜间版本并不稳定，建议仅在想要添加功能或修复问题的情况下使用。

如果需要使用此模板进行二次开发，本模板也提供了一些易用的接口：

```typ
#import tntt.exports: *
#import tntt: multi-numbering
```

其中 `exports` 模块导出了除封面外的所有布局和页面组件，而功能性函数则直接导出，您可以在此基础上进行修改和扩展，如实现个性化的 `define-config` 来声明模板配置，案例可参考 [simple-handout-template][simple-handout-template]。

## 导引

如果您对 [Typst 语法][Typst Docs]并不熟悉，可参阅[中文社区导航][Typst CN]快速入门。推荐使用 [Tinymist][Tinymist] 或 [Typst Webapp][Typst] 来编辑项目。**对于论文等重要材料，请务必及时备份并进行版本管理，以防内容丢失。**

在开始编辑之前，如果您对 Typst 字体配置不了解，建议先阅读以下的字体配置说明：

### 字体配置

本模板主要面向中文排版，并依照论文字体规范设置了相应的中文字族信息，即：

- SongTi: 宋体，正文字体，通常对应西文中的衬线字体
- HeiTi: 黑体，标题字体，通常对应西文中的无衬线字体
- KaiTi: 楷体，适用于说明性文本和主观性表述
- FangSong: 仿宋，通常用于注释、引文及权威性阐述
- Mono: 等宽字体，适用于代码。暂不清楚相关规范，默认西文字体为 Typst 内置的 `DejaVu Sans Mono`，建议中文字体选用黑体或楷体，或使用常见的中文等宽字体，默认为 `SimHei`
- Math: 数学字体。暂不清楚相关规范，默认西文字体为 Typst 内置的 `New Computer Modern Math`，中文字体为 `KaiTi`

其中 Songti、KaiTi 和 FangSong 三个字族的默认西文字体为 `Times New Roman`，HeiTi 字族的默认西文字体为 `Arial`。对于 Windows 10/11 用户或安装了相应字体的 Linux 用户，中文字体配置可使用 `NSimSun`、`SimHei`、`KaiTi`、`FangSong`，这与 Word 论文模板中的字体配置完全相同，也是本模板默认的字体配置；对于 MacOS 用户，除了安装上述字体外，建议配置为 `Songti SC`、`Heiti SC`、`Kaiti SC`、`Fangsong SC`。您也可以用 `Source Han Serif`、`Source Han Sans` 等来替代宋体和黑体。**请注意，由于 Typst 目前对可变字体支持有限，不建议使用可变字体（部分平台 Noto 系列字体可能以可变字体形式分发，请自行留意）**。

本模板已内置适用于 Windows 10/11 系统的字体配置，中文版 Windows 系统通常已预装这些字体。Linux 和 MacOS 用户如需严格使用论文要求的字体，可将本地 Windows 对应字体提取、下载并安装到系统中，或在下载后通过指定字体路径来使用，如：

```sh
# 将字体压缩包下载至当前目录，并解压到 fonts 文件夹，仅供参考
curl -sSLf https://github.com/chillcicada/tntt/releases/latest/download/fonts.zip -o fonts.zip
unzip -q fonts.zip && rm fonts.zip

# 在 typst 编译时指定字体路径，假设 thesis.typ 为入口文件
typst compile thesis.typ --font-path fonts
# 或（适用于克隆源代码仓库的用户）
typst compile template/thesis.typ --root . --font-path fonts
# 将 typst 文件视作脚本运行（仅适用于克隆源仓库代码的 UNIX 用户）
# ./template/thesis.typ --root .. --font-path fonts
```

对于使用 VSCode + Tinymist 的用户（其他编辑器及更多设置请参考 [Tinymist 文档][Tinymist Docs]）：

```jsonc
// .vscode/settings.json
{
  "tinymist.fontPaths": [
    "${workspaceFolder}/fonts"
  ]
}
```

对于使用 Typst Web 应用的用户，由于默认未提供所需中文字体，您需要手动将字体文件上传至项目中，webapp 将自动识别字体文件（请勿上传压缩包）。

---

更多使用说明与示例已内置在[模板][Template]中，建议从模板创建项目以获得更好的体验。

## 预览

![preview][Preview]

## 致谢

衷心感谢 [OrangeX4][OrangeX4] 为南京大学学位论文 Typst 模板 [modern-nju-thesis][NJU Thesis] 所做的贡献。本项目移植自由 OrangeX4 及 [nju-lug][nju-lug] 维护的 modern-nju-thesis 模板，感谢他们的出色工作。

在移植过程中，主要参考了[清华大学学位论文 Word 模板][THU Word Thesis]、[清华大学学位论文 LaTeX 模板][ThuThesis]以及教务下发的 Word 和 PDF 模板，在此表达感谢。

感谢[纸夜][Myriad-Dreamin]开发的 [Tinymist][Tinymist] 工具。

## 相关资源

- [清华大学学位论文 Word 模板][THU Word Thesis]（已过时，非常建议使用教务处下发的 Word 模板）
- [清华大学学位论文 LaTeX 模板（ThuThesis）][ThuThesis]

## 许可证

模板源代码采用 [MIT][LICENSE] 许可证分发，您可以自由使用、修改和分发，但不提供任何担保。

> 本项目中包含清华大学校徽与校名的图形文件，用于制作制作本科生综合论文训练封面。这些图形取自[清华大学视觉形象系统][THU VI]，项目维护者未进行任何修改。
>
> **请注意：相关图形与文字都是清华大学的注册商标，除此模板外，请勿用于任何其他用途。**

---

English | [简体中文](#介绍)

## Introduction

TnTT is a recursive acronym for "Tntt is Not a Tex Thesis Template for Tsinghua University", as an **unofficial** Tsinghua University (THU) comprehensive thesis template based on [Typst][Typst].

> **Currently, it basically supports theses for all degrees. Since Typst is not yet stable, this template will continuously track its latest release. Therefore, it is recommended to use the latest released version of Typst for editing to ensure access to new features and avoid compatibility issues.**

**For update notes and migration guides, please refer to the [version release page][Latest Release].**

## Usage

You can use this template in the [Typst Web][Typst] by clicking "Start from template" on the dashboard and searching for `tntt` to create a project, or simply click [here][Quick Start] to get started quickly.

Alternatively, you can use the `typst` command-line tool to create a new project based on this template:

```sh
typst init @preview/tntt
```

Of course, you can also import the template in any Typst file by adding:

```typ
#import "@preview/tntt:0.5.0"
#import tntt: define-config
```

In addition, due to frequency updates, you can clone the source repository to use the latest nightly version, and then modify `template/thesis.typ` to edit your thesis.

> The nightly version is unstable and is recommended if you want to add a feature or resolve an issue.

If you need to use this template for secondary development, this template also provides some easy-to-use interfaces:

```typ
#import tntt.exports: *
#import tntt: multi-numbering
```

The `exports` module exports all layout and page components except the cover, and functional functions are directly exported. You can modify and extend them on this basis, such as implementing a personalized `define-config` to declare template configurations. Refer to [simple-handout-template][simple-handout-template] for an example.

## Instructions

If you are not familiar with [Typst Syntax][Typst Docs], you can refer to [Chinese Community Navigation][Typst CN] for a quick start. It is recommended to use [Tinymist][Tinymist] or [Typst Webapp][Typst] for editing. **For important materials like your thesis, please back up your work regularly and use version control to prevent data loss.**

Before you begin editing, if you have no idea about Typst font configuration, please read the following font configuration notes first:

### Font Configuration

This template is designed primarily for Chinese typesetting and includes corresponding Chinese font families according to thesis typography standards:

- **SongTi**: Serif typeface, used for the main body text.
- **HeiTi**: Sans-serif typeface, used for headings.
- **KaiTi**: Standard Chinese typeface, suitable for explanatory text and subjective expressions.
- **FangSong**: Standard Chinese typeface, typically used for annotations, citations, and authoritative explanations.
- **Mono**: Monospace typeface, used for code. The relevant specifications are not yet clear. The default Western font is Typst's built-in `DejaVu Sans Mono`. For Chinese typeface, Heiti or KaiTi is recommended, or commonly used Chinese monospace font, default to `SimHei`.
- **Math**: Math typeface. The relevant specifications are not yet clear. The default Western font is Typst's built-in `New Computer Modern Math`, with Chinese typeface default to `KaiTi`.

The default Western font for the Songti, KaiTi, and FangSong is `Times New Roman`, and the default Western font for the HeiTi is `Arial`. For Windows 10/11 users or Linux users with corresponding fonts installed, you can use the Chinese font configuration `NSimSun`, `SimHei`, `KaiTi`, and `FangSong`, which matched the Word thesis template exactly. For MacOS users, besides installing the above fonts, the recommended configuration is `Songti SC`, `Heiti SC`, `Kaiti SC`, and `Fangsong SC`. You may also replace `SongTi` and `HeiTi` with fonts such as `Source Han Serif` or `Source Han Sans`. **Please note that currently Typst has limited support variable fonts, it's recommended not to use variable fonts (Some platforms may distribute the Noto font series in variable font format, please pay attention to this yourself)**.

This template includes built-in font configuration for Windows 10/11 systems, Chinese‑language Windows systems usually come with these fonts preinstalled. Linux and MacOS users who need to strictly adhere the required thesis fonts canYou can extract, download, and install the corresponding local Windows font to the system, or use it after downloading by specifying the font path, for example:

```sh
# Download the fonts zip to the current directory and extract it to the fonts folder, for reference only
curl -sSLf https://github.com/chillcicada/tntt/releases/latest/download/fonts.zip -o fonts.zip
unzip -q fonts.zip && rm fonts.zip

# Specify the font path when compiling, assuming thesis.typ is the entry file
typst compile thesis.typ --font-path fonts
# Or (for users who cloned the source repository)
typst compile template/thesis.typ --root . --font-path fonts
# Run typst file as script (for UNIX users who cloned the source repository only)
# ./template/thesis.typ --root .. --font-path fonts
```

For users of VSCode with Tinymist (other editors and more options are documented in the [Tinymist Documentation][Tinymist Docs]):

```jsonc
// .vscode/settings.json
{
  "tinymist.fontPaths": [
    "${workspaceFolder}/fonts"
  ]
}
```

For users of the Typst Webapp, since the required Chinese fonts are not provided by default, you need to manually upload the font files to your project. The webapp will automatically recognize the font files (please do not upload compressed files).

---

Further instructions and examples are included in the [template][Template]. Starting a project from the template is recommended for a better experience.

## Preview

![preview][Preview]

## Credits

Special thanks to [OrangeX4][OrangeX4] for their contributions to the Nanjing University thesis template [modern-nju-thesis][NJU Thesis]. This project is adapted from the modern-nju-thesis template maintained by OrangeX4 and [nju-lug][nju-lug]. We greatly appreciate their work.

During the adaptation process, we mainly referred the [Tsinghua University Thesis Word Template][THU Word Thesis], [Tsinghua University Thesis LaTeX Template][ThuThesis], and Word & PDF templates issued by the Academic Affairs Office. Our gratitude goes to them and their contributors.

Thanks to [Myriad-Dreamin][Myriad-Dreamin] for developing the [Tinymist][Tinymist] tool.

## Relevant Resources

- [Tsinghua University Thesis Word Template][THU Word Thesis] (Marked as Outdated, it is highly recommended to use the Word template issued by the Academic Affairs Office)
- [Tsinghua University Thesis LaTeX Template (ThuThesis)][ThuThesis]

## License

The template source code is distributed under the [MIT][LICENSE] license. You are free to use, modify, and distribute it without any warranty.

> This project contains the Tsinghua University emblem and name graphics for creating the Comprehensive Thesis Training cover for undergraduates. These graphics are obtained from the [Tsinghua University Visual Identity System][THU VI] without any modification by the maintainers.
>
> **Please note that the related graphics and text are registered trademarks of Tsinghua University. Except for this template, they must not be used for any other purpose.**

<!-- Markdown Links -->

[Typst]: https://typst.app
[Quick Start]: https://typst.app/app?template=tntt&version=0.5.0
[Typst Docs]: https://typst.app/docs
[Typst CN]: https://typst.dev
[simple-handout-template]: https://github.com/chillcicada/simple-handout-template
[Tinymist]: https://github.com/Myriad-Dreamin/tinymist
[Tinymist Docs]: https://myriad-dreamin.github.io/tinymist/
[OrangeX4]: https://github.com/OrangeX4
[NJU Thesis]: https://typst.app/universe/package/modern-nju-thesis
[nju-lug]: https://github.com/nju-lug
[THU Word Thesis]: https://github.com/fatalerror-i/ThuWordThesis
[ThuThesis]: https://github.com/tuna/thuthesis
[Myriad-Dreamin]: https://github.com/Myriad-Dreamin
[THU VI]: https://vi.tsinghua.edu.cn/
[Latest Release]: https://github.com/chillcicada/tntt/releases/latest

[Template]: template/thesis.typ
[Preview]: thumbnail.png
[LICENSE]: LICENSE
