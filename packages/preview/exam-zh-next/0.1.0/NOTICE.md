# 致谢与版权说明 / Credits and notices

## exam-zh

本项目是 LaTeX 试卷模板 [exam-zh](https://github.com/xkwxdyy/exam-zh) 的 Typst 移植。
模板的设计、命令与选项的命名、文档的章节结构和示例都来自 exam-zh。没有 exam-zh
作者多年的工作，就没有这个项目。

- exam-zh 作者：Zeping Lee
- exam-zh 维护者：Kangwei Xia、Lijun Guo
- exam-zh 借鉴了 exam、jnuexam、BHCexam 等模板
- exam-zh 以 [LaTeX Project Public License 1.3c](https://www.latex-project.org/lppl/lppl-1-3c/) 发布

This project ports the LaTeX class exam-zh (author Zeping Lee; maintainers
Kangwei Xia and Lijun Guo; LPPL 1.3c) to Typst. Its design, the names of its
commands and options, and the structure and examples of its documentation come
from exam-zh. The Typst code is an independent implementation and contains no
code from exam-zh.

## 各部分的许可 / What is licensed how

| 文件 | 许可 |
|---|---|
| `src/`、`examples/`、`docs/` 中的 Typst 代码、`scripts/`、`tests/` | MIT，见 [LICENSE](LICENSE) |
| `template/`（`typst init` 生成的初始试卷） | MIT-0，见 [LICENSE-MIT-0](LICENSE-MIT-0)：用它写出的试卷无需保留任何声明 |
| `docs/` 中逐字引用的 exam-zh LaTeX 示例代码与说明文字 | 版权属于 exam-zh 作者，LPPL 1.3c；仅作对照引用，不在 MIT 许可范围内 |

`docs/` 不包含在发布到 Typst Universe 的包中。示例试卷中的题目取自 exam-zh 的示例，
原题为 2021 年普通高等学校招生全国统一考试试题。

The verbatim exam-zh LaTeX snippets and descriptions quoted in `docs/` remain
the work of the exam-zh authors under LPPL 1.3c and are not covered by the MIT
license. `docs/` is not part of the package bundle.
