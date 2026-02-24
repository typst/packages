#let appendix(level: 2, body) = {
  counter(heading).update(0)

  show heading: set heading(
    numbering: (..numbers) => {
      let clevel = numbers.pos().len()
      if (clevel <= level) {
        return none
      } else {
        return numbering("A ", ..numbers.pos().slice(level))
      }
    },
    supplement: [Appendix],
  )

  body
}
