#import "../touying.typ": utils

// Use logical slide counters: animation frames repeat a number, while explicit
// backup-slide calls retain the preceding number and do not inflate totals.
#let slide-number(self) = context {
  let current = utils.slide-counter.get().first()
  let main-total = utils.last-slide-counter.final().first()
  if current > main-total {
    let pattern = self.store.appendix-numbering
    if pattern != none {
      let appendix-current = current - main-total
      if self.store.appendix-total {
        let appendix-total = utils.slide-counter.final().first() - main-total
        if type(pattern) == function {
          numbering(pattern, appendix-current, appendix-total)
        } else {
          [#numbering(pattern, appendix-current) / #numbering(pattern, appendix-total)]
        }
      } else {
        numbering(pattern, appendix-current)
      }
    }
  } else {
    utils.slide-counter.display() + " / " + utils.last-slide-number
  }
}
