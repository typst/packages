#let chapter-l1-name-str-state = state("chapter-l1-name-str")
#let chapter-l1-name-show-state = state("chapter-l1-name-show")
#let chapter-l1-true-loc-state = state("chapter-l1-true-loc")
#let chapter-l1-numbering-show-state = state("chapter-l1-numbering-show")
#let chapter-l1-page-number-show-state = state("chapter-l1-page-number-show")

#let heading-l1-updating-name-str-state = state("heading-l1-updating")

#let chapter-name-str-state = state("chapter-name-str")
#let chapter-name-show-state = state("chapter-name-show")
#let chapter-true-loc-state = state("chapter-true-loc")
#let chapter-numbering-show-state = state("chapter-numbering-show")
#let chapter-page-number-show-state = state("chapter-page-number-show")
#let chapter-level-state = state("chapter-level")

#let part-state = state("part")
#let appendix() = {
  part-state.update("附录")
  counter(heading).update(0)
  counter(heading.where(level: 1)).update(0)
}