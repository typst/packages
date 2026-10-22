// etat.typ (farfadet-socle) — états typographiques partagés par tous les paquets farfadet-*.
//
// Règle : un module lit un état dans un `context` et le modifie par `.update`.
// Aucun module ne crée d'état portant un nom déjà utilisé ici.

// (les réglages de rdcrep sont partis dans farfadet-crep,
// la version prof/élève dans version.typ, la couleur d'accent dans couleurs.typ)

// ---------- Tailles de police nommées de LaTeX ----------
// Classe article : les tailles dépendent de l'option 10pt / 11pt / 12pt.
#import "precoce.typ": bf-etat, bf-maj, bf-lire
#let tailles-latex = (
  "10pt": (tiny: 5pt, scriptsize: 7pt, footnotesize: 8pt, small: 9pt, normalsize: 10pt,
    large: 12pt, Large: 14.4pt, LARGE: 17.28pt, huge: 20.74pt, Huge: 24.88pt),
  "11pt": (tiny: 6pt, scriptsize: 8pt, footnotesize: 9pt, small: 10pt, normalsize: 10.95pt,
    large: 12pt, Large: 14.4pt, LARGE: 17.28pt, huge: 20.74pt, Huge: 24.88pt),
  "12pt": (tiny: 6pt, scriptsize: 8pt, footnotesize: 10pt, small: 10.95pt, normalsize: 12pt,
    large: 14.4pt, Large: 17.28pt, LARGE: 20.74pt, huge: 24.88pt, Huge: 24.88pt),
)

/// Point TeX (1/72,27 in) → longueur Typst (le `pt` de Typst vaut 1/72 in).
#let ptl(x) = x * 1pt * 72 / 72.27

/// Taille RÉELLE du corps de texte (taille Typst de la police du corps).
#let bf-taille-base-p = bf-etat("bf-taille-base", 11.715pt)
#let bf-taille-base = bf-taille-base-p.etat

/// Barème des tailles nommées, facteur d'échelle et famille du corps de texte.
/// bfcours (bfcours-fonts : scrextend fontsize=12 + fourier) : barème « 12pt » ; Utopia est
/// réduite à 11/12, et Erewhon (clone OTF d'Utopia) dessine 6,5 % plus petit qu'elle
/// (chasses AFM/hmtx : 692/650 = 1,065) : même rendu avec Erewhon à 11 × 1,065 = 11,715 pt,
/// d'où echelle = 11,715/12 (\large → 14,06 pt).
/// `texte` : famille du corps (sert au fantôme des boîtes placées dans une formule).
/// `taille` : taille NOMINALE réelle de `\normalsize` (12 pt ; 14 pt en variante dys), ajout du 06/10/2026
/// (demande farfadet-modele) : le cadratin et les en-têtes s'en déduisent sans passer par
/// `bf-taille-base / echelle`.
/// `echelle` : rapport entre la taille Typst du corps et la taille nominale DU BARÈME (`schema` : 10, 11
/// ou 12 pt), et non à `taille`. Sans effet de différence jusqu'à 12 pt ; en dys (14 pt, barème 12 pt),
/// les tailles nommées (`large`…) sont ainsi multipliées par 14/12 comme le corps.
#let bf-police-p = bf-etat("bf-police", (schema: "12pt", echelle: 11.715 / 12, texte: none, taille: 12pt))
#let bf-police = bf-police-p.etat

/// Interlignage LaTeX du document (mesuré sur bfcours : \baselineskip 14,5 pt, \lineskip 1 pt).
#let bf-interligne-p = bf-etat("bf-interligne", (baselineskip: ptl(14.5), lineskip: ptl(1), parskip: 0pt))
#let bf-interligne = bf-interligne-p.etat

/// Pied de page substitué en cours de document, sans `set page`. Un `set page` écrit après du contenu ouvre une
/// nouvelle page : sous `modele`, dont le bandeau est déjà sur la page 1, cela laissait une page 1 vide.
/// `bf-pied-modele` vaut `true` quand le pied du modèle est lu dans cet état (posé par `bfcours-page`) ;
/// `bf-pied-surcharge` porte le pied de remplacement (contenu) ou `none` (pied du modèle).
#let bf-pied-modele = state("bf-pied-modele", false)
#let bf-pied-surcharge = state("bf-pied-surcharge", none)

/// Équations centrées à gauche (option de classe fleqn) et leur retrait (\mathindent).
#let bf-fleqn-p = bf-etat("bf-fleqn", (actif: true, retrait: ptl(27.37)))
#let bf-fleqn = bf-fleqn-p.etat

/// Taille LaTeX nommée (« large »…) → longueur réelle ; une longueur passe telle quelle. À appeler dans un `context`.
#let taille-latex(nom) = {
  if type(nom) == length { return nom }
  let p = bf-lire(bf-police-p)
  tailles-latex.at(p.schema).at(nom) * p.echelle
}

// ---------- Options « clé=valeur » à la tcolorbox / pgfkeys ----------

/// Découpe une liste LaTeX « a=1, b={x, y}, c » au premier niveau d'accolades.
/// Renvoie un dictionnaire : valeurs en chaînes (accolades externes retirées), clés sans valeur → true.
/// Les clés sont normalisées : espaces internes → « - » (« extra lines » → « extra-lines »).
#let lire-options(chaine) = {
  if chaine == none { return (:) }
  if type(chaine) == dictionary { return chaine }
  let morceaux = ()
  let courant = ""
  let profondeur = 0
  for c in chaine.clusters() {
    if c == "{" { profondeur += 1 }
    if c == "}" { profondeur -= 1 }
    if c == "," and profondeur == 0 {
      morceaux.push(courant)
      courant = ""
    } else { courant += c }
  }
  morceaux.push(courant)
  let options = (:)
  for m in morceaux {
    let m = m.trim()
    if m == "" { continue }
    let pos = m.position("=")
    let (cle, valeur) = if pos == none { (m, true) } else { (m.slice(0, pos).trim(), m.slice(pos + 1).trim()) }
    if type(valeur) == str and valeur.starts-with("{") and valeur.ends-with("}") {
      valeur = valeur.slice(1, -1)
    }
    options.insert(cle.split(regex("\s+")).join("-"), valeur)
  }
  options
}

/// Longueur LaTeX simple (« 2.5cm », « 3pt », « 0.5\linewidth », « 1em ») → longueur Typst ; sinon `defaut`.
#let longueur-latex(v, defaut: none) = {
  if type(v) in (length, relative, ratio) { return v }
  if type(v) != str { return defaut }
  let s = v.replace(" ", "")
  let m = s.match(regex("^(-?[0-9]*\.?[0-9]+)(cm|mm|pt|em|ex|in|bp)$"))
  if m != none {
    let x = float(m.captures.at(0))
    let u = m.captures.at(1)
    return if u == "cm" { x * 1cm } else if u == "mm" { x * 1mm } else if u == "pt" { x * 1pt * 72 / 72.27 } else if u == "bp" { x * 1pt } else if u == "in" { x * 1in } else if u == "em" { x * 1em } else { x * 0.5em }
  }
  let m = s.match(regex("^(-?[0-9]*\.?[0-9]+)?\\\\(linewidth|textwidth|columnwidth|hsize)$"))
  if m != none {
    let x = if m.captures.at(0) == none { 1 } else { float(m.captures.at(0)) }
    return x * 100%
  }
  defaut
}

/// Valeur booléenne d'une option LaTeX (« true », « false », clé seule).
#let booleen-latex(v) = v == true or v == "true"
