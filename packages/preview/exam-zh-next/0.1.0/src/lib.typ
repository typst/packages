// exam-zh: Chinese exam papers for Typst.

#import "config.typ": (
    circled-number, exam-setup, exam-state, fangsong, font-presets, heiti, kaishu, songti,
    student-only, teacher-only, with-setup, zihao,
)
#import "template.typ": exam, teacher-defaults
#import "page.typ": draftpaper
#import "title.typ": (
    chapter, exam-outline, examsquare, information, make-title, notice,
    scoringbox, secret, warning,
)
#import "question.typ": (
    case, fillin, method, paren, print-moved-solutions, problem, question,
    score, solution, step,
)
#import "choices.typ": choices

// `set-choices(..)` is `exam-setup(choices: (..))`.
#let set-choices(..args) = exam-setup(choices: args.named())
#import "math.typ": calculations, eu, iu, upe, upi, uppi, vect
#import "figures.typ": multifigures, textfigure
// Textbook-style math symbols; `#import symbols: *` puts them in scope.
#import "symbols.typ"
#import "chinese.typ": composition-grid, lineto, material, poem, select, zhu
#import "english.typ": writingbox, writingline, writinglines
