// mcx.typ — A Typst package for typesetting multiple-choice exams. It is a Typst implementation inspired by the LaTeX package *mcexam*, redesigned for Typst's capabilities.
//
// Core features implemented:
// - Define multiple-choice questions with answers, correctness/points, explanations, notes.
// - Generate multiple deterministic versions via seed.
// - Randomize question blocks (respecting `follow`) and answer order (permute types).
//   - permute types: permuteall, fixlast, fixlastn, ordinal, permutenone, user-defined permutations.
// - Render different outputs: concept, exam, answers, key.
// - Render permutation tables and answer key tables.
//
// Minimum Typst version: 0.14 (required by suiji package).

#import "utils.typ": *

// -------------------------
// Public data constructors
// -------------------------

/// Create an answer.
/// - body (content): content of the answer.
/// - mark (string | number): "correct" or a number (points). Use none for 0.
#let mc-answer(body, mark: none) = (
  body: body,
  mark: mark,
)

/// Create a question object.
/// - `body` (content): The core content of the question. Supports text, math equations, and code blocks.
/// - `answers` (array): An array of answer objects generated using the `mc-answer` function.
/// - `follow` (boolean): Connectivity logic. If `true`, this question is bundled into a "block" with the previous one, ensuring they are shuffled together as a single unit. Ideal for reading comprehension or data analysis sets.
/// - `instruction` (content): Optional introductory text (e.g., "Read the following passage to answer questions 1-3") that appears *before* the question body.
/// - `explanation` (content): Optional solution or explanation shown only in the `concept` and `answers` output modes.
/// - `notes` (content): Optional internal notes or metadata shown only in the `concept` output mode.
/// - `permute`: Logic for shuffling answer choices.
///   - `"permuteall"` **Full Random**: Shuffles all choices randomly (Default). |
///   - `"fixlast"` **Fix Last**: Shuffles all choices except for the very last one (useful for "None of the above").
///   - `(type: "fixlastn", n: 2)` **Fix Last N**: Keeps the specified number of choices at the end of the list static. `n` is clamped to `[1, total answers]`.
///   - `"ordinal"` **Ordinal**: Maintains a logical or sequential order while still allowing for permutation logic.
///   - `"permutenone"` **No Shuffling**: Displays choices in the exact order they are defined in the code.
///   - `(1, 3, 2, 4)` **Fixed Map**: Manually forces a specific display order using an array of 1-based indices.
///   - `((1,2..), (2,1..))` **Multi-Version Map**: Provides distinct manual permutations for different versions of the exam.
#let mc-question(
  body,
  answers,
  follow: false,
  permute: "permuteall",
  instruction: none,
  explanation: none,
  notes: none,
) = (
  body: body,
  answers: answers,
  follow: follow,
  permute: permute,
  instruction: instruction,
  explanation: explanation,
  notes: notes,
)

/// Render multiple-choice questions.
/// Parameters:
/// - `questions`: array of questions created with `mc-question`.
/// - `output`: output mode. One of:
///   - `"concept"`: Concept version with all details.
///   - `"exam"`: Student exam version.
///   - `"answers"`: Answer version with solutions.
///   - `"key"`: Answer key table only.
/// - `number-of-versions`: total number of versions.
/// - `version`: selected version (used when output wants per-version output).
/// - `seed`: positive integer controlling deterministic randomization.
/// - `randomize-questions`: shuffle question blocks.
/// - `randomize-answers`: shuffle answers according to `permute`.
/// - `config` : boolean dictionary overriding defaults (any of the cfg keys)
///   - `show-per-version`: Show per-version question numbering.
///   - `show-q-perm-table`: Show question permutation table.
///   - `show-q-list`: Show question list.
///   - `show-correct`: Show correct answers.
///   - `show-points`: Show points.
///   - `show-explanation`: Show explanations.
///   - `show-a-perm-table`: Show answer permutation table.
///   - `show-notes`: Show internal notes.
///   - `show-key-table`: Show answer key table.
#let mc-questions(
  questions,
  output: "exam",
  number-of-versions: 4,
  version: 1,
  seed: 1,
  randomize-questions: true,
  randomize-answers: true,
  config: none,
) = {
  // Sanitize inputs
  let cfg = _cfg(output, config)
  let v = calc.clamp(int(version), 1, number-of-versions)
  seed = calc.clamp(int(seed), 1, 2147483647)

  // Precompute permutations
  let q_order_by_v = _permute_questions(questions, number-of-versions, seed, randomize-questions)
  let answers_perm_by_v = _permute_answers(questions, number-of-versions, seed, randomize-answers)

  let components = (
    _heading_for(output, v, cfg),
    _question_perm_table(questions, number-of-versions, q_order_by_v, cfg),
    _question_list(
      questions,
      if cfg.show-per-version { v } else { 1 },
      number-of-versions,
      q_order_by_v,
      answers_perm_by_v,
      cfg,
      output,
    ),
    _key_table(questions, number-of-versions, q_order_by_v, answers_perm_by_v, cfg),
  )

  components.filter(it => it != none).join()
}
