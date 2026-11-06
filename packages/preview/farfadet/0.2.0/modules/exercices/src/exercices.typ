// exercices.typ (farfadet-exo) — FAÇADE publique des exercices.
// Moteur : moteur/exo.typ (et skins.typ, etoiles.typ, listes.typ, reglages.typ).
// Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».

#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements
#import "moteur/exo.typ" as _m
#import "moteur/etoiles.typ" as _e
#import "moteur/listes.typ" as _l

/// Sépare la compétence des clés rdexo. Les clés `tcblower:` et `exocorrection:` n'existent plus : la
/// partie basse et la correction s'écrivent dans le corps, après les marqueurs `#tcblower` et `#exocorrection`.
#let _separer(nom, args) = {
  let cles = args.named()
  for k in ("tcblower", "exocorrection") {
    if k in cles {
      panic(nom + " : la clé « " + k + " » n'existe plus. Écrire " + (if k == "tcblower" { "la partie basse" } else { "la correction" }) + " à la suite de l'énoncé, après le marqueur #" + k + " : #" + nom + "[Titre][Énoncé #tcblower Partie basse #exocorrection Correction].")
    }
  }
  let competence = cles.remove("competence", default: auto)
  (cles, competence)
}

/// Marqueur facultatif `#tcblower` : dans le corps d'un `exo` ou `exo-eval`, ce qui le suit est la partie basse de l'exercice (zone de réponse, `crep`), affichée dans sa boîte.
///
/// ```example
/// #exo[Un calcul][Calculer $3 times 4$. #tcblower $3 times 4 = 12$.]
/// ```
///
/// À écrire sans parenthèses, une seule fois, au premier niveau du corps, avant `#exocorrection`. Hors d'un exercice, il n'affiche rien.
/// -> content
#let tcblower = _m.bf-tcblower

/// Marqueur `#exocorrection` (le `\exocorrection` de LaTeX) : dans le corps d'un `exo` ou `exo-eval`, ce qui le suit est la correction de l'exercice. Elle n'est pas affichée à cet endroit : `rdexocorrection` la rejoue plus loin.
///
/// ```example
/// #exo[Une équation][
///   Résoudre $2 x + 1 = 7$.
///   #exocorrection
///   $2 x = 6$, donc $x = 3$.
/// ]
/// #rdexocorrection(0)
/// ```
///
/// À écrire sans parenthèses, une seule fois, au premier niveau du corps (pas dans une liste ni des colonnes). Hors d'un exercice, il n'affiche rien.
/// -> content
#let exocorrection = _m.bf-exocorrection

/// Positionnels d'EXO / EXOEVAL : `[énoncé]`, `[titre][énoncé]` ou `[titre](tags)[énoncé]` (ordre LaTeX).
#let _positionnels(nom, pos) = {
  if pos.len() == 1 { (none, auto, pos.at(0)) }
  else if pos.len() == 2 { (pos.at(0), auto, pos.at(1)) }
  else if pos.len() == 3 { (pos.at(0), pos.at(1), pos.at(2)) }
  else {
    panic(nom + " : un à trois arguments positionnels attendus (titre, étiquettes, énoncé), reçu " + str(pos.len()) + ". Syntaxe : #" + nom + "[Titre][Énoncé] ou #" + nom + "[Énoncé].")
  }
}

