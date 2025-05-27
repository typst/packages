// SPDX-FileCopyrightText: 2025 Julien Rippinger <https://julienrippinger.eu>
//
// SPDX-License-Identifier: MIT-0

#import "@preview/lumen:0.1.0": cover

// CHOOSE LANGUAGE
#set text(lang: "fr") // or "en"

// (FR) PRESETS
#show: cover(
  logo: "template/logos/archi.png",
  title-font: "IBM Plex Sans", // "Libertinus Sans"
  body-font: "IBM Plex Serif", // "Libertinus Serif"
  title: "[Titre de la thèse]",
  subtitle: "[Facultatif: sous-titre de la thèse]", // disable with 'none,'
  name: "[Prénom NOM]",
  field-en: "[Diploma]",
  field-fr: "[Diplôme]",
  aca-year: "20[..]-20[..]",
  supervisor: "[du/de la] Professeur[e] [Prénom NOM]",
  supervisor-role: "[promoteur/promotrice]", // choose
  co-supervisor: "[du/de la] Professeur[e] [Prénom NOM]", // disable with 'none,'
  co-supervisor-role: "[co-promoteur/promotrice]",
  lab: "[facultatif: unité de recherche]", // disable with 'none,'
  jury1: "Prénom NOM (Université libre de Bruxelles, Chair)", // disable all jury list with 'none,'
  jury2: "Prénom NOM ([Université], Secretary)",
  jury3: "Prénom NOM ([Université])",
  jury4: "Prénom NOM ([Université])",
  jury5: none, // "Prénom NOM ([Université])"
  jury6: none, // "Prénom NOM ([Université])"
  jury7: none, // "Prénom NOM ([Université])"
  fund-logo: "template/logos/FNRS-fr.png",
  fund-logo-width: 90%,
)
