// great-theorems 定理环境封装
#import "@preview/great-theorems:0.1.2": mathblock, proofblock
#import "@preview/headcount:0.1.1": dependent-numbering

#let theorem-counter = counter("theorem")
#let lemma-counter = counter("lemma")
#let corollary-counter = counter("corollary")
#let definition-counter = counter("definition")
#let proposition-counter = counter("proposition")
#let example-counter = counter("example")

#let theorem = mathblock(
  blocktitle: "定理",
  counter: theorem-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[定理 #counter:],
)

#let lemma = mathblock(
  blocktitle: "引理",
  counter: lemma-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[引理 #counter:],
)

#let corollary = mathblock(
  blocktitle: "推论",
  counter: corollary-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[推论 #counter:],
)

#let definition = mathblock(
  blocktitle: "定义",
  counter: definition-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[定义 #counter:],
)

#let proposition = mathblock(
  blocktitle: "命题",
  counter: proposition-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[命题 #counter:],
)

#let example = mathblock(
  blocktitle: "例",
  counter: example-counter,
  numbering: dependent-numbering("1.1", levels: 1),
  prefix: counter => strong[例 #counter:],
)

#let remark = mathblock(
  blocktitle: "备注",
  prefix: strong[备注:],
)

#let proof = proofblock(
  blocktitle: "证明",
  prefix: strong[证明:],
  prefix_with_of: of => strong[证明（#of）:],
  suffix: [#h(1fr) $square$],
)