/// Exercice de bfcours (`\begin{EXO}{titre}{tags}`) et environnement `exo` de rdexo (fusionnés) :
/// en-tête « ■ Exercice n – titre » avec étoiles de niveau et case de score, puis l'énoncé. Le titre
/// entre dans l'index des compétences (`printcompindex`) et dans le sommaire. Le corps se coupe aux marqueurs
/// `#tcblower` (ce qui suit est la partie basse, dans la boîte) et `#exocorrection` (ce qui suit est la
/// correction, qui n'est pas affichée ici : `rdexocorrection` la rejoue plus loin, avec des liens cliquables
/// dans les deux sens).
///
/// Toutes les clés de `setrdexo` s'emploient localement ; la clé locale l'emporte sur un style nommé,
/// lui-même sur le réglage du type (`setrdexo(pour: "EXO", …)`), puis sur le réglage global. Les clés de
/// couleur d'un thème (`bg-color`, `score-bg-color`…) s'emploient aussi localement, pour ce seul exercice.
///
/// ```example
/// #exo(tags: "équations", level: 2)[Une équation][
///   #itempoint(2)[Résoudre $2 x + 1 = 7$.]
///   #exocorrection
///   $2 x = 6$, donc $x = 3$.
/// ]
/// ```
///
/// - tags (str, array): étiquettes (« a, b » ou tableau) ; affichées selon `display-tags`, filtrées par `rdexofilter`.
/// - level (int, float, auto): niveau de 0 à 3 (demi-étoiles permises). Défaut : `auto` (dernier `rdifficulty`, 1).
/// - score (int, float, auto): barème. Défaut : `auto` (somme des `itempoint` de l'énoncé).
/// - exotitle (content, none): titre donné par clé (au lieu du premier argument positionnel).
/// - competence (content, str, auto): entrée de l'index des compétences. Défaut : le titre.
/// - skin (str): thème : "bouyachakka" (défaut), "default", "pooja", "rikid", "griba", "objiva", "exobac", "exobrevet", "exolombards".
/// - exo-header (str): "tcolorbox" (bandeau, défaut), "tcbox" (étiquette en ligne), "none" (titre de boîte).
/// - cadre (auto, none, function): cadre autour de CET exercice, qui l'emporte sur celui du thème et sur `setrdexo`.
/// - cadre-correction (auto, none, function): cadre du bloc de correction de CET exercice (appliqué par `rdexocorrection`).
/// - style (str, array): style(s) nommé(s) défini(s) par `setrdexo(definir: …)`.
/// - numexo (int, auto): numéro de CET exercice (les suivants continuent à partir de lui).
/// - ..args (content): titre (facultatif), puis le corps : énoncé, éventuellement `#tcblower` et la partie basse, `#exocorrection` et la correction ; trois positionnels : titre, étiquettes, corps.
/// -> content
#let exo(..args) = {
  let (cles, competence) = _separer("EXO", args)
  let (titre, tags, corps) = _positionnels("EXO", args.pos())
  let corps = environnements(corps) // begin/end dans le corps, avant le découpage aux marqueurs
  let (enonce, basse, correction) = _m.bf-couper-exo("EXO", corps)
  if tags != auto { cles.insert("tags", tags) }
  _m.bf-EXO(titre, enonce, tcblower: basse, exocorrection: correction, competence: competence, cles: cles)
}

/// Exercice d'évaluation (`\begin{EXOEVAL}{titre}{compétence}`) : EXO dont l'en-tête porte la grille
/// d'auto-évaluation MI / MF / MS / TBM ; ses étiquettes (`tags`) entrent dans l'index des compétences.
///
/// ```example
/// #exo-eval(tags: "Résoudre une équation")[Équations][
///   #itempoint(1.5)[Résoudre $2 x + 1 = 7$.]
///   #exocorrection
///   $2 x = 6$, donc $x = 3$.
/// ]
/// ```
///
/// - tags (str, array): compétence(s) évaluée(s) (étiquettes), inscrites dans `printcompindex`.
/// - level (int, float, auto): niveau (0 à 3). Défaut : `auto`.
/// - score (int, float, auto): barème. Défaut : `auto`.
/// - competence (content, str, auto): entrée de l'index. Défaut : les étiquettes.
/// - ..args (content): titre (facultatif), puis le corps : énoncé, éventuellement `#tcblower` et la partie basse, `#exocorrection` et la correction.
/// -> content
#let exo-eval(..args) = {
  let (cles, competence) = _separer("EXOEVAL", args)
  let (titre, tags, corps) = _positionnels("EXOEVAL", args.pos())
  let corps = environnements(corps)
  let (enonce, basse, correction) = _m.bf-couper-exo("EXOEVAL", corps)
  if tags != auto { cles.insert("tags", tags) }
  _m.bf-EXOEVAL(titre, enonce, tcblower: basse, exocorrection: correction, competence: competence, cles: cles)
}

