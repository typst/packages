# Structured question API (1.1)

The recommended bank syntax keeps the `tn/ds/tln/tl` call shape from 1.0.6. Bind `#let (tn, ds, tln, tl) = bank-mode()` once, then write `tn([stem], (options), id: "1D7N2-1", loigiai: [...])` inside `question-bank(...)`. These functions return data; `render-question` or `render-exam-variant` prints it. A standalone `#tn(...)` without `bank-mode` still renders immediately as before.

`1D7N2-1` is a `bank.json` catalogue code. The first digit maps `0/1/2` to grades `10/11/12`; the next letter is branch `D/H/C`; the next digit is chapter; `N/H/V/C` maps to difficulty `1/2/3/4`; the next digit is lesson and the last digit after `-` is form. `bank-mode` fills `grade`, `chapter`, `topic` code, `difficulty`, and `metadata.bank-id` from this code. The function name supplies MCQ/true-false/short-answer/written kind because the ID does not encode it. This validates the ID's format, not membership in an external `bank.json`; copy an existing code from the catalogue. Multiple questions may share a catalogue code.

`question(...)` remains available for advanced dictionaries and optional teaching metadata. It does not render PDF or change counters. The student, teacher, and solution modes of `render-question(q, mode: ...)` use the existing exam layout and record answers in the legacy exam states, so `print-answer-key()` and `sang-omr-qr()` continue to work.

## Kinds and answers

| Kind | Required content | Answer options |
|---|---|---|
| `QUESTION_MC` (`"mcq"`) | `prompt`, nonempty `choices` | Mark one `choice(..., correct: true)` or use `answer("choice", one_based_index)` |
| `QUESTION_TF` (`"true-false"`) | `prompt`, nonempty `choices` | Mark each choice with `correct: true/false`, or provide a boolean tuple in `answer` |
| `QUESTION_SA` (`"short-answer"`) | `prompt` | `answer` can be text, content, a number, or a typed answer dictionary |
| `QUESTION_WRITTEN` (`"written-response"`) | `prompt` | Optional solution or rubric data |

`choice(content, correct: false, metadata: (:))` is the canonical choice format. `answer(kind, value, ..fields)` stores extensible typed answers, such as `answer("numeric", 3.14, tolerance: 0.001)`. PDF currently supports typed choice indices directly; specialized grading for numeric tolerance and rubrics is future work.

`solution` accepts legacy content or a tuple of `solution-step(content, title: none)` values. `hints` is a tuple of optional content and is not displayed in the PDF modes.

## Render modes

- `student`: question and answer space without correct-answer marks or solutions.
- `teacher`: question with correct-answer marks; no detailed solution.
- `solution`: answer marks and detailed solution.
- `answer-key`: one compact answer entry. Pass `num:` when a displayed number is wanted.

The PDF mode names are separate from the legacy `"dethi"`, `"loigiai"`, and `"solcolor"` macro modes. The old macros and `exam-preset` profile names are unchanged.

## Metadata and validation

All metadata is optional: `id`, `subject`, `grade`, `chapter`, `topic`, `difficulty`, `cognitive-level`, `tags`, `estimated-time`, `source`, `points`, and open `metadata: (:)`. Difficulty is an integer from 1 (very easy) to 5 (very hard). Suggested cognitive levels are `remember`, `understand`, `apply`, `analyze`, `evaluate`, and `create`.

`validate-question(q)` uses strict mode by default. It checks required prompts, supported kinds, choice structure, maximum six choices for the current PDF renderer, a unique MCQ answer (marked choice or typed index), conflicting MCQ/true-false answer data, out-of-range choice indices, nonnegative points/numeric tolerance/estimated time, difficulty range, string tags, and metadata types. Errors include the question ID when available. Legacy macros call the validator in `legacy-compatible` mode to avoid rejecting historical documents.

## Banks and deterministic order

`question-bank(q1, q2, ...)` returns a tuple. `bank-filter(bank, grade:, topic:, id-prefix:, difficulty:, kind:, tags:)` validates structured questions and returns matching questions; difficulty can be a single value or tuple. `id-prefix: "1D7"` selects a bank catalogue chapter without repeating free-text topic labels. Invalid kinds, tags, prefixes, and difficulty fail clearly. `bank-select(bank, count:, seed:)` selects without replacement in reproducible order. `bank-shuffle-choices(q, seed:)` reorders a single question's choices and remaps a typed choice index or an explicit true/false boolean tuple.

The seed is an integer. The implementation uses a fixed Park–Miller generator so selection never depends on Typst's random state. Calling these functions does not reorder a legacy exam implicitly. If choices are shuffled, render the shuffled question and generate its answer key/OMR from that same rendering.

## Exam variants and OMR

`exam-variant(bank, blueprint, seed:, ma-de:, shuffle-choices: true)` accepts a nonempty tuple of section dictionaries. Each section has `count` and optional `kind`, `grade`, `topic`, `id-prefix`, `difficulty`, `tags`, and `title`. It selects exactly that many questions without reuse, validates IDs and quotas, and returns `(ma-de, seed, sections, questions)`. The four-digit exam code is zero-padded. MCQ choices and their typed answer index are shuffled together; true/false statements stay in their original order.

`exam-variants(bank, blueprint, codes, seed:)` generates multiple codes and chooses questions with the lowest prior use first, then uses the seed to break ties. Every question needs an ID; questions made with `bank-mode` may share a catalogue ID, and their stable bank positions distinguish them during balancing. Advanced `question(...)` records retain unique-ID validation. Duplicate normalized exam codes fail. The output is deterministic for identical inputs and bank order.

`render-exam-variant(variant, mode: "student")` renders the selected sections with the existing exam layout. `exam-variant-qr(variant)` encodes answer data directly from that variant, so QR codes remain correct even when several variants share one document. `exam-variant-qr-payload(variant)` returns the same `SMKEY:1:` text for external export. The default OMR profile is `12-4-6ngang` (12 MCQ, 4 true/false, 6 short answers, A5). It requires four options/statements per MCQ/true-false question, grouped in OMR order, and rejects a profile count mismatch. A different profile can be passed as `(id:, mcq:, tf:, tln:, paper:)`; names and paper must be nonempty strings and the three counts must be nonnegative integers.

The eight generated OMR presets accept optional Typst states `sbd` and `made` immediately before `#include`. Prefilled bubbles and printed codes use six and four digits respectively; blank states keep the form empty. The fixed `SMOMR` QR printed on the sheet identifies its geometry. The `SMKEY` QR from `exam-variant-qr` contains the teacher answer key and should be distributed separately. See [`../examples/exam-variant-omr.typ`](../examples/exam-variant-omr.typ).

See [`../examples/question-bank-demo.typ`](../examples/question-bank-demo.typ) for a complete document and [`../MIGRATION.md`](../MIGRATION.md) for the 1.0.6 transition.
