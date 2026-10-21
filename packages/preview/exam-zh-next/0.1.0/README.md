# exam-zh-next：Typst 中文试卷模板

Chinese exam papers in Typst, ported from the LaTeX class
[exam-zh](https://github.com/xkwxdyy/exam-zh): auto-column choices, answer
blanks, solutions with scoring points, seal lines, A3 two-up layout, and
student and teacher versions from one source. An independent port, not
affiliated with the exam-zh authors.

| 学生版 | 教师版 | 密封线、A3 双栏 |
|:-:|:-:|:-:|
| ![学生版](docs/images/first-student.png) | ![教师版](docs/images/first-teacher.png) | ![A3 密封线试卷](docs/images/sealline-a3.png) |

- **一份源码，两个版本**：学生版隐藏答案，教师版显示答案、正确选项和评分点，命令行一个参数切换；
- **选择题自动分栏**：选项按内容宽度排成 4、2 或 1 列；括号自动排到行末；
- **填空**：下划线、括号、圆圈、方框、空白，学生版显示 ▲、编号或空白，长答案自动换行；
- **解答**：评分点引导线画到页边；答案可隐藏、原位显示或集中到文末；
- **整卷版式**：密封线、A3 横向双栏、评分框、草稿纸、多份试卷合集与目录；
- **各学科**：语文的材料、古诗注释、连线题、作文格，英语作文框，数学计算题与教材写法的符号；
- **熟悉的接口**：选项名与 exam-zh 相同，写错键名时直接报错；一次编译完成，不需要 `-shell-escape`。

## 快速开始

```typ
#import "@preview/exam-zh-next:0.1.0": *

#show: exam.with(title: [2021 年普通高等学校招生全国统一考试], subject: [数学])

#secret()
#make-title()

= 选择题：本题共 8 小题，每小题 5 分，共 40 分。

#question[
  设集合 $A = {x | -1 < x < 4}$，$B = {2, 3, 4, 5}$，则 $A inter B = $ #paren[B]
  #choices(answer: "B")[${2}$][${2, 3}$][${3, 4}$][${2, 3, 4}$]
]

= 填空题：本题共 4 小题，每小题 5 分，共 20 分。

#question[
  已知函数 $f(x) = x^3 (a dot 2^x - 2^(-x))$ 是偶函数，则 $a = $ #fillin[$1$]。
]

= 解答题：本题共 6 小题，共 70 分。

#problem(points: 12)[
  已知函数 $f(x) = x (1 - ln x)$，讨论 $f(x)$ 的单调性。
  #solution[
    $f'(x) = -ln x$，#score(2) 故 $f(x)$ 在 $(0, 1)$ 上递增，在 $(1, +infinity)$ 上递减。#score(4)
  ]
]
```

```sh
typst compile exam.typ                                              # 学生版
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf   # 教师版
```

也可以用 `typst init @preview/exam-zh-next` 生成一份完整的试卷再修改。在 [typst.app](https://typst.app)
上从模板新建项目即可，无需安装字体；本地编译请先安装 Noto CJK 字体，或改用其他字体（见下文）。

## 文档与示例

| | |
|---|---|
| [入门指南](https://github.com/pku-lemonade/exam-zh-next/releases/download/v0.1.0/guide.pdf)（[源码](https://github.com/pku-lemonade/exam-zh-next/blob/v0.1.0/docs/guide.typ)） | 快速开始、各种题型、常见场景、FAQ；与 exam-zh 的入门文档逐章对应 |
| [API 对照手册](https://github.com/pku-lemonade/exam-zh-next/releases/download/v0.1.0/reference.pdf)（[源码](https://github.com/pku-lemonade/exam-zh-next/blob/v0.1.0/docs/reference.typ)） | exam-zh 的每个命令和选项 → Typst 写法、说明与效果；章节编号与 exam-zh 完整文档相同 |
| [examples/](https://github.com/pku-lemonade/exam-zh-next/tree/v0.1.0/examples) | exam-zh 全部示例的 Typst 版：2021 全国乙卷数学、A3 试卷合集，以及语文、英语、真实考试场景 |

两份文档本身也用本模板排版；自行编译时在仓库根目录运行 `typst compile --root . docs/guide.typ`。

## 设置

所有选项按模块分组，三个入口用同样的键名：

```typ
#show: exam.with(choices: (max-columns: 2))  // 整份试卷
#exam-setup(fillin: (type: "paren"))         // 从此处往后
#choices(columns: 2)[A][B][C][D]              // 只作用于这一次
```

键名写错时编译报错，例如 ``unknown option `choices.colums` ``。全部选项与默认值见
[`src/config.typ`](src/config.typ) 和 API 对照手册第 4 章。

教师版显示哪些内容由 `teacher` 决定，默认是 `teacher-defaults`，可以在其上增改：

```typ
#show: exam.with(teacher: teacher-defaults + (solution: (show-solution: "show-move")))
#teacher-only[本题考查函数的单调性。]
```

### 字体

`font: (preset: ..)` 选择一组中文字体，也可以单独指定，例如 `font: (kai: "LXGW WenKai")`：

| preset | 宋体 | 黑体 | 楷体 | 仿宋 |
|---|---|---|---|---|
| `noto`（默认） | Noto Serif CJK SC | Noto Sans CJK SC | （同宋体） | （同宋体） |
| `source-han` | Source Han Serif SC | Source Han Sans SC | （同宋体） | （同宋体） |
| `fandol` | FandolSong | FandolHei | FandolKai | FandolFang |
| `windows` | SimSun | SimHei | KaiTi | FangSong |
| `mac` | Songti SC | Heiti SC | Kaiti SC | STFangsong |
| `founder` | FZShuSong-Z01 | FZHei-B01 | FZKai-Z03 | FZFangSong-Z02 |

西文与数学默认使用 Typst 自带的 New Computer Modern。Typst 不会伪造粗体，请选用带粗体字重的中文字体。

## 从 exam-zh 迁移

大多数命令一一对应，完整对照见 [API 对照手册](https://github.com/pku-lemonade/exam-zh-next/releases/download/v0.1.0/reference.pdf)：

| exam-zh (LaTeX) | Typst |
|---|---|
| `\documentclass{exam-zh}`、`\examsetup{..}` | `#show: exam.with(..)`、`#exam-setup(..)` |
| `\section{..}` | `= ..` |
| `question`、`problem[points = 12]` | `question[..]`、`problem(points: 12)[..]` |
| `choices` 与 `\item` | `choices[..][..]`，`answer: "B"` 标出正确选项 |
| `\paren[B]`、`\fillin[答案]` | `paren[B]`、`fillin[答案]` |
| `solution`、`\score{2}` | `solution[..]`、`score(2)` |
| `\draftpaper`、`\scoringbox`、`\tableofcontents` | `draftpaper()`、`scoringbox()`、`exam-outline()` |
| `\ExamPrintAnswerSet` 与 `-shell-escape` | `--input exam-mode=teacher` 与 `exam(teacher: ..)` |

与 exam-zh 不同或暂不支持的地方（文字绕排、选择与填空答案后置等）列在 [ROADMAP.md](ROADMAP.md)。

## 开发

```sh
scripts/check.sh [--font-path DIR]       # 编译全部示例（两个版本）、测试与文档，有警告即失败
scripts/doc-images.sh [--font-path DIR]  # 重新生成文档与 README 中的整页图片和模板缩略图
scripts/package.sh [--font-path DIR]     # 生成提交到 Typst Universe 的目录，并按用户的方式测试
```

## 许可与致谢

本项目是 [exam-zh](https://github.com/xkwxdyy/exam-zh) 的非官方 Typst 移植。设计、选项命名和示例来自 exam-zh
（作者 Zeping Lee，维护者 Kangwei Xia、Lijun Guo），感谢他们的工作。Typst 代码为独立实现。

代码以 [MIT](LICENSE) 许可发布；`template/` 中的初始试卷以 [MIT-0](LICENSE-MIT-0) 许可发布，用它写出的试卷无需保留任何声明。
文档中引用的 exam-zh 原文与 LaTeX 代码仍属于 exam-zh 作者（LPPL 1.3c），详见 [NOTICE.md](NOTICE.md)。
