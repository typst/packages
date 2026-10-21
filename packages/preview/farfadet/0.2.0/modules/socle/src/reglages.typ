// reglages.typ (farfadet-socle) — mécanisme GÉNÉRIQUE de réglages, commun à tous les paquets farfadet-*.
//
// Un paquet décrit ses réglages une fois (`reglages-paquet`), puis s'en sert pour :
// - un réglage global (le setter LaTeX : `setrdcrep`, `setrdexo`… ou `regler-<paquet>`) ;
// - des réglages par type d'objet (`pour: "definition"`) ;
// - des styles nommés (équivalent des `/.style` de pgfkeys), appelés par la clé `style:` ;
// - la réinitialisation (`reinitialiser: true` ou setter `Reset…`) ;
// - la résolution des valeurs effectives, dans un `context`, avec la priorité unique :
//     clé locale > style nommé > réglage du type > réglage global > défaut du paquet.
//   (Un `style:` écrit dans un réglage global ou de type s'applique au même niveau, sous les clés
//   explicites de ce niveau : locale > styles locaux > type > styles du type > global > styles du global.)
// - la validation : clé, type ou style inconnu, valeur invalide = `panic` qui liste les possibilités.
//
// Documentation complète et exemple : ../REGLAGES.md. Noms exportés par interne.typ : `reglages-*`.

// =====================================================================
// Messages et contrôles de valeurs
// =====================================================================

#import "etat.typ": tailles-latex
#import "couleurs.typ": bf-est-nommee, bf-couleur-nommee
#import "precoce.typ": bf-maj, bf-lire

/// « a », « b », « c » : liste lisible pour les messages d'erreur.
#let reglages-liste(elements) = elements.map(e => "« " + str(e) + " »").join(", ")

// Un marqueur de couleur nommée (`bf-nommee("thm")`, couleurs.typ) passe tous les contrôles de couleur
// (et `reglages-deduit` en déduit `couleur-ou-nom`) : `reglages-resoudre` le remplace par la valeur
// courante de la couleur.
#let _est-couleur(v) = type(v) in (color, gradient, tiling) or bf-est-nommee(v)
#let _est-longueur(v) = type(v) in (length, relative, ratio)

/// Contrôles prêts à l'emploi : (test, description de ce qui est attendu).
#let reglages-controles = (
  booleen: (v => type(v) == bool, "true ou false"),
  couleur: (v => _est-couleur(v), "une couleur Typst"),
  couleur-ou-nom: (v => _est-couleur(v) or type(v) == str, "une couleur Typst ou un nom xcolor (\"red!50!black\")"),
  couleur-ou-auto: (v => v == auto or _est-couleur(v), "auto ou une couleur Typst"),
  couleur-ou-none: (v => v == none or _est-couleur(v), "none ou une couleur Typst"),
  longueur: (v => _est-longueur(v), "une longueur (2pt, 1cm, 50%…)"),
  longueur-ou-auto: (v => v == auto or _est-longueur(v), "auto ou une longueur"),
  longueur-ou-none: (v => v == none or _est-longueur(v), "none ou une longueur"),
  entier: (v => type(v) == int, "un entier"),
  nombre: (v => type(v) in (int, float), "un nombre"),
  texte: (v => type(v) == str, "une chaîne de caractères"),
  // `symbol` accepté (sym.times, sym.space.thin…) : demande farfadet-maths du 06/10/2026
  contenu: (v => type(v) in (content, str, symbol), "un contenu"),
  contenu-ou-none: (v => v == none or type(v) in (content, str, symbol), "none ou un contenu"),
  fonction: (v => type(v) == function, "une fonction"),
  // taille nommée de LaTeX ou longueur (demande farfadet-modele du 06/10/2026)
  taille-latex: (
    v => (type(v) == str and v in tailles-latex.at("12pt")) or _est-longueur(v),
    "un nom de taille LaTeX (" + tailles-latex.at("12pt").keys().map(k => "\"" + k + "\"").join(", ") + ") ou une longueur",
  ),
  tout: (v => true, "toute valeur"),
)

/// Contrôle « une valeur parmi » : reglages-choix("gauche", "droite").
#let reglages-choix(..valeurs) = {
  let vs = valeurs.pos()
  (v => v in vs, vs.map(repr).join(", ", last: " ou "))
}

