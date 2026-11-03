// --- Imports ---
#import "000-paquets.typ": *
#import "001-variables.typ": *
#import "002-fonctions.typ": *
#import "003-communs.typ": *

// ╔══════════════════════════════════════════════════════════════════╗
// ║  MODÈLE COMPLET — modele-junia                                   ║
// ║  Pour les rapports formels JUNIA avec architecture de dossiers   ║
// ╚══════════════════════════════════════════════════════════════════╝

/// Modèle principal conforme à la charte graphique JUNIA.
///
/// Conçu pour les rapports et mémoires formels. S'appuie sur l'architecture de dossiers standard et génère automatiquement
/// la page de garde, le pré-sommaire et le corps du document.
///
/// *Quand l'utiliser ?* Pour tout rapport ou mémoire soumis dans le cadre de JUNIA — stage, projet, apprentissage.
///
/// Dans `squelette.typ`, appeler avec `#show: modele-junia.with(...)`.
/// Paramètres minimaux obligatoires :
/// `titre-rapport: [Mon rapport]` et `auteurs: ("NOM Prénom",)`.
/// Le paramètre `glossaire` doit toujours recevoir `v-liste-glossaire`
/// (disponible automatiquement via `005-centralisation.typ`).
///
/// -> content
#let modele-junia(
  /// Liste des entrées du lexique. Dans `squelette.typ`, passer
  /// `v-liste-glossaire` — alimenté automatiquement depuis
  /// `E-lexique.typ`. Le lexique n'est affiché que si non vide. -> array
  glossaire:        (),
  /// `true` = génère la page de garde depuis les paramètres ci-dessous.
  /// `false` = utiliser `cover-pdf-path` pour un PDF externe. -> bool
  generate-cover:   true,
  /// Chemin vers un PDF externe comme page de garde. N'a d'effet que si `generate-cover` est `false`. -> str
  cover-pdf-path:   none,
  /// Nature du document. Ex : `[Rapport de stage]`. -> content
  type-rapport:     [],
  /// Titre du document. *Obligatoire.* Utilisé pour les métadonnées PDF. -> content
  titre-rapport:    [],
  /// Mention de confidentialité en rouge sur la page de garde. -> content
  confidentialite:  [],
  /// Diplôme visé, affiché sous le titre. -> content
  type-diplome:     [],
  /// Enseignant référent. -> content
  professeur:       [],
  /// Encadrant en entreprise. -> content
  encadrant:        [],
  /// Liste des auteurs. *Obligatoire.* Ex : `("DUPONT Alice", "MARTIN Bob")`. -> array
  auteurs:          (),
  /// Filière ou formation. -> content
  formation:        [],
  /// Nom ou code de la promotion. -> content
  promotion:        [],
  /// Niveau ou numéro de classe. -> content
  niveau-classe:    [],
  /// Date de la page de garde. `auto` = mois/année actuels traduits
  /// selon `lang-doc`. Valeur manuelle : `[Juin 2025]`. -> content
  mois-annee:       auto,
  /// Mode brouillon. `true` = filigrane BROUILLON, notes de relecture
  /// visibles, `#fr-note-de-marge` affiché. -> bool
  ebauche:          false,
  /// Bandeau CONFIDENTIEL rouge sur chaque page. -> bool
  filigrane:        false,
  /// Numérotation des équations mathématiques, dans le corps du document -> bool
  num-equations:    false,
  // Tailles des titres niveaux 1 à 6
  tailles-police:   (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em),
  // Couleurs des liens : (glossaire, bibliographie, annexe)
  couleurs-cite:    (green, blue, purple),
  /// Langue du document. `"fr"` ou `"en"`. Traduit automatiquement les titres des sections. Toute autre valeur revient à `"fr"`. -> str
  lang-doc:         "fr",
  /// Chemin vers le logo gauche de la page de garde. Par défaut : logo JUNIA. -> str
  img-gau:          "../03-images/030-page-de-garde/junia-logo.png",
  /// Adresse affichée sous le logo gauche. `none` = adresse JUNIA par défaut. -> content
  adr-gau:          none,
  /// Chemin vers le logo central de la page de garde. Vide = aucun logo. -> str
  img-cen:          "",
  /// Adresse affichée sous le logo central. -> content
  adr-cen:          [],
  /// Chemin vers le logo droit de la page de garde. Vide = aucun logo. -> str
  img-dro:          "",
  /// Adresse affichée sous le logo droit. -> content
  adr-dro:          [],
  body,

) = {

  // --- Valeurs obligatoires ---
  // Le titre du document
  assert(
    titre-rapport != [],
    message: "modele-junia : `titre-rapport` est vide — requis pour les métadonnées PDF."
  )
  // Les auteur(s) du document
  assert(
    auteurs.len() > 0,
    message: "modele-junia : `auteurs` est vide — requis pour les métadonnées PDF."
  )

  // --- Mise à jour des états globaux du modèles ---
  // Gestion du mode ébauche
  v-ebauche-global.update(ebauche)
  // Gestion de la confidentialité
  v-filigrane-global.update(filigrane)
  // Gestion des couleurs de citations
  v-couleurs-cite-global.update(couleurs-cite)
  // Gestion des numérotations des équations dans le corps du document
  v-equations-global.update(num-equations)
  // Gestion du fond de page pour l'affichage des filigranes
  v-fond-de-page-global.update(fa-fond-de-page())

  // --- Langue du document ---
  // Mise à jour de la langue du document si elle existe dans le dictionnaire
  if v-liste-trad-auto.sommaire.keys().contains(lang-doc) == false { lang-doc = "fr" }
  v-langue-global.update(lang-doc)

  // --- Métadonnées --- 
  // Mise à jour des métadonnées du document
  set document(title: titre-rapport, author: auteurs.join(","))

  // --- Configuration minimale ---
  // Utilisation du noyau pour la mise en page commune, tailles de police, etc.
  show: junia-core.with(
    glossaire:       glossaire,
    tailles-police:  tailles-police,
    langue-document: lang-doc,
  )

  // --- Page de garde ---
  if generate-cover {
    show: fbc-page-de-garde.with(
      type-rapport:    type-rapport,
      titre-rapport:   titre-rapport,
      confidentialite: confidentialite,
      type-diplome:    type-diplome,
      professeur:      professeur,
      encadrant:       encadrant,
      auteurs:         auteurs,
      formation:       formation,
      promotion:       promotion,
      niveau-classe:   niveau-classe,
      mois-annee:      mois-annee,
      img-gau:         img-gau,
      adr-gau:         adr-gau,
      img-cen:         img-cen,
      adr-cen:         adr-cen,
      img-dro:         img-dro,
      adr-dro:         adr-dro,
    )
  } else if cover-pdf-path != none {
    page(margin: 0pt, header: none, footer: none,
      background: image(cover-pdf-path, width: 100%, height: 100%)
    )[]
  }
  // --- Basculement ---
  // Passage en mode pré-sommaire du document
  show: fmp-pre-sommaire
  
  // --- Notes de brouillon ---
  show: fbc-liste-notes
  
  body
}


