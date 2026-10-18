#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#import "../consts.typ": *
#import "@preview/theoretic:0.2.0" as theoretic: fmt-body, proof, theorem

#let equation-code = "equation-code"

#let equation-numering(nums, element: none) = {
  let chapter-num = counter(heading.where(level: 1)).display()
  let loc = if element != none { element.location() } else { here() }
  let type-num = counter(equation-code + chapter-num).at(loc).first()
  let num-str = (
    "(" + numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num) + 1) + ")"
  )
  num-str
}

#let equation-numering-step() = {
  let chapter-num = counter(heading.where(level: 1)).display()
  counter(equation-code + chapter-num).step()
}

#let frac-depth = state("frac-depth", 0)
#let cases-depth = state("cases-depth", 0)

#let set-equation(body) = {
  set math.equation(
    numbering: equation-numering,
    supplement: [式],
    number-align: horizon,
  )

  // 嵌套分数处理. 首层分数不缩小字体。attach里的base不缩小字体。
  show math.attach: it => {
    if it.has("label") and it.label == <__stop__> {
      return it
    }
    let fields = it.fields()
    let base = fields.remove("base")
    for key in ("t", "b", "tl", "bl", "tr", "br") {
      if key in fields and fields.at(key) != none {
        fields.insert(key, {
          frac-depth.update(d => d + 999)
          fields.at(key, default: none)
          frac-depth.update(d => d - 999)
        })
      }
    }
    [#math.attach(base, ..fields) <__stop__>]
  }

  set math.cases(gap: 0.6em)
  show math.cases: it => {
    if it.has("label") and it.label == <__stop__> {
      return it
    }
    let fields = it.fields()
    let children = fields.remove("children")
    children = children.map(item => {
      cases-depth.update(d => d + 1)
      item
      cases-depth.update(d => d - 1)
    })
    let tagged-display = [#math.cases(..children, ..fields) <__stop__>]
    context {
      let depth = cases-depth.get()
      if depth < 1 {
        math.display(tagged-display)
      } else {
        it
      }
    }
  }

  show math.equation.where(block: true): it => {
    show math.frac: it => {
      if it.has("label") and it.label == <__stop__> {
        return it
      }
      let nested-num = {
        frac-depth.update(d => d + 1)
        it.num
        frac-depth.update(d => d - 1)
      }

      let nested-denom = {
        frac-depth.update(d => d + 1)
        it.denom
        frac-depth.update(d => d - 1)
      }
      let tagged-frac = [#math.frac(nested-num, nested-denom, style: it.style) <__stop__>]

      context {
        let depth = frac-depth.get()
        if depth < 1 {
          math.display(tagged-frac)
        } else {
          tagged-frac
        }
      }
    }

    let formatting = math.equation(numbering: none, it.body)
    set text(size: font-size.小四)

    let eqNumbering = none
    // if it.has("label"){
    let eqCounter = counter(math.equation).at(it.location())
    equation-numering-step()
    eqNumbering = numbering(it.numbering, ..eqCounter)
    // }

    // 设置公式内部行距 (防止切断积分号)
    set par(leading: 单倍行距)

    block(
      width: 100%,
      inset: 0pt, // 确保没有额外内边距
      above: above-leading-space(space: 7pt, word-space: 单倍行距),
      below: below-leading-space(4pt),
      // stroke: 0.5pt,
      grid(
        columns: (1fr, auto, 1fr),
        [],
        align(horizon)[
          // #set text(top-edge: "cap-height", bottom-edge: "baseline")
          #set text(top-edge: "bounds", bottom-edge: "bounds")
          // #set par(leading: 20pt)
          #formatting
        ],
        align(right + horizon)[#eqNumbering],
      ),
    )
  }
  body
}

#let theorem-supplement = text(font: "SimHei")[定理]
#let lemma-supplement = text(font: "SimHei")[引理]
#let proof-supplement = text(font: "SimHei")[证明]

#let numbering-theorem(kind: none, step: false, ref: none) = {
  let loc = if ref != none { ref } else { here() }
  let n = counter(heading.where(level: 1)).at(loc).first()
  let thm-counter = counter("_thm" + str(n))
  let name-counter = if kind != none { kind + str(n) } else { "_thm" + str(n) }
  if step {
    counter(name-counter).step()
  }
  let count = counter(name-counter).at(loc).first() + 1
  let num = numbering("1", n) + "." + str(count)
  num
}

#let new-fmt-body(body, solution) = {
  [
    #let body-content = body
    #if body.has("children") and body.children.first() == [#parbreak()] {
      // 3. 切片：跳过第 0 个，取从第 1 个开始的所有元素，然后 join 重新拼接成 content
      body-content = body.children.slice(1).join()
    }
    #fmt-body(body-content, solution)
    #parbreak()
  ]
}

#let theorem = theorem.with(
  fmt-prefix: (s, n, t) => {
    let num = numbering-theorem(kind: s.child.text, step: true)
    text[#s#num]
    if t != none {
      h(2pt)
    }
    h(0.5em)
  },
  fmt-body: new-fmt-body,
  supplement: theorem-supplement,
  kind: "theorem",
  toctitle: false,
)

#let lemma = theorem.with(
  supplement: lemma-supplement,
  kind: "lemma",
)

#let proof = proof.with(
  fmt-prefix: (s, n, t) => {
    {
      if t != none {
        let ele = query(t.target)
        let num = numbering-theorem(kind: ele.first().value.supplement.child.text, step: false, ref: t.target)
        t = link(ele.first().location())[#ele.first().value.supplement#num]
      }

      if t != none [#t]
      s
      if n != none [ #n]
      h(0.5em)
    }
  },
  fmt-suffix: () => [#h(1fr)$qed$],
  fmt-body: new-fmt-body,
  supplement: proof-supplement,
)

#let show-ref(
  it,
) = {
  let el = it.element
  if (
    el != none
      and el.func() == metadata
      and type(el.value) == dictionary
      and el.value.at("theorem-kind", default: none) != none
  ) {
    let ele = query(it.target)

    if ele.first().value.theorem-kind == "proof" {
      assert(ele.first().value.title != none, message: "证明的引用必须有标题")
      if ele.first().value.title != none {
        let title-ref = ele.first().value.title.target
        let title-ele = query(title-ref)
        let num = numbering-theorem(
          kind: title-ele.first().value.supplement.child.text,
          step: false,
          ref: title-ref,
        )
        link(ele.first().location())[#title-ele.first().value.supplement#num#ele.first().value.supplement]
      }
    } else {
      let num = numbering-theorem(
        kind: ele.first().value.supplement.child.text,
        step: false,
        ref: it.target,
      )
      link(ele.first().location())[#ele.first().value.supplement#num]
    }
  } else {
    // Other references as usual.
    it
  }
}

#let set-theoretic(body) = {
  show ref: show-ref
  body
}
