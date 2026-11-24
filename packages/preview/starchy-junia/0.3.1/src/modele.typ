// --- Imports ---
#import "paquets.typ": *
#import "etats.typ": *
#import "outils.typ": *
#import "composants.typ": *
#import "zones.typ": *

// ╔══════════════════════════════════════════════════════════════════╗
// ║  MODÈLE — modele-junia                                           ║
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
/// (importé depuis `ressources/lexique.typ` dans `squelette.typ`).
///
/// -> content
#let modele-junia(
  /// Liste des entrées du lexique. Dans `squelette.typ`, passer
  /// `v-liste-glossaire` — alimenté automatiquement depuis
  /// `ressources/lexique.typ`. Le lexique n'est affiché que si non vide. -> array
  glossaire:            (),

  // ── Page de garde ────────────────────────────────────────────────────────────
  /// Page de garde du document.
  /// - `auto` (défaut) : générée à partir des paramètres ci-dessous ;
  /// - `image("garde.pdf")` : page externe (PDF, PNG…) affichée en pleine page,
  ///   *à la place* de la page générée — les paramètres de la page générée sont alors ignorés ;
  /// - `none` : pas de page de garde. -> auto | content | none
  page-de-garde:        auto,
  /// Nature du document. Ex : `[Rapport de stage]`. -> content
  type-rapport:         [],
  /// Titre du document. *Obligatoire.* Utilisé pour les métadonnées PDF. -> content
  titre-rapport:        [],
  /// Mention de confidentialité en rouge sur la page de garde. -> content
  confidentialite:      [],
  /// Diplôme visé, affiché sous le titre. -> content
  type-diplome:         [],
  /// Enseignant référent. -> content
  professeur:           [],
  /// Encadrant en entreprise. -> content
  encadrant:            [],
  /// Liste des auteurs. *Obligatoire.* Ex : `("DUPONT Alice", "MARTIN Bob")`. -> array
  auteurs:              (),
  /// Filière ou formation. -> content
  formation:            [],
  /// Nom ou code de la promotion. -> content
  promotion:            [],
  /// Niveau ou numéro de classe. -> content
  niveau-classe:        [],
  /// Date de la page de garde. `auto` = mois et année de compilation, traduits
  /// selon `langue`. Une date précise, ex : `datetime(year: 2025, month: 6, day: 30)`,
  /// est affichée de la même façon et sert aussi de date des métadonnées PDF.
  /// Valeur libre : `[Juin 2025]`. `none` = pas de date. Un texte entre guillemets
  /// est refusé, ex : `"2025-06-30"`. -> auto | datetime | content | none
  date:                 auto,
  /// Logo gauche de la page de garde. `auto` = logo JUNIA. Pour un autre logo,
  /// passer l'image elle-même, ex : `image("images/logo.png")` — le chemin est alors
  /// résolu depuis le fichier appelant. `none` = aucun logo. -> auto | content | none
  logo-gauche:          auto,
  /// Adresse sous le logo gauche. `auto` = adresse de JUNIA, `none` = aucune. -> auto | content | none
  adresse-gauche:       auto,
  /// Logo central, ex : `image("images/logo.png")`. `none` = aucun logo. -> content | none
  logo-centre:          none,
  /// Adresse sous le logo central. -> content | none
  adresse-centre:       none,
  /// Logo droit, ex : `image("images/logo.png")`. `none` = aucun logo. -> content | none
  logo-droite:          none,
  /// Adresse sous le logo droit. -> content | none
  adresse-droite:       none,

  // ── Document ─────────────────────────────────────────────────────────────────
  /// Langue du document. `"fr"` ou `"en"`. Traduit automatiquement les titres des sections. Toute autre valeur revient à `"fr"`. -> str
  langue:               "fr",
  /// Mots-clés du document, dans sa langue de rédaction, ex : `("IoT", "LoRa", "capteurs")`.
  /// Enregistrés dans les métadonnées PDF et affichés par `fbc-mots-cles`, à placer sous le résumé. -> array
  mots-cles:            (),
  /// Mode brouillon. `true` = filigrane BROUILLON sur chaque page. -> bool
  ebauche:              false,
  /// Bandeau CONFIDENTIEL rouge sur chaque page. -> bool
  bandeau-confidentiel: false,
  /// Numérotation, seules les clés à modifier sont nécessaires, ex : `numerotation: (equations: true)`.
  /// - `profondeur` : niveau de titre maximum numéroté dans le corps du document. Par défaut `3`.
  /// - `equations` : numérote les équations par chapitre, ex : (2.1). Par défaut `false`.
  /// - `delimiteur` : texte ajouté après le numéro des titres, dans le document, les sommaires et
  ///   l'en-tête, ex : `")"` donne « 1.1) ». Les citations `@titre` ne sont pas concernées. Par défaut `none`.
  /// - `annexes` : numérotation des annexes, `"A"` (A, A.1…), `"1"` (1, 1.1…), `"Annexe A"` ou
  ///   `"Annexe 1"` (mot « Annexe », traduit selon `langue`, devant le numéro des titres `=`). Par défaut `"A"`. -> dictionary
  numerotation:         (:),
  /// Gestion des blocs de code placés dans une `figure`. Seules les clés à
  /// modifier sont nécessaires, ex : `code: (mode: "figure")`.
  /// - `mode` : `"programme"` (défaut) = numérotation, légende au-dessus et liste
  ///   propres (« Programme 1.1 », `fbc-liste-programme`) ; `"figure"` = traités
  ///   comme des figures (même numérotation, table des figures).
  /// - `supplement` : nom en légende en mode `"programme"`. `auto` = « Programme » / « Listing ».
  /// - `court` : forme courte des citations `@ref` en mode `"programme"`. `auto` = « prog. » / « lst. ».
  /// - `coloration` : mise en forme codly (numéros de lignes, icône du langage). Par défaut `true`. -> dictionary
  code:                 (:),
  /// Police, seules les clés à modifier sont nécessaires, ex : `police: (taille: 11pt)`.
  /// - `famille` : police du texte. Par défaut `"New Computer Modern Sans"`.
  /// - `taille` : taille du texte. Par défaut `12pt`.
  /// - `titres` : tailles des titres, niveaux 1 à 6. Par défaut `(1.75em, 1.6em, 1.4em, 1.25em, 1.1em, 1em)`. -> dictionary
  police:               (:),
  /// Couleurs des liens, seules les clés à modifier sont nécessaires, ex : `couleurs-liens: (annexe: red)`.
  /// Clés : `glossaire` (vert), `bibliographie` (bleu), `annexe` (violet). -> dictionary
  couleurs-liens:       (:),
  /// Anciens paramètres, détectés pour afficher la consigne de migration.
  ..autres,
  body,

) = {

  // --- Paramètres des versions précédentes ---
  let migration-garde = "utiliser `page-de-garde: auto` (page générée), `page-de-garde: image(\"garde.pdf\")` ou `page-de-garde: none`."
  fa-verifier-arguments("modele-junia", autres, renommes: (
    generate-cover:    migration-garde,
    cover-pdf-donnees: migration-garde,
    cover-pdf-path:    migration-garde,
    lang-doc:          "renommé en `langue`.",
    mois-annee:        "renommé en `date`.",
    filigrane:         "renommé en `bandeau-confidentiel`.",
    num-equations:     "remplacé par `numerotation: (equations: true)`.",
    tailles-police:    "remplacé par `police: (titres: (...))`.",
    couleurs-cite:     "remplacé par `couleurs-liens: (glossaire: ..., bibliographie: ..., annexe: ...)`.",
    img-gau:           "renommé en `logo-gauche`, ex : `logo-gauche: image(\"logo.png\")`.",
    img-cen:           "renommé en `logo-centre`, ex : `logo-centre: image(\"logo.png\")`.",
    img-dro:           "renommé en `logo-droite`, ex : `logo-droite: image(\"logo.png\")`.",
    adr-gau:           "renommé en `adresse-gauche`.",
    adr-cen:           "renommé en `adresse-centre`.",
    adr-dro:           "renommé en `adresse-droite`.",
  ))
  if page-de-garde != auto and page-de-garde != none and type(page-de-garde) != content {
    panic("modele-junia : `page-de-garde` attend une image, pas un chemin — écrire `page-de-garde: image(\"garde.pdf\")`.")
  }
  // Date : un texte entre guillemets ou un nombre ressemble à une date mais n'en est pas une
  if date != auto and date != none and type(date) not in (content, datetime) {
    panic("modele-junia : `date` attend une date, ex : `datetime(year: 2025, month: 6, day: 30)`, ou un texte entre crochets, ex : `[Juin 2025]` — reçu : " + repr(date) + ".")
  }
  // Une date réduite à une heure, ex : `datetime(hour: 10, minute: 0, second: 0)`, ne peut pas être affichée
  if type(date) == datetime and date.year() == none {
    panic("modele-junia : `date` doit contenir l'année, le mois et le jour, ex : `datetime(year: 2025, month: 6, day: 30)`.")
  }
  // Mots-clés : une liste de textes. `("IoT")` sans virgule finale est un texte, pas une liste
  if type(mots-cles) != array or mots-cles.any(m => type(m) != str) {
    panic("modele-junia : `mots-cles` attend une liste de textes, ex : `(\"IoT\", \"LoRa\")` — avec un seul mot-clé, ne pas oublier la virgule : `(\"IoT\",)`.")
  }

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

  // Paramètres regroupés : clés connues uniquement, complétées par les valeurs par défaut
  let code           = fa-completer("modele-junia", "code",           code,           v-code-defaut)
  let numerotation   = fa-completer("modele-junia", "numerotation",   numerotation,   v-numerotation-defaut)
  let police         = fa-completer("modele-junia", "police",         police,         v-police-defaut)
  let couleurs-liens = fa-completer("modele-junia", "couleurs-liens", couleurs-liens, v-couleurs-liens-defaut)
  assert(
    numerotation.annexes in ("A", "1", "Annexe A", "Annexe 1"),
    message: "modele-junia : `numerotation.annexes` doit valoir \"A\", \"1\", \"Annexe A\" ou \"Annexe 1\", reçu : " + repr(numerotation.annexes) + "."
  )
  assert(
    code.mode in ("programme", "figure"),
    message: "modele-junia : `code.mode` doit valoir \"programme\" ou \"figure\", reçu : \"" + str(code.mode) + "\"."
  )

  // --- Mise à jour des états globaux du modèles ---
  // Gestion du mode ébauche
  v-ebauche-global.update(ebauche)
  // Gestion du bandeau de confidentialité
  v-confidentiel-global.update(bandeau-confidentiel)
  // Mots-clés affichés par `fbc-mots-cles`
  v-mots-cles-global.update(mots-cles)
  // Gestion des couleurs des liens
  v-couleurs-liens-global.update(couleurs-liens)
  // Gestion de la numérotation des titres et des équations dans le corps du document
  v-numerotation-global.update(numerotation)
  // Gestion des figures de code
  v-code-global.update(code)

  // --- Langue du document ---
  // Mise à jour de la langue du document si elle existe dans le dictionnaire
  let langue = if langue in v-liste-trad-auto.sommaire.keys() { langue } else { "fr" }
  v-langue-global.update(langue)

  // --- Métadonnées --- 
  // Mise à jour des métadonnées du document
  set document(title: titre-rapport, author: auteurs, keywords: mots-cles, date: if type(date) == datetime { date } else { auto })

  // --- Police et langue ---
  set text(
    lang: langue,
    size: police.taille,
    font: police.famille
    )

  // --- Réglages globaux de mise en page ---
  // Format A4, marges automatiques (proportionnelles au format) ; en-têtes et pieds de page sont définis par zone (zones.typ)
  // Filigranes BROUILLON et CONFIDENTIEL sur toutes les pages, page de garde générée comprise
  set page(
    paper: "a4", 
    margin: auto, 
    binding: auto,
    background: fa-fond-de-page()
  )

  // Paragraphes justifiés, avec une coupure de lignes optimisée sur l'ensemble du paragraphe
  set par(
    justify: true, 
    linebreaks: "optimized"
  )

  // --- Styles globaux ---
  // Notes de bas de page
  show footnote.entry: set text(size: 0.75em)
  
  // Espacement de la légende des figures
  set figure(gap: 1em)
  
  // Texte des tableaux légèrement réduit
  show table: set text(size: 0.833em)
  
  // Légende des tableaux au-dessus
  show figure.where(kind: table): set figure.caption(position: top)

  // --- Suppléments (formes longues pour les légendes) ---
  // Utilisation de `context` pour une résolution dynamique selon la langue
  let supp-eq  = context v-liste-trad-auto.at("eq_long").at(v-langue-global.get())
  let supp-fig = context v-liste-trad-auto.at("fig_long").at(v-langue-global.get())
  let supp-tab = context v-liste-trad-auto.at("tab_long").at(v-langue-global.get())
  // Programmes : « Figure » en mode figure, sinon le supplément choisi ou « Programme » / « Listing »
  let supp-prog = if code.mode == "figure" { supp-fig }
    else if code.supplement != auto { code.supplement }
    else { context v-liste-trad-auto.at("prog_long").at(v-langue-global.get()) }

  // Gestion des équations
  set math.equation(supplement: supp-eq)

  // Gestion des figures : numérotation commune selon la zone (voir `fa-numero-figure`)
  // et supplément par type — les types personnalisés gardent le supplément fourni par l'utilisateur
  set figure(numbering: fa-numerotation-figure, supplement: supp-fig)
  show figure.where(kind: table): set figure(supplement: supp-tab)
  show figure.where(kind: raw): set figure(supplement: supp-prog)

  // Programmes : un bloc de code long peut s'étendre sur plusieurs pages,
  // légende au-dessus comme les tableaux, sauf s'ils sont traités comme des figures
  show figure.where(kind: raw): set block(breakable: true)
  show figure.where(kind: raw): set figure.caption(position: if code.mode == "programme" { top } else { bottom })

  // --- Paquet : Glossarium ---
  // Mise à jour du state pour que fbc-lexique puisse le lire
  v-glossaire-global.update(glossaire)
  
  // Active la gestion des citations `@cle` vers les entrées du lexique
  show: make-glossary
  // Vérification avant enregistrement pour éviter une panique si la liste est vide
  if glossaire.len() != 0 {
    register-glossary(glossaire)
  }

  // Numéro court d'une équation référencée, résolu à l'emplacement de
  // l'équation elle-même — et non de la référence — pour rester correct en
  // cas de citation depuis un autre chapitre. Dans le corps, `el.numbering`
  // est une fonction (chapitre.numéro) ; ailleurs une chaîne ou `none`.
  let numero-equation(el) = {
    let loc = el.location()
    let num = el.numbering
    if type(num) == function {
      "(" + fa-chapitre(loc) + "." + str(counter(math.equation).at(loc).first()) + ")"
    } else if num != none {
      numbering(num, ..counter(math.equation).at(loc))
    } else {
      none
    }
  }

  // Forme courte du supplément d'une figure citée : fig., tab., prog.
  // Les types personnalisés gardent leur supplément complet.
  let supplement-court(el, lang) = {
    let trad(cle) = v-liste-trad-auto.at(cle).at(lang)
    if el.kind == image { trad("fig_court") }
    else if el.kind == table { trad("tab_court") }
    else if el.kind == raw {
      if code.mode == "figure" { trad("fig_court") }
      else if code.court != auto { code.court }
      else { trad("prog_court") }
    }
    else { el.supplement }
  }

  // --- Gestion des références (@clé) ---
  // IMPORTANT : pas de `context` global — cela briserait le chaînage
  // vers la règle show ref de make-glossary (nécessaire pour le lexique).
  // Les `context` sont locaux aux cas qui en ont besoin.
  // Clés des entrées du lexique, pour reconnaître leurs citations
  let cles-lexique = glossaire.map(entree => entree.key)
  show ref: it => {
    // Entrée du lexique, reconnue par sa clé (`@api`, `@api:pl`…) plutôt que par l'élément ciblé,
    // qui n'existe pas encore à la première passe : repère de citation (voir `v-lexique-cite`)
    // et couleur appliquée par une simple règle `set`, sans `context`, pour que la règle show ref
    // de glossarium traite toujours la citation
    if str(it.target).split(":").first() in cles-lexique {
      return { fa-repere-lexique(); set text(fill: couleurs-liens.glossaire.darken(45%)); it }
    }
    let el = it.element
    if el != none {

      // Figure de type annexe
      if el.func() == figure and el.kind == "annexe" {
        return fa-style-lien(it, kind: "annexe")
      }
      // Toute autre figure (image, tableau, programme, type personnalisé) — forme courte dans le texte
      // Une numérotation propre fournie par l'utilisateur (chaîne) est respectée telle quelle
      if el.func() == figure and el.numbering != none {
        return context {
          let sup = supplement-court(el, v-langue-global.get())
          let num = if type(el.numbering) == function { fa-numero-figure(el) }
            else { numbering(el.numbering, ..counter(figure.where(kind: el.kind)).at(el.location())) }
          link(el.location())[#sup~#num]
        }
      }
      // Équation — forme courte dans le texte
      if el.func() == math.equation {
        return context {
          let sup = v-liste-trad-auto.at("eq_court").at(v-langue-global.get())
          link(el.location())[#sup~#numero-equation(el)]
        }
      }
    }
    // Chaînage vers make-glossary : `it` retourné hors de tout context
    // permet à la règle show ref de glossarium de s'exécuter normalement.
    it
  }

  // --- Citations bibliographiques ---
  show cite: it => fa-style-lien(it, kind: "bibliographie")

  // --- Style des titres ---
  // Niveau écrit : les titres d'annexes sont décalés d'un niveau (voir `fmp-annexes`)
  // Typst règle déjà la taille des titres selon leur niveau (1.4em, 1.2em, puis 1em) et leurs
  // espacements (au-dessus 1.8 puis 1.44, au-dessous 0.75, en tailles de texte du document) ; les
  // réglages du modèle s'y ajoutent. Un titre d'annexe, décalé d'un niveau (voir `fmp-annexes`),
  // reçoit ceux de son niveau écrit, pour rester identique à un titre du corps
  show heading.where(level: 2, offset: 1): set text(size: 1em * 1.4 / 1.2)
  show heading.where(level: 2, offset: 1): set block(above: 1.8em / 1.4, below: 0.75em / 1.4)
  show heading.where(level: 3, offset: 1): set text(size: 1em * 1.2)
  show heading.where(level: 3, offset: 1): set block(above: 1.44em / 1.2, below: 0.75em / 1.2)
  show heading: it => {
    let niveau = it.level - it.offset
    if niveau == 1 {
      // Saut de page avant chaque chapitre de niveau 1
      pagebreak(weak: true)
      v(1em)
    } else {
      // Espacement proportionnel au niveau
      v(1em / niveau)
    }
    // Taille décroissante selon le niveau
    let v-taille = police.titres.at(niveau - 1, default: 1em)
    set text(size: v-taille, weight: "bold")
    // `sticky` empêche un titre orphelin en bas de page
    block(sticky: true, {
      if it.numbering != none {
        fa-numero-titre(it)
        h(0.5em / niveau)
      }
      it.body
    })
    v(0.35em / niveau)
  }

  // --- Sommaires ---
  // Numéro des titres affiché comme dans le document : mot « Annexe » et délimiteur (voir `fa-numero-titre`)
  show outline.entry: it => {
    let el = it.element
    // Titres d'annexes, décalés d'un niveau : entrée au niveau écrit, pour garder l'indentation du corps
    if el.func() == heading and el.offset > 0 and it.level == el.level {
      return outline.entry(el.level - el.offset, el, fill: it.fill)
    }
    if el.func() != heading or el.numbering == none { return it }
    link(el.location(), it.indented(fa-numero-titre(el), it.inner()))
  }

  // --- Paquet : Codly (blocs de code) ---
  // Chaque bloc de code est converti par `codly.new` ; réglages par défaut du modèle posés par les
  // règles `*-set_` de codly, que l'utilisateur peut à son tour modifier (`#show: codly.set_(...)`).
  // Désactivable via `code: (coloration: false)` : les blocs gardent alors le rendu natif de Typst.
  show: if code.coloration {
    doc => {
      // Noms, couleurs et icônes des langages
      show: codly.lang-set_(languages: codly-languages)
      // Numéros de lignes discrets, alignés à droite
      show: codly.number-set_(
        numbering: n => text(fill: rgb("#aaaaaa"), size: 0.8em, str(n)),
        align:     right + horizon,
      )
      show raw.where(block: true): codly.new
      doc
    }
  } else {
    // Sans codly, un bloc de code occupe toute la largeur pour rester aligné à gauche dans une figure centrée
    doc => {
      show raw.where(block: true): it => block(width: 100%, align(start, it))
      doc
    }
  }


  // --- Page de garde ---
  // Une seule page de garde : la page générée, ou à la place la page externe fournie
  if page-de-garde == auto {
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
      date:            date,
      logo-gauche:     logo-gauche,
      adresse-gauche:  adresse-gauche,
      logo-centre:     logo-centre,
      adresse-centre:  adresse-centre,
      logo-droite:     logo-droite,
      adresse-droite:  adresse-droite,
    )
  } else if page-de-garde != none {
    page(margin: 0pt, header: none, footer: none,
      // Taille imposée par règle `set` sur l'image fournie par l'appelant
      background: { set image(width: 100%, height: 100%); page-de-garde }
    )[]
  }
  // --- Basculement ---
  // Passage en mode pré-sommaire du document
  show: fmp-pre-sommaire
  
  body
}
