#import "@preview/lumen:0.1.2": cover

// DOCUMENT SETUP
#set page(paper:"a4")
#set text(lang: "fr") // or "en"

// (FR) PRESETS
#cover(
  faculty-logo: image("logos/archi.png"),
  faculty-logo-width: 75%,
  title: "[Titre de la thèse]",
  subtitle: "[Facultatif: sous-titre de la thèse]", // optional
  name: "[Prénom NOM]",
  field-en: "[Diploma]", // unnecessary for FR
  field-fr: "[Diplôme]",
  aca-year: "20[..]-20[..]",
  supervisor: "[du/de la] Professeur[e] [Prénom NOM]",
  supervisor-role: "[promoteur/promotrice]", // unnecessary for EN
  co-supervisor: "[du/de la] Professeur[e] [Prénom NOM]", // optional
  co-supervisor-role: "[co-promoteur/promotrice]",  // unnecessary for EN
  lab: "[facultatif: unité de recherche]", // optional
  jury1: "Prénom NOM (Université libre de Bruxelles, Président·e)", // optional
  jury2: "Prénom NOM ([Université], Sécretaire)",
  jury3: "Prénom NOM ([Université])",
  jury4: "Prénom NOM ([Université])",
  jury5: none,
  jury6: none,
  jury7: none,
  fund-logo: image("logos/FNRS-fr.png"),
  fund-logo-width: 90%,
)
