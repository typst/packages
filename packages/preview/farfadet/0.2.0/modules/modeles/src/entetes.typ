// entetes.typ — façade des en-têtes de document : bandeau de chapitre (\chapitre), bandeau d'évaluation
// (\chapEval), pied de page et ligne de progression (\SequenceItem).
//
//   #chapitre(niveau: "2nde", theme: [Les vecteurs], cycle: [Lycée], etablissement: [Lycée du Parc])
//   #chap-eval(niveau: "2nde", theme: [Les vecteurs], type: [Contrôle])
//
// Noms et clés de LaTeX : les six arguments de \chapitre[niveau]{thème}{cycle}{établissement}{zone droite}{type}
// se donnent par leur nom (`niveau:`, `theme:`…) OU, comme en LaTeX, par position dans l'ordre
// `theme, cycle, etablissement, zone-droite, type` (`niveau` reste nommé : c'est l'argument facultatif).
// Les clés non nommées dans la signature (hauteur, couleurs…) sont celles du registre `modele-reglages` :
// elles se règlent globalement (`setbfmodele`), par type, par style nommé ou localement.
// Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».

#import "moteur/entetes.typ" as m

// Tables des niveaux et des types de document : dans le moteur (la correspondance se fait après résolution des réglages).
#let _types-document = m._types-document
#let _types-effectifs = m._types-effectifs

/// Range les arguments positionnels (ordre LaTeX) dans les clés nommées ; refuse un doublon.
#let _positionnels(commande, noms, args, nommes) = {
  let pos = args.pos()
  if pos.len() > noms.len() {
    panic(
      commande + " : au plus " + str(noms.len()) + " arguments positionnels (" + noms.join(", ") + ") ; reçu : " + str(pos.len()) + ".",
    )
  }
  let res = nommes
  for (i, v) in pos.enumerate() {
    let cle = noms.at(i)
    if res.at(cle, default: auto) != auto {
      panic(commande + " : « " + cle + " » est donné deux fois (en position " + str(i + 1) + " et par son nom).")
    }
    res.insert(cle, v)
  }
  res
}

