// Appendix helper — switches heading numbering to appendix style.
//
// Usage:
//   #show: appendix
//   = First Appendix    // → "Appendix A" or "附錄A"
//   == Section           // → "A.1"

#import "config.typ"

// Styled bibliography not yet placed. NTU order puts 參考文獻 before 附錄,
// so `thesis` stores it here and `appendix` places it ahead of the appendices.
// Whatever is still pending at the end of the document is placed there.
#let pending-bibliography = state("fubell-pending-bibliography", none)

#let appendix(body) = {
  context pending-bibliography.get()
  pending-bibliography.update(none)
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
