#let background-color-state = state("zebraw-background-color", luma(245))
#let highlight-color-state = state("zebraw-highlight-color", rgb("#94e2d5").lighten(70%))
#let comment-color-state = state("zebraw-comment-color", none)
#let lang-color-state = state("zebraw-lang-color", none)

#let inset-state = state("zebraw-inset", (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em))
#let comment-flag-state = state("zebraw-comment-flag", ">")
#let lang-state = state("zebraw-lang", true)
#let extend-state = state("zebraw-extend", true)

#let numbering-font-args-state = state("zebraw-numbering-font-args", (:))
#let comment-font-args-state = state("zebraw-comment-font-args", (:))
#let lang-font-args-state = state("zebraw-lang-font-args", (:))
