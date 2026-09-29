// Copyright 2026 Arthur Meyer
//
// This work may be distributed and/or modified under the
// conditions of the LaTeX Project Public License, either version 1.3c
// of this license or (at your option) any later version.
// The latest version of this license is in
//   https://www.latex-project.org/lppl.txt
// and version 1.3c or later is part of all distributions of LaTeX
// version 2008 or later.
//
// This work has the LPPL maintenance status `maintained'.
// The Current Maintainer of this work is Arthur Meyer.
//
// This work consists of all the .typ files in the src/ directory
// and its subdirectories.

// États partagés entre les fonctions.
// Tous sont remis à zéro par `maquette` : deux maquettes d'un même document ne
// partagent rien.

// ─── Couleurs ────────────────────────────────────────────────────────────────

// couleur-externe : liens vers l'extérieur (haltère, QR codes, source) ;
//   cyan foncé, qui reste bien contrasté imprimé en noir et blanc.
// couleur-interne : navigation dans le document (clé, titres des corrigés) ;
//   Crimson, comme « CouleurSol » de ProfMaquette.
#let couleurs-defaut = (
  externe: rgb("#0090C8"),
  interne: rgb("#DC143C"),
)
#let etat-couleurs = state("etat-couleurs-liens", couleurs-defaut)

// À appeler dans un `context`.
#let couleur-externe() = etat-couleurs.get().externe
#let couleur-interne() = etat-couleurs.get().interne

// Couleur des exercices sur la route (étiquette + filet).
#let etat-couleur-route = state("etat-couleur-route", black)

// ─── Réglages de la fiche ────────────────────────────────────────────────────

// Style des cadres (exercices et bloc « Automatismes »), cf. `boite-etiquette`.
#let styles-exercice = ("fond-blanc", "etiquette-encadree", "bandeau", "etiquette-pleine")
#let etat-style = state("etat-style-exercice", "fond-blanc")

// Réglages des corrigés (cf. `reglages-corriges` dans maquette.typ).
// mode : none (aucun corrigé), "apres", "fin" ou "apres-question".
#let etat-reglages-corriges = state("etat-reglages-corriges", (
  mode: none,
  vers-corrige: false,
  titre-corriges: auto,
  nouvelle-page: true,
  page-par-corrige: false,
))

// Affichage du barème (mode "interro" seulement, sinon none) : none, "partiel"
// ou "complet" (cf. `maquette(afficher-brm: …)`).
#let etat-afficher-brm = state("etat-afficher-brm", none)

// Corrigés à afficher (auto = tous), sous la forme rendue par `parser-plage`.
#let etat-selection = state("etat-selection", (corriges: auto))

// Réglages du schéma `afficher-fdr`.
#let etat-fdr = state("etat-fdr", (couleur: black))

// Langue des mots du paquet (cf. `terme`).
#let etat-langue = state("etat-langue-exercices", auto)

// ─── Exercices et corrigés ───────────────────────────────────────────────────

// Un dictionnaire par exercice rencontré (route, pas-corrige, titre,
// entrainement) : sa longueur donne le numéro de l'exercice courant.
#let etat-historique = state("etat-historique-exercices", ())

// Numéro de la maquette en cours : distingue les « exercice 1 » de deux fiches
// d'un même document dans les liens exercice ↔ corrigé.
#let etat-serie = state("etat-serie-exercices", 0)

// Corrigés en attente (mode "fin"), restitués par `bloc-corriges`.
#let etat-corriges = state("etat-corriges", ())

// Sert à `page-par-corrige` en mode "apres" : saut de page avant chaque
// corrigé sauf le premier.
#let etat-corrige-deja-affiche = state("etat-corrige-deja-affiche", false)

// Mode "apres-question" : nombre de `seyes` et de `corrige` rencontrés depuis
// le dernier exercice. Le k-ième corrigé remplace le k-ième seyes.
#let etat-nb-seyes = state("etat-nb-seyes", 0)
#let etat-nb-reponses = state("etat-nb-reponses", 0)

// Blocs de fin déjà affichés pour la fiche en cours (un second appel n'affiche rien).
#let etat-blocs-fin = state("etat-blocs-fin", (entrainements: false, corriges: false))

// Nombre de maquettes ouvertes à cet endroit (interdit les maquettes imbriquées).
#let etat-profondeur = state("etat-profondeur-maquette", 0)

// ─── Repères de la feuille de route ──────────────────────────────────────────

// Posés dans le document et relus par `afficher-fdr` : un par exercice, un par
// thématique, et une borne au début et à la fin de chaque maquette.
#let repere-exercice = <profmaquette-minimal-fdr-exercice>
#let repere-borne = <profmaquette-minimal-fdr-borne>
#let repere-thematique = <profmaquette-minimal-fdr-thematique>

// Corrigé d'une question (mode "apres-question"), relu par le `seyes` qu'il remplace.
#let repere-reponse = <profmaquette-minimal-reponse>
// Un `seyes` entier (sa grille en `metadata`, son compteur, sa recherche de
// corrigé) : remplacé par la grille seule dans le corps d'un corrigé.
#let repere-seyes = <profmaquette-minimal-seyes>
