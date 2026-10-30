// style-rd.typ (farfadet-didactique) — le style « rd » des environnements didactiques.
//
// `setbfenvironments(style: "rd")` (ou `definition(style: "rd")`, ou la clé `rendu: "rd"`) fait rendre
// chaque environnement par la boîte de `rdboites` qui lui correspond (paquet `rdboites`, module `rd`),
// à la place du rendu de bfcours (style « bf », le défaut). Sans autre réglage, le style « rd » garde les
// couleurs et les cotes de `rdboites` (exception de la convention 2).
//
// Clés de bfcours traduites. Les clés de personnalisation RÉGLÉES par l'utilisateur (sur l'appel, par
// `setbfenvironments` global ou par type, ou par un style nommé) sont traduites vers les clés de la boîte :
//   - `couleur` teinte la boîte : cadre et éléments d'accent (bande de titre, ruban, dégradé…), avec des
//     dérivés pâles pour le fond quand la boîte en a un (table `_teintes`) ;
//   - `colback`, `colframe`, `colbacktitle`, `coltitle`, `arc`, `boxrule`, `left`, `right`, `top`,
//     `bottom`, `boxsep`, `width` passent sous le même nom ; `fonttitle` devient `fonttitle-size` ;
//     seules les clés que la boîte connaît (`cles-rd(pour: …)`) sont transmises.
// Les défauts du catalogue de bfcours ne sont JAMAIS traduits (registre « ombre » `_R-explicite` de
// reglages.typ) : le style « rd » par défaut garde exactement son rendu. Priorité : clé `rd:` > clés de
// bfcours réglées (une clé explicite comme `colframe` l'emporte sur la teinte tirée de `couleur`) >
// défauts de `rdboites`. On peut aussi régler une boîte par `setrdboites(pour: "ltitlebox", …)`.
//
// Table de correspondance (confirmée par comparaison visuelle, voir docs/guide.typ) :
//   Theoreme → rd.cours · Definition → rd.ltitlebox · Propriete → rd.zone · Demonstration → rd.mydoc ·
//   Methode → rd.methode · Activite → rd.tache · Vocabulaire → rd.etiquette · Solution → rd.corrdembox ·
//   Exemple → rd.exemple · ContreExemple → rd.exem · Remarque → rd.coinpli · Notation → rd.encadre ·
//   Aide → rd.helpblock · Histoire → rd.parchemin · bfEnv → rd.designbox · cracked → rd.tornpage ·
//   boite, bfbox → rd.mydoc (rd.encadre sans titre) · boiteFigure → rd.figbox.
// None n'a pas de boîte `rdboites` : il garde le rendu de bfcours.
//
// Ce que le rendu `rdboites` ne connaît pas est absorbé ici : une banderole `rdboites` n'affiche pas le nom
// du type, le titre composé est donc « Définition 2.3 — Vecteur » ; la numérotation, l'étiquette et
// l'entrée de sommaire restent celles de bfcours (`_habiller` et `_rendre` de construction.typ) ;
// `breakable`, `craie`, `variant`, `drop-shadow`… (propres au rendu bfcours) sont sans effet.

#import "../../socle/lib.typ": interne as _socle
#import _socle: bf-resoudre-couleur, bf-vide, taille-latex, xmix
// rdboites chargé au premier usage du style rd
#let cles-rd(..a) = { import "../../rd-boites/lib.typ": cles-rd as _f; _f(..a) }
#let _rd() = { import "../../rd-boites/lib.typ": rd; rd }

/// « Nom », ou « Nom 2.3 » quand l'environnement est numéroté.
#let _nom-num(extra, numero) = [#extra.nom#if numero != none [ #numero]]

/// Titre composé d'une boîte à titre unique : « Nom 2.3 — Titre » (ou « Nom 2.3 (Titre) » avec
/// `forme: "parentheses"`, pour les boîtes qui ajoutent elles-mêmes un « : »).
#let _titre(extra, numero, titre, forme: "tiret") = {
  let t = _nom-num(extra, numero)
  if bf-vide(titre) { t } else if forme == "parentheses" { [#t (#titre)] } else { [#t — #titre] }
}

/// Titre éventuel mis en gras en tête du corps, pour les boîtes `rdboites` sans titre.
#let _avec-titre(titre, corps) = if bf-vide(titre) { corps } else { [#strong(titre)#parbreak()#corps] }

// =====================================================================
// Traduction des clés de bfcours réglées
// =====================================================================

/// Teinte tirée de la clé `couleur`, boîte par boîte : clés de la boîte à teinter (cadre et accents),
/// fonds pâles dérivés pour les boîtes qui ont un fond gris.
#let _teintes = (
  cours: c => (colframe: c, colframe-fin: xmix(c, 45), colback: xmix(c, 8)),
  ltitlebox: c => (colframe: c, colbacktitle: c, colback: xmix(c, 12)),
  zone: c => (colframe: c),
  mydoc: c => (colframe: c, colback: xmix(c, 8)),
  methode: c => (colframe: c),
  tache: c => (ruban: c, colframe: c, colback: xmix(c, 10)),
  etiquette: c => (colframe: c, colback: xmix(c, 8)),
  corrdembox: c => (colframe: c),
  exemple: c => (colframe: c),
  exem: c => (colframe: c, colback: xmix(c, 8)),
  coinpli: c => (colframe: c, colback: xmix(c, 8)),
  encadre: c => (colframe: c, colback: xmix(c, 8)),
  helpblock: c => (colframe: c),
  parchemin: c => (colframe: xmix(c, 70, autre: black)),
  tornpage: c => (colframe: xmix(c, 70, autre: black), colback: xmix(c, 10)),
  designbox: c => (color: c),
  figbox: c => (:),
)

/// Clés de bfcours traduites sous le même nom (si la boîte les connaît).
#let _directes = ("colback", "colframe", "colbacktitle", "coltitle", "arc", "boxrule", "left", "right", "top", "bottom", "boxsep", "width")

/// Renommages propres à une boîte : clé de bfcours → clé de la boîte.
#let _alias = (tache: (colbacktitle: "ruban"))

/// Clés de la boîte `boite` tirées des clés de bfcours RÉGLÉES (`x` : résolution du registre ombre,
/// `auto` = non réglée).
#let _traduites(boite, x) = {
  let connues = cles-rd(pour: boite).keys()
  let res = (:)
  let couleur = x.at("couleur", default: auto)
  if couleur != auto { res += _teintes.at(boite, default: c => (colframe: c))(bf-resoudre-couleur(couleur)) }
  let alias = _alias.at(boite, default: (:))
  for k in _directes {
    let v = x.at(k, default: auto)
    if v == auto { continue }
    if k.starts-with("col") { v = bf-resoudre-couleur(v) }
    res.insert(alias.at(k, default: k), v)
  }
  let ft = x.at("fonttitle", default: auto)
  if ft != auto { res.insert("fonttitle-size", if type(ft) == str { taille-latex(ft) } else { ft }) }
  // `tache` ne dessine pas son cadre (boxrule 0) : un cadre demandé reçoit un filet visible
  if boite == "tache" and "colframe" in x and x.colframe != auto and x.at("boxrule", default: auto) == auto {
    res.insert("boxrule", 0.8pt)
  }
  res.pairs().filter(((k, v)) => k in connues).to-dict()
}

/// Clés passées à la boîte `boite` : espaces demandés, clés propres au type, clés de bfcours réglées
/// (traduites), puis clés `rd:` de l'utilisateur (elles l'emportent).
#let _cles(r, extra, boite, propres: (:)) = {
  let espaces = (:)
  if r.before-skip != auto { espaces.insert("before-skip", r.before-skip) }
  if r.after-skip != auto { espaces.insert("after-skip", r.after-skip) }
  espaces + propres + _traduites(boite, extra.explicites) + r.rd
}

/// Un constructeur par type : (r, numero, titre, corps, extra) → contenu. À appeler dans un `context`.
/// `extra.nom` est le libellé du type (« Définition »), ou le titre pour `bf-env` et `cracked` ;
/// `extra.explicites` : les clés de bfcours réglées par l'utilisateur (`auto` sinon).
#let _construire-rd = (
  Theoreme: (r, numero, titre, corps, extra) => _rd().cours(
    _titre(extra, numero, titre, forme: "parentheses"),
    corps,
    .._cles(r, extra, "cours"),
  ),
  Definition: (r, numero, titre, corps, extra) => _rd().ltitlebox(
    _nom-num(extra, numero),
    _avec-titre(titre, corps),
    .._cles(r, extra, "ltitlebox"),
  ),
  Propriete: (r, numero, titre, corps, extra) => _rd().zone(_titre(extra, numero, titre), corps, .._cles(r, extra, "zone")),
  Demonstration: (r, numero, titre, corps, extra) => _rd().mydoc(_titre(extra, numero, titre), corps, .._cles(r, extra, "mydoc")),
  Methode: (r, numero, titre, corps, extra) => _rd().methode(
    corps,
    .._cles(r, extra, "methode", propres: if bf-vide(titre) and numero == none { (:) } else { (title: _titre(extra, numero, titre)) }),
  ),
  Activite: (r, numero, titre, corps, extra) => _rd().tache(
    _nom-num(extra, numero),
    if bf-vide(titre) [] else { titre },
    corps,
    .._cles(r, extra, "tache"),
  ),
  Vocabulaire: (r, numero, titre, corps, extra) => _rd().etiquette(
    _titre(extra, numero, titre),
    corps,
    .._cles(r, extra, "etiquette", propres: (width: 100%)),
  ),
  Solution: (r, numero, titre, corps, extra) => _rd().corrdembox(
    _titre(extra, numero, titre),
    corps,
    .._cles(r, extra, "corrdembox", propres: (visible: true)),
  ),
  Exemple: (r, numero, titre, corps, extra) => _rd().exemple(
    corps,
    .._cles(r, extra, "exemple", propres: if bf-vide(titre) and numero == none { (:) } else { (title: _titre(extra, numero, titre)) }),
  ),
  ContreExemple: (r, numero, titre, corps, extra) => _rd().exem(
    corps,
    .._cles(r, extra, "exem", propres: (title: _titre(extra, numero, titre))),
  ),
  Remarque: (r, numero, titre, corps, extra) => _rd().coinpli(_avec-titre(titre, corps), .._cles(r, extra, "coinpli")),
  Notation: (r, numero, titre, corps, extra) => _rd().encadre(
    [#strong(_titre(extra, numero, titre))#parbreak()#corps],
    .._cles(r, extra, "encadre"),
  ),
  Aide: (r, numero, titre, corps, extra) => if bf-vide(titre) { _rd().helpblock(corps, .._cles(r, extra, "helpblock")) } else {
    _rd().helpblock(titre, corps, .._cles(r, extra, "helpblock"))
  },
  Histoire: (r, numero, titre, corps, extra) => _rd().parchemin(
    [#strong(_titre(extra, numero, titre))#if not bf-vide(extra.auteur) [ #parbreak()#text(style: "italic", extra.auteur)]#parbreak()#corps],
    .._cles(r, extra, "parchemin"),
  ),
  bfEnv: (r, numero, titre, corps, extra) => _rd().designbox(
    _nom-num(extra, numero),
    corps,
    .._cles(r, extra, "designbox", propres: if bf-vide(extra.sous-titre) { (:) } else { ("sous-texte": extra.sous-titre) }),
  ),
  cracked: (r, numero, titre, corps, extra) => _rd().tornpage(
    [#strong(_nom-num(extra, numero))#if not bf-vide(extra.sous-titre) [ (#extra.sous-titre)]#parbreak()#corps],
    .._cles(r, extra, "tornpage"),
  ),
  boite: (r, numero, titre, corps, extra) => if bf-vide(titre) { _rd().encadre(corps, .._cles(r, extra, "encadre")) } else {
    _rd().mydoc(titre, corps, .._cles(r, extra, "mydoc"))
  },
  bfbox: (r, numero, titre, corps, extra) => if bf-vide(titre) { _rd().encadre(corps, .._cles(r, extra, "encadre")) } else {
    _rd().mydoc(titre, corps, .._cles(r, extra, "mydoc"))
  },
  boiteFigure: (r, numero, titre, corps, extra) => _rd().figbox(corps, .._cles(r, extra, "figbox", propres: (title: titre))),
)
