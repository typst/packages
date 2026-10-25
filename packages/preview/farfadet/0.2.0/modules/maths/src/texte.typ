// texte.typ — façade du texte : mise en valeur (acc, encadrer, surligner), guillemets, outil du
// cours, lien interne, calculatrice interdite, place réservée. (Épurage 07/10/2026 : `formuleTable`
// → `encadrer(couleur: "red")` ; `bfred`, `bfblue`, `degree` supprimés.)
//
//   Un #acc[mot important], #encadrer[une formule à retenir], #surligner[un passage].
//
// Habille `moteur/texte.typ`. Sources LaTeX : bfcours-commands.sty. Tout ce qui n'est pas un nom public de
// lib.typ commence par « _ ».
//
// noms LaTeX (`guillemets` → `frquote`, `calculatrice-interdite` → `pascalc`, `reserver-espace` →
// `needspace`) et rendu réglable par `setbfmaths` (reglages.typ). `carre-couleur` (→ `coloredsquare`)
// est parti dans farfadet-didactique ; `voc` aussi.

#import "moteur/texte.typ" as m
#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, bf-xcolor, xmix, bf-couleur, taille-latex, bf-lire, bf-couleur-p
#import "reglages.typ": _M

// Les clés locales valant `auto` (« selon les réglages ») sont ignorées par le socle : on les lui passe telles quelles.

/// Dessine une boîte en ligne d'après les valeurs résolues `r` ; `cadre-noir` : le filet se mélange au noir
/// (encadrer) et non au blanc (surligner, connecteurs).
#let _boite(corps, r, cadre-noir: false) = {
  let c = bf-xcolor(r.couleur)
  let fond = if r.colback == auto { xmix(c, r.fond) } else { bf-xcolor(r.colback) }
  let cadre = if r.colframe == auto {
    xmix(c, r.filet, autre: if cadre-noir { black } else { white })
  } else { bf-xcolor(r.colframe) }
  let texte = if r.colupper == auto { xmix(c, r.at("texte", default: 75), autre: black) } else { bf-xcolor(r.colupper) }
  m.boite-en-ligne(
    corps, cadre, fond, texte: texte, gauche: r.left, droite: r.right, haut: r.top, bas: r.bottom,
    sep: r.boxsep, arc: r.arc, regle: r.boxrule,
    taille: if "fontupper" in r { taille-latex(r.fontupper) } else { auto },
  )
}

/// Résout les réglages d'un type de boîte en ligne (`encadrer`, `surligner`, un connecteur).
#let _boite-reglee(corps, type, commande, couleur, style, options, cadre-noir: false) = context {
  let r = reglages-resoudre(
    _M, pour: type, commande: commande,
    local: options.named() + (couleur: couleur, style: style),
  )
  _boite(corps, r, cadre-noir: cadre-noir)
}

// =====================================================================
// Mise en valeur
// =====================================================================

/// Met un mot en valeur : gras, dans la couleur d'accent du contexte (celle de l'environnement
/// où l'on se trouve, noir ailleurs). Les formules gardent leur graisse normale.
///
/// ```typ
/// Une fonction est *affine* si elle s'écrit #acc[$a x + b$].
/// Dans un #acc(couleur: "red")[texte rouge], ou #acc(couleur: "thm")[couleur de la palette].
/// ```
///
/// - corps (content): le texte à mettre en valeur.
/// - couleur (auto, color, str): `auto` : couleur d'accent courante ; sinon une couleur Typst ou une expression xcolor (`"thm"`, `"red!50!black"`).
/// - graisse (auto, str, int): graisse du texte (`"bold"` par défaut).
/// - formules-regulieres (auto, bool): `true` (défaut) : les formules du texte gardent leur graisse normale.
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let acc(corps, couleur: auto, graisse: auto, formules-regulieres: auto, style: auto) = context {
  let r = reglages-resoudre(
    _M, pour: "acc", commande: "acc",
    local: (couleur: couleur, graisse: graisse, formules-regulieres: formules-regulieres, style: style),
  )
  let c = if r.couleur == auto { bf-lire(bf-couleur-p) } else { bf-xcolor(r.couleur) }
  if r.formules-regulieres {
    show math.equation: set text(weight: "regular")
    text(fill: c, weight: r.graisse, corps)
  } else {
    text(fill: c, weight: r.graisse, corps)
  }
}

