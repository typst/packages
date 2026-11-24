// sujets.typ (farfadet-exo) — FAÇADE publique des habillages de sujets : bfcours-exobac.sty (bac, brevet)
// et bfcours-exolombards-skin.sty. Moteur : moteur/exobac.typ, moteur/exolombards.typ, moteur/skins.typ.

#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements
#import "moteur/exobac.typ" as _b
#import "moteur/exolombards.typ" as _l
#import "moteur/skins.typ" as _s

// =====================================================================
// bfcours-exobac
// =====================================================================

/// Sujet de baccalauréat (\chapitreBac[clés]) : police sans empattement, pied de page officiel
/// (code du sujet, « Page : n/N » du sujet seul), skin « exobac » et page de garde. En Typst c'est un
/// modèle : `#show: chapitreBac.with(…)` (en LaTeX, une commande de préambule).
///
/// ```example
/// #show: chapitre-bac.with(session: 2026, code: "26-MATJ1ME1", garde: false)
/// #exo(score: 5)[Suites][Énoncé de l'exercice.]
/// ```
///
/// - style (str): "bac" (défaut) ou "brevet".
/// - examen, epreuve, matiere, serie, duree (content): textes de la page de garde ; none = texte officiel du style.
/// - session (int, str, auto): année. Défaut : auto (année en cours).
/// - coefficient (int, content), code (str, content): coefficient ; code du sujet (pied de page gauche).
/// - pages (int, auto): nombre de pages annoncé. Défaut : auto (pages du sujet, sans le corrigé).
/// - calculatrice, annonce, composition, qualite, infos (content): paragraphes de la page de garde.
/// - bareme (array, content): barème du DNB : ((intitulé, points), …).
/// - famille (str, array, none): police du document. Défaut : TeX Gyre Heros (substitut d'Arial).
/// - garde, sans-serif, mise-en-page, skin (bool): page de garde, police, retraits nuls, skin. Défaut : true.
/// -> content
#let chapitre-bac(..cles, doc) = _b.bf-chapitreBac(..cles, environnements(doc))

/// Sujet du DNB (\chapitreBrevet[clés] = \chapitreBac[style=brevet, …]).
///
/// ```example
/// #show: chapitre-brevet.with(session: 2026, code: "26GENMATMEAG1", garde: false)
/// #exo(score: 2.5)[Statistiques][Énoncé.]
/// ```
/// -> content
#let chapitre-brevet(..cles, doc) = _b.bf-chapitreBrevet(..cles, environnements(doc))

/// Active le skin « exobac » (\styleExoBac[clés rdexo]) : « Exercice n » souligné, « (5 points) » en gras.
///
/// ```example
/// #style-exo-bac()
/// #exo(score: 5)[Probabilités][Énoncé.]
/// ```
/// -> content
#let style-exo-bac(..cles) = _b.bf-styleExoBac(..cles)

/// Active le skin « exobrevet » (\styleExoBrevet[clés rdexo]) : « Exercice n : titre (X points) » en gras.
///
/// ```example
/// #style-exo-brevet()
/// #exo(score: 2.5)[Géométrie][Énoncé.]
/// ```
/// -> content
#let style-exo-brevet(..cles) = _b.bf-styleExoBrevet(..cles)

/// Partie « Questions » (\styleQuestionsBac[*][clés]) : items « Question n » sans barème ni titre,
/// numérotés à partir de 1 (`etoile: true` : la numérotation continue).
///
/// ```example
/// #style-exo-bac()
/// #style-questions-bac()
/// #exo[Calculer $2^10$.]
/// ```
/// -> content
#let style-questions-bac(etoile: false, ..cles) = _b.bf-styleQuestionsBac(etoile: etoile, ..cles)

/// Partie « Exercices » (\styleExercicesBac[*][clés]) : « Exercice n (X points) », titre affiché.
///
/// ```example
/// #style-exercices-bac()
/// ```
/// -> content
#let style-exercices-bac(etoile: false, ..cles) = _b.bf-styleExercicesBac(etoile: etoile, ..cles)

/// Le prochain exercice portera le numéro n + 1 (\numeroterBac[n]).
///
/// ```example
/// #numeroter-bac(n: 3)
/// ```
///
/// - n (int): décalage. Défaut : 0.
/// -> content
#let numeroter-bac(n: 0) = _b.bf-numeroterBac(n: n)

/// Titre de partie centré et gras (\partieBac[*]{titre}) ; sans étoile, entrée de sommaire.
///
/// ```example
/// #partie-bac[PREMIÈRE PARTIE : AUTOMATISMES]
/// ```
/// -> content
#let partie-bac(titre, etoile: false) = _b.bf-partieBac(titre, etoile: etoile)

/// Cadre de consignes en gras italique centré (\consigneBac[*]{texte}) ; `etoile` : gras au fil du texte.
///
/// ```example
/// #consigne-bac[Pour chaque question, une seule réponse est exacte.]
/// ```
/// -> content
#let consigne-bac(texte, etoile: false) = _b.bf-consigneBac(texte, etoile: etoile)

