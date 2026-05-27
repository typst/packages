// Appendix — matches LaTeX
#let appendix(humanities: false, body) = {
  heading(level: 1, numbering: none, outlined: true)[附录]
  set heading(numbering: (..nums) => {
    let pos = nums.pos()
    let lv = pos.len()
    let letter(n) = numbering("A", n)
    if humanities {
      if lv == 2 { "（" + letter(pos.at(1)) + "）" }
      else if lv == 3 { str(pos.at(2)) + "." }
    } else {
      if lv == 2 { letter(pos.at(1)) + "." }
      else if lv == 3 { letter(pos.at(1)) + "." + str(pos.at(2)) }
    }
  })
  counter(heading).update(1)

  // Reset appendix figure/table counters at each H2 section
  show heading: it => {
    if it.level == 2 {
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(figure.where(kind: "algo")).update(0)
    }
    it
  }

  // Appendix figure/table numbering: letter-based per-section (A.1, A.2; B.1, B.2 …)
  // Uses set rather than show to avoid the recursion/condition problem with non-none numbering.
  set figure(numbering: n => context {
    let hc = counter(heading).get()
    let sec = hc.at(1, default: 1)
    numbering("A", sec) + "." + str(n)
  })

  body
}
