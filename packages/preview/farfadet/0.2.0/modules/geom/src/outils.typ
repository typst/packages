// outils.typ (farfadet-geom) — calculs sur des points (x, y) : fonctions pures, utilisables hors d'une figure.

#let est-nombre(v) = type(v) in (int, float)

/// Vérifie qu'un argument est un point `(x, y)` de deux nombres (ne renvoie rien : sans effet dans un bloc de dessin).
#let verifier-point(p, cmd, nom) = {
  if type(p) != array or p.len() != 2 or not p.all(est-nombre) {
    panic(cmd + " : « " + nom + " » doit être un point (x, y) de deux nombres ; reçu : " + repr(p) + ".")
  }
}

/// Comme `verifier-point`, mais renvoie le point (pour l'employer dans une expression).
#let point-valide(p, cmd, nom) = {
  verifier-point(p, cmd, nom)
  p
}

#let ajouter(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let retrancher(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let multiplier(a, k) = (a.at(0) * k, a.at(1) * k)
#let produit-scalaire(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)
#let norme(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let perpendiculaire(a) = (-a.at(1), a.at(0))
#let angle-du-vecteur(a) = calc.atan2(a.at(0), a.at(1))
#let direction-angle(a) = (calc.cos(a), calc.sin(a))

/// Vecteur unitaire de même direction ; erreur si le vecteur est nul.
#let unitaire(a, cmd: "geom") = {
  let n = norme(a)
  if n < 1e-12 { panic(cmd + " : deux points confondus : la direction n'est pas définie.") }
  multiplier(a, 1 / n)
}

/// Distance entre deux points.
///
/// - a (array): point `(x, y)`.
/// - b (array): point `(x, y)`.
/// -> float
#let distance(a, b) = {
  verifier-point(a, "distance", "a")
  verifier-point(b, "distance", "b")
  norme(retrancher(b, a))
}

/// Milieu de `[a b]`.
///
/// - a (array): point `(x, y)`.
/// - b (array): point `(x, y)`.
/// -> array
#let milieu(a, b) = {
  verifier-point(a, "milieu", "a")
  verifier-point(b, "milieu", "b")
  multiplier(ajouter(a, b), 0.5)
}

/// Projeté orthogonal de `p` sur la droite `(a b)`.
///
/// - p (array): point à projeter.
/// - a (array): premier point de la droite.
/// - b (array): second point de la droite.
/// -> array
#let projete(p, a, b) = {
  verifier-point(p, "projete", "p")
  verifier-point(a, "projete", "a")
  verifier-point(b, "projete", "b")
  let v = unitaire(retrancher(b, a), cmd: "projete")
  ajouter(a, multiplier(v, produit-scalaire(retrancher(p, a), v)))
}

/// Point d'intersection des droites `(a b)` et `(c d)` ; erreur si elles sont parallèles.
///
/// - a (array): point de la première droite.
/// - b (array): second point de la première droite.
/// - c (array): point de la seconde droite.
/// - d (array): second point de la seconde droite.
/// -> array
#let intersection(a, b, c, d) = {
  for (p, n) in ((a, "a"), (b, "b"), (c, "c"), (d, "d")) { verifier-point(p, "intersection", n) }
  let u = retrancher(b, a)
  let v = retrancher(d, c)
  let det = u.at(0) * v.at(1) - u.at(1) * v.at(0)
  if calc.abs(det) < 1e-12 { panic("intersection : les droites (a b) et (c d) sont parallèles ou confondues.") }
  let w = retrancher(c, a)
  let t = (w.at(0) * v.at(1) - w.at(1) * v.at(0)) / det
  ajouter(a, multiplier(u, t))
}

/// Part de la droite `p + t d` contenue dans le rectangle `fen = ((x0, y0), (x1, y1))` ; `depuis-p` ne garde que `t >= 0`.
/// Renvoie `(debut, fin)` ou `none` si la droite ne rencontre pas le rectangle.
#let couper(p, d, fen, depuis-p: false) = {
  let bas = if depuis-p { 0.0 } else { -float.inf }
  let haut = float.inf
  for i in (0, 1) {
    let mn = fen.at(0).at(i)
    let mx = fen.at(1).at(i)
    if calc.abs(d.at(i)) < 1e-12 {
      if p.at(i) < mn or p.at(i) > mx { return none }
    } else {
      let t1 = (mn - p.at(i)) / d.at(i)
      let t2 = (mx - p.at(i)) / d.at(i)
      bas = calc.max(bas, calc.min(t1, t2))
      haut = calc.min(haut, calc.max(t1, t2))
    }
  }
  if bas > haut { none } else { (ajouter(p, multiplier(d, bas)), ajouter(p, multiplier(d, haut))) }
}

/// Valide une fenêtre `((x0, y0), (x1, y1))`.
#let verifier-fenetre(f, cmd) = {
  let ok = type(f) == array and f.len() == 2 and f.all(p => type(p) == array and p.len() == 2 and p.all(est-nombre))
  if not ok or f.at(0).at(0) >= f.at(1).at(0) or f.at(0).at(1) >= f.at(1).at(1) {
    panic(cmd + " : la fenêtre attend ((xmin, ymin), (xmax, ymax)) avec xmin < xmax et ymin < ymax ; reçu : " + repr(f) + ".")
  }
}

/// Comme `verifier-fenetre`, mais renvoie la fenêtre.
#let fenetre-valide(f, cmd) = {
  verifier-fenetre(f, cmd)
  f
}