/// Contrôle « l'un ou l'autre » : reglages-ou(reglages-controles.booleen, reglages-choix("auto")).
#let reglages-ou(..controles) = {
  let cs = controles.pos()
  (v => cs.any(c => (c.at(0))(v)), cs.map(c => c.at(1)).join(", ", last: " ou "))
}

/// Contrôle déduit de la valeur par défaut (quand le paquet n'en donne pas).
#let reglages-deduit(defaut) = {
  if type(defaut) == bool { reglages-controles.booleen }
  else if _est-couleur(defaut) { reglages-controles.couleur-ou-nom }
  else if _est-longueur(defaut) { reglages-controles.longueur }
  else if type(defaut) in (int, float) { reglages-controles.nombre }
  else { reglages-controles.tout }
}

/// Vérifie un dictionnaire de clés nommées (`controles` = (clé: (test, description))). Renvoie
/// `reglages` si tout est valide ; sinon `panic` explicite (« clé inconnue … Clés possibles : … »).
#let reglages-verifier(commande, reglages, controles) = {
  for (cle, valeur) in reglages {
    if cle not in controles {
      panic(commande + " : clé inconnue « " + cle + " ». Clés possibles : " + reglages-liste(controles.keys()) + ".")
    }
    let (test, attendu) = controles.at(cle)
    if not test(valeur) {
      panic(commande + " : valeur invalide pour la clé « " + cle + " » : " + repr(valeur) + ". Valeurs possibles : " + attendu + ".")
    }
  }
  reglages
}

// =====================================================================
// Description des réglages d'un paquet
// =====================================================================

/// Décrit les réglages d'un paquet. Renvoie un dictionnaire « registre » à passer aux autres fonctions.
///
/// - nom (str): identifiant du paquet ou de la famille (« crep », « exo »…) ; l'état s'appelle « bfr-<nom> ».
/// - defauts (dictionary): clés communes et leurs valeurs par défaut.
/// - controles (dictionary): (clé: (test, description)) ; une clé sans contrôle est contrôlée d'après son défaut.
/// - types (dictionary): (type: (clé: défaut propre au type)) — clés supplémentaires ou défauts différents.
/// - commande (str, auto): nom du réglage global dans les messages (défaut : « regler-<nom> »).
/// - groupes (dictionary): (groupe: (type, type…)) — noms acceptés par `pour:` pour viser plusieurs types
///   d'un coup (`pour: "connecteurs"`) ; `pour:` accepte aussi un tableau de types ou de groupes.
/// - styles (dictionary): (nom: (clé: valeur…)) — styles nommés PRÉDÉFINIS, présents dès le départ
///   (`TableauBox`, `ColonnesBaseStyle`, `bfd theoreme`…) ; `reglages-reinitialiser(styles: true)`
///   revient à eux. Leurs clés sont contrôlées ici. (Demandes farfadet-enum et farfadet-didactique.)
#let reglages-paquet(nom, defauts, controles: (:), types: (:), commande: auto, groupes: (:), styles: (:)) = {
  let commande-msg = if commande == auto { "regler-" + nom } else { commande }
  for (g, membres) in groupes {
    if g in types { panic(commande-msg + " : le groupe « " + g + " » porte le nom d'un type.") }
    if type(membres) != array { panic(commande-msg + " : le groupe « " + g + " » doit être un tableau de types ; reçu : " + repr(membres) + ".") }
    for m in membres {
      if m not in types {
        panic(commande-msg + " : le groupe « " + g + " » cite un type inconnu « " + str(m) + " ». Types possibles : " + reglages-liste(types.keys()) + ".")
      }
    }
  }
  let tous-controles = (:)
  let toutes = defauts
  for (_, d) in types { toutes += d }
  for (cle, valeur) in toutes {
    tous-controles.insert(cle, controles.at(cle, default: reglages-deduit(valeur)))
  }
  for (cle, c) in controles { if cle not in tous-controles { tous-controles.insert(cle, c) } }
  if type(styles) != dictionary { panic(commande-msg + " : `styles` attend un dictionnaire (nom: (clé: valeur…)) ; reçu : " + repr(styles) + ".") }
  for (s, cles) in styles {
    if type(cles) != dictionary { panic(commande-msg + " : le style prédéfini « " + s + " » doit être un dictionnaire de clés ; reçu : " + repr(cles) + ".") }
    for (cle, valeur) in cles {
      if cle == "style" or valeur == auto { continue }
      if cle not in tous-controles {
        panic(commande-msg + " : style prédéfini « " + s + " » : clé inconnue « " + cle + " ». Clés possibles : " + reglages-liste(tous-controles.keys() + ("style",)) + ".")
      }
      let (test, attendu) = tous-controles.at(cle)
      if not test(valeur) {
        panic(commande-msg + " : style prédéfini « " + s + " » : valeur invalide pour la clé « " + cle + " » : " + repr(valeur) + ". Valeurs possibles : " + attendu + ".")
      }
    }
  }
  (
    nom: nom,
    commande: if commande == auto { "regler-" + nom } else { commande },
    defauts: defauts,
    types: types,
    groupes: groupes,
    controles: tous-controles,
    styles-initiaux: styles,
    etat: state("bfr-" + nom, (global: (:), types: (:), styles: styles)),
    cle: "bfr-" + nom,
    init: (global: (:), types: (:), styles: styles),
  )
}

