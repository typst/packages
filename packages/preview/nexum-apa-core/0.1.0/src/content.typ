// Semantic section composition. Typst does not enumerate folders automatically,
// so each user project supplies a small content manifest. The library owns order.
#let labels(language: "es") = if language == "en" {
  (
    theoretical_framework: [Theoretical framework],
    objectives: [Objectives],
    materials_methods: [Materials and methods],
    results: [Results],
    discussion: [Discussion],
    conclusion: [Conclusions],
    appendices: [Appendices],
    literature_review: [Literature review],
    method: [Method],
    acknowledgments: [Acknowledgments],
  )
} else {
  (
    theoretical_framework: [Marco teórico],
    objectives: [Objetivos],
    materials_methods: [Materiales y métodos],
    results: [Resultados],
    discussion: [Discusión],
    conclusion: [Conclusiones],
    appendices: [Apéndices],
    literature_review: [Marco teórico],
    method: [Método],
    acknowledgments: [Agradecimientos],
  )
}

#let render-section(body, title: none, level: 1) = {
  if body == none {
    none
  } else if title == none {
    body
  } else {
    [
      #heading(level: level)[#title]
      #body
    ]
  }
}

#let render-laboratory-content(content, language: "es") = {
  let text-labels = labels(language: language)
  [
    #render-section(content.at("introduction", default: none))
    #render-section(content.at("theoretical_framework", default: none), title: text-labels.theoretical_framework)
    #render-section(content.at("objectives", default: none), title: text-labels.objectives)
    #render-section(content.at("materials_methods", default: none), title: text-labels.materials_methods)
    #render-section(content.at("results", default: none), title: text-labels.results)
    #render-section(content.at("discussion", default: none), title: text-labels.discussion)
    #render-section(content.at("conclusion", default: none), title: text-labels.conclusion)
    #render-section(content.at("appendices", default: none), title: text-labels.appendices)
  ]
}

#let render-academic-content(content, language: "es") = {
  let text-labels = labels(language: language)
  [
    #render-section(content.at("introduction", default: none))
    #render-section(content.at("literature_review", default: none), title: text-labels.literature_review)
    #render-section(content.at("method", default: none), title: text-labels.method)
    #render-section(content.at("results", default: none), title: text-labels.results)
    #render-section(content.at("discussion", default: none), title: text-labels.discussion)
    #render-section(content.at("conclusion", default: none), title: text-labels.conclusion)
    #render-section(content.at("acknowledgments", default: none), title: text-labels.acknowledgments)
    #render-section(content.at("appendices", default: none), title: text-labels.appendices)
  ]
}
