#set heading(numbering: none)  // Heading numbering
= Appendix
#counter(heading).update(1)

#set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

== Notation<sec:notation>
#table(
  columns: 2,
  column-gutter: 3em,
  stroke: none,
  [$C_0$], [functions with compact support],
  [$overline(RR)$], [extended real numbers $RR union {oo}$],
)
#v(1.5cm, weak: true)

== Abbreviations<sec:abbreviations>
#table(
  columns: 2,
  column-gutter: 1.55em,
  stroke: none,
  [iff], [if and only if],
  [s.t.], [such that],
  [w.r.t.], [with respect to],
  [w.l.o.g], [without loss of generality],
)

