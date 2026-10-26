**非官方模板**

- [论文模式](#论文模式)
- [调研报告模式](#调研报告模式)
- [参数说明](#参数说明)
  - [通用参数](#通用参数)
  - [调研报告专用参数](#调研报告专用参数)
- [字号与行距](#字号与行距)
- [其他说明](#其他说明)
  - [章节分页](#章节分页)
  - [参考文献与引用](#参考文献与引用)
  - [三线表示例](#三线表示例)
- [LICENSE](#license)

## 论文模式

`paper-type: "thesis"`

默认论文模式，示例：

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

论文模式的页面顺序：

```text
封面 → 诚信声明* → 中文摘要 → 英文摘要* → 目录 → 正文
```

`*` 为可选，默认显示，通过下面参数控制:
- `include-statement`
- `include-abstract-en`

## 调研报告模式

`paper-type: "report"`

填写报告封面与分工表字段：

```typst
#show: jnu-thesis.with(
  paper-type: "report",
  title: ("调查题目第一行", "第二行"),
  short-title: "学生实践调查报告",
  course: ("课程名称第一行", "第二行"),
  class-name: "2024 级xx工程",
  supervisor: "Teacher",
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

调研报告模式的页面顺序：

```text
封面 → 分工表 → 诚信声明* → 中文摘要 → 英文摘要* → 目录 → 正文
```

报告模式默认**不显示**诚信声明和英文摘要

可通过下面参数控制样式
- `include-statement: true`
- `include-abstract-en: true`
- 填写 `abstract-en`、`keywords-en`、`title-en`；

## 参数说明

### 通用参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `paper-type` | `"thesis"` | `"thesis"` 论文 / `"report"` 调研报告 |
| `title` | `""` | 论文题目；报告模式下可传字符串数组指定封面换行 |
| `title-en` | `""` | 英文题目 |
| `short-title` | `none` | 页眉短标题，缺省使用 `title` |
| `college` | `""` | 学院（论文封面） |
| `major` | `""` | 专业（论文封面） |
| `author` | `""` | 姓名（论文封面 / PDF 元数据） |
| `student-id` | `""` | 学号（论文封面） |
| `supervisor` | `""` | 指导教师；报告封面显示为“指导老师” |
| `date` | `""` | 日期，例如 `"二〇二六年六月"` / `"2026 年 5 月"` |
| `abstract` | `[]` | 中文摘要内容 |
| `abstract-en` | `[]` | 英文摘要内容 |
| `keywords` | `()` | 中文关键词数组 |
| `keywords-en` | `()` | 英文关键词数组 |
| `bib` | `none` | `bibliography(...)` 返回的内容；`none` 表示不生成参考文献。|
| `logo` | `"res/jnulogo.png"` | 封面校徽路径 |
| `sizes` | `(:)` | 字号覆盖字典，见下一节 |
| `chapter-pagebreak` | `false` | 编号章节是否另起一页 |
| `leading` | `0.83em` | 行距，约等于 1.5 倍 |
| `include-statement` | `auto` | `auto`：论文显示、报告隐藏 |
| `include-abstract-en` | `auto` | `auto`：论文显示、报告隐藏 |

### 调研报告专用参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `course` | `""` | 课程名称，可传数组换行 |
| `class-name` | `""` | 专业班级 |
| `score` | `""` | 成绩评分，留空则显示空下划线 |
| `team` | `()` | 分工表成员数组，元素为 `(name, student-id, work)` |

## 字号与行距

`jnu-thesis` 的默认字号：

| 键 | 默认值 | 对应 |
|---|---|---|
| `body` | `14pt` | 正文（四号） |
| `heading` | `15pt` | 各级标题（小三） |
| `caption` | `10.5pt` | 图、表标题（五号） |
| `note` | `9pt` | 脚注（小五） |
| `code` | `10.5pt` | 代码块 |
| `cover-title` | `36pt` | 封面校名 / 报告标题 |
| `cover-info` | `auto` | 封面信息栏，跟随 `body` |
| `statement-title` | `22pt` | 诚信声明标题 |
| `statement-body` | `auto` | 诚信声明正文 |
| `abstract-title` | `18pt` | 摘要页标题 |
| `abstract-body` | `auto` | 摘要正文 |
| `reference` | `auto` | 参考文献条目，跟随 `caption` |
| `toc-title` | `24pt` | 目录标题 |
| `toc-entry` | `auto` | 目录条目，跟随 `body` |
| `header` | `10.5pt` | 页眉 |
| `footer` | `10.5pt` | 页码 |

## 其他说明

### 章节分页

`chapter-pagebreak` 控制**带编号章节**是否另起一页：

### 参考文献与引用

1. 在 `res/refs.bib` 中添加条目；
2. 正文中引用：

```typst
文学化编程的思想可参见#cite(<knuth1984>)。
```

### 三线表示例

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

## LICENSE

本项目中的 Typst 模板源代码依据 MIT-0 许可证进行授权。

模板内置的校徽（res/jnulogo.png）为暨南大学标识资源，属于受商标权、著作权保护的资源文件，不在 MIT-0 许可证授权范围内，其知识产权归相关权利人所有。上述资源仅限用于学位论文排版的学术、非商业用途，除法律法规另有规定或已获得相关授权外，不得对上述资源进行再分发、修改或用于其他用途。使用者需自行确认其对资源的使用符合暨南大学的有关规定及适用法律法规。

The Typst template source code in this project is licensed under the MIT-0 License.

The university logo (`res/jnulogo.png`) included in the template is an identifier resource of Jinan University and is a resource file protected by trademark and copyright. It is not covered by the MIT-0 License, and its intellectual property rights belong to the respective rights holders. The aforementioned resource is permitted solely for academic, non-commercial use in thesis/dissertation typesetting. Unless otherwise provided by laws and regulations or duly authorized, the resource must not be redistributed, modified, or used for other purposes. Users are responsible for ensuring that their use of the resource complies with the relevant regulations of Jinan University and applicable laws and regulations.
