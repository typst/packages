// ============================================================================
// 🎯 RAPPORT DE LABORATOIRE HES-SO
// ============================================================================
//
// Configuration: src/settings/name.typ
// Modifiez UNIQUEMENT le fichier src/settings/name.typ pour configurer votre rapport
//
// ============================================================================


#import "@preview/rapport-labo-hes-so:0.1.0": *

#import "src/settings/name.typ": config

// Configuration numérotation équations (ternaire)
#set math.equation(numbering: if config.afficher-numéros-équations { "(1)" } else { none })

#show: rapport()

// ============================================================================
// 📝 CONTENU DE VOTRE RAPPORT
// ============================================================================
// Ajouter vos chapitres ici en remplaçant le contenu ci-dessous


//possibilité de faire des autre fichiers et des les #include "" ici
= Introduction

Bienvenue dans votre rapport de laboratoire HES-SO ! 🎉

Ce template vous offre une mise en page professionnelle et complète pour vos rapports.

== Objectifs

Expliquez les objectifs de votre expérience ici.

== Méthodologie

Décrivez la méthodologie que vous avez utilisée.

#pagebreak()
= Développement

Présentez vos résultats et analyses ici.

== Section 1

Contenu de la section 1.

== Section 2

Contenu de la section 2.

#pagebreak()
= Conclusion

Résumez vos conclusions et résultats principaux.