/// Encadre un texte ou une formule : fond très pâle, filet de la même teinte en plus foncé, texte noir.
/// Dans une formule, l'appeler sans `#` : `$ f(x) = encadrer(1/x) $` garde le style de la formule
/// (une fraction reste grande en maths affichées), comme le `\mathpalette` de LaTeX ; `#encadrer($1/x$)`
/// composerait la fraction en petit.
///
/// ```typ
/// À retenir : #encadrer[$a^2 + b^2 = c^2$]
/// #encadrer(couleur: "green", arc: 0pt)[coins droits] #encadrer(fond: 20, boxrule: 1pt)[fond plus soutenu]
/// $ f(x) = encadrer(1/x) $
/// ```
///
/// - corps (content): le contenu encadré.
/// - couleur (auto, color, str): couleur de la boîte (`"blue"` par défaut) : couleur Typst ou expression xcolor.
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): clés tcolorbox : `colback`, `colframe`, `colupper` (couleurs ; `auto` : dérivées de `couleur`), `fond` (5) et `filet` (75) : pourcentages de `couleur` ; `arc`, `boxsep`, `boxrule`, `left`, `right`, `top`, `bottom` (longueurs).
/// -> content
#let encadrer(corps, couleur: auto, style: auto, ..options) = _boite-reglee(
  corps, "encadrer", "encadrer", couleur, style, options, cadre-noir: true,
)

/// Surligne un texte ou une formule, comme un marqueur : fond clair, texte dans la teinte foncée.
///
/// ```typ
/// Le résultat est #surligner(couleur: "red")[faux] si l'on oublie le signe.
/// ```
///
/// - corps (content): le contenu surligné.
/// - couleur (auto, color, str): couleur du marqueur (`"blue"` par défaut).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): clés tcolorbox : `colback`, `colframe`, `colupper`, `fond` (10), `filet` (10), `texte` (75) : pourcentages de `couleur` ; `arc`, `boxsep`, `boxrule`, `left`, `right`, `top`, `bottom`.
/// -> content
#let surligner(corps, couleur: auto, style: auto, ..options) = _boite-reglee(
  corps, "surligner", "surligner", couleur, style, options,
)

// =====================================================================
// Guillemets, calculatrice, place réservée
// =====================================================================

/// Texte entre guillemets français, avec les espaces insécables : « comme ceci ».
///
/// ```typ
/// On dit qu'une fonction est #frquote[croissante].
/// ```
///
/// - corps (content): le texte cité.
/// - ouvrant (auto, content): guillemet ouvrant (`«`).
/// - fermant (auto, content): guillemet fermant (`»`).
/// - espace (auto, content): espace entre guillemet et texte (insécable par défaut).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let frquote(corps, ouvrant: auto, fermant: auto, espace: auto, style: auto) = context {
  let r = reglages-resoudre(
    _M, pour: "frquote", commande: "frquote",
    local: (ouvrant: ouvrant, fermant: fermant, espace: espace, style: style),
  )
  [#r.ouvrant#r.espace#corps#r.espace#r.fermant]
}

/// Mention « Calculatrice interdite », en gras.
///
/// ```typ
/// #pascalc()
/// #pascalc(libelle: "Sans calculatrice")
/// ```
///
/// - libelle (auto, content): le texte affiché.
/// - graisse (auto, str, int): graisse (`"bold"`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let pascalc(libelle: auto, graisse: auto, style: auto) = context {
  let r = reglages-resoudre(
    _M, pour: "pascalc", commande: "pascalc",
    local: (libelle: libelle, graisse: graisse, style: style),
  )
  if r.graisse == "bold" { strong(r.libelle) } else { text(weight: r.graisse, r.libelle) }
}