/// L'unique réglage du paquet : exercices, thèmes, étoiles, boîtes de points, tableaux de compétences,
/// cartouches d'évaluation, sujets d'examen.
///
/// - Sans `pour` : réglage global des exercices (clés ci-dessous).
/// - `pour: "EXO"` ou `"EXOEVAL"` : réglage de ce seul type d'exercice.
/// - `pour: "<thème>"` (`"default"`, `"pooja"`, `"rikid"`, `"griba"`, `"objiva"`, `"bouyachakka"`, `"exobac"`,
///   `"exobrevet"`) : couleurs et cotes du thème : `bg-color`, `fg-color`,
///   `frame-color`, `star-fg-color`, `star-bg-color`, `star-line-color`, `score-fg-color`, `score-bg-color`,
///   `lower-bg-color`, `tags-bg-color`, `tags-fg-color`, `title-color`, `label-color` (objiva), `rule-color`
///   et `correction-fg-color` (exobac), `square-color` (carré devant « Exercice n » ; `auto` : couleur
///   du texte du bandeau), `arc`, `righthand-width`.
/// - `pour: "rdexostars"` : étoiles : `star-color`, `star-background`, `line-color`,
///   `line-width`, `raise`, `scale`, `show-bg`, `display-mode`, `background`, `background-app`.
/// - `pour: "itempoint"`, `"itempoint"`, `"infotcbitempoint"`, `"baremepoint"` : boîtes de points ;
///   `"competences"`, `"tableauEval"`, `"tableauProjetEval"`, `"tableauPresenteEvalSixieme"`, `"overlaychrono"`,
///   `"chrono"` : tableaux et cartouches ; `"bfexobacUline"`, `"chapitreBac"` : sujets d'examen.
/// - `pour: "exolombards"` : options de l'habillage exolombards (`pied`, `auteur`, `etablissement`,
///   `decalage`, `correction`, `etiquette`, `titre`, `bareme`, `mot-correction`).
/// - `definir: "nom"` : définit un style nommé, appelé ensuite par `style: "nom"`.
/// - `reinitialiser: true` : oublie les réglages (tous, ou ceux de `pour`) ; `"tout"` : et les styles nommés.
///
/// Actions immédiates : `numexo: n` met le compteur à n (le prochain exercice porte le numéro n + 1) ; `correction-style` range des styles de boîte de correction par numéro d'exercice (une seule fois).
///
/// ```example
/// #setrdexo(label: "Problème", display-level: false)
/// #setrdexo(pour: "EXOEVAL", score-label: ("pt", "pts"))
/// #setrdexo(pour: "pooja", score-bg-color: "teal")
/// #setrdexo(definir: "sobre", display-score: false)
/// ```
///
/// - skin (str): thème. Défaut : "bouyachakka".
/// - exo-header (str): "tcolorbox", "tcbox" ou "none". Défaut : "tcolorbox".
/// - header-skip (length): espace sous l'en-tête. Défaut : 6 pt.
/// - label (str, content): libellé. Défaut : "Exercice".
/// - display-numexo (bool): numéro affiché. Défaut : true.
/// - numexo (int): valeur du compteur (action immédiate).
/// - display-score (bool): score affiché. Défaut : true (bfcours).
/// - score (int, float, auto): barème par défaut. Défaut : auto.
/// - score-label (array): libellés (singulier, pluriel). Défaut : ("point", "points").
/// - display-level (bool): étoiles affichées. Défaut : true (bfcours).
/// - level (int, float, auto): niveau par défaut. Défaut : auto (rdifficulty).
/// - display-exotitle (bool): titre affiché. Défaut : true.
/// - exotitle-color (color, str): couleur du titre. Défaut : noir.
/// - exotitle-font (str, dictionary): police du titre. Défaut : "\sffamily\bfseries\footnotesize".
/// - display-lower (auto, bool): boîte basse : auto (si contenu), true, false. Défaut : auto.
/// - lower (dictionary): position ("bottom", "left", "right"), width, skip, box ("crep", "default"), style, raster, mirror ; raccourcis left, right, seyes-left, seyes-right.
/// - save-lower (bool): accepté, sans effet (comme dans rdexo.sty).
/// - display-tags (bool, str): true, false ou "correction" (version professeur). Défaut : "correction".
/// - tags-wrap (ratio, none): étiquettes sous le bandeau : si elles tiennent dans cette part de la largeur de la ligne, l'énoncé commence sur leur ligne, à leur gauche, et le texte se poursuit sous elles ; au-delà, elles gardent leur ligne ; `none` : toujours sur leur ligne. Défaut : 50 %.
/// - correction-as-lower (bool): la correction devient la boîte basse. Défaut : false.
/// - cadre (auto, none, function): cadre autour de l'exercice entier, `(info, contenu) => contenu`. `auto` : celui du thème (aucun pour les thèmes intégrés) ; `none` : aucun, même si le thème en a un. Priorité : clé de l'exercice > style nommé > type > global > thème > aucun. Défaut : auto.
/// - cadre-correction (auto, none, function): idem pour chaque bloc de `rdexocorrection`. Défaut : auto.
/// - breakable (bool): exercice sécable. Défaut : true.
/// - after-skip (length): espace après l'exercice. Défaut : 10 pt.
/// - sommaire (bool): EXO entre au sommaire (ajout). Défaut : true.
/// - exo (dictionary): styles par numéro (`exo <n>/.try`) : ("3": (display-score: false)).
/// - correction (dictionary): défauts de `rdexocorrection` (columns, raster, mirror, mirror-style, reset-num-start).
/// - correction-style (dictionary): styles de boîte de correction par numéro, pour le prochain `rdexocorrection` : ("1,3": (colback: "yellow!10", colframe: "orange")).
/// - emoji (bool, str): niveaux de maîtrise `mi`, `mf`, `ms`, `tbm` en émojis (true, "images") ou en texte gras (false). Défaut : true.
/// - pour (str, array, none): type réglé (voir plus haut) ou none (global).
/// - definir (str, none): nom du style défini.
/// - reinitialiser (bool, str): true, false ou "tout".
/// -> content
#let setrdexo(pour: none, reinitialiser: false, definir: none, ..cles) = _m.bf-setrdexo(pour: pour, reinitialiser: reinitialiser, definir: definir, ..cles)