/// Petit cadre pleine largeur (\encadreBac[titre]{contenu}).
///
/// ```example
/// #encadre-bac(titre: [Aide au calcul.])[$2^10 = 1024$]
/// ```
/// -> content
#let encadre-bac(corps, titre: none) = _b.bf-encadreBac(environnements(corps), titre: titre)

/// Même cadre, à la largeur du contenu (\encadreBacEtroit[titre]{contenu}).
///
/// ```example
/// #encadre-bac-etroit(titre: [Rappel :])[$e^0 = 1$]
/// ```
/// -> content
#let encadre-bac-etroit(corps, titre: none) = _b.bf-encadreBacEtroit(environnements(corps), titre: titre)

/// Clôt le sujet et ouvre le corrigé, à pagination séparée (\corrigeBac[*][titre=CORRIGÉ]) ;
/// rejoue toutes les corrections, sauf avec `etoile: true`.
///
/// ```example
/// #corrige-bac()
/// ```
/// -> content
#let corrige-bac(titre: [CORRIGÉ], etoile: false) = _b.bf-corrigeBac(titre: titre, etoile: etoile)

/// Souligne exactement la largeur du texte (\bfexobacUline{texte}).
///
/// ```example
/// #bfexobac-uline[*Exercice 1*] #bfexobac-uline(depth: 3pt, width: 1pt)[*épais*]
/// ```
///
/// - depth (length): profondeur du filet sous la ligne de base. Défaut : 2,4 pt.
/// - width (length): épaisseur du filet. Défaut : 0,5 pt.
/// -> content
#let bfexobac-uline(corps, ..cles) = _s.bf-bfexobacUline(corps, ..cles)

// =====================================================================
// bfcours-exolombards-skin
// =====================================================================

/// Charge l'habillage « exolombards » (\usepackage[options]{bfcours-exolombards-skin}, ajout) :
/// règle les options, active le skin (`auto`) et pose le pied de page d'origine (`pied`). Les options se
/// règlent aussi, en cours de document, par `setrdexo(pour: "exolombards", …)` (`decalage`, `correction`,
/// `etiquette`, `titre`, `bareme`, `mot-correction`).
///
/// ```example
/// #show: exolombards.with(pied: true, auteur: [M. Dupont])
/// #exo(score: 5)[Fonctions][L'énoncé démarre sur la ligne de l'étiquette.]
/// ```
///
/// - auto (bool): active le skin. Défaut : true.
/// - pied (bool): pied « auteur | page | établissement ». Défaut : false.
/// - auteur, etablissement (content): textes du pied.
/// - decalage (length): débordement de l'étiquette dans la marge. Défaut : −0,25 cm.
/// - correction (str): "auto", "suite" ou "separee".
/// -> content
#let exolombards(..cles, doc) = _l.bf-exolombards(..cles, environnements(doc))

/// Active le skin « exolombards » (\styleExoLombards[clés rdexo]) : « [Exercice n] » encadré en ligne.
///
/// ```example
/// #style-exo-lombards()
/// #exo(score: 3)[Suites][Énoncé sur la même ligne.]
/// ```
/// -> content
#let style-exo-lombards(..cles) = _l.bf-styleExoLombards(..cles)

/// Change le mode des corrections (\correctionsLombards{auto|suite|separee}).
///
/// ```example
/// #corrections-lombards("separee")
/// ```
/// -> content
#let corrections-lombards(mode) = _l.bf-correctionsLombards(mode)

/// Corrigé n à la manière du document de correction d'origine (\corrigeLombards[réf.]{n}),
/// ou « Pas de corrigé disponible pour cet exercice. ».
///
/// ```example
/// #corrige-lombards(1, reference: "PO020")
/// ```
/// -> content
#let corrige-lombards(n, reference: none) = _l.bf-corrigeLombards(n, reference: reference)

/// Étiquette encadrée en gras (\exolombardsEtiquette{texte}).
///
/// ```example
/// #exolombards-etiquette[Exercice 1]
/// ```
/// -> content
#let exolombards-etiquette(texte) = _l.bf-exolombardsEtiquette(texte)

/// Titre discret en italique (\exolombardsTitre{titre}).
///
/// ```example
/// #exolombards-titre[Suites géométriques]
/// ```
/// -> content
#let exolombards-titre(texte) = _l.bf-exolombardsTitre(texte)

/// Barème entre parenthèses (\exolombardsBareme{points}).
///
/// ```example
/// #exolombards-bareme[5 points]
/// ```
/// -> content
#let exolombards-bareme(texte) = _l.bf-exolombardsBareme(texte)

/// Mot placé devant une correction (\exolombardsMotCorrection) : « Correction : ».
///
/// ```example
/// #exolombards-mot-correction()
/// ```
/// -> content
#let exolombards-mot-correction() = _l.bf-exolombardsMotCorrection()
