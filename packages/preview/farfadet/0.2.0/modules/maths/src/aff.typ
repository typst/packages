// aff.typ — `affiche` : nombre relatif entre parenthèses quand il est négatif (bfcours-commands.sty).
//
//   $ 3 times #affiche(-2) $            →  3 × (−2)
//
// Les nombres passent par `num` (virgule décimale, espaces de `sisetup`).
// ÉPURAGE (07/10/2026) : les expressions à signe automatique (`affMonome`, `affBinome`, `affBinomeColor`,
// `affSigne`, `affTermeSigne`, `affPolyDeux`, `plusterme`, `plustermex`) sont supprimées.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "reglages.typ": _M
#import "nombres.typ": num

/// Valeur numérique d'un argument (nombre, ou chaîne de chiffres).
#let _v(x) = if type(x) == str { float(x.replace("−", "-").replace(",", ".")) } else { x }

/// Un nombre par `num` : la valeur est passée en chaîne, pour que zero ne l'arrondisse pas avant.
#let _n(x) = {
  let t = str(x).replace("−", "-").replace(",", ".")
  num(t)
}

/// Nombre relatif entre parenthèses quand il est négatif (`\affiche[code]{nombre}`).
///
/// `code` : `0` (défaut) : parenthèses si négatif ; `1` : toujours ; `-1` : jamais.
///
/// ```typ
/// $ 3 times #affiche(-2) quad 3 times #affiche(2) quad 3 times #affiche(2, code: 1) $
/// ```
///
/// - nombre (int, float, str): le nombre.
/// - code (auto, int): `1`, `0` ou `-1`.
/// - style (auto, str, array): nom d'un style défini par `setbfmaths(definir: …)`.
/// -> content
#let affiche(nombre, code: auto, style: auto) = context {
  let r = reglages-resoudre(
    _M, pour: "affiche", commande: "affiche", local: (code: code, style: style),
  )
  let parentheses = r.code == 1 or (r.code == 0 and _v(nombre) < 0)
  if parentheses [(#_n(nombre))] else { _n(nombre) }
}
