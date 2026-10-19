[简体中文](README.md) | **English**
 
<h1>Jinan University Undergraduate Thesis / Research Report Typst Template</h1>

This template was created with reference to **the PDF file exported from Teacher Jianrui Lü’s template.**

> [!NOTE]
>
> Unofficial template.

## Installation

The Typst Universe package is named `modern-jnu-thesis`. Run this in an empty directory:

```sh
typst init @preview/modern-jnu-thesis:0.1.0
```

You can also import it directly in an existing document:

```typst
#import "@preview/modern-jnu-thesis:0.1.0": jnu-thesis
```

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Installation](#installation)
- [Thesis Mode](#thesis-mode)
- [Research Report Mode](#research-report-mode)
- [Parameters](#parameters)
  - [General Parameters](#general-parameters)
  - [Research Report Parameters](#research-report-parameters)
- [Font Sizes and Line Spacing](#font-sizes-and-line-spacing)
- [Other Notes](#other-notes)
  - [Chapter Page Breaks](#chapter-page-breaks)
  - [References and Citations](#references-and-citations)
  - [Three-line Table Example](#three-line-table-example)

## Thesis Mode

`paper-type`: `"thesis"`

This is the default mode. Example:

```typst
#import "@preview/modern-jnu-thesis:0.1.0": jnu-thesis

#show: jnu-thesis.with(
  paper-type: "thesis",
  title: "论文题目",
  title-en: "English Title",
  short-title: "页眉短标题",
  college: "学院",
  major: "专业",
  author: "姓名",
  student-id: "学号",
  supervisor: "指导教师",
  date: "二〇二六年六月",
  abstract: [中文摘要],
  abstract-en: [English abstract],
  keywords: ("关键词1", "关键词2"),
  keywords-en: ("Keyword1", "Keyword2"),
  bib: bibliography("res/refs.bib", style: "gb-7714-2015-numeric", title: none),
)
```

Thesis page order:

```text
Cover → Integrity Statement* → Chinese Abstract → English Abstract* → Table of Contents → Body
```

`*` marks optional pages. They are shown by default and controlled by:

- `include-statement`
- `include-abstract-en`

## Research Report Mode

`paper-type`: `"report"`

Fill in the report cover and division-of-labor fields:

```typst
#show: jnu-thesis.with(
  paper-type: "report",
  title: ("调查题目第一行", "第二行"),
  short-title: "学生实践调查报告",
  course: ("课程名称第一行", "第二行"),
  class-name: "2024 级金融工程",
  supervisor: "许文芳",
  score: "",
  date: "2026 年 5 月",
  abstract: [中文摘要],
  keywords: ("关键词1", "关键词2"),
  team: (
    (name: "张三", student-id: "2024xxxxxx", work: "资料收集"),
    (name: "李四", student-id: "2024xxxxxx", work: "问卷设计与数据分析"),
  ),
  bib: none,
)
```

Research report page order:

```text
Cover → Division-of-Labor Table → Integrity Statement* → Chinese Abstract → English Abstract* → Table of Contents → Body
```

In report mode, the integrity statement and English abstract are **hidden by default**.

To enable them:

- `include-statement: true`
- `include-abstract-en: true`
- Also fill in `abstract-en`, `keywords-en`, and `title-en`.

## Parameters

### General Parameters

| Parameter | Default | Description |
|---|---|---|
| `paper-type` | `"thesis"` | `"thesis"` for a thesis / `"report"` for a research report |
| `title` | `""` | Thesis/survey title; in report mode, an array of strings can be used to force cover line breaks |
| `title-en` | `""` | English title |
| `short-title` | `none` | Short running header; falls back to `title` |
| `college` | `""` | College (thesis cover) |
| `major` | `""` | Major (thesis cover) |
| `author` | `""` | Author (thesis cover / PDF metadata) |
| `student-id` | `""` | Student ID (thesis cover) |
| `supervisor` | `""` | Supervisor; shown as “指导老师” on the report cover |
| `date` | `""` | Date, e.g. `"二〇二六年六月"` / `"2026 年 5 月"` |
| `abstract` | `[]` | Chinese abstract |
| `abstract-en` | `[]` | English abstract |
| `keywords` | `()` | Chinese keywords |
| `keywords-en` | `()` | English keywords |
| `bib` | `none` | Content returned by `bibliography(...)`, or a `.bib` path; `none` disables the bibliography |
| `logo` | `"res/jnulogo.png"` | Cover logo path |
| `sizes` | `(:)` | Font size overrides; see the next section |
| `chapter-pagebreak` | `false` | Whether numbered chapters start on a new page |
| `leading` | `0.83em` | Line spacing, approximately 1.5× |
| `include-statement` | `auto` | `auto`: shown for theses, hidden for reports |
| `include-abstract-en` | `auto` | `auto`: shown for theses, hidden for reports |

### Research Report Parameters

| Parameter | Default | Description |
|---|---|---|
| `course` | `""` | Course name; an array can be used for line breaks |
| `class-name` | `""` | Class / program |
| `score` | `""` | Score; an empty value renders a blank underline |
| `team` | `()` | Division-of-labor members: `(name, student-id, work)` |

## Font Sizes and Line Spacing

Default font sizes for `jnu-thesis`:

| Key | Default | Used for |
|---|---|---|
| `body` | `14pt` | Body text (Chinese size 4) |
| `heading` | `15pt` | All heading levels (Chinese size 3) |
| `caption` | `10.5pt` | Figure and table captions (Chinese size 5) |
| `note` | `9pt` | Footnotes (Chinese size 5-small) |
| `code` | `10.5pt` | Code blocks |
| `cover-title` | `36pt` | Cover university name / report title |
| `cover-info` | `auto` | Cover information fields; follows `body` |
| `statement-title` | `22pt` | Integrity statement title |
| `statement-body` | `auto` | Integrity statement body |
| `abstract-title` | `18pt` | Abstract page title |
| `abstract-body` | `auto` | Abstract body |
| `reference` | `auto` | Bibliography entries; follows `caption` |
| `toc-title` | `24pt` | Table of contents title |
| `toc-entry` | `auto` | TOC entries; follows `body` |
| `header` | `10.5pt` | Running header |
| `footer` | `10.5pt` | Page number |

## Other Notes

### Chapter Page Breaks

`chapter-pagebreak` controls whether **numbered chapters** start on a new page:

### References and Citations

1. Add entries to `res/refs.bib`;
2. Cite them in the body:

```typst
Literate programming is discussed in #cite(<knuth1984>).
```

### Three-line Table Example

```typst
#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (center + horizon, left + horizon, left + horizon),
    table.hline(stroke: 1pt),
    [*工具*], [*优势*], [*局限*],
    table.hline(stroke: 0.5pt),
    [Word], [操作直观], [长文档样式一致性较弱],
    [Typst], [语法简洁], [生态仍在发展],
    table.hline(stroke: 1pt),
  ),
  caption: [排版工具比较],
)
```


# PS

The repository was named with reference to [yueryang/LaTeX4JNUBachelor](https://github.com/yueryang/LaTeX4JNUBachelor)
