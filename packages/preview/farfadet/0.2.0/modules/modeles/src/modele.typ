// modele.typ — le modèle de document `farfadet`.
//
//   #show: farfadet.with(niveau: "2nde", theme: [Les vecteurs], correction: false)
//
// Les calibrages du moteur
// (échelles Fourier/Erewhon, échelle des maths, resserrement du gras, décalage vertical) sont
// des clés réglables ; leurs valeurs par défaut sont celles de bfcours (`moteur/modele.typ`).
//
// Les clés de PAGE (papier, marges, decalage, avec-page, pied) sont des arguments directs, car Typst
// interdit `set page` dans un `context`. Toutes les autres clés se règlent aussi globalement
// (`setbfmodele(pour: "bfcours", …)`) ou par style nommé (`setbfmodele(definir: …)`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, reglages-liste, bf-vide
#import "../../didactique/lib.typ": interne as _didactique
#import _didactique: tableofcontents, bf-appliquer-environnements as _appliquer-environnements, bf-appliquer-jeu-titres as _appliquer-jeu-titres
#import "moteur/modele.typ": bfcours-page, bfcours-texte, bfcours-valeurs
#import "moteur/reglages.typ": modele-reglages as _R, champs-identite as _champs-identite
#import "entetes.typ": _types-effectifs, chap-eval, chapitre

// Clés du bandeau que le modèle accepte aussi (ajout 11/10/2026) : identité, rendu de l'en-tête, séparateur et
// libellés des types. Les autres clés du bandeau (hauteur, couleurs…) restent refusées ici : elles se règlent
// par `setbfmodele`.
#let _cles-bandeau = _champs-identite.filter(k => k not in ("cycle", "etablissement")) + ("rendu", "skin", "champs", "separateur-type", "libelles-types")

