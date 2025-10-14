#import "utils.typ"
#import "store.typ" as store: default-frozen-counters


// put `alias-counter.step()` after each specified elements.
#let apply-cover-counters(cont, covering: default-frozen-counters) = {
  let is-numbering(element) = element.at("numbering") != none

  show math.equation.where(block: true): it => {
    it
    if is-numbering(it) {
      covering.at("math.equation").cover.step()
    }
  }
  show heading: it => {
    it
    if is-numbering(it) {
      covering.at("heading").cover.step(level: it.level)
    }
  }
  show figure.where(kind: "image"): it => {
    it
    if is-numbering(it) {
      covering.at("image").cover.step()
    }
  }
  show figure.where(kind: "table"): it => {
    it
    if is-numbering(it) {
      covering.at("table").cover.step()
    }
  }
  show quote: it => {
    it
    if is-numbering(it) {
      covering.at("quote").cover.step()
    }
  }
  show footnote: it => {
    it
    if is-numbering(it) {
      covering.at("footnote").cover.step()
    }
  }
  cont
}

// Rewind the counter values by subtracting the current counter number by its alias counter.
#let freeze-counter-marker(
  i,
  steps,
) = if store.settings.get().freeze-counter and i < steps {

  // Get current values of cover counters
  let cover-counter-values = store
    .settings
    .get()
    .frozen-counters
    .values()
    .map(it => it.cover.get())
  // Update normal counters based on cover counter values
  for (real, cover) in store
    .settings
    .get()
    .frozen-counters
    .values()
    .map(it => it.real)
    .zip(cover-counter-values) {
    real.update((..n) => {
      utils.subtract-array(n.pos().map(it => it), cover).map(it => {
        it 
      })
    })
  }
}
