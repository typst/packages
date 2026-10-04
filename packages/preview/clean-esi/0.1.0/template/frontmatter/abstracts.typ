#import "@preview/clean-esi:0.1.0": abstract-page-ar, abstract-page-en, abstract-page-fr

// ESI requires one abstract per page: English, French, and Arabic.
#abstract-page-en(
  abstract-content: [Summarise the problem, the approach, and the main results in 200–300 words.],
  keywords: ("Keyword one", "Keyword two", "Keyword three"),
)

#abstract-page-fr(
  abstract-content: [Résumez le problème, l'approche et les principaux résultats.],
  keywords: ("Mot-clé un", "Mot-clé deux", "Mot-clé trois"),
)

#abstract-page-ar(
  abstract-content: [لخّص المشكلة والمنهجية وأهم النتائج.],
  keywords: ("كلمة أولى", "كلمة ثانية", "كلمة ثالثة"),
)