/// Réserve de la place : si moins de `longueur` reste sur la page, passe à la page suivante ; sinon ne
/// fait rien : quand la place suffit, aucun espace n'est ajouté ni retiré, l'écart avec l'élément suivant est
/// identique à celui d'un document sans `needspace`. Sert à ne pas laisser un titre seul en bas de page.
/// Une seule forme (le `\Needspace*` de LaTeX). À écrire au niveau de la page ; dans un `block`, un `box` ou des
/// colonnes (où un saut de page est interdit), ajouter `conteneur: true`.
///
/// ```typ
/// #needspace(6em)
/// ```
///
/// - longueur (length): hauteur à réserver.
/// - conteneur (bool): `true` dans un conteneur : bloc insécable de la hauteur demandée plutôt qu'un saut de page.
/// -> content
#let needspace(longueur, conteneur: false) = m.needspace(longueur, conteneur: conteneur)

// =====================================================================
// Outil du cours, lien interne
// =====================================================================

/// Ligne grise, en petit, qui nomme la méthode ou la propriété du cours à mobiliser : « ▷ Outil du cours : … ».
/// Elle se distingue ainsi de la rédaction attendue, composée en noir à la suite.
///
/// ```typ
/// #outilcours[Méthode « lire une probabilité dans un tableau ».]
/// #outilcours(etiquette: "Rappel")[la formule du contraire.]
/// ```
///
/// - corps (content): le texte de l'outil.
/// - etiquette (auto, content): libellé en italique (`Outil du cours`).
/// - couleur (auto, color, str): couleur de la ligne (`"gray"`).
/// - taille (auto, str, length): taille du texte : nom LaTeX (`"small"`) ou longueur.
/// - symbole (auto, content): symbole de tête (▷).
/// - italique (auto, bool): étiquette en italique.
/// - espace-sous (auto, length): espace sous la ligne (`\smallskip`, 3 pt).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let outilcours(
  corps, etiquette: auto, couleur: auto, taille: auto, symbole: auto, italique: auto, espace-sous: auto, style: auto,
) = context {
  let r = reglages-resoudre(
    _M, pour: "outilcours", commande: "outilcours",
    local: (
      etiquette: etiquette, couleur: couleur, taille: taille, symbole: symbole, italique: italique,
      espace-sous: espace-sous, style: style,
    ),
  )
  let libelle = if r.italique { emph[#r.etiquette#sym.space.nobreak:] } else [#r.etiquette#sym.space.nobreak:]
  block(below: r.espace-sous, {
    set text(size: taille-latex(r.taille), fill: bf-xcolor(r.couleur))
    [#r.symbole#sym.space.nobreak#libelle #corps]
  })
}

/// Lien interne vers une étiquette du document (le `\hyperref` de bfcours) : texte en gras, couleur des liens
/// internes (`red!50!yellow`).
///
/// ```typ
/// Voir #lien("def-aire")[la définition de l'aire].
/// #lien("def-aire", couleur: "blue")[Autre couleur]
/// #[Aire d'un rectangle.] <def-aire>
/// ```
///
/// - ancre (str, label): nom de l'étiquette visée (`"def-aire"` pour `<def-aire>`).
/// - corps (content): le texte du lien.
/// - couleur (auto, color, str): couleur du lien (`auto` : celle des liens internes).
/// - graisse (auto, str, int): graisse (`"bold"`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// -> content
#let lien(ancre, corps, couleur: auto, graisse: auto, style: auto) = context {
  let r = reglages-resoudre(
    _M, pour: "lien", commande: "lien", local: (couleur: couleur, graisse: graisse, style: style),
  )
  let c = bf-xcolor(r.couleur)
  link(if type(ancre) == str { label(ancre) } else { ancre }, text(fill: c, weight: r.graisse, corps))
}