/// \chapitre : bandeau de chapitre. Étiquette de niveau, titre « type thème » sur un dégradé gris, zone libre à droite.
/// Il enregistre aussi les textes du pied de page, qui les reprend à chaque page suivante.
///
/// Le bandeau est le début d'une fiche, d'un cours ou d'une activité. Le modèle `farfadet` le pose
/// pour vous quand on lui donne `niveau` ou `theme` ; on l'écrit à la main pour changer de bandeau
/// en cours de document, ou pour un document sans modèle. Comme en LaTeX, `theme, cycle,
/// etablissement, zone-droite, type` peuvent aussi se donner par position, dans cet ordre.
///
/// ```typ
/// #chapitre(niveau: "2nde", theme: [Les vecteurs], cycle: [Lycée], etablissement: [Lycée du Parc])
/// #chapitre(niveau: "6e", [La proportionnalité], [Collège], [Marie Curie], [], [Cours])   // forme LaTeX
/// ```
///
/// - niveau (str, content): niveau de la classe. Écritures courtes : `"6e"`, `"5e"`, `"4e"`, `"3e"`, `"2nde"`, `"1ère"`, `"Tle"` (exposant ajouté) ; tout autre texte est affiché tel quel. Défaut : vide.
/// - theme (content, str): titre du chapitre, dans le bandeau et le pied de page.
/// - cycle (content, str): cycle, à droite du pied de page.
/// - etablissement (content, str): établissement, à droite du pied de page.
/// - zone-droite (content): contenu libre à droite du bandeau.
/// - type (content, str): nature du document, devant le thème : `"cours"` (défaut), `"exercices"`, `"activite"`, `"fiche"`, `"evaluation"` (libellé correspondant, modifiable par `libelles-types`), un type ajouté par `libelles-types`, ou un contenu libre.
/// - style (str, array): style(s) nommé(s) défini(s) par `setbfmodele(definir: …)`.
/// - pied (bool): `false` : le bandeau ne renseigne pas le pied de page. Défaut : `true`.
/// - hauteur (length): hauteur du bandeau. Défaut : `1.5cm`.
/// - hauteur-etiquette (length): hauteur du carré de niveau et du titre. Défaut : `1.4cm`.
/// - colonnes (int): colonnes de la grille (`raster columns`). Défaut : `9`.
/// - colonnes-titre (int): colonnes occupées par le titre (le reste va à la zone de droite). Défaut : `6`.
/// - boxsep (length): marge intérieure du bandeau. Défaut : `1mm`.
/// - gouttiere (length): écart entre les colonnes. Défaut : `5pt`.
/// - epaisseur-filet (length, auto): épaisseur des filets. Défaut : `auto` (`1pt` pour `"bf"`, `0.6pt` pour `"sobre"` et `"encadre"`, celle de rdboites pour `"rd"`).
/// - couleur-filet (color, str): couleur des filets. Défaut : noir.
/// - couleur-debut (color, str): couleur du dégradé à gauche. Défaut : `gray!60`.
/// - couleur-fin (color, str): couleur du dégradé à droite. Défaut : `gray!10`.
/// - couleur-etiquette (color, str): fond du carré de niveau. Défaut : `gray!60`.
/// - couleur-niveau (color, str): texte du niveau. Défaut : noir.
/// - couleur-contour (color, str): contour du texte du niveau. Défaut : blanc.
/// - epaisseur-contour (length): épaisseur de ce contour. Défaut : `0.64pt`.
/// - couleur-titre (color, str, auto): couleur du titre ; `auto` : couleur d'accent. Défaut : `auto`.
/// - taille-niveau (str, length): taille du niveau (nom LaTeX ou longueur). Défaut : `"Large"`.
/// - taille-titre (str, length): taille du titre. Défaut : `"large"`.
/// - espace-avant-type (length): espace avant le type. Défaut : `0.34em`.
/// - espace-type-theme (length): largeur de l'espace entre le type et le thème. Défaut : `0.39em`. Sans effet quand `separateur-type` est réglé.
/// - separateur-type (content, auto): ce qui s'écrit entre le libellé du type et le thème. `auto` (défaut) : « : » (« Cours : Les vecteurs »), sauf si le libellé du type finit déjà par deux-points (libellé libre `[Cours :]`) : l'espace d'origine, de largeur `espace-type-theme`, est alors conservée. Pour retrouver l'ancien rendu « Cours Les vecteurs », écrire `[ ]`. Un contenu remplace le séparateur : `[ : ]` donne « Cours : Les vecteurs », `" - "` « Cours - Les vecteurs » (un tiret simple s'écrit en chaîne : `[ - ]` serait lu comme une puce de liste) ; de même `[ – ]` (demi-cadratin) ou `[ -- ]`.Les espaces autour du signe s'écrivent dans le contenu ; `[]` colle le type au thème. Sans type ou sans thème, le séparateur n'est pas affiché. Le pied de page reprend ce séparateur pour son « type thème ». Se règle une fois pour toutes : `setbfmodele(separateur-type: [ : ])`.
/// - libelles-types (dictionary): libellés des types de document : `(cours: [Leçon], exercices: [Entraînement], tp: [TP])`. Les types non cités gardent leur libellé (`cours`, `exercices`, `activite`, `fiche`, `evaluation`) ; un type nouveau (`tp`) s'emploie ensuite par `type: "tp"` ou `type-document: "tp"`. Les types connus gardent leur nature de bandeau (seul `evaluation` pose le bandeau d'évaluation) ; un type nouveau a un bandeau ordinaire. Se règle une fois pour toutes : `setbfmodele(libelles-types: (cours: [Leçon]))` ; un nouvel appel remplace le dictionnaire précédent. Défaut : `(:)`.
/// - espace-apres (length): espace après le bandeau. Défaut : `9.47pt` (`7.25pt` pour `chap-eval`).
/// - rendu ("bf" | "rd" | "sobre" | "encadre" | function): dessin de l'en-tête. `"bf"` : ce bandeau (défaut) ; `"rd"` : le bandeau `rd.entete` du paquet rdboites (filets et fond dégradés), réutilisé tel quel ; `"sobre"` : une ligne sur fond blanc et un filet fin dessous ; `"encadre"` : un cadre fin à trois cases (identité, titre, niveau et année) ; une fonction `d => contenu` : votre propre dessin (champs de `d` ci-dessous). Numérotation du pied, espace après et contenu `apres` restent assurés. Défaut : `"bf"`.
/// - skin (dictionary): options du rendu, lues par une fonction dans `d.options` ; pour `"rd"`, clés de `rd.entete` (`colframe`, `colback`, `rule-width`…). Défaut : `(:)`.
/// - champs (dictionary, auto): ce que montre chaque zone : `(gauche: (…), centre: (…), droite: (…))`, une liste par zone (les zones absentes gardent celles du rendu, `none` vide une zone). Un élément est un nom de champ (`"niveau"`, `"type"`, `"theme"`, `"titre"` = type et thème, `"zone"` = `zone-droite` ou cases d'évaluation, `"cycle"`, `"etablissement"`, `"professeur"`, `"academie"`, `"annee"`, `"classe"`, `"matiere"`, `"logo"`, `"mentions"`), un contenu libre ou une fonction `d => contenu`. Les champs sont empilés, un par ligne ; un `"logo"` cité en premier se place à gauche des autres. Défaut : `auto` (`"bf"` et `"rd"` : niveau, titre, zone ; `"sobre"` : niveau, titre, établissement et année ; `"encadre"` : logo, établissement, professeur | type, thème | niveau, classe, année).
/// - professeur (content): nom du professeur. Champ d'identité : comme `academie`, `annee`, `classe`, `matiere`, `logo` et `mentions`, il se règle une fois pour toutes (`setbfmodele(pour: "identite", professeur: […])`) et ne s'affiche que si le rendu ou `champs` le montre. Défaut : vide.
/// - academie (content): académie (champ d'identité). Défaut : vide.
/// - annee (content): année scolaire (champ d'identité). Défaut : vide.
/// - classe (content): classe (champ d'identité). Défaut : vide.
/// - matiere (content): discipline (champ d'identité). Défaut : vide.
/// - logo (content, none): logo (champ d'identité) : `image("logo.png")`, chemin lu depuis le fichier qui l'écrit, ou un dessin ; ramené à `hauteur-logo`. Défaut : `none`.
/// - mentions (content): mentions de pied de page : licence, adresse (champ d'identité). Défaut : vide.
/// - hauteur-logo (length, auto): hauteur du logo. Défaut : `auto` (le carré de niveau pour `"bf"`, 1,2 cm sinon).
/// - police-titre (str, array, auto): police du titre. Défaut : `auto` (police du texte).
/// - graisse-titre (str, int, auto): graisse du titre. Défaut : `auto` (`"bf"`, `"rd"` : inchangée ; `"sobre"`, `"encadre"` : gras).
/// - police-champs (str, array, auto): police des champs d'identité. Défaut : `auto`.
/// - taille-champs (str, length): taille des champs d'identité (nom LaTeX ou longueur). Défaut : `"footnotesize"`.
/// - couleur-champs (color, str, auto): couleur des champs d'identité. Défaut : `auto` (couleur du texte).
/// - couleur-fond (color, str, none, auto): fond de l'en-tête. Défaut : `auto` (dégradé `couleur-debut` → `couleur-fin` pour `"bf"`, dégradé de rdboites pour `"rd"`, aucun fond sinon).
/// - largeurs (array, auto): largeurs des trois colonnes des rendus `"rd"`, `"sobre"`, `"encadre"`. Défaut : `auto` (`(auto, 1fr, auto)` ; `(1fr, 2fr, 1fr)` pour `"encadre"`).
///
/// Le dictionnaire `d` reçu par un rendu personnel : `niveau`, `type`, `theme`, `titre`, `zone` et les champs d'identité (bruts) ; `commande` (`"chapitre"` ou `"chapEval"`), `evaluation` (booléen) ; `champs` (les zones résolues) ; `pile` (fonction : `(d.pile)(("classe", "annee"))` empile des champs mis en forme) ; `hauteur-logo` ; `options` (la clé `skin`) ; `r` (toutes les clés résolues, couleurs comprises).
/// -> content
#let chapitre(
  niveau: auto,
  theme: auto,
  cycle: auto,
  etablissement: auto,
  zone-droite: auto,
  type: auto,
  style: auto,
  ..options,
) = {
  let c = _positionnels("chapitre", ("theme", "cycle", "etablissement", "zone-droite", "type"), options, (
    theme: theme,
    cycle: cycle,
    etablissement: etablissement,
    zone-droite: zone-droite,
    type: type,
  ))
  m.chapitre(
    niveau: niveau,
    c.theme,
    c.cycle,
    c.etablissement,
    c.zone-droite,
    c.type,
    ..m._style(style),
    ..options.named(),
  )
}

/// \chapEval : bandeau d'évaluation. Comme `chapitre`, avec les cases « Classe » et « Date » à droite
/// et un contenu facultatif juste sous le bandeau. Les clés de réglage sont celles de `chapitre`
/// (type de réglage `"chapEval"`).
///
/// En LaTeX : `\chapEval[niveau]{thème}{cycle}{établissement}{contenu sous le bandeau}{type}` ; ici
/// les positionnels sont `theme, cycle, etablissement, apres, type`.
///
/// ```typ
/// #chap-eval(niveau: "3e", theme: [Théorème de Thalès], type: [Contrôle n° 2])
/// ```
///
/// - niveau (str, content): niveau de la classe (voir `chapitre`).
/// - theme (content, str): titre du chapitre.
/// - cycle (content, str): cycle, à droite du pied de page.
/// - etablissement (content, str): établissement, à droite du pied de page.
/// - apres (content): contenu placé juste sous le bandeau : consignes, barème…
/// - type (content, str): nature du document ; `"evaluation"` (défaut) donne « Évaluation ».
/// - style (str, array): style(s) nommé(s).
/// - hauteur (length): hauteur du bandeau (autres clés : voir `chapitre`). Défaut : `1.5cm`.
/// - colonnes-titre (int): colonnes occupées par le titre. Défaut : `4`.
/// - espace-apres (length): espace entre le bandeau et `apres` (le cartouche `tableau-eval`, qui s'y confond sans s'y ajouter). Défaut : `7.25pt`.
/// -> content
#let chap-eval(
  niveau: auto,
  theme: auto,
  cycle: auto,
  etablissement: auto,
  apres: auto,
  type: auto,
  style: auto,
  ..options,
) = {
  let c = _positionnels("chapEval", ("theme", "cycle", "etablissement", "apres", "type"), options, (
    theme: theme,
    cycle: cycle,
    etablissement: etablissement,
    apres: apres,
    type: type,
  ))
  m.chapeval(
    niveau: niveau,
    c.theme,
    c.cycle,
    c.etablissement,
    c.apres,
    c.type,
    ..m._style(style),
    ..options.named(),
  )
}