// ╔══════════════════════════════════════════════════════════════════╗
// ║  MODELE LEGER — junia-light                                      ║
// ║  Pour les documents courts rediges dans un seul fichier          ║
// ╚══════════════════════════════════════════════════════════════════╝

/// Modèle autonome pour les documents courts.
///
/// Tout se rédige dans un seul fichier `.typ`, sans architecture de
/// dossiers. Pas de séparation pré-sommaire/corps — numérotation
/// des titres active dès le début, figures numérotées simplement.
///
/// *Quand l'utiliser ?* Pour tout document court ne nécessitant pas
/// la page de garde institutionnelle ni l'architecture de dossiers.
///
/// Dans un fichier autonome, l'appel minimal est :
/// `#show: junia-light.with(titre: [Mon titre], auteurs: ("NOM Prénom",))`
/// suivi directement du contenu. Pas de `squelette.typ` requis.
///
/// -> content
#let junia-light(
  /// Titre du document. *Obligatoire.* Affiché dans la mini garde
  /// et dans les métadonnées PDF. -> content
  titre:               [],
  /// Liste des auteurs. *Obligatoire.*
  /// Ex : `("DUPONT Alice",)` — virgule obligatoire pour un seul auteur. -> array
  auteurs:             (),
  /// Affiche un bloc titre/auteurs/date en haut de la première page.
  /// La rédaction commence juste après, sans saut de page. -> bool
  avec-garde:          true,
  /// Sous-titre optionnel dans la mini garde. -> content
  sous-titre:          [],
  /// Date dans la mini garde. `auto` = mois/année actuels.
  /// Valeur manuelle : `[Juin 2025]`. -> content
  date:                auto,
  /// Génère une table des matières. Par défaut `false`. -> bool
  avec-sommaire:       false,
  /// Niveau maximum dans la table des matières. Par défaut `2`.
  /// N'a d'effet que si `avec-sommaire: true`. -> int
  profondeur-sommaire: 2,
  /// Entrées du lexique. Par défaut `()` = pas de lexique.
  /// Format : `((key: "api", short: [API], desc: [...]),)`. -> array
  glossaire:           (),
  /// Chemins vers les fichiers `.bib` ou `.yml`. Par défaut `()` =
  /// pas de bibliographie. La section n'apparaît que si des citations
  /// `@cle` sont présentes. Ex : `("refs.bib",)`. -> array
  chemins-biblio:      (),
  /// Style de citation. Par défaut `"ieee"`. -> str
  style-biblio:        "ieee",
  /// Mode brouillon. -> bool
  ebauche:             false,
  /// Langue. `"fr"` ou `"en"`. -> str
  lang-doc:            "fr",
  // Couleurs des liens : (glossaire, bibliographie, annexe)
  couleurs-cite:       (green, blue, purple),
  // Tailles des titres niveaux 1 à 6
  tailles-police:      (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em),
  body,

) = {

  // --- Valeurs obligatoires ---
  // Le titre du document
  assert(
    titre != [],
    message: "junia-light : `titre` est vide — requis pour les métadonnées."
  )
  // Les auteur(s) du document
  assert(
    auteurs.len() > 0,
    message: "junia-light : `auteurs` est vide — au moins un auteur requis."
  )

  // --- Mise à jour des états globaux du modèles ---
  // Gestion du mode ébauche
  v-ebauche-global.update(ebauche)
  // Gestion du filigrane de confidentialité
  v-filigrane-global.update(false)
  // Gestion des couleurs de citation
  v-couleurs-cite-global.update(couleurs-cite)

  // --- Langue du document ---
  // Mise à jour de la langue du document si elle existe dans le dictionnaire  
  let lang = if v-liste-trad-auto.sommaire.keys().contains(lang-doc) { lang-doc } else { "fr" }
  v-langue-global.update(lang)

  // --- Métadonnées --- 
  // Mise à jour des métadonnées du document  
  set document(title: titre, author: auteurs.join(","))

  // --- Configuration minimale ---
  // Utilisation du noyau pour la mise en page commune, tailles de police, etc.
  show: junia-core.with(
    glossaire:       glossaire,
    tailles-police:  tailles-police,
    langue-document: lang,
  )

  // Pagination arabe dès la première page.
  // Pied de page masqué sur la première page si la mini-garde est active.
  set page(
    paper: "a4",
    numbering: "1",
    footer: context {
      if avec-garde and here().page() == 1 { return }
      line(length: 100%, stroke: 0.4pt)
      align(right)[
        #v-liste-trad-auto.at("page_app").at(v-langue-global.get())
        #counter(page).display()
        #v-liste-trad-auto.at("delim_app").at(v-langue-global.get())
        #counter(page).final().first()
      ]
    },
    background: fa-fond-de-page(),
  )

  // --- Numérotation des éléments
  // Titres numérotés et figures numérotées simplement (sans préfixe chapitre)
  set heading(
    outlined: true,
    supplement: context v-liste-trad-auto.at("chap_court").at(v-langue-global.get()),
    numbering: (..nums) => {
      if nums.pos().len() <= 3 { numbering("1.1", ..nums) } else { none }
    }
  )
  // Figure numéroté simplement
  set figure(numbering: "1")
  // Équation mathématique non numéroté
  set math.equation(numbering: none)

  // --- Page de garde ---
  if avec-garde {
    v(15%)
    align(center)[
      #text(2em, weight: "bold")[#titre]
      #if sous-titre != [] { v(0.5em); text(1.2em)[#sous-titre] }
      #v(1em)
      #for a in auteurs { a; linebreak() }
      #v(0.5em)
      #context {
        if date == auto {
          [#v-liste-trad-auto.at("mois_date").at(v-langue-global.get()) #v-annee-court]
        } else { date }
      }
    ]
    v(10%)
    line(length: 100%, stroke: 0.6pt)
    v(1em)
  }

  // --- Lexique ---
  show: fbc-lexique

  // --- Sommaire ---
  if avec-sommaire { show: fbc-sommaire.with(profondeur: profondeur-sommaire) }

  // --- Liste des notes
  show: fbc-liste-notes

  body

  // --- Bibliographie ---
  // Affichée uniquement si des chemins sont fournis ET des citations sont présentes.
  if chemins-biblio != () {
    show: fbc-bibliographie.with(
      chemins-biblio: chemins-biblio,
      style-biblio:   style-biblio,
    )
  }
}


