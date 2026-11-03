// nombres.typ — nombres et unités à la française : `num`, `qty`, `unit` (noms de siunitx) sur zero.
// Réglages : `sisetup` (regler.typ), description des clés : reglages.typ (clés de siunitx traduites en clés de zero).
//
// (`nombre` → `num`, `unite` → `unit` et `qty`, `regler-nombres` → `sisetup`).

// zero est importé dans les corps (chargé au premier appel)
#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "reglages.typ": _N, vers-zero

/// Écrit un nombre à la française : virgule décimale et espace fine entre les groupes de trois chiffres.
///
/// La valeur se passe de préférence en chaîne (`"1234.5"`), pour que Typst ne l'arrondisse pas avant
/// zero. Les clés locales (celles de siunitx) l'emportent sur `sisetup`.
///
/// ```typ
/// #num("1234567.891") ; #num("0.000125", exponent-mode: "scientific") ; #num(12.5, round-precision: 2)
/// ```
///
/// - valeur (str, int, float): le nombre.
/// - style (auto, str, array): nom d'un style de `sisetup(definir: …)`.
/// - ..options (any): `output-decimal-marker`, `group-separator`, `group-minimum-digits`, `group-digits`, `round-mode`, `round-precision`, `round-pad`, `exponent-mode`, `exponent-product`, `print-unity-mantissa`, `print-zero-exponent`, `retain-explicit-plus`, `uncertainty-mode`, `zero`.
/// -> content
#let num(valeur, style: auto, ..options) = context {
  import "@preview/zero:0.7.1" as _zero
  let r = reglages-resoudre(_N, pour: "num", local: options.named() + (style: style), commande: "num")
  _zero.num(valeur, ..vers-zero(r).nombre)
}

/// Écrit une grandeur : un nombre suivi de son unité, séparés par une espace fine insécable.
///
/// L'unité se note comme en texte : `"m/s^2"`, `"kg m"`, `"mus"` (µs).
///
/// ```typ
/// #qty("9.81", "m/s^2") ; #qty("20", "°C") ; #qty(1234.5, "kg", round-precision: 0)
/// ```
///
/// - valeur (str, int, float): la valeur.
/// - unite (str): l'unité.
/// - style (auto, str, array): nom d'un style de `sisetup(definir: …)`.
/// - ..options (any): les clés de `num`, plus `per-mode` et `inter-unit-product`.
/// -> content
#let qty(valeur, unite, style: auto, ..options) = context {
  import "@preview/zero:0.7.1" as _zero
  let r = reglages-resoudre(_N, pour: "qty", local: options.named() + (style: style), commande: "qty")
  let z = vers-zero(r)
  _zero.zi.declare(unite)(valeur, ..z.nombre, ..z.unite)
}

/// Écrit une unité seule.
///
/// ```typ
/// l'unité #unit("kg m/s^2") ; #unit("m/s^2", per-mode: "fraction")
/// ```
///
/// - unite (str): l'unité, par exemple `"m/s^2"`.
/// - style (auto, str, array): nom d'un style de `sisetup(definir: …)`.
/// - ..options (any): `per-mode` (`"power"`, `"fraction"`, `"symbol"`), `inter-unit-product`.
/// -> content
#let unit(unite, style: auto, ..options) = context {
  import "@preview/zero:0.7.1" as _zero
  let r = reglages-resoudre(_N, pour: "unit", local: options.named() + (style: style), commande: "unit")
  _zero.zi.declare(unite)(..vers-zero(r).unite)
}

/// Alias de `num` (le `\np` de numprint) : mêmes arguments, même rendu.
///
/// ```typ
/// #np("1234567.5")
/// ```
///
/// -> content
#let np = num