/// Pied de page de bfcours : filet, « type thème » à gauche, « cycle établissement » à droite, numéro
/// de page dans un disque gris. Il lit les textes posés par le dernier `chapitre` ou
/// `chap-eval` rencontré, et ne montre rien avant le premier (sauf si `gauche`, `centre` ou `droite`
/// sont donnés). Quand deux bandeaux sont posés sur la même page, le pied de cette page porte le
/// second, comme celui des pages suivantes qui n'ont pas de bandeau.
///
/// Le modèle `farfadet` l'installe tout seul. On s'en sert pour une mise en page personnelle :
///
/// ```typ
/// #set page(footer: pied-de-page(), footer-descent: 0pt)
/// #set page(footer: pied-de-page(disposition: "simple", gauche: [Mon nom]), footer-descent: 0pt)
/// ```
///
/// - disposition (str, function): `"bfcours"` (défaut : disque de numéro à droite), `"simple"` (texte à gauche, numéro au centre, texte à droite : pied du skin exolombards) ou une fonction `d => contenu` qui dessine tout le pied (zone de `hauteur` de haut, texte déjà réglé par `taille`, `graisse`, `couleur-texte`). `d` contient `type`, `theme`, `titre`, `niveau`, `numero` (le numéro de page), les champs d'identité, `ligne` (fonction : `(d.ligne)(("professeur", "annee"))` les met bout à bout), `hauteur-logo` et `r` (toutes les clés résolues).
/// - gauche (content, array, function, auto): texte de gauche ; une liste de champs (`("professeur", "annee")`, séparés par `separateur`) ou une fonction `d => contenu` ; `auto` : « type thème » du dernier bandeau.
/// - centre (content, array, function, auto): texte du centre (mêmes formes) ; `auto` : rien (disposition `"bfcours"`) ou le numéro de page (`"simple"`).
/// - droite (content, array, function, auto): texte de droite (mêmes formes) ; `auto` : « cycle établissement » du dernier bandeau.
/// - separateur (content, auto): entre les champs d'une liste. Défaut : `auto` (point médian).
/// - hauteur-logo (length, auto): hauteur du champ `"logo"`. Défaut : `auto` (1 em).
/// - professeur (content): champ d'identité, comme `cycle`, `etablissement`, `academie`, `annee`, `classe`, `matiere`, `logo`, `mentions` : il sert quand le dernier bandeau ne le renseigne pas. Champs cités par leur nom : ceux-là, et `"type"`, `"theme"`, `"titre"`, `"niveau"`, `"numero"`.
/// - numero (bool): afficher le numéro de page. Défaut : `true`.
/// - style (str, array): style(s) nommé(s).
/// - hauteur (length): hauteur de la zone du pied (`\footskip`). Défaut : `30pt`.
/// - epaisseur-filet (length): épaisseur du filet (`\footrulewidth`). Défaut : `0.3985pt`.
/// - position-filet (length): distance du filet au bas de la zone. Défaut : `14.65pt`.
/// - couleur-filet (color, str): couleur du filet. Défaut : noir.
/// - taille (str, length): taille du texte. Défaut : `"scriptsize"`.
/// - graisse (str, int): graisse du texte. Défaut : `"bold"`.
/// - couleur-texte (color, str): couleur du texte. Défaut : noir.
/// - espace-avant-type (length): espace avant le type. Défaut : `0.2em`.
/// - espace-type-theme (length): espace entre les deux textes accolés. Défaut : `0.59em`. Sans effet quand un séparateur est réglé.
/// - separateur-type (content, auto): ce qui s'écrit entre le type et le thème du « type thème » de gauche. `auto` (défaut) : celui du dernier bandeau (`separateur-type` de `chapitre`), à défaut « : » selon la même règle (espace d'origine si le libellé finit déjà par deux-points).
/// - decalage-droite (ratio): début de la zone de droite, en proportion de la largeur. Défaut : `30%`.
/// - largeur-droite (ratio): largeur de la zone de droite. Défaut : `40%`.
/// - rayon (length): rayon du disque du numéro. Défaut : `7.815pt`.
/// - decalage-numero (length): décalage vertical du disque. Défaut : `7.815pt`.
/// - couleur-disque (color, str): couleur du disque. Défaut : `gray!80!black`.
/// - couleur-numero (color, str): couleur du numéro. Défaut : blanc.
/// - echelle-numero (float): taille du numéro, en proportion du corps du texte. Défaut : `0.8`.
/// -> content
#let pied-de-page(
  disposition: auto,
  gauche: auto,
  centre: auto,
  droite: auto,
  numero: auto,
  style: auto,
  ..options,
) = m.pied-de-page(
  disposition: disposition,
  gauche: gauche,
  centre: centre,
  droite: droite,
  numero: numero,
  ..m._style(style),
  ..options,
)