/// Clés permises pour un type (`pour: none` : toutes les clés du paquet).
#let _permises(r, pour) = {
  if pour == none { r.controles.keys() } else { (r.defauts + r.types.at(pour, default: (:))).keys() }
}

/// Défauts effectifs d'un type.
#let _defauts(r, pour) = if pour == none { r.defauts } else { r.defauts + r.types.at(pour, default: (:)) }

#let _controler-type(r, commande, pour) = {
  if pour != none and r.types.len() > 0 and pour not in r.types {
    let groupes = r.at("groupes", default: (:))
    panic(
      commande + " : type inconnu « " + str(pour) + " ». Types possibles : " + reglages-liste(r.types.keys())
        + (if groupes.len() > 0 { " ; groupes : " + reglages-liste(groupes.keys()) } else { "" }) + ".",
    )
  }
}

/// Types visés par `pour` : none (global), un type, un groupe, ou un tableau de types et de groupes.
/// Renvoie un tableau (`(none,)` pour le réglage global), sans doublon.
#let _cibles(r, commande, pour) = {
  if pour == none { return (none,) }
  let groupes = r.at("groupes", default: (:))
  let noms = if type(pour) == array { pour } else { (pour,) }
  let res = ()
  for p in noms {
    if type(p) != str {
      panic(commande + " : `pour` attend un nom de type, de groupe, ou un tableau de noms ; reçu : " + repr(p) + ".")
    }
    if p in groupes { res += groupes.at(p) } else {
      _controler-type(r, commande, p)
      res.push(p)
    }
  }
  res.dedup()
}

/// Contrôle d'un dictionnaire de clés pour `pour` (la clé `style` est toujours permise).
#let _controler(r, commande, pour, cles) = {
  let permises = _permises(r, pour)
  for (cle, valeur) in cles {
    if cle == "style" {
      // `style: auto` (défaut d'une signature) : « pas de style », ignoré (demande farfadet-maths)
      if valeur == auto { continue }
      if not (type(valeur) == str or (type(valeur) == array and valeur.all(x => type(x) == str))) {
        panic(commande + " : la clé « style » attend un nom de style ou un tableau de noms ; reçu : " + repr(valeur) + ".")
      }
      continue
    }
    if cle not in permises {
      panic(
        commande + " : clé inconnue « " + cle + " »" + (if pour == none { "" } else { " pour « " + pour + " »" })
          + ". Clés possibles : " + reglages-liste(permises + ("style",)) + ".",
      )
    }
    // `auto` sur une clé : « selon les réglages » — toujours accepté, ignoré à la résolution
    if valeur == auto { continue }
    let (test, attendu) = r.controles.at(cle)
    if not test(valeur) {
      panic(commande + " : valeur invalide pour la clé « " + cle + " » : " + repr(valeur) + ". Valeurs possibles : " + attendu + ".")
    }
  }
}

// =====================================================================
// Écriture : réglage global, par type, styles nommés, réinitialisation
// =====================================================================

/// Règle la suite du document. Sans `pour` : réglage global ; avec `pour: "<type>"` : réglage de ce type.
/// Les appels s'ajoutent clé par clé ; `reinitialiser: true` repart des défauts (les styles nommés restent).
#let reglages-regler(r, pour: none, reinitialiser: false, commande: auto, ..cles) = {
  let commande = if commande == auto { r.commande } else { commande }
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  let c = cles.named()
  let cibles = _cibles(r, commande, pour)
  for p in cibles { _controler(r, commande, p, c) }
  bf-maj(r, e => {
    let e = if reinitialiser { e + (global: (:), types: (:)) } else { e }
    for p in cibles {
      if p == none { e.global = e.global + c } else { e.types.insert(p, e.types.at(p, default: (:)) + c) }
    }
    e
  })
}