/// Déclare un thème (\rdexoSkin{nom}{en-tête tcbox}{en-tête tcolorbox}). Les en-têtes sont des
/// fonctions qui reçoivent un dictionnaire `info` (n, label, titre, score, niveau, tags, c (couleurs)…)
/// et renvoient l'en-tête ; un en-tête omis reprend celui du thème `default`. Les couleurs du thème se
/// règlent ensuite par `setrdexo(pour: "<nom>", …)`.
///
/// ```example
/// #rdexo-skin("simple", tcolorbox: info => block(stroke: (bottom: 1pt), [*#info.label #info.n* -- #info.titre]))
/// #exo(skin: "simple", exotitle: [Essai])[Énoncé.]
/// ```
///
/// - nom (str): nom du thème.
/// - tcbox (function, none): en-tête en ligne (`exo-header: "tcbox"`).
/// - tcolorbox (function, none): en-tête en bandeau (`exo-header: "tcolorbox"` ou `"none"`).
/// - correction (function, none): en-tête de correction (reçoit n, label, titre, cible, c).
/// - cadre (function, none): cadre facultatif autour de l'exercice entier : `(info, contenu) => contenu`, où `contenu` est l'en-tête suivi de l'énoncé (et de la boîte basse). `info` reçoit en plus `couleur` (cadre du thème), `fond`, `breakable` et `correction` (false). Défaut : aucun cadre.
/// - cadre-correction (function, none): même forme, pour chaque bloc de `rdexocorrection` (`info.correction` vaut true, `breakable` vaut true). Défaut : aucun cadre.
/// - couleurs (dictionary): couleurs du thème (clés de `setrdexo(pour: "<thème>")`).
/// -> content
#let rdexo-skin(nom, tcbox: none, tcolorbox: none, correction: none, cadre: none, cadre-correction: none, couleurs: (:)) = _m.bf-rdexoSkin(nom, tcbox: tcbox, tcolorbox: tcolorbox, correction: correction, cadre: cadre, cadre-correction: cadre-correction, couleurs: couleurs)