/// \SequenceItem{forme}{description}{commentaire} : une ligne d'une progression de séquence : forme en
/// chevron contenant un libellé (« Séance 1 »), suivie d'une boîte à deux volets (description, commentaire).
///
/// En LaTeX la commande se pose dans une `tikzpicture` à des coordonnées choisies ; ici elle est un
/// bloc, qui s'empile. Les options de `[…]` (couleur de la forme) sont des clés nommées.
///
/// ```typ
/// #sequence-item([Séance 1], [Découvrir les vecteurs], [Prérequis : repère du plan])
/// ```
///
/// - forme (content, str): libellé dans le chevron.
/// - description (content, str): volet de gauche.
/// - commentaire (content, str): volet de droite, plus clair.
/// - style (str, array): style(s) nommé(s).
/// - couleur (color, str): couleur de la forme et du cadre (`myblue`). Défaut : `rgb(79, 129, 189)`.
/// - couleur-texte (color, str): couleur du libellé. Défaut : blanc.
/// - hauteur (length): hauteur de la ligne. Défaut : `3cm`.
/// - largeur-forme (length): largeur du chevron. Défaut : `3cm`.
/// - largeur-boite (length): largeur de la boîte. Défaut : `15cm`.
/// - largeur-texte (length): largeur du libellé. Défaut : `2.5cm`.
/// - pointe (length): profondeur de la pointe du chevron. Défaut : `0.7cm`.
/// - fond-description (ratio): teinte du volet de gauche (`myblue!25`). Défaut : `25%`.
/// - fond-commentaire (ratio): teinte du volet de droite (`myblue!10`). Défaut : `10%`.
/// - rayon (length): rayon des coins. Défaut : `4pt`.
/// - epaisseur (length): épaisseur du cadre. Défaut : `0.5mm`.
/// - ombre (bool): ombre portée. Défaut : `true`.
/// - retrait (length): retrait à gauche. Défaut : `0pt`.
/// -> content
#let sequence-item(forme, description, commentaire, style: auto, ..options) = m.sequence-item(
  forme,
  description,
  commentaire,
  ..m._style(style),
  ..options,
)