/// Modèle de document bfcours : page A4, polices Erewhon, équations, bandeau de chapitre (niveau,
/// thème, type de document), pied de page, sommaire facultatif et réglage des environnements.
///
/// Les clés sont toutes facultatives et toutes nommées ; les valeurs par défaut sont celles de bfcours.
/// Le bandeau de chapitre n'est posé que si `niveau` ou `theme` est renseigné. Les clés se règlent aussi
/// une fois pour toutes (`setbfmodele`) ou par style nommé (`style:`) ; priorité : clé locale >
/// style nommé > réglage du type `"bfcours"` > réglage global > défaut.
///
/// ```typ
/// #show: farfadet.with(niveau: "2nde", theme: [Les vecteurs], correction: false)
/// #show: farfadet.with(fontsize: 11pt, fleqn: false, sommaire: true)
/// #show: farfadet.with(dys: true)
/// ```
///
/// - correction (bool): `true` : version professeur ; `false` : version élève. `--input correction=true|false` l'emporte. Défaut : `true`.
/// - fontsize (length, auto): taille nominale du texte (option de `scrextend`). Défaut : `auto` (12pt ; 14pt en dys).
/// - fleqn (bool): `true` : équations en display alignées à gauche avec retrait (option de classe `fleqn`) ; `false` : centrées. Défaut : `true`.
/// - mathindent (length, auto): retrait des équations de `fleqn` (`\mathindent`). Défaut : `auto` (27.37pt TeX).
/// - baselineskip (length, auto): interligne (`\baselineskip`). Défaut : `auto` (14.5pt TeX, proportionnel à `fontsize`).
/// - dys (bool): variante dys de `bfcours-fonts` : police sans empattement (`police-dys`), 14 pt, interligne × 1,2, espaces élargis, texte non justifié. Défaut : `false`.
/// - niveau (str, content): niveau du bandeau. Écritures courtes : `"6e"`, `"5e"`, `"4e"`, `"3e"`, `"2nde"`, `"1ère"` (ou `"1re"`), `"Tle"` (exposant ajouté) ; tout autre texte ou contenu est affiché tel quel.
/// - theme (content, str): titre du chapitre, dans le bandeau et le pied de page.
/// - type-document ("cours" | "exercices" | "activite" | "fiche" | "evaluation" | content): nature du document. `"evaluation"` pose le bandeau d'évaluation `chap-eval` (cases Classe et Date) ; un contenu quelconque sert de libellé libre sur un bandeau ordinaire. Les types et leurs libellés se règlent par la clé `libelles-types` (`"tp"` s'emploie après `libelles-types: (tp: [TP])`). Défaut : `"cours"`.
/// - cycle (content, str): cycle, à droite du pied de page. Défaut : « Lycée ».
/// - etablissement (content, str): établissement, à droite du pied de page.
/// - zone-droite (content): contenu libre à droite du bandeau (hors évaluation).
/// - professeur (content): nom du professeur. Comme les autres champs d'identité, il se règle d'habitude une fois pour toutes (`setbfmodele(pour: "identite", …)`) et ne s'affiche que si le rendu de l'en-tête ou la clé `champs` le montre.
/// - academie (content): académie (champ d'identité).
/// - annee (content): année scolaire, par exemple `[2026-2027]` (champ d'identité).
/// - classe (content): classe, par exemple `[2#super[de] 4]` (champ d'identité).
/// - matiere (content): discipline (champ d'identité).
/// - mentions (content): mentions de pied de page : licence, adresse… (champ d'identité).
/// - logo (content, none): logo, par exemple `image("logo.png")` (champ d'identité).
/// - rendu ("bf" | "rd" | "sobre" | "encadre" | function): rendu de l'en-tête pour ce document (voir `chapitre`). Défaut : `"bf"`.
/// - skin (dictionary): options du rendu (voir `chapitre`).
/// - champs (dictionary, auto): champs affichés dans les zones de l'en-tête (voir `chapitre`).
/// - separateur-type (content, auto): ce qui s'écrit entre le type et le thème : `[ : ]` donne « Cours : Les vecteurs » (voir `chapitre`). Défaut : `auto` (« : », ou une simple espace si le libellé du type finit déjà par deux-points ; `[ ]` redonne l'ancien rendu).
/// - libelles-types (dictionary): libellés des types de document, complétés par de nouveaux types : `(cours: [Leçon], tp: [TP])` (voir `chapitre`). Défaut : `(:)`.
/// - titres ("bfcours" | "sobre" | "classique" | "documentation" | "rd"): jeu de titres des niveaux 1 à 4 (rendu dans le sectionnement de farfadet-didactique). `"bfcours"` : bandeaux des cours (défaut) ; `"sobre"` : numéro coloré et filet fin ; `"classique"` : titres gras d'article ; `"documentation"` : rendu des documentations ; `"rd"` : badge « ■ Titre » de rdboites au niveau 1.
/// - numeros ("arabe" | "romain" | "lettres" | array): style de numérotation des titres. `"arabe"` : 1, 1.1, 1.1.1 ; `"romain"` : I, II… pour les sections, puis 1., 2.… pour les sous-sections et a), b)… au niveau 3 ; `"lettres"` : A, B… puis 1., 2.… et a), b)… ; un tableau de motifs Typst par niveau (`("I", "1.", "a)")`) règle chaque niveau. Défaut : `auto` (réglage de `setbfsections(numeros: …)`, `"arabe"` sans réglage).
/// - sommaire (bool): `true` : table des matières sous le bandeau. Défaut : `false`.
/// - titre-sommaire (content): titre de la table des matières. Défaut : « Table des matières ».
/// - colonnes-sommaire (int): nombre de colonnes de la table des matières. Défaut : `2`.
/// - environnements (dictionary, none): réglages des environnements, même contenu que les arguments de `setbfenvironments` : `(tous: (…), Definition: (…))`.
/// - style (str, array): style(s) nommé(s) défini(s) par `setbfmodele(definir: …)`.
/// - papier (str): format de papier Typst : `"a4"` (défaut), `"a5"`, `"us-letter"`… (page : argument direct).
/// - marges (dictionary): marges à modifier, parmi `left`, `right`, `top`, `bottom` ; les clés absentes gardent la valeur de bfcours (1 cm, 0,5 cm, 0,5 cm, 2 cm).
/// - decalage (length): décalage vertical de 2,5 pt TeX des documents bfcours (`\headheight` porté à 14,5 pt après geometry). Défaut : `2.5pt` TeX.
/// - avec-page (bool): `false` : ne règle ni le format de page ni le pied de page, seulement le style du texte (aperçus encadrés, documentation). Défaut : `true`.
/// - pied (bool): `false` : pas de pied de page (voir `pied-de-page()` pour le poser soi-même). Défaut : `true`.
/// - police-dys (str, dictionary): famille dys : `"Fira"` (défaut), `"lmodern"`, `"tgheros"` ou `(texte: (…), maths: (…))` (voir `choice-fonts-dys`).
/// - police (array, auto): polices du texte, par ordre de préférence. Défaut : `auto` (`("Erewhon", "Libertinus Serif")`).
/// - police-maths (array, auto): polices des formules. Défaut : `auto` (`("Erewhon Math", "New Computer Modern Math")`).
/// - etirement-interligne (float, auto): facteur d'interligne (`\setstretch`). Défaut : `auto` (1 ; 1,2 en dys).
/// - espace-mot (length, none, auto): espace intermot fixe (`\spaceskip`). Défaut : `auto` (espace de la police ; 0,8 em en dys).
/// - justifier (bool, auto): justification du texte. Défaut : `auto` (oui ; non en dys).
/// - echelle-fourier (float, auto): fourier compose Utopia à 11/12 du nominal. Défaut : `auto` (11/12 ; 1 en dys).
/// - echelle-police (float, auto): rapport Utopia / police Typst à corps égal. Défaut : `auto` (1,065 ; 1 en dys).
/// - echelle-maths (float, auto): facteur d'agrandissement de la police mathématique (la formule est composée à 1/facteur). Défaut : `auto` (1).
/// - tracking-gras (length, auto): resserrement de l'approche du gras. Défaut : `auto` (-0.009em ; 0 en dys).
/// - abovedisplayskip (length): espace avant une équation (`\abovedisplayskip`). Défaut : `12pt` TeX.
/// - belowdisplayskip (length): espace après une équation (`\belowdisplayskip`). Défaut : `12pt` TeX.
/// - espace-mot-min (ratio): resserrement maximal de l'espace intermot. Défaut : `100% * (0.207 - 0.05) / 0.207`.
/// - espace-mot-max (ratio): étirement maximal de l'espace intermot. Défaut : `160%`.
/// - correction-fraction-haut (length): espace ajouté au-dessus des équations à fractions. Défaut : `1.9pt`.
/// - correction-fraction-bas (length): espace ajouté au-dessous. Défaut : `2.3pt`.
/// - ecart-colonnes-matrice (length): écart entre colonnes de matrice. Défaut : `10pt` TeX.
/// - doc (content): le document, fourni par `#show:`.
/// -> content
#let farfadet(
  correction: auto,
  fontsize: auto,
  fleqn: auto,
  mathindent: auto,
  baselineskip: auto,
  dys: auto,
  niveau: auto,
  theme: auto,
  type-document: auto,
  cycle: auto,
  etablissement: auto,
  zone-droite: auto,
  titres: auto,
  numeros: auto,
  sommaire: auto,
  titre-sommaire: auto,
  colonnes-sommaire: auto,
  environnements: auto,
  style: auto,
  papier: "a4",
  marges: (left: 1cm, right: 0.5cm, top: 0.5cm, bottom: 2cm),
  decalage: 2.5pt * 72 / 72.27,
  avec-page: true,
  pied: true,
  doc,
  ..options,
) = {
  show: bfcours-page.with(papier: papier, marges: marges, decalage: decalage, avec-page: avec-page, pied: pied)
  // Clés d'identité et de rendu de l'en-tête (ajout 11/10/2026) : transmises au bandeau, pour ce document seul.
  let vers-bandeau = options.named().pairs().filter(((k, _)) => k in _cles-bandeau).to-dict()
  let options = arguments(..options.named().pairs().filter(((k, _)) => k not in _cles-bandeau).to-dict())
  context {
    let cles-style = if style == auto { (:) } else { (style: style) }
    let r = reglages-resoudre(_R, pour: "bfcours", commande: "farfadet", local: (
      correction: correction,
      fontsize: fontsize,
      fleqn: fleqn,
      mathindent: mathindent,
      baselineskip: baselineskip,
      dys: dys,
      titres: titres,
      numeros: numeros,
      sommaire: sommaire,
      titre-sommaire: titre-sommaire,
      colonnes-sommaire: colonnes-sommaire,
      environnements: environnements,
    ) + cles-style + options.named())
    // Bandeau : posé si un niveau ou un thème est donné (argument, style ou réglage global).
    // `theme: none` est toléré : pas de thème.
    let theme = if theme == none { auto } else { theme }
    let bandeau = (
      niveau: niveau,
      theme: theme,
      cycle: cycle,
      etablissement: etablissement,
      zone-droite: zone-droite,
      type: type-document,
    ) + cles-style + vers-bandeau
    let rc = reglages-resoudre(_R, pour: "chapitre", commande: "farfadet", local: bandeau)
    let td = rc.type
    // cycle du modèle : « Lycée » tant qu'aucun autre n'est donné (le bandeau seul n'a pas de cycle par défaut)
    let cycle = if bf-vide(rc.cycle) { [Lycée] } else { rc.cycle }
    let types = _types-effectifs(rc.libelles-types)
    if type(td) == str and td not in types {
      panic(
        "farfadet : type de document inconnu « " + td + " ». Valeurs possibles : "
          + reglages-liste(types.keys()) + ", ou un contenu pour un libellé libre (nouveaux types : clé libelles-types).",
      )
    }
    let est-evaluation = type(td) == str and types.at(td).at(1)
    let a-bandeau = not bf-vide(rc.theme) or not bf-vide(rc.niveau)
    bfcours-texte(..bfcours-valeurs(r), {
      _appliquer-environnements(r.environnements)
      _appliquer-jeu-titres(r.titres, numeros: r.numeros)
      if a-bandeau {
        if est-evaluation {
          chap-eval(niveau: niveau, theme: theme, cycle: cycle, etablissement: etablissement, type: td, ..cles-style, ..vers-bandeau)
        } else {
          chapitre(
            niveau: niveau,
            theme: theme,
            cycle: cycle,
            etablissement: etablissement,
            zone-droite: zone-droite,
            type: td,
            ..cles-style,
            ..vers-bandeau,
          )
        }
      }
      if r.sommaire { tableofcontents(titre: r.titre-sommaire, colonnes: r.colonnes-sommaire) }
      doc
    })
  }
}