/// Étoiles de niveau (\rdexostars[options]{niveau}{total}) ; un niveau décimal remplit une étoile en partie.
/// Les défauts se règlent par `setrdexo(pour: "rdexostars", …)`.
///
/// ```example
/// #rdexostars(1.5, 3) #rdexostars(2, 3, star-color: red, scale: 1.5)
/// #rdexostars(2, 3, display-mode: "vertical")
/// ```
///
/// - niveau (int, float): nombre d'étoiles remplies.
/// - total (int): nombre d'étoiles.
/// - star-color (color, str): étoiles pleines. Défaut : "yellow".
/// - star-background (color, str): étoiles vides. Défaut : "gray".
/// - line-color (color, str): contour. Défaut : noir.
/// - line-width (length): épaisseur du contour (0 : pas de contour). Défaut : 0,6 pt.
/// - raise (length): décalage vertical. Défaut : 0 pt.
/// - scale (int, float): échelle. Défaut : 1.
/// - show-bg (bool): boîte de fond. Défaut : false.
/// - display-mode (str): "horizontal" ou "vertical". Défaut : "horizontal".
/// - background, background-app (dictionary): boîte de fond (colback, colframe, boxrule, arc, boxsep, opacityback).
/// -> content
#let rdexostars(niveau, total, ..cles) = _e.bf-rdexostars(niveau, total, ..cles)

/// Rejoue les corrections (\rdexocorrection[options]{liste}) sous un en-tête de solution, avec des
/// liens cliquables vers les énoncés. Le style d'une boîte de correction se règle par
/// `setrdexo(correction-style: …)`.
///
/// ```example
/// #rdexocorrection(0)
/// #rdexocorrection("1,3", columns: 2)
/// ```
///
/// - liste (int, str, array): 0 (depuis le dernier appel), "1,3", "2,...,5", (2, 4), ou "tous" (ajout).
/// - columns (int): nombre de colonnes. Défaut : 1.
/// - raster (dictionary): raster-column-skip, raster-row-skip, raster-before-skip.
/// - mirror (bool): corrections tournées de 180° (partage écran/papier). Défaut : false.
/// - mirror-style (dictionary): habillage du bloc tourné (colback, colframe, boxrule…).
/// - reset-num-start (bool): le prochain `rdexocorrection(0)` repart d'ici. Défaut : true.
/// -> content
#let rdexocorrection(liste, ..cles) = _m.bf-rdexocorrection(liste, ..cles)

/// N'affiche que les exercices dont les étiquettes satisfont l'expression (\rdexofilter) : opérateurs
/// `!` (non), `&` (et), `|` (ou), parenthèses ; les exercices écartés ne sont ni numérotés ni comptés.
///
/// ```example
/// #rdexofilter("calcul & !difficile")
/// ```
///
/// - expr (str): expression booléenne d'étiquettes.
/// - match-case (bool): respecter la casse. Défaut : false.
/// -> content
#let rdexofilter(expr, match-case: false) = _m.bf-rdexofilter(expr, match-case: match-case)

/// Supprime le filtre d'étiquettes (\rdexoresetfilter).
///
/// ```example
/// #rdexoresetfilter()
/// ```
/// -> content
#let rdexoresetfilter() = _m.bf-rdexoresetfilter()

/// Liste horizontale (\rdexohlist[options]{liste}).
///
/// ```example
/// #rdexohlist("a, b, c")
/// #rdexohlist("x; y", list-sep: ";", sep: [ -- ], macro: t => strong(t))
/// #rdexohlist("a, b, c", avec-rang: true, macro: (t, i, n) => [#t (#i/#n)])
/// ```
///
/// - liste (str, array): éléments.
/// - list-sep (str): séparateur d'entrée. Défaut : ",".
/// - sep (content, auto): séparateur affiché. Défaut : « ; » entouré de 0,5 em.
/// - before, after (content, none): avant et après la liste.
/// - macro (function, none): mise en forme de chaque élément.
/// - avec-rang (bool): `macro` reçoit aussi le rang et le nombre d'éléments (\hlistindex, \hlistcount de rdexo). Défaut : false.
/// -> content
#let rdexohlist(liste, ..cles) = _l.bf-rdexohlist(liste, ..cles)

/// Liste en matrice qui choisit son nombre de colonnes selon la largeur (\rdexotikzlist).
///
/// ```example
/// #rdexotikzlist("alpha, beta, gamma, delta, epsilon", max-cols: 2)
/// ```
///
/// - liste (str, array): éléments.
/// - col-sep (length): écart entre colonnes. Défaut : 2 em.
/// - row-sep (length): écart entre lignes. Défaut : 0,5 em (1 ex).
/// - max-cols (int): nombre maximal de colonnes (0 : sans limite). Défaut : 0.
/// - macro (function, none): mise en forme de chaque élément.
/// -> content
#let rdexotikzlist(liste, ..cles) = _l.bf-rdexotikzlist(liste, ..cles)

