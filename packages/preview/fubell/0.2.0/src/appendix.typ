// Appendix helper — switches heading numbering to appendix style.
//
// Usage:
//   #show: appendix
//   = First Appendix    // → "Appendix A" or "附錄A"
//   == Section           // → "A.1"

#import "config.typ"

#let appendix(body) = {
  counter(heading).update(0)

  let appendix-numbering = (..nums) => {
    let nums = nums.pos()
    if nums.len() == 1 {
      context {
        let prefix = if text.lang == "zh" { "附錄" } else { "Appendix " }
        prefix + numbering("A", nums.first()) + " "
      }
    } else {
      numbering("A.1", ..nums) + " "
    }
  }

  set heading(numbering: appendix-numbering)

  body
}
