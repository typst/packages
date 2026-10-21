// exam-zh-next API 对照手册。章节编号与 exam-zh 的完整文档 exam-zh-doc 相同：
// 每个 LaTeX 命令、环境和键值都给出 Typst 写法、说明，以及原文档示例的
// LaTeX 代码、Typst 代码和效果。
// 编译：typst compile --root .. reference.typ

#import "doc-style.typ": *

#show: doc.with(title: [exam-zh-next API 对照手册], subject: [LaTeX → Typst])

#make-title()

#tip(none, kind: "info")[
    本手册按 LaTeX 版完整文档 `exam-zh-doc.pdf` 的章节顺序排列，*章节编号与原文档相同*（例如原文档 3.4.12 节“方格”在本手册中也是 3.4.12 节）。每一条给出：

    - 左边是 LaTeX 版的命令、环境或键值，右边是 Typst 版的写法；
    - 二者的语法；
    - 说明（与原文档相同的部分照录，有差别的地方单独指出）；
    - 原文档的每个示例：LaTeX 代码、对应的 Typst 代码，以及 Typst 版的排版效果。

    标注“写法不同”的条目功能相同、写法有差异；标注“Typst 中不需要”的条目在 Typst 中没有对应的问题；标注“留给独立包”的条目计划由单独的 Typst 包提供。
]

#outline(title: [目录], depth: 3)

= 介绍

试卷排版是中小学教师经常遇到的需求。LaTeX 版 exam-zh（作者 Zeping Lee，维护者 Kangwei Xia、Lijun Guo）借鉴 exam、jnuexam、BHCexam 等前人的工作，重新设计并用 LaTeX3 编写，构建了一套简洁的接口；它自 2024 年 4 月 26 日起停止维护。

本模板用 Typst 重新实现 exam-zh：沿用它的设计、选项名称和示例，接口改为 Typst 的函数与字典。Typst 一次编译即可完成目录、页码和答案后置，也不需要 `-shell-escape` 来生成师生两版。

= 安装与更新

== 标准安装

LaTeX 版通过 `tlmgr install exam-zh` 安装。Typst 版不需要安装：在文件开头写

#code-only(```typ
#import "@preview/exam-zh-next:0.1.0": *
```)

Typst 会自动下载并缓存模板。升级时把版本号改为新版本即可。

== 手动安装

把本仓库放到 Typst 的本地包目录（Linux 为 `~/.local/share/typst/packages/local/exam-zh-next/0.1.0`，macOS 为 `~/Library/Application Support/typst/packages/local/exam-zh-next/0.1.0`，Windows 为 `%APPDATA%\typst\packages\local\exam-zh\0.1.0`），然后导入 `@local/exam-zh-next:0.1.0`；或者直接导入仓库中 `src/lib.typ` 的路径。

== 模板组成

#table(
    columns: (32%, 36%, 1fr),
    [*LaTeX 版文件*], [*Typst 版文件*], [*功能说明*],
    [`exam-zh-doc.pdf`], [`docs/reference.typ`], [API 手册（本文档）；入门指南为 `docs/guide.typ`],
    [`example-single.tex`、`example-multiple.tex`], [`examples/example-single.typ`、`examples/example-multiple.typ`], [模板的示例文件],
    [`exam-zh.cls`], [`src/template.typ`、`src/page.typ`、`src/title.typ`], [模板、页面、抬头],
    [`exam-zh-choices.sty`], [`src/choices.typ`], [选择题],
    [`exam-zh-question.sty`], [`src/question.typ`], [题干、括号、填空、解答],
    [`exam-zh-font.sty`], [`src/config.typ`（`font-presets`）], [字体],
    [`exam-zh-math.sty`], [`src/math.typ`], [计算题、正体常数、向量],
    [`exam-zh-symbols.sty`], [`src/symbols.typ`], [中国化数学符号],
    [`exam-zh-chinese.sty`], [`src/chinese.typ`], [语文],
    [`exam-zh-english.sty`], [`src/english.typ`], [英语],
    [`exam-zh-textfigure.sty`], [`src/figures.typ`], [图文排版],
    [`exam-zh-counter.sty`、`exam-zh-circlednumber.sty`], [`src/config.typ`（`format-label`、`circled-number`）], [编号与带圈数字],
    [—], [`src/config.typ`], [全部选项与默认值],
    [`README.md`、`LICENSE`], [`README.md`、`LICENSE`], [自述与许可证],
)

= 使用说明

== 基本用法

#compare(```latex
% main.tex
\documentclass{exam-zh}
\begin{document}
  \section{Welcome to exam-zh!}
  你好，\LaTeX{}！
\end{document}
```, ```typ
// main.typ
#import "@preview/exam-zh-next:0.1.0": *
#show: exam

= Welcome to exam-zh!
你好，Typst！
```)

LaTeX 版在 Overleaf 等在线编辑器上需要在 `\documentclass` 前加 `\let\stop\empty`；Typst 版在 typst.app 上不需要任何额外设置。

== 编译方式

LaTeX 版只支持 XeLaTeX，并且至少要编译两次才能得到正确的目录与引用。Typst 版只需编译一次：

#code-only(```sh
typst compile example.typ
typst watch example.typ     # 保存时自动重新编译
```)

== 模板选项

LaTeX 版的模板选项是 `\documentclass[⟨模板选项⟩]{exam-zh}`，接口与 ctexart 相同（如字号、`fontset`）。Typst 版没有文档类选项，全部设置都是 `exam` 的命名参数：

#table(
    columns: (auto, 1fr),
    [*LaTeX 版*], [*Typst 版*],
    [`\documentclass[zihao=-4]{exam-zh}`], [`#show: exam.with(font: (size: zihao(-4)))`],
    [`\documentclass[fontset=windows]{exam-zh}`], [`#show: exam.with(font: (preset: "windows"))`],
    [`\documentclass{exam-zh}` 后的 `\examsetup{...}`], [`#show: exam.with(...)`，见 3.5 节],
)

#include "reference/commands.typ"
#include "reference/options.typ"

= 选项总表

全部选项及默认值如下，键的说明见 `src/config.typ`。

#context {
    set text(size: 8pt)
    set par(first-line-indent: 0pt, justify: false)
    for (section, options) in default-config {
        if type(options) != dictionary or section == "meta" { continue }
        block(above: 1em, below: 0.4em, sticky: true, text(weight: "bold", size: 9pt, raw(section)))
        table(
            columns: (auto, 1fr),
            ..options.pairs().map(((key, value)) => (raw(key), raw(repr(value)))).flatten(),
        )
    }
}
