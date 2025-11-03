#let theorion-i18n(map) = {
  if type(map) != dictionary {
    return map
  }
  return context {
    let value = map
    if "en" in map {
      if type(map.at("en")) != dictionary {
        value = map.at("en")
      } else {
        value = map.at("en").values().at(0, default: value)
      }
    }
    if text.lang == none {
      return value
    }
    if text.lang in map {
      if type(map.at(text.lang)) != dictionary {
        value = map.at(text.lang)
      } else {
        if text.region != none and text.region in map.at(text.lang) {
          value = map.at(text.lang).at(text.region)
        } else {
          value = map.at(text.lang).values().at(0, default: value)
        }
      }
    }
    return value
  }
}

#let theorion-i18n-map = (
  theorem: (
    en: (us: "Theorem", gb: "Theorem"),
    zh: (cn: "定理", hk: "定理", tw: "定理"),
    de: (de: "Satz", at: "Satz", ch: "Satz"),
    fr: (fr: "Théorème", ca: "Théorème", ch: "Théorème"),
    es: (es: "Teorema", mx: "Teorema"),
    pt: (pt: "Teorema", br: "Teorema"),
    ja: "定理",
    ko: "정리",
    ru: "Теорема",
  ),
  lemma: (
    en: (us: "Lemma", gb: "Lemma"),
    zh: (cn: "引理", hk: "引理", tw: "引理"),
    de: (de: "Lemma", at: "Lemma", ch: "Lemma"),
    fr: (fr: "Lemme", ca: "Lemme", ch: "Lemme"),
    es: (es: "Lema", mx: "Lema"),
    pt: (pt: "Lema", br: "Lema"),
    ja: "補助定理",
    ko: "보조정리",
    ru: "Лемма",
  ),
  corollary: (
    en: (us: "Corollary", gb: "Corollary"),
    zh: (cn: "推论", hk: "推論", tw: "推論"),
    de: (de: "Korollar", at: "Korollar", ch: "Korollar"),
    fr: (fr: "Corollaire", ca: "Corollaire", ch: "Corollaire"),
    es: (es: "Corolario", mx: "Corolario"),
    pt: (pt: "Corolário", br: "Corolário"),
    ja: "系",
    ko: "따름정리",
    ru: "Следствие",
  ),
  note: (
    en: (us: "Note", gb: "Note"),
    zh: (cn: "注意", hk: "注意", tw: "注意"),
    de: (de: "Hinweis", at: "Hinweis", ch: "Hinweis"),
    fr: (fr: "Note", ca: "Note", ch: "Note"),
    es: (es: "Nota", mx: "Nota"),
    pt: (pt: "Nota", br: "Nota"),
    ja: "注意",
    ko: "주의",
    ru: "Примечание",
  ),
  warning: (
    en: (us: "Warning", gb: "Warning"),
    zh: (cn: "警告", hk: "警告", tw: "警告"),
    de: (de: "Warnung", at: "Warnung", ch: "Warnung"),
    fr: (fr: "Avertissement", ca: "Avertissement", ch: "Avertissement"),
    es: (es: "Advertencia", mx: "Advertencia"),
    pt: (pt: "Aviso", br: "Aviso"),
    ja: "警告",
    ko: "경고",
    ru: "Предупреждение",
  ),
  definition: (
    en: (us: "Definition", gb: "Definition"),
    zh: (cn: "定义", hk: "定義", tw: "定義"),
    de: (de: "Definition", at: "Definition", ch: "Definition"),
    fr: (fr: "Définition", ca: "Définition", ch: "Définition"),
    es: (es: "Definición", mx: "Definición"),
    pt: (pt: "Definição", br: "Definição"),
    ja: "定義",
    ko: "정의",
    ru: "Определение",
  ),
  axiom: (
    en: (us: "Axiom", gb: "Axiom"),
    zh: (cn: "公理", hk: "公理", tw: "公理"),
    de: (de: "Axiom", at: "Axiom", ch: "Axiom"),
    fr: (fr: "Axiome", ca: "Axiome", ch: "Axiome"),
    es: (es: "Axioma", mx: "Axioma"),
    pt: (pt: "Axioma", br: "Axioma"),
    ja: "公理",
    ko: "공리",
    ru: "Аксиома",
  ),
  postulate: (
    en: (us: "Postulate", gb: "Postulate"),
    zh: (cn: "设准", hk: "設準", tw: "設準"),
    de: (de: "Postulat", at: "Postulat", ch: "Postulat"),
    fr: (fr: "Postulat", ca: "Postulat", ch: "Postulat"),
    es: (es: "Postulado", mx: "Postulado"),
    pt: (pt: "Postulado", br: "Postulado"),
    ja: "要請",
    ko: "공준",
    ru: "Постулат",
  ),
  proposition: (
    en: (us: "Proposition", gb: "Proposition"),
    zh: (cn: "命题", hk: "命題", tw: "命題"),
    de: (de: "Satz", at: "Satz", ch: "Satz"),
    fr: (fr: "Proposition", ca: "Proposition", ch: "Proposition"),
    es: (es: "Proposición", mx: "Proposición"),
    pt: (pt: "Proposição", br: "Proposição"),
    ja: "命題",
    ko: "명제",
    ru: "Предложение",
  ),
  example: (
    en: (us: "Example", gb: "Example"),
    zh: (cn: "例", hk: "例", tw: "例"),
    de: (de: "Beispiel", at: "Beispiel", ch: "Beispiel"),
    fr: (fr: "Exemple", ca: "Exemple", ch: "Exemple"),
    es: (es: "Ejemplo", mx: "Ejemplo"),
    pt: (pt: "Exemplo", br: "Exemplo"),
    ja: "例",
    ko: "예",
    ru: "Пример",
  ),
  problem: (
    en: (us: "Problem", gb: "Problem"),
    zh: (cn: "问题", hk: "問題", tw: "問題"),
    de: (de: "Problem", at: "Problem", ch: "Problem"),
    fr: (fr: "Problème", ca: "Problème", ch: "Problème"),
    es: (es: "Problema", mx: "Problema"),
    pt: (pt: "Problema", br: "Problema"),
    ja: "問題",
    ko: "문제",
    ru: "Задача",
  ),
  exercise: (
    en: (us: "Exercise", gb: "Exercise"),
    zh: (cn: "练习", hk: "練習", tw: "練習"),
    de: (de: "Übung", at: "Übung", ch: "Übung"),
    fr: (fr: "Exercice", ca: "Exercice", ch: "Exercice"),
    es: (es: "Ejercicio", mx: "Ejercicio"),
    pt: (pt: "Exercício", br: "Exercício"),
    ja: "練習",
    ko: "연습",
    ru: "Упражнение",
  ),
  conclusion: (
    en: (us: "Conclusion", gb: "Conclusion"),
    zh: (cn: "结论", hk: "結論", tw: "結論"),
    de: (de: "Schlussfolgerung", at: "Schlussfolgerung", ch: "Schlussfolgerung"),
    fr: (fr: "Conclusion", ca: "Conclusion", ch: "Conclusion"),
    es: (es: "Conclusión", mx: "Conclusión"),
    pt: (pt: "Conclusão", br: "Conclusão"),
    ja: "結論",
    ko: "결론",
    ru: "Вывод",
  ),
  assumption: (
    en: (us: "Assumption", gb: "Assumption"),
    zh: (cn: "假设", hk: "假設", tw: "假設"),
    de: (de: "Annahme", at: "Annahme", ch: "Annahme"),
    fr: (fr: "Hypothèse", ca: "Hypothèse", ch: "Hypothèse"),
    es: (es: "Suposición", mx: "Suposición"),
    pt: (pt: "Suposição", br: "Suposição"),
    ja: "仮定",
    ko: "가정",
    ru: "Предположение",
  ),
  property: (
    en: (us: "Property", gb: "Property"),
    zh: (cn: "性质", hk: "性質", tw: "性質"),
    de: (de: "Eigenschaft", at: "Eigenschaft", ch: "Eigenschaft"),
    fr: (fr: "Propriété", ca: "Propriété", ch: "Propriété"),
    es: (es: "Propiedad", mx: "Propiedad"),
    pt: (pt: "Propriedade", br: "Propriedade"),
    ja: "性質",
    ko: "성질",
    ru: "Свойство",
  ),
  remark: (
    en: (us: "Remark", gb: "Remark"),
    zh: (cn: "注解", hk: "注解", tw: "注解"),
    de: (de: "Bemerkung", at: "Bemerkung", ch: "Bemerkung"),
    fr: (fr: "Remarque", ca: "Remarque", ch: "Remarque"),
    es: (es: "Observación", mx: "Observación"),
    pt: (pt: "Observação", br: "Observação"),
    ja: "注解",
    ko: "비고",
    ru: "Замечание",
  ),
  solution: (
    en: (us: "Solution", gb: "Solution"),
    zh: (cn: "解", hk: "解", tw: "解"),
    de: (de: "Lösung", at: "Lösung", ch: "Lösung"),
    fr: (fr: "Solution", ca: "Solution", ch: "Solution"),
    es: (es: "Solución", mx: "Solución"),
    pt: (pt: "Solução", br: "Solução"),
    ja: "解",
    ko: "풀이",
    ru: "Решение",
  ),
  proof: (
    en: (us: "Proof", gb: "Proof"),
    zh: (cn: "证明", hk: "證明", tw: "證明"),
    de: (de: "Beweis", at: "Beweis", ch: "Beweis"),
    fr: (fr: "Démonstration", ca: "Démonstration", ch: "Démonstration"),
    es: (es: "Demostración", mx: "Demostración"),
    pt: (pt: "Demonstração", br: "Demonstração"),
    ja: "証明",
    ko: "증명",
    ru: "Доказательство",
  ),
  tip: (
    en: (us: "Tip", gb: "Tip"),
    zh: (cn: "提示", hk: "提示", tw: "提示"),
    de: (de: "Tipp", at: "Tipp", ch: "Tipp"),
    fr: (fr: "Conseil", ca: "Conseil", ch: "Conseil"),
    es: (es: "Consejo", mx: "Consejo"),
    pt: (pt: "Dica", br: "Dica"),
    ja: "ヒント",
    ko: "팁",
    ru: "Подсказка",
  ),
  important: (
    en: (us: "Important", gb: "Important"),
    zh: (cn: "重要", hk: "重要", tw: "重要"),
    de: (de: "Wichtig", at: "Wichtig", ch: "Wichtig"),
    fr: (fr: "Important", ca: "Important", ch: "Important"),
    es: (es: "Importante", mx: "Importante"),
    pt: (pt: "Importante", br: "Importante"),
    ja: "重要",
    ko: "중요",
    ru: "Важно",
  ),
  caution: (
    en: (us: "Caution", gb: "Caution"),
    zh: (cn: "小心", hk: "小心", tw: "小心"),
    de: (de: "Vorsicht", at: "Vorsicht", ch: "Vorsicht"),
    fr: (fr: "Attention", ca: "Attention", ch: "Attention"),
    es: (es: "Precaución", mx: "Precaución"),
    pt: (pt: "Cuidado", br: "Cuidado"),
    ja: "注意",
    ko: "주의",
    ru: "Осторожно",
  ),
)