/// Nombre d'éléments d'une liste (\rdexocountlist).
///
/// ```example
/// #rdexocountlist("a, b, c")
/// ```
///
/// - liste (str, array): liste.
/// -> int
#let rdexocountlist(liste, sep: ",") = _l.bf-rdexocountlist(liste, sep: sep)

/// Numéro de l'exercice en cours (\thenumexo[*][avant][après]) ; `etoile` : seulement si `display-numexo`.
///
/// ```example
/// #exo(exotitle: [Essai])[Je suis l'exercice #thenumexo().]
/// ```
///
/// - etoile (bool): forme étoilée.
/// - avant, apres (content): entourage (forme étoilée).
/// -> content
#let thenumexo(etoile: false, avant: [], apres: []) = _m.bf-thenumexo(etoile: etoile, avant: avant, apres: apres)

/// Valeur du compteur d'exercices (\rdexonumexo = `\value{rdexo@numexo}`) ; `f` reçoit l'entier, pour calculer avec.
///
/// ```example
/// #exo(exotitle: [Essai])[Le suivant portera le numéro #rdexonumexo(f: n => n + 1).]
/// ```
///
/// - f (function, none): fonction appliquée à l'entier. Défaut : none (affiche le numéro).
/// -> content
#let rdexonumexo(f: none) = _m.bf-rdexonumexo(f: f)

/// Score de l'exercice en cours (\thescore[*][avant][après]), à la française.
///
/// ```example
/// #exo(score: 2.5)[Barème : #thescore().]
/// ```
/// -> content
#let thescore(etoile: false, avant: [], apres: []) = _m.bf-thescore(etoile: etoile, avant: avant, apres: apres)

/// Score avec son libellé (\theScore[*][avant][après]) : « 2,5 points ».
///
/// ```example
/// #exo(score: 1)[Barème : #thescore-libelle().]
/// ```
/// -> content
#let thescore-libelle(etoile: false, avant: [], apres: []) = _m.bf-theScore(etoile: etoile, avant: avant, apres: apres)

/// Valeur brute du score de l'exercice en cours (\rdexoscore).
///
/// ```example
/// #exo(score: 4)[Valeur brute : #rdexoscore().]
/// ```
/// -> content
#let rdexoscore() = _m.bf-rdexoscore()

/// Niveau (nombre d'étoiles) de l'exercice en cours (\thelevel).
///
/// ```example
/// #exo(level: 2)[Niveau : #thelevel().]
/// ```
/// -> content
#let thelevel() = _m.bf-thelevel()

/// Titre de l'exercice en cours (\theexotitle[*][avant][après]).
///
/// ```example
/// #exo(exotitle: [Pythagore])[Rappel du titre : #theexotitle().]
/// ```
/// -> content
#let theexotitle(etoile: false, avant: [], apres: []) = _m.bf-theexotitle(etoile: etoile, avant: avant, apres: apres)

/// Titre dans sa police et sa couleur (\theExotitle[*][avant][après]).
///
/// ```example
/// #exo(exotitle: [Pythagore])[Titre mis en forme : #theexotitle-style().]
/// ```
/// -> content
#let theexotitle-style(etoile: false, avant: [], apres: []) = _m.bf-theExotitle(etoile: etoile, avant: avant, apres: apres)

/// Applique au texte la police des titres d'exercice (\rdexotitlefont) : celle de l'exercice en cours,
/// sinon celle du réglage `exotitle-font`.
///
/// ```example
/// #rdexotitlefont[Texte à la police des titres]
/// ```
/// -> content
#let rdexotitlefont(corps) = _m.bf-rdexotitlefont(corps)

/// Étiquettes de l'exercice en cours, au style du thème (\thetags[*][max cols]).
///
/// ```example
/// #exo(tags: "calcul, fractions")[Étiquettes : #thetags()]
/// ```
///
/// - etoile (bool): seulement si `display-tags` les montre.
/// - max-cols (int): colonnes au plus (0 : autant que possible).
/// -> content
#let thetags(etoile: false, max-cols: 0) = _m.bf-thetags-courant(etoile: etoile, max-cols: max-cols)

