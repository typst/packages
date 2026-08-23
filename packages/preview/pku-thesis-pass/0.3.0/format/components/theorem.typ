// ============================================================
// theorem.typ — 定理环境组件
// 提供编号的定理类环境（定理/定义/引理/推论/命题/性质/例/注）及证明
// ============================================================

#import "../utils/number.typ": chinesenumbering
#import "../utils/style.typ": style as _style
#import "../utils/counter.typ": chaptercounter, theoremcounter, definitioncounter, lemmacounter, corollarycounter, propositioncounter, propertycounter, examplecounter, remarkcounter

/// 编号定理的标签与正文构建
/// 生成"定理 3.1（标题）"标签并置入正文
/// 不设置段落格式，首行缩进与两端对齐继承正文样式
/// theorem-counter: 对应类型的计数器（如 theoremcounter）
/// kind-label: 环境类型前缀（如 [定理]）
/// title: 可选命名标题，显示为"（标题）"
/// body: 定理陈述内容
#let _theorem-block(theorem-counter, kind-label, title, body) = {
  context [
    #strong[#kind-label #chinesenumbering(
      chaptercounter.at(here()).first(),
      theorem-counter.at(here()).first(),
      location: here(),
    )]
    #if title != none { strong[（#title）] }
    #h(0.5em)
    #body
  ]
}

/// 工厂函数：统一生成定理类环境（定理/定义/引理/推论/命题/性质/例/注）
/// name: 中文名（如 "定理"），kind: figure kind，supplement: 引用前缀，counter: 对应计数器
#let _make-theorem(name, kind, supplement, counter) = {
  (title: none, body) => figure(
    _theorem-block(counter, [#name], title, body),
    kind: kind, supplement: supplement,
  )
}

#let theorem     = _make-theorem("定理",    "theorem",     [定理], theoremcounter)
#let definition  = _make-theorem("定义",    "definition",  [定义], definitioncounter)
#let lemma       = _make-theorem("引理",    "lemma",       [引理], lemmacounter)
#let corollary   = _make-theorem("推论",    "corollary",   [推论], corollarycounter)
#let proposition = _make-theorem("命题",    "proposition", [命题], propositioncounter)
#let property    = _make-theorem("性质",    "property",    [性质], propertycounter)
#let example     = _make-theorem("例",      "example",     [例],   examplecounter)
#let remark      = _make-theorem("注",      "remark",      [注],   remarkcounter)

/// 证明环境：不编号，"证明"开头，正文后接空心方框 □ 收尾
#let proof(body) = par(
  [#strong[证明] #h(0.5em) #body #h(0.5em) #text(size: _style.证明.标记字号)[#sym.square]],
)
