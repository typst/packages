# Migrating from sang-math 1.0.6 to 1.1.0

No migration is required for existing valid 1.0.6 documents. All existing public APIs remain supported.

## Keep using the legacy API

Existing calls to `tn`, `ds`, `tln`, `tl`, `exam-mode`, exam profiles, answer keys, and OMR continue to use the same arguments and PDF layout. Update only the package version in the import when 1.1.0 is published.

```typ
#tn([Tính $1+1$.], ([$1$], True([$2$]), [$3$], [$4$]), loigiai: [$1+1=2$.])
```

## Build a bank with the familiar `tn/ds/tln/tl` syntax

`bank-mode()` changes the four function bindings to return question data. The call format stays familiar: stem, options or answer, `id`, and `loigiai`. Use a code from `bank.json`; it supplies class, chapter, topic code, and difficulty. The function name supplies the question kind. Multiple questions may share one catalogue code.

```typ
#let (tn, ds, tln, tl) = bank-mode()
#let bank = question-bank(
  tn([Đạo hàm của $x^2$ là gì?], ([$x$], True([$2x$]), [$x^2$], [$2$]), id: "1D7N2-1"),
  tln([Tính $f'(2)$ với $f(x)=x^2$.], 4, id: "1D7H2-1"),
)
#let variant = exam-variant(bank, ((kind: QUESTION_MC, count: 1),), seed: 101)
#render-exam-variant(variant)
```

Use `bank-filter(bank, id-prefix: "1D7")` or an `id-prefix` in a blueprint to select a chapter by code. Existing standalone `#tn/#ds/#tln/#tl` calls remain unchanged.

## Use the advanced structured constructor when useful

The new `question` constructor returns data. `render-question` places it in the document. `choice` stores one canonical option with a `correct` flag. The `answer` helper can carry typed answers; a one-based `choice` index is supported for MCQ. Set the `correct` flag consistently with the index when supplying both.

```typ
#let q = question(
  id: "MATH-001",
  kind: QUESTION_MC,
  prompt: [Tính $1+1$.],
  choices: (choice([$1$]), choice([$2$], correct: true), choice([$3$])),
  answer: answer("choice", 2),
  solution: (solution-step([$1+1=2$.], title: [Tính toán]),),
  hints: ([Hãy cộng hai số.],),
  grade: 10,
  topic: "so-hoc",
  difficulty: 1,
  tags: ("basic",),
  metadata: (curriculum-code: "K10-1"),
)
#render-question(q, mode: "student")
#render-question(q, mode: "solution")
```

Valid render modes are `student`, `teacher`, `solution`, and `answer-key`. The student mode hides answers and solutions. The teacher mode marks answers; the solution mode also prints explanations. The answer-key mode prints a compact entry. The legacy `print-answer-key()` remains available for a rendered exam.

## Build a reproducible question bank

```typ
#let bank = question-bank(q1, q2, q3)
#let subset = bank-filter(bank, grade: 12, topic: "dao-ham", difficulty: (2, 3))
#let chosen = bank-select(subset, count: 2, seed: 101)
#for item in chosen { render-question(item) }
```

The same bank, filters, and seed produce the same selection and order. `bank-shuffle-choices(q, seed: 101)` deterministically reorders a question's choices and remaps a typed choice-index answer. Randomization is explicit; existing OMR flows are unchanged unless the caller deliberately renders reordered questions.

## Scope of 1.1

The data model allows later HTML, SCORM, Manim, AI, and analytics adapters. Version 1.1 includes deterministic section quotas through `exam-variant` and balanced multiple codes through `exam-variants`; a larger blueprint DSL and those adapters remain future work. Version 1.1 requires Typst 0.15.0 or newer because its preserved beamer namespace now uses Touying 0.8.0. Stay on sang-math 1.0.6 with Typst 0.14.x. CI checks Typst 0.15.0 and 0.15.1.

For the horizontal 12–4–6 OMR sheet, set `state("sbd")` and `state("made")` before including the template. `exam-variant-qr(variant)` creates the teacher answer-key QR directly from one variant. The sheet's existing profile QR stays fixed for scanner calibration. See [`examples/exam-variant-omr.typ`](examples/exam-variant-omr.typ).
