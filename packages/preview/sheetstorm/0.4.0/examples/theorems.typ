#import "@preview/sheetstorm:0.4.0": (
  assignment, corollary, lemma, proof, task, theorem,
)


#show: assignment.with(
  title: "Theorem-Style Demonstration",
  authors: "GOATlob Frege",
)

#task(points: 42)[
  #theorem[This is a theorem with the standard numbering and no name.]

  #theorem(name: [Beautiful Name])[
    This theorem is special because it is named. The numbering follows the standard.
  ]

  #theorem(emphasized: false)[
    This is a theorem without emphasized text.
  ]

  #theorem(numbering: "4.2")[
    This theorem uses a custom numbering.
    Be creative when defining your one numbering style.
  ]

  #theorem(label: "banana", name: "Yellow bananas")[
    Bananas are yellow.
  ]

  Now you can reference @banana easily and it's displayed with a nice name.
  Or you link to it manually: #link(<banana>)[banana].

  #corollary(label: "cor")[
    A corollary usually follows from a preceding theorem.
  ]

  Of course, you can also reference @cor.

  #lemma[
    A lemma is typically a supporting statement.
    You can also assign a name or custom numbering as for theorem.
  ]

  #proof[This is a standard proof.]

  #proof(qed: $q.e.d.$)[
    This proof ends with a custom symbol.
  ]
]
