// Single counter shared across all theorem-like environments, reset per chapter
#let thm-counter = counter("theorem")

// Internal helper: renders a numbered block with a bold label
#let thm-block(supplement, body, name: none) = {
  thm-counter.step()
  context {
    let chapter-num = counter(heading).get().first()
    let thm-num = thm-counter.get().first()
    let label = str(chapter-num) + "." + str(thm-num)
    let header = if name != none {
      [*#supplement #label* (#name)*.*]
    } else {
      [*#supplement #label.*]
    }
    block(above: 1em, below: 1em)[#header #body]
  }
}

#let theorem(body, name: none) = thm-block([Theorem], body, name: name)
#let lemma(body, name: none) = thm-block([Lemma], body, name: name)
#let corollary(body, name: none) = thm-block([Corollary], body, name: name)
#let proposition(body, name: none) = thm-block([Proposition], body, name: name)
#let definition(body, name: none) = thm-block([Definition], body, name: name)
#let example(body, name: none) = thm-block([Example], body, name: name)
#let remark(body, name: none) = thm-block([Remark], body, name: name)
#let claim(body, name: none) = thm-block([Claim], body, name: name)

#let proof(body) = block(above: 1em, below: 1em)[_Proof._ #body #h(1fr) $square$]
