// ============================================================
// thETS — Chaînes localisées (français / anglais)
// Portage des sections 6a–6c de thETS.cls.
// ============================================================

// Les dates sont mises en forme par datify, qui couvre les locales CLDR.
// `custom-date-format` rend une chaîne : les libellés du jury et des articles
// la concatènent et lui appliquent `upper`.
#import "@preview/datify:1.3.0": custom-date-format

// Date longue : « 15 mai 2026 » en français, « May 15, 2026 » en anglais.
// Un code de langue inconnu retombe sur l'anglais.
#let long-date(d, lang) = {
  if d == none { return "" }
  custom-date-format(d, pattern: "long", lang: lang)
}

// Mois + année : utilisé pour le statut de publication des articles.
#let month-year(d, lang) = {
  if d == none { return "" }
  custom-date-format(d, pattern: "MMMM y", lang: lang)
}

#let strings = (
  fr: (
    // Sections préliminaires
    foreword: "Avant-propos",
    acknowledgements: "Remerciements",
    resume: "RÉSUMÉ",
    abstract: "ABSTRACT",
    keywords-fr: "Mots-clés:",
    keywords-en: "Keywords:",
    contents: "Table des matières",
    list-of-tables: "Liste des tableaux",
    list-of-figures: "Liste des figures",
    list-of-algorithms: "Liste des algorithmes",
    list-of-abbr: "Liste des abréviations, sigles et acronymes",
    list-of-symbols: "Liste des symboles et unités de mesure",
    page: "Page",

    // Corps
    introduction: "Introduction",
    conclusion: "Conclusion",
    recommendations: "Recommandations",

    // Divisions
    chapter: "Chapitre",
    annex: "Annexe",
    appendix: "Appendice",

    // Flottants
    figure: "Figure",
    table: "Tableau",
    algorithm: "Algorithme",
    equation: "Équation",
    figure-annex: "Figure-A",
    table-annex: "Tableau-A",
    algorithm-annex: "Algorithme-A",
    taken-from: "Tiré de ",

    // Bibliographies
    bibname: "LISTE DE RÉFÉRENCES BIBLIOGRAPHIQUES",
    refsname: "BIBLIOGRAPHIE",

    // Page titre
    by: "par",
    presented-thesis: "THÈSE PRÉSENTÉE",
    presented-manuscript-thesis: "THÈSE PAR ARTICLES PRÉSENTÉE",
    presented-masters: "MÉMOIRE PRÉSENTÉ",
    presented-manuscript-masters: "MÉMOIRE PAR ARTICLES PRÉSENTÉ",
    presented-project: "RAPPORT DE PROJET PRÉSENTÉ",
    cotutorship-mid: " EN COTUTELLE",
    to-ets: " À L'ÉCOLE DE TECHNOLOGIE SUPÉRIEURE",
    cotutorship-and: " ET À ",
    partial-requirement: "COMME EXIGENCE PARTIELLE À L'OBTENTION ",
    city-line: "MONTRÉAL, LE ",
    university: "ÉCOLE DE TECHNOLOGIE SUPÉRIEURE\nUNIVERSITÉ DU QUÉBEC",
    all-rights: "Tous droits réservés, ",
    in-field: " EN ",

    // Diplômes
    diploma-masters: "DE LA MAÎTRISE\nAVEC MÉMOIRE",
    diploma-masters-suffix: "M. Sc. A.",
    diploma-project: "DE LA MAÎTRISE\nAVEC PROJET",
    diploma-project-suffix: "M. Ing.",
    diploma-doctorate: "DU DOCTORAT",
    diploma-doctorate-suffix: "Ph. D.",

    // Verso licence
    licence-reserved-title: "Tous droits réservés",
    licence-reserved-body: "Cette licence signifie qu'il est interdit de reproduire, d'enregistrer ou de diffuser en tout ou en partie, le présent document. Le lecteur qui désire imprimer ou conserver sur un autre media une partie importante de ce document, doit obligatoirement en demander l'autorisation à l'auteur.",
    licence-cc-body-before: "Cette ",
    licence-cc-link: "licence Creative Commons CC BY-NC-ND 4.0",
    licence-cc-body-after: " signifie qu'il est permis de diffuser, d'imprimer ou de sauvegarder sur un autre support une partie ou la totalité de cette œuvre à condition de créditer l'auteur, que ces utilisations soient faites à des fins non commerciales et que le contenu de l'œuvre n'ait pas été modifié.",

    // Page du jury
    jury-title: "PRÉSENTATION DU JURY",
    jury-eval-thesis: "CETTE THÈSE A ÉTÉ ÉVALUÉE",
    jury-eval-masters: "CE MÉMOIRE A ÉTÉ ÉVALUÉ",
    jury-eval-project: "CE RAPPORT DE PROJET A ÉTÉ ÉVALUÉ",
    jury-composed: "PAR UN JURY COMPOSÉ DE:",
    defense-thesis: "ELLE A FAIT L'OBJET D'UNE SOUTENANCE DEVANT JURY ET PUBLIC",
    defense-masters: "IL A FAIT L'OBJET D'UNE SOUTENANCE DEVANT JURY ET PUBLIC",
    defense-date-prefix: "LE ",
    defense-place: "À L'ÉCOLE DE TECHNOLOGIE SUPÉRIEURE",

    // Rôles du jury
    role-supervisor-thesis: "direction de thèse",
    role-supervisor-masters: "direction de mémoire",
    role-supervisor-project: "direction de projet",
    role-cosupervisor-thesis: "codirection de thèse",
    role-cosupervisor-masters: "codirection de mémoire",
    role-cosupervisor-project: "codirection de projet",
    role-chair: "présidence du jury",
    role-jury: "membre du jury",
    role-external: "jury externe",
    role-independent: "jury externe indépendant",
    default-affiliation: "École de technologie supérieure",

    // Articles intégrés
    article-submitted: "Article soumis pour publication, ",
    article-accepted-before: "Article accepté pour publication dans ",
    article-published-before: "Article publié dans ",

    // Filigrane
    confidential: "CONFIDENTIEL",
  ),

  en: (
    foreword: "Foreword",
    acknowledgements: "Acknowledgements",
    resume: "RÉSUMÉ",
    abstract: "ABSTRACT",
    keywords-fr: "Mots-clés:",
    keywords-en: "Keywords:",
    contents: "Table of Contents",
    list-of-tables: "List of Tables",
    list-of-figures: "List of Figures",
    list-of-algorithms: "List of algorithms",
    list-of-abbr: "List of abbreviations and acronyms",
    list-of-symbols: "List of symbols and units of measurements",
    page: "Page",

    introduction: "Introduction",
    conclusion: "Conclusion",
    recommendations: "Recommendations",

    chapter: "Chapter",
    annex: "Annex",
    appendix: "Appendix",

    figure: "Figure",
    table: "Table",
    algorithm: "Algorithm",
    equation: "Equation",
    figure-annex: "Figure-A",
    table-annex: "Table-A",
    algorithm-annex: "Algorithm-A",
    taken-from: "Taken from ",

    bibname: "LIST OF BIBLIOGRAPHICAL REFERENCES",
    refsname: "BIBLIOGRAPHY",

    by: "by",
    presented-thesis: "THESIS PRESENTED",
    presented-manuscript-thesis: "MANUSCRIPT-BASED THESIS PRESENTED",
    presented-masters: "THESIS PRESENTED",
    presented-manuscript-masters: "MANUSCRIPT-BASED THESIS PRESENTED",
    presented-project: "PROJECT REPORT PRESENTED",
    cotutorship-mid: "",
    to-ets: " TO ÉCOLE DE TECHNOLOGIE SUPÉRIEURE",
    cotutorship-and: " AND ",
    partial-requirement: "IN PARTIAL FULFILLMENT ",
    city-line: "MONTREAL, ",
    university: "ÉCOLE DE TECHNOLOGIE SUPÉRIEURE\nUNIVERSITÉ DU QUÉBEC",
    all-rights: "All rights reserved, ",
    in-field: " IN ",

    diploma-masters: "OF A MASTER'S DEGREE\nWITH THESIS",
    diploma-masters-suffix: "M.A.Sc.",
    diploma-project: "OF A MASTER'S DEGREE\nWITH PROJECT",
    diploma-project-suffix: "M.Eng.",
    diploma-doctorate: "FOR THE DEGREE OF DOCTOR",
    diploma-doctorate-suffix: "Ph.D.",

    licence-reserved-title: "All rights reserved",
    licence-reserved-body: "This license means that it is prohibited to reproduce, record or distribute this document in whole or in part. Readers who wish to print or store a significant part of this document on another medium must request permission from the author.",
    licence-cc-body-before: "This ",
    licence-cc-link: "Creative Commons CC BY-NC-ND 4.0 license",
    licence-cc-body-after: " means that it is permitted to distribute, print or save on another medium part or all of this work provided that the author is credited, that these uses are made for non-commercial purposes and that the content of the work has not been modified.",

    jury-title: "BOARD OF EXAMINERS",
    jury-eval-thesis: "THIS THESIS HAS BEEN EVALUATED",
    jury-eval-masters: "THIS THESIS HAS BEEN EVALUATED",
    jury-eval-project: "THIS PROJECT REPORT HAS BEEN EVALUATED",
    jury-composed: "BY THE FOLLOWING BOARD OF EXAMINERS",
    defense-thesis: "THIS THESIS WAS PRESENTED AND DEFENDED IN THE PRESENCE OF A BOARD OF EXAMINERS AND THE PUBLIC",
    defense-masters: "THIS THESIS WAS PRESENTED AND DEFENDED IN THE PRESENCE OF A BOARD OF EXAMINERS AND THE PUBLIC",
    defense-date-prefix: "",
    defense-place: "AT ÉCOLE DE TECHNOLOGIE SUPÉRIEURE",

    role-supervisor-thesis: "thesis Supervisor",
    role-supervisor-masters: "thesis Supervisor",
    role-supervisor-project: "project Supervisor",
    role-cosupervisor-thesis: "thesis Co-supervisor",
    role-cosupervisor-masters: "thesis Co-supervisor",
    role-cosupervisor-project: "project Co-supervisor",
    role-chair: "Chair, Board of Examiners",
    role-jury: "Member of the Jury",
    role-external: "External Examiner",
    role-independent: "External Independent Examiner",
    default-affiliation: "École de technologie supérieure",

    article-submitted: "Article submitted for publication, ",
    article-accepted-before: "Article accepted for publication in ",
    article-published-before: "Article published in ",

    confidential: "CONFIDENTIAL",
  ),
)

// Raccourci : récupère la table de chaînes de la langue courante.
#let tr(lang) = strings.at(lang)
