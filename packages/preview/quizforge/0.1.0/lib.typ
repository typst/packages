// quizforge — randomized exam sets from a single Typst source.
//
// Two authoring styles, one engine:
//
// 1. Plain markup (recommended):        2. Question banks (constructors):
//
//    #show: quiz.with(id: "quiz-1")        #make-exam(
//    = Multiple Choice                       exam: (id: "quiz-1", ..),
//    + #m(2) Why does $x$ matter?            questions: bank,
//      - ✓ because reasons                   sections: (
//      - not this                              (title: .., filter: .., pick: 8),
//                                            ),
//                                          )
//
// Compile with --input set=B --input mode=exam|key. See the package README.

// Plain-markup front-end
#import "src/parse.typ": quiz

// Constructor front-end
#import "src/model.typ": mcq, fib, subj, opt, ans
#import "src/render.typ": make-exam, exam-doc

// Inline markers (markup mode) — all render as nothing and configure the
// question they appear in.
#import "src/model.typ": blank, m, yes, pin, pin-first, qid, opts, explain, answer, section

// Power-user access to the deterministic PRNG and text extraction.
#import "src/rng.typ" as rng
#import "src/base.typ": plaintext
