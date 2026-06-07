# `examora` - A package to create examination papers

## Control Parameters

This package provide following controlled parameters in `documentclass` function.:

|         Parameter         |                                     Description                                      |                   Default Value                    |
| :-----------------------: | :----------------------------------------------------------------------------------: | :------------------------------------------------: |
|        info.school        |                                   Scholl Infomatin                                   |                   "布鲁斯特大学"                   |
|       info.subject        |                                       subject                                        |                     "高等数学"                     |
|        info.major         |                                 major for this exam                                  |                         ""                         |
|        info.class         |                                  class for students                                  |                         ""                         |
|         info.time         |                                      exam time                                       |                         []                         |
|         info.date         |                                      exam date                                       |                  datetime.today()                  |
|       info.duration       |                                    exam duration                                     |                     [120 分钟]                     |
|       info.columns        |                           columns number for info display                            |                         -1                         |
|          margin           | page margin (for double page, also use outside and inside, don't use left and right) | (top: 3cm, bottom: 3cm, outside: 2cm, inside: 4cm) |
|       student-info        |                    information for students that should be filled                    | student-info: ("学院", "专业班级", "姓名", "学号") |
|           font            |                                   main font family                                   |         font: ("Times New Roman", "KaiTi")         |
|         font-size         |                                    main font size                                    |                        13pt                        |
|           type            |                                 type for exam paper                                  |                         ""                         |
|          method           |                                     exam method                                      |                       "闭卷"                       |
|          random           |                           whether should shuffle questions                           |                        true                        |
|           frame           |                        whether should add frame to each page                         |                        true                        |
|       frame-stroke        |                                stroke style for frame                                |            frame-stroke: 0.2pt + black             |
| choice-question-breakable |   whether can break question and choices into different page for choice questions    |                        true                        |
|        double-page        |                         whether put two pages into one paper                         |                        true                        |
|        show-answer        |                             show answer of all questions                             |                       false                        |
|     only-show-answer      |                         only print answer without questions                          |                       false                        |
|      continue-number      |            whether to init question number to one in every major question            |                       false                        |
|           seed            |             random seed (negative means generate according to exam type)             |                         -1                         |
|       answer-color        |                                font color for answers                                |                        red                         |
|         mono-font         |                                  font for raw text                                   |      ("Cascadia Code", "LXGW WenKai Mono GB")      |
|      mono-font-size       |                                font size for raw text                                |                        13pt                        |
|        title-font         |                                    font for title                                    |            ("Times New Roman", "KaiTi")            |
|      title-underline      |                           whether add underline for title                            |                        true                        |
|      title-font-size      |                                 font size for title                                  |                       1.5em                        |


## Question Header

Each major question section should be introduced by `question-header`. It automatically:

- Advances the major question counter and displays the question number (I, II, III…).
- Renders a score‑table header with two columns: a score column and the question description.
- If `continue-number: false` (default), resets the sub‑question numbering to 1 for each new section.

```typst
#question-header[Multiple Choice (2 points each, 30 points total)]
```

**Output**  
A score‑box header, e.g.:

```
Score
I. Multiple Choice (2 points each, 30 points total)
```

## Score Table

`#score-table()` generates the master score table at the top of the exam (right after the title). It automatically creates the right number of columns based on the major question sections you define, with a “Total” column at the end.

```typst
#score-table()
```

**Example output**

| Item No. | I   | II  | III | Total |
| -------- | --- | --- | --- | ----- |
| Score    |     |     |     |       |

## Choice Question

`choice-question` takes an array of question items. Each item consists of:

- The question text.
- An array of choices.
- Optional configuration groups (named argument groups in parentheses).

```typst
#choice-question(
  (
    (
      "Question text",
      ("Option A", ("Option B", true), "Option C", "Option D"),
      (inset: 0.8em),         // optional: padding inside the choices block
      (fixed: true),          // optional: keep choices in this exact order (no shuffling)
    ),
    // more questions ...
  ),
  // optional global parameters
  show-answer: false,
  answer-color: red,
  seed: 1,
  // ...
)
```

**Choice syntax**

- Normal choice: `"text"` or `[content]`
- Correct answer: `("text", true)` or `([content], true)`
- A question may have multiple correct answers.

**Per‑question optional arguments** (placed in the question tuple after the choices):

- `inset` – padding for the choices block (e.g. `inset: 0.8em`).
- `fixed` – if `true`, prevents shuffling of the choices for that question (even when global `random: true`).

**Global parameters** (passed directly to the `choice-question` call):

- `seed` – random seed.
- `random` – whether to shuffle question order and within‑question choice order.
- `show-answer` – whether to display correct answers.
- `answer-color` – color for the answer text.
- `font-size` – font size for choices (usually inherited from the document).
- `breakable` – allow a single question to split across pages (tied to `choice-question-breakable`).
- `only-show-answer` – output only the answers (useful for answer‑key generation).
- `continue-number` – continue question numbering across major sections.
- `show-score-table` – whether to show choice table before questions.
- `show-fill-blank` – if `true`, draws a blank parathesis after the each question (default `false`).

## Fill Question

`fill-question` creates fill‑in‑the‑blank items. The content of each question is a sequence where blanks are represented as `(answer text, width)` tuples. When rendered, the blanks appear as underlined spaces.

```typst
#fill-question(
  (
    ([In Java, loop control keywords include:], ([`break`], 3cm), [, ], ([`continue`], 3cm), [ and ], ([`goto`], 3cm), [.]),
    ("This is a question", ("the answer", 3cm), " followed by more text."),
    // ...
  ),
  spacing: 1.5em,   // vertical spacing between questions
  leading: 1.5em,   // line spacing within a question
)
```

**Question tuples**  
Each question is a sequence of content. A blank is a two‑element tuple: `(answer content, width)`, where `width` can be `3cm`, `4em`, etc. All other parts are strings or content blocks.

**Global parameters**  
- `spacing` – extra vertical space between questions.
- `leading` – paragraph leading inside a question.
- Also supports `show-answer`, `answer-color`, `only-show-answer`, `continue-number`, etc.

## True Or False Question

Generate true/false questions. Each item consists of a statement and a boolean (`true` = correct, `false` = incorrect).

```typst
#true-false-question(
  (
    ([Statement 1], true),
    ([Statement 2], false),
    // ...
  ),
  spacing: 1.2em,
  leading: 1em,
)
```

**Question tuples**  
`(question content, boolean)`

**Parameters**  
Same as `fill-question`: `spacing`, `leading`, and all common display control parameters (`show-answer`, `answer-color`, `only-show-answer`, `continue-number`, etc.).

## Normal Question

`question` is used for any non‑choice major question type (e.g., short‑answer, program reading, programming tasks, proofs). It provides a question body, an answer area, optional supplementary content, and adjustable answer space height.

```typst
#question(
  question: [Question text],
  answer: [Answer text],
  body: [
    // optional extra content (code blocks, figures, etc.)
  ],
  spacing: 40%,      // height of answer area as a percentage or fixed length
)
```

**Parameters**

- `question` (required) – the question text.
- `answer` (optional) – shown only when `show-answer: true` or `only-show-answer: true`. If omitted, “(omitted)” is displayed.
- `body` (optional) – additional content like code blocks, images, or tables; typically used for program‑reading or material‑based questions.
- `spacing` – controls the height of the answer box (or blank space). It can be a percentage (e.g., `40%`, meaning 40% of the remaining page height) or a fixed length (e.g., `3cm`). If not provided, a default blank area is used.

**Usage**  
`question` must be placed after a `question-header` (same major section). The sub‑question numbering increments automatically.

```typst
#question-header[Short‑Answer Questions (5 points each, 10 points total)]

#question(question: [...], answer: [...])

#question(question: [...], answer: [...], spacing: 3cm)
```

## New Page

`new-page` forces a page break in the exam (e.g., to start a new section or leave answering space). In `only-show-answer: true` mode, `new-page()` is ignored to keep the answer key compact.

```typst
#new-page()
```

---

For complete examples of how all these elements work together, see `template/exam.typ` in the repository. Compile that file to see the visual result of each parameter combination.

---

# `examora` - 一个用于生成试卷的包

## 控制参数

该包在 `documentclass` 函数中提供以下控制参数：

|           参数            |                                描述                                 |                       默认值                       |
| :-----------------------: | :-----------------------------------------------------------------: | :------------------------------------------------: |
|        info.school        |                              学校信息                               |                   “布鲁斯特大学”                   |
|       info.subject        |                                科目                                 |                     “高等数学”                     |
|        info.major         |                           考试面向的专业                            |                         ""                         |
|        info.class         |                           考试面向的班级                            |                         ""                         |
|         info.time         |                              考试时间                               |                         []                         |
|         info.date         |                              考试日期                               |                  datetime.today()                  |
|       info.duration       |                              考试时长                               |                     [120 分钟]                     |
|       info.columns        |                            信息显示列数                             |                         -1                         |
|          margin           | 页边距（对双页打印，请使用 outer 和 inner，不要使用 left 和 right） | (top: 3cm, bottom: 3cm, outside: 2cm, inside: 4cm) |
|       student-info        |                       需要学生填写的个人信息                        | student-info: (“学院”, “专业班级”, “姓名”, “学号”) |
|           font            |                              主字体族                               |         font: (“Times New Roman”, “KaiTi”)         |
|         font-size         |                               主字号                                |                        13pt                        |
|           type            |                              试卷类型                               |                         ""                         |
|          method           |                              考核方式                               |                       “闭卷”                       |
|          random           |                        是否随机打乱题目顺序                         |                        true                        |
|           frame           |                         是否在每页添加边框                          |                        true                        |
|       frame-stroke        |                            边框描边风格                             |            frame-stroke: 0.2pt + black             |
| choice-question-breakable |               对于选择题，是否允许题目和选项跨页拆分                |                        true                        |
|        double-page        |                      是否将两页合并到一张纸上                       |                        true                        |
|        show-answer        |                         显示所有题目的答案                          |                       false                        |
|     only-show-answer      |                       仅打印答案，不打印题目                        |                       false                        |
|      continue-number      |                   是否在每个大题中重置小题编号为1                   |                       false                        |
|           seed            |                随机种子（负数表示根据试卷类型生成）                 |                         -1                         |
|       answer-color        |                           答案的字体颜色                            |                        red                         |
|         mono-font         |                         用于原始文本的字体                          |      (“Cascadia Code”, “LXGW WenKai Mono GB”)      |
|      mono-font-size       |                            原始文本字号                             |                        13pt                        |
|        title-font         |                              标题字体                               |            (“Times New Roman”, “KaiTi”)            |
|      title-underline      |                        是否给标题添加下划线                         |                        true                        |
|      title-font-size      |                              标题字号                               |                       1.5em                        |


## 大题节

每个大题节应该由 `question-header` 引入。它会自动：

- 推进大题计数器并显示题号（一、二、三…）。
- 渲染一个两列的计分表头：一列是“分值”，另一列是题目描述。
- 如果 `continue-number: false`（默认值），则每个新章节将重置小题编号为1。

```typst
#question-header[选择题（每题2分，共30分）]
```

**输出**  
一个计分框标题，例如：

```
分值
一、选择题（每题2分，共30分）
```

## 分数表

`#score-table()` 在试卷顶部（标题之后）生成总计分表。它会根据你定义的大题节自动创建正确的列数，并在最后添加“总分”列。

```typst
#score-table()
```

**示例输出**

| 题号 | 一  | 二  | 三  | 总分 |
| ---- | --- | --- | --- | ---- |
| 分数 |     |     |     |      |

## 选择题

`choice-question` 接收一个题目项数组。每个项包含：

- 题目文本。
- 选项数组。
- 可选的配置组（括号中的命名参数组）。

```typst
#choice-question(
  (
    (
      “题目文本”,
      (“选项A”, (“选项B”, true), “选项C”, “选项D”),
      (inset: 0.8em),         // 可选：选项块的内边距
      (fixed: true),          // 可选：保持此顺序（不打乱）
    ),
    // 更多题目……
  ),
  // 可选的全局参数
  show-answer: false,
  answer-color: red,
  seed: 1,
  // ...
)
```

**选项语法**

- 普通选项：`"文本"` 或 `[内容]`
- 正确答案：`("文本", true)` 或 `([内容], true)`
- 一道题可以有多个正确答案。

**每题的可选参数**（放在题目元组中、选项之后）：

- `inset` – 选项块的内边距（例如 `inset: 0.8em`）。
- `fixed` – 若为 `true`，则禁止对该题的选项打乱顺序（即使全局 `random: true` 时也不打乱）。

**全局参数**（直接传递给 `choice-question` 调用）：

- `seed` – 随机种子。
- `random` – 是否打乱题目顺序以及每道题内部的选项顺序。
- `show-answer` – 是否显示正确答案。
- `answer-color` – 答案文本的颜色。
- `font-size` – 选项的字号（通常继承自文档）。
- `breakable` – 允许一道题跨页拆分（与 `choice-question-breakable` 关联）。
- `only-show-answer` – 只输出答案（用于生成答案卷）。
- `continue-number` – 跨大题节继续题目编号。
- `show-score-table` – 是否在题目前边显示选择框。
- `show-fill-blank` – 若为 `true`，在每个题目后添加一个空括号（默认 `false`）。

## 填空题

`fill-question` 创建填空题项。每道题的内容是一个序列，其中的空位表示为 `(答案文本, 宽度)` 元组。渲染时，空位显示为带下划线的空格。

```typst
#fill-question(
  (
    ([在 Java 中，循环控制关键字包括：], ([`break`], 3cm), [, ], ([`continue`], 3cm), [ 和 ], ([`goto`], 3cm), [.]),
    (“这是一道题”, (“答案文本”, 3cm), “ 后面跟着更多文本。”),
    // ...
  ),
  spacing: 1.5em,   // 题目之间的垂直间距
  leading: 1.5em,   // 题目内部的行距
)
```

**题目元组**  
每道题是一个内容序列。一个空位是一个二元组：`(答案内容, 宽度)`，其中宽度可以是 `3cm`、`4em` 等。其他部分均为字符串或内容块。

**全局参数**  
- `spacing` – 题目之间额外的垂直间距。
- `leading` – 题目内部段落行距。
- 同样支持 `show-answer`、`answer-color`、`only-show-answer`、`continue-number` 等。
- `show-score-table` – 控制此节的计分框是否出现在总计分表中。

## 判断题

生成对错题。每个项包含一个陈述句和一个布尔值（`true` = 正确，`false` = 错误）。

```typst
#true-false-question(
  (
    ([陈述句1], true),
    ([陈述句2], false),
    // ...
  ),
  spacing: 1.2em,
  leading: 1em,
)
```

**题目元组**  
`(题目内容, 布尔值)`

**参数**  
同 `fill-question`：`spacing`、`leading`，以及所有通用显示控制参数（`show-answer`、`answer-color`、`only-show-answer`、`continue-number` 等）。

## 普通题

`question` 用于任何非选择题的大题类型（例如简答题、程序阅读题、编程题、证明题）。它提供题目正文、答案区、可选补充内容以及可调的答案区高度。

```typst
#question(
  question: [题目文本],
  answer: [答案文本],
  body: [
    // 可选的额外内容（代码块、图表等）
  ],
  spacing: 40%,      // 答案区高度，可以是百分比或固定长度
)
```

**参数**

- `question`（必需） – 题目文本。
- `answer`（可选） – 仅在 `show-answer: true` 或 `only-show-answer: true` 时显示。若省略，则显示 “（已省略）”。
- `body`（可选） – 额外内容，如代码块、图片或表格；通常用于程序阅读或材料型题目。
- `spacing` – 控制答案框（或空白区域）的高度。可以是百分比（例如 `40%`，表示剩余页面高度的 40%）或固定长度（例如 `3cm`）。如果未提供，则使用默认的空白区域。

**用法**  
`question` 必须放在 `question-header` 之后（同一个大题节内）。小题编号会自动递增。

```typst
#question-header[简答题（每题5分，共10分）]

#question(question: [...], answer: [...])

#question(question: [...], answer: [...], spacing: 3cm)
```

## 新页面

`new-page` 在试卷中强制分页（例如为了开始一个新的部分或留出作答空间）。在 `only-show-answer: true` 模式下，`new-page()` 会被忽略，以保持答案卷紧凑。

```typst
#new-page()
```

---

关于所有这些元素如何一起工作的完整示例，请参阅仓库中的 `template/exam.typ` 文件。编译该文件可以查看每个参数组合的实际视觉效果。