#let thm-dict = (
  definition: (en: "Definition", fr: "Définition", ko: "정의", ja: "定義", zh: "定义"),
  property: (en: "Property", fr: "Propriété", ko: "성질", ja: "性質", zh: "性质"),
  axiom: (en: "Axiom", fr: "Axiome", ko: "공리", ja: "公理", zh: "公理"),
  postulate: (en: "Postulate", fr: "Postulat", ko: "공준", ja: "公準", zh: "公设"),
  assumption: (en: "Assumption", fr: "Hypothèse", ko: "가정", ja: "仮定", zh: "假设"),
  hypothesis: (en: "Hypothesis", fr: "Hypothèse", ko: "가설", ja: "仮説", zh: "假说"),
  conjecture: (en: "Conjecture", fr: "Conjecture", ko: "추측", ja: "予想", zh: "猜想"),
  proposition: (en: "Proposition", fr: "Proposition", ko: "명제", ja: "命題", zh: "命题"),
  lemma: (en: "Lemma", fr: "Lemme", ko: "보조정리", ja: "補題", zh: "引理"),
  theorem: (en: "Theorem", fr: "Théorème", ko: "정리", ja: "定理", zh: "定理"),
  corollary: (en: "Corollary", fr: "Corollaire", ko: "따름정리", ja: "系", zh: "推论"),
  remark: (en: "Remark", fr: "Remarque", ko: "주의", ja: "注意", zh: "注记"),
  note: (en: "Note", fr: "Note", ko: "노트", ja: "ノート", zh: "注释"),
)

#let thm-array = thm-dict.values().map(v => lower(v.en))


#let support-dict = (
  proof: (en: "Proof", fr: "Démonstration", ko: "증명", ja: "証明", zh: "证明"),
  example: (en: "Example", fr: "Exemple", ko: "예제", ja: "示例", zh: "示例"),
  exercise: (en: "Exercise", fr: "Exercice", ko: "연습", ja: "演習", zh: "练习"),
  problem: (en: "Problem", fr: "Problème", ko: "문제", ja: "問題", zh: "问题"),
  solution: (en: "Solution", fr: "Solution", ko: "풀이", ja: "解答", zh: "解答"),
  conclusion: (en: "Conclusion", fr: "Conclusion", ko: "결론", ja: "結論", zh: "结论"),
)

#let support-array = support-dict.values().map(v => lower(v.en))


#let kind-array = thm-array + support-array