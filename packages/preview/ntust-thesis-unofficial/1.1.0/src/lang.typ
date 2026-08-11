// Language-dependent labels for the NTUST thesis template
// Note: Typst's #outline() and #bibliography() have language-dependent titles
//       controlled by `set text(lang: ...)`. These labels are for custom sections
//       that don't have built-in Typst translations.

#let labels = (
  en: (
    recommendation-form: "Recommendation Form",
    committee-form: "Qualification Form",
    copyright-form: "Letter of Authority",
    c-abstract: "摘要",
    e-abstract: "ABSTRACT",
    acknowledgement: "Acknowledgments",
    toc: "Table of Contents",
    lot: "List of Tables",
    lof: "List of Figures",
    loa: "List of Algorithms",
    symbols: "Symbols",
    references: "References",
    vita: "Biography",
    degree-thesis: "Thesis",
    chapter-pre: "Chapter",
    chapter-post: "",
    abstract-label: "Abstract",
    advisor-label: "Advisor: ",
  ),
  zh: (
    recommendation-form: "指導教授推薦書",
    committee-form: "考試委員審定書",
    copyright-form: "授權書",
    c-abstract: "摘要",
    e-abstract: "ABSTRACT",
    acknowledgement: "誌謝",
    toc: "目錄",
    lot: "表目錄",
    lof: "圖目錄",
    loa: "演算法目錄",
    symbols: "符號說明",
    references: "參考文獻",
    vita: "自傳",
    degree-thesis: "學位論文",
    chapter-pre: "第",
    chapter-post: "章",
    abstract-label: "摘要",
    advisor-label: "指導教授：",
  ),
)

#let get-labels(lang) = {
  if lang == "zh" { labels.zh } else { labels.en }
}