/// Libellé des exercices (\thelabel) : « Exercice ».
///
/// ```example
/// #thelabel()
/// ```
/// -> content
#let thelabel() = _m.bf-thelabel()

/// Étiquettes de l'exercice en cours, séparées par des virgules (\rdexotags).
///
/// ```example
/// #exo(tags: "calcul, fractions")[#rdexotags()]
/// ```
/// -> content
#let rdexotags() = _m.bf-rdexotags()

/// `oui` si le numéro de l'exercice en cours est affiché, `non` sinon (\TFNumexo{oui}{non}).
///
/// ```example
/// #exo[#tf-numexo[Numéro affiché][Numéro masqué]]
/// ```
/// -> content
#let tf-numexo(oui, non) = _m.bf-TFNumexo(oui, non)

/// `oui` si le score de l'exercice en cours est affiché, `non` sinon (\TFScore{oui}{non}).
///
/// ```example
/// #exo(score: 2)[#tf-score[Score affiché][Score masqué]]
/// ```
/// -> content
#let tf-score(oui, non) = _m.bf-TFScore(oui, non)

/// `oui` si le niveau de l'exercice en cours est affiché, `non` sinon (\TFLevel{oui}{non}).
///
/// ```example
/// #exo(level: 2)[#tf-level[Étoiles affichées][Étoiles masquées]]
/// ```
/// -> content
#let tf-level(oui, non) = _m.bf-TFLevel(oui, non)

/// `oui` si le titre de l'exercice en cours est affiché, `non` sinon (\TFTitle{oui}{non}).
///
/// ```example
/// #exo(exotitle: [Essai])[#tf-title[Titre affiché][Titre masqué]]
/// ```
/// -> content
#let tf-title(oui, non) = _m.bf-TFTitle(oui, non)

/// `oui` si les étiquettes de l'exercice en cours sont affichées (`display-tags`), `non` sinon (\TFTags{oui}{non}).
///
/// ```example
/// #exo(tags: "calcul", display-tags: true)[#tf-tags[Étiquettes affichées][Étiquettes masquées]]
/// ```
/// -> content
#let tf-tags(oui, non) = _m.bf-TFTags(oui, non)

/// Texte cliquable vers la solution de l'exercice n (\rdexoEnonceLabel{n}{texte}).
///
/// ```example
/// #rdexo-enonce-label(1)[voir la solution de l'exercice 1]
/// ```
/// -> content
#let rdexo-enonce-label(n, corps) = _m.bf-rdexoEnonceLabel(n, corps)

/// Texte cliquable vers l'énoncé de l'exercice n (\rdexoSolutionLabel{n}{texte}).
///
/// ```example
/// #rdexo-solution-label(1)[retour à l'énoncé 1]
/// ```
/// -> content
#let rdexo-solution-label(n, corps) = _m.bf-rdexoSolutionLabel(n, corps)

/// Niveau par défaut des exercices suivants (\def\rdifficulty{n}) ; équivaut à `setrdexo(level: n)`.
///
/// ```example
/// #rdifficulty(2)
/// ```
///
/// - n (int, float): niveau de 0 à 3.
/// -> content
#let rdifficulty(n) = _m.rdifficulty(n)

/// Modulo (\rdexoMod{a}{b}) : `a - b ⌊a / b⌋`.
///
/// ```example
/// #rdexo-mod(17, 5) et #rdexo-mod(-3, 5)
/// ```
///
/// - a, b (int, float): dividende et diviseur.
/// -> int, float
#let rdexo-mod(a, b) = _m.bf-rdexoMod(a, b)

/// Inclut un exercice rangé dans un fichier (\rdexoinclude[*][options]{fichier}). Le fichier est lu par
/// le document (`include "fichier.typ"`) : un paquet Typst ne peut pas lire les fichiers de l'utilisateur.
///
/// ```example
/// #rdexoinclude(exotitle: [Inclus])[Contenu lu dans un fichier.]
/// ```
///
/// - contenu (content): contenu du fichier (`include "…"`).
/// - etoile (bool): le fichier contient déjà ses exercices, qui reçoivent les options. Défaut : false.
/// -> content
#let rdexoinclude(contenu, etoile: false, ..cles) = _m.bf-rdexoinclude(environnements(contenu), etoile: etoile, ..cles)