// ╔══════════════════════════════════════════════════════════════════╗
// ║  MODELE EXPERT — junia-expert                                    ║
// ║  Fonctionnalites completes, architecture libre                   ║
// ╚══════════════════════════════════════════════════════════════════╝

/// Modèle autonome à fonctionnalités complètes, sans architecture
/// de dossiers imposée.
///
/// Mêmes capacités que `modele-junia`, mais tous les chemins sont
/// paramétrables. Différence clé : *aucune transition de zone n'est
/// appelée automatiquement* — `fmp-pre-sommaire`, `fmp-corps-document`
/// et `fmp-annexes` sont à placer manuellement dans le document.
///
/// *Quand l'utiliser ?* Pour les utilisateurs ayant leur propre
/// organisation de projet ou souhaitant intégrer le modèle dans une
/// structure existante sans adopter l'architecture standard.
///
/// Après `#show: junia-expert.with(...)`, les zones sont à appeler manuellement
/// dans l'ordre souhaité. Séquence typique :
/// `#show: fmp-pre-sommaire` puis `#show: fbc-sommaire`
/// puis `#show: fmp-corps-document` pour le corps,
/// et optionnellement `#show: fmp-annexes` en fin de document.
///
/// -> content
#let junia-expert(

  /// Titre du document. *Obligatoire.* -> content
  titre-rapport:    [],
  /// Liste des auteurs. *Obligatoire.* -> array
  auteurs:          (),
  /// Génère une page de garde. Par défaut `false`. Si `true`,
  /// renseigner les champs ci-dessous. -> bool
  generate-cover:   false,
  /// Chemin vers un PDF externe comme page de garde.
  /// Mutuellement exclusif avec `generate-cover`. -> str
  cover-pdf-path:   none,
  /// Chemin vers le logo gauche. Vide = aucun logo. -> str
  img-gau:          "",
  /// Adresse sous le logo gauche. `none` = pas d'adresse. -> content
  adr-gau:          none,
  /// Chemin vers le logo central. Vide = aucun logo. -> str
  img-cen:          "",
  /// Adresse sous le logo central. -> content
  adr-cen:          [],
  /// Chemin vers le logo droit. Vide = aucun logo. -> str
  img-dro:          "",
  /// Adresse sous le logo droit. -> content
  adr-dro:          [],
  /// Nature du document sur la page de garde. -> content
  type-rapport:     [],
  /// Mention de confidentialité en rouge. -> content
  confidentialite:  [],
  /// Diplôme visé. -> content
  type-diplome:     [],
  /// Enseignant référent. -> content
  professeur:       [],
  /// Encadrant entreprise. -> content
  encadrant:        [],
  /// Filière ou formation. -> content
  formation:        [],
  /// Promotion ou année. -> content
  promotion:        [],
  /// Niveau ou numéro de classe. -> content
  niveau-classe:    [],
  /// Date sur la page de garde. `auto` = date actuelle traduite. -> content
  mois-annee:       auto,
  /// Entrées du lexique. Par défaut `()` = pas de lexique. -> array
  glossaire:        (),
  /// Mode brouillon. -> bool
  ebauche:          false,
  /// Bandeau CONFIDENTIEL sur chaque page. -> bool
  filigrane:        false,
  /// Numérotation des équations par chapitre. -> bool
  num-equations:    false,
  /// Langue. `"fr"` ou `"en"`. -> str
  lang-doc:         "fr",
  // Couleurs des liens : (glossaire, bibliographie, annexe)
  couleurs-cite:    (green, blue, purple),
  // Tailles des titres niveaux 1 à 6
  tailles-police:   (1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em),
  body,

) = {

  // --- Valeurs obligatoires ---
  // Le titre du document
  assert(
    titre-rapport != [],
    message: "junia-expert : `titre-rapport` est vide — requis pour les métadonnées PDF."
  )
  // Les auteur(s) du document
  assert(
    auteurs.len() > 0,
    message: "junia-expert : `auteurs` est vide — au moins un auteur requis."
  )
  // generate-cover et cover-pdf-path sont mutuellement exclusifs
  assert(
    not (generate-cover and cover-pdf-path != none),
    message: "junia-expert : `generate-cover` et `cover-pdf-path` sont mutuellement exclusifs."
  )

  // --- Mise à jour des états globaux du modèle ---
  // Gestion du mode ébauche
  v-ebauche-global.update(ebauche)
  // Gestion de la confidentialité
  v-filigrane-global.update(filigrane)
  // Gestion des couleurs de citations
  v-couleurs-cite-global.update(couleurs-cite)
  // Gestion de la numérotation des équations dans le corps du document
  v-equations-global.update(num-equations)
  // Gestion du fond de page pour l'affichage des filigranes
  v-fond-de-page-global.update(fa-fond-de-page())

  // --- Langue du document ---
  // Mise à jour de la langue du document si elle existe dans le dictionnaire
  let lang = if v-liste-trad-auto.sommaire.keys().contains(lang-doc) { lang-doc } else { "fr" }
  v-langue-global.update(lang)

  // --- Métadonnées ---
  // Mise à jour des métadonnées du document
  set document(title: titre-rapport, author: auteurs.join(","))

  // --- Configuration minimale ---
  // Utilisation du noyau pour la mise en page commune, tailles de police, etc.
  show: junia-core.with(
    glossaire:       glossaire,
    tailles-police:  tailles-police,
    langue-document: lang,
  )

  // --- Page de garde ---
  // Utilise la même fonction fbc-page-de-garde que modele-junia.
  // Aucun logo par défaut — tous les chemins sont à fournir explicitement.
  if generate-cover {
    show: fbc-page-de-garde.with(
      type-rapport:    type-rapport,
      titre-rapport:   titre-rapport,
      confidentialite: confidentialite,
      type-diplome:    type-diplome,
      professeur:      professeur,
      encadrant:       encadrant,
      auteurs:         auteurs,
      formation:       formation,
      promotion:       promotion,
      niveau-classe:   niveau-classe,
      mois-annee:      mois-annee,
      img-gau:         img-gau,
      adr-gau:         adr-gau,
      img-cen:         img-cen,
      adr-cen:         adr-cen,
      img-dro:         img-dro,
      adr-dro:         adr-dro,
    )
  } else if cover-pdf-path != none {
    // Insertion d'un PDF externe comme page de garde
    page(margin: 0pt, header: none, footer: none,
      background: image(cover-pdf-path, width: 100%, height: 100%)
    )[]
  }

  // --- Basculement ---
  // Contrairement à modele-junia, aucune transition de zone n'est déclenchée
  // automatiquement. L'utilisateur appelle manuellement dans son fichier :
  //   #show: fmp-pre-sommaire   (optionnel)
  //   #show: fbc-sommaire       (optionnel)
  //   #show: fmp-corps-document
  //   #show: fmp-annexes        (optionnel)
  body
}
