// Public entrypoint. Dependencies remain available as modules for advanced use.
#import "src/book.typ": neat-book
#import "src/fonts.typ": default-fonts, zh, en, ja, ko
#import "src/components.typ": introduction
#import "src/theorems.typ": (
  theorem, definition, example, lemma, proposition, corollary, axiom,
  postulate, assumption, property, conjecture, remark, note, exercise,
  problem, proof, solution, conclusion, qedhere, theorion,
  note-block, tip-block, important-block, warning-block, caution-block,
  remark-block, quote-block, emph-block,
)
#import "src/algorithms.typ": algorithm, algorithmic
#import "src/code.typ": codeblock, codly, codly-languages
