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