/// Réglage de plusieurs types en un appel, à la manière de `regler-environnements` :
/// reglages-regler-types(r, tous: (…), definition: (…), exemple: (…)).
#let reglages-regler-types(r, tous: none, reinitialiser: false, commande: auto, ..types) = {
  let commande = if commande == auto { r.commande } else { commande }
  if types.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés (tous: (…), <type>: (…)) ; reçu : " + repr(types.pos().first()) + ".")
  }
  // un nom de groupe vaut pour chacun de ses types (les types écrits ensuite l'emportent)
  let ecritures = ()
  for (pour, dico) in (if tous == none { () } else { ((none, tous),) }) + types.named().pairs() {
    if type(dico) != dictionary {
      panic(commande + " : un dictionnaire de clés est attendu, par exemple (couleur: red) ; reçu : " + repr(dico) + ".")
    }
    for p in _cibles(r, commande, pour) {
      _controler(r, commande, p, dico)
      ecritures.push((p, dico))
    }
  }
  bf-maj(r, e => {
    let e = if reinitialiser { e + (global: (:), types: (:)) } else { e }
    for (p, dico) in ecritures {
      if p == none { e.global = e.global + dico } else { e.types.insert(p, e.types.at(p, default: (:)) + dico) }
    }
    e
  })
}

/// Définit (ou remplace) un style nommé : un paquet de clés appelé ensuite par `style: "<nom>"`.
/// Un style peut lui-même contenir `style:` (héritage). `pour` : style réservé à un type (contrôle des clés).
#let reglages-definir-style(r, nom, pour: none, commande: auto, ..cles) = {
  let commande = if commande == auto { r.commande } else { commande }
  if type(nom) != str { panic(commande + " : le nom d'un style est une chaîne ; reçu : " + repr(nom) + ".") }
  let c = cles.named()
  for p in _cibles(r, commande, pour) { _controler(r, commande, p, c) }
  bf-maj(r, e => {
    e.styles.insert(nom, c)
    e
  })
}

/// Styles nommés COMMUNS à tous les paquets : définis par la fonction publique
/// `definir-style` du socle, appelés par `style:` dans n'importe quel paquet qui emploie ce mécanisme.
/// Un style du paquet (reglages-definir-style) l'emporte sur un style commun du même nom.
#let bf-styles-communs = state("bfr-styles-communs", (:))
#let _styles-communs-p = (etat: bf-styles-communs, cle: "bfr-styles-communs", init: (:))

/// Définit (ou remplace) un style nommé commun. Ses clés sont contrôlées à l'emploi, contre les clés
/// du paquet qui l'appelle (message « style « x » : clé inconnue … »).
#let reglages-definir-style-commun(nom, commande: "definir-style", ..cles) = {
  if type(nom) != str or nom.trim() == "" {
    panic(commande + " : le nom d'un style est une chaîne non vide ; reçu : " + repr(nom) + ".")
  }
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés après le nom du style ; reçu : " + repr(cles.pos().first()) + ".")
  }
  let c = cles.named()
  if "style" in c and not (type(c.style) == str or (type(c.style) == array and c.style.all(x => type(x) == str))) {
    panic(commande + " : la clé « style » attend un nom de style ou un tableau de noms ; reçu : " + repr(c.style) + ".")
  }
  bf-maj(_styles-communs-p, d => d + ((nom): c))
}

/// Oublie tous les styles communs.
#let reglages-oublier-styles-communs() = bf-maj(_styles-communs-p, _ => (:))

/// Réinitialise les réglages (global et types) ; `styles: true` ramène aussi les styles nommés à
/// ceux que le paquet prédéfinit (`reglages-paquet(styles: …)`) : les styles de l'utilisateur sont
/// oubliés, les styles prédéfinis retrouvent leur définition d'origine.
#let reglages-reinitialiser(r, styles: false) = bf-maj(r, e => (
  global: (:),
  types: (:),
  styles: if styles { r.at("styles-initiaux", default: (:)) } else { e.styles },
))

