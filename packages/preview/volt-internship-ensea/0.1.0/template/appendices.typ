
// In this file, use level 2 headings(`heading(level: 2)` or `==`)
// to properly organize the appendices under the "Appendices" chapter.

// ============================
// CONFIGURATION
// ============================

#let annexes() = {
  counter(heading).update(0)

  // From Reddit:
  // https://www.reddit.com/r/typst/comments/18exrv5/comment/kcrdfc3/
  set heading(
    numbering: (..nums) => {
      // Get the position of the title in the hierarchy
      let nums = nums.pos()

      let level = nums.len() - 1

      // Indentation could be calculated based on the level
      // let indent = level * 1em

      // Define the number to display based on the position in the hierarchy
      let num = nums.last()

      let style = ("1.", "A)", "1)").at(level)

      numbering(style, num)
    },
    supplement: "showAppendices", // I hope no one will use the 'supplement' option for appendices ^_^
  )

  // From the Polytechnique Typst Template by remigerme:
  // https://github.com/remigerme/typst-polytechnique
  let appendix(body, title: "Annexe") = {
    // From https://github.com/typst/typst/discussions/3630
    set heading(
      numbering: (..nums) => {
        let vals = nums.pos()
        let s = ""
        if vals.len() == 1 {
          s += title + " "
        }
        s += numbering("A.1.", ..vals)
        s
      },
    )

    body
  }

  show: appendix

  text[
    // ============================
    // START HERE
    // ============================

    = Une figure pour illustrer les "Annexes"
    #figure(image("media/logo.png", width: 25%), caption: [Logo générique])

    // ============================
    // STOP HERE
    // ============================
  ]
}
