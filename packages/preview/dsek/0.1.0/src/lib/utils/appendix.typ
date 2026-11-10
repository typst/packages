#import "../misc/text.typ": to-label, to-text

/// Adds an appendix on a separate page.
///
/// === Example
/// ```typst
/// #appendix("Poster som bör väljas innan årsskiftet")[
///   - Stabsmedlem
///   - Brunchmästare
///   - Framtidsledamot
/// ]
/// ```
#let apdx-counter = counter("appendix")
#let appendix(title, body) = page[
  #let count = context if apdx-counter.final().first() < 2 [] else [ #apdx-counter.display("A")]
  #counter(heading).update(0)
  #apdx-counter.step()
  #show heading.where(depth: 1, numbering: none): set text(size: 15pt)
  #context [
    #heading(
      [Appendix#count: #title],
      numbering: none,
      outlined: false,
      bookmarked: true,
      supplement: [Appendix #if apdx-counter.final().first() < 2 [] else [ #apdx-counter.display("A")]],
      depth: 1,
    )
    #label("appendix" + to-label(if apdx-counter.final().first() < 2 { "" } else { to-text[ #apdx-counter.display("A")] }, sep: "-"))
  ]
  #set heading(offset: 1, numbering: (..nums) => nums.pos().slice(1).map(str).join(".") + "  ")
  #show heading.where(level: 2): set text(size: 14pt)
  #show heading.where(level: 3): set text(size: 12pt)
  #show heading.where(level: 4): set text(size: 11pt)
  #v(1em)
  #body
]