// =====================================================================
// Lecture : valeurs effectives (dans un `context`)
// =====================================================================

/// Développe les styles nommés `noms` (chaîne ou tableau) en un dictionnaire de clés.
#let _developper(r, commande, styles, noms, profondeur: 0) = {
  if noms == none or noms == auto { return (:) }
  if profondeur > 16 { panic(commande + " : styles nommés imbriqués trop profondément (boucle ?).") }
  let noms = if type(noms) == str { (noms,) } else { noms }
  let res = (:)
  for nom in noms {
    if nom not in styles {
      panic(
        commande + " : style inconnu « " + nom + " ». Styles définis : "
          + (if styles.len() == 0 { "aucun" } else { reglages-liste(styles.keys()) }) + ".",
      )
    }
    let s = styles.at(nom)
    res += _developper(r, commande, styles, s.at("style", default: none), profondeur: profondeur + 1)
    for (cle, valeur) in s {
      if cle == "style" { continue }
      // contrôle (utile pour les styles communs, définis sans connaître le paquet)
      if cle not in r.controles {
        panic(
          commande + " : style « " + nom + " » : clé inconnue « " + cle + " ». Clés possibles : "
            + reglages-liste(r.controles.keys() + ("style",)) + ".",
        )
      }
      if valeur != auto {
        let (test, attendu) = r.controles.at(cle)
        if not test(valeur) {
          panic(commande + " : style « " + nom + " » : valeur invalide pour la clé « " + cle + " » : " + repr(valeur) + ". Valeurs possibles : " + attendu + ".")
        }
      }
      res.insert(cle, valeur)
    }
  }
  res
}

/// Ajoute à `res` les clés de `niveau` (précédées de ses styles), limitées aux clés permises ; `auto` ignoré.
#let _appliquer(r, commande, styles, res, niveau) = {
  let permises = res.keys()
  let couche = _developper(r, commande, styles, niveau.at("style", default: none))
  // une clé `auto` du niveau (« non précisée ») ne masque pas la valeur d'un style : demande farfadet-latex
  for (cle, valeur) in niveau { if cle != "style" and valeur != auto { couche.insert(cle, valeur) } }
  for (cle, valeur) in couche {
    if valeur == auto { continue }
    if cle in permises { res.insert(cle, valeur) }
  }
  res
}

/// Remplace les marqueurs `bf-nommee(…)` par la valeur courante de leur couleur, y compris dans les
/// tableaux et dictionnaires (un niveau ou plus). À appeler dans un `context`.
#let _substituer-nommees(v, commande, cle) = {
  if bf-est-nommee(v) { bf-couleur-nommee(v, commande: commande + " (" + cle + ")") } else if type(v) == array {
    v.map(x => _substituer-nommees(x, commande, cle))
  } else if type(v) == dictionary {
    v.pairs().map(((k, x)) => (k, _substituer-nommees(x, commande, cle))).to-dict()
  } else { v }
}

/// Valeurs effectives pour le type `pour` (none : global seul) et les clés locales `local`
/// (dictionnaire ; `auto` = « non précisé »). À appeler dans un `context`.
/// Priorité : local > styles locaux > type > styles du type > global > styles du global > défaut.
/// Les marqueurs de couleur nommée (`bf-nommee("thm")`) sont remplacés par la valeur COURANTE de la
/// couleur (`setbfcolors`) : le dictionnaire rendu ne contient que des couleurs Typst.
#let reglages-resoudre(r, pour: none, local: (:), commande: auto) = {
  let commande = if commande == auto { if pour == none { r.commande } else { pour } } else { commande }
  if local.len() > 0 { _controler(r, commande, pour, local) }
  let e = bf-lire(r)
  // styles du paquet, puis styles communs (definir-style) : le paquet l'emporte à nom égal
  let styles = bf-lire(_styles-communs-p) + e.styles
  let res = _defauts(r, pour)
  res = _appliquer(r, commande, styles, res, e.global)
  if pour != none { res = _appliquer(r, commande, styles, res, e.types.at(pour, default: (:))) }
  res = _appliquer(r, commande, styles, res, local)
  res.pairs().map(((k, v)) => (k, _substituer-nommees(v, commande, k))).to-dict()
}

/// Raccourci : valeurs effectives sans clé locale. À appeler dans un `context`.
#let reglages-courants(r, pour: none) = reglages-resoudre(r, pour: pour)
