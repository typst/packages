// commun.typ (rdsheet) — setter commun et aides communes aux paquets rd* : réglages (global, style nommé,
// réinitialisation) et couleurs.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: bf-xcolor, reglages-regler, reglages-reinitialiser, reglages-definir-style

// =====================================================================
// Setter commun (convention des réglages : pour, reinitialiser, definir, clés)
// =====================================================================

/// Corps des setters `setrd…` : réglage global ou d'un type (`pour`), style nommé (`definir`),
/// réinitialisation (`true` : réglages seuls ; `"tout"` : réglages et styles). `cles` : dictionnaire des clés.
#let rd-regler(r, commande, pour, reinitialiser, definir, cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic(commande + " : `reinitialiser` vaut `true`, `false` ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    if type(definir) != str or definir.trim() == "" {
      panic(commande + " : `definir` attend le nom du style (chaîne non vide) ; reçu : " + repr(definir) + ".")
    }
    if reinitialiser != false {
      panic(commande + " : `definir` et `reinitialiser` ne se combinent pas.")
    }
    reglages-definir-style(r, definir, pour: pour, commande: commande, ..cles)
  } else if reinitialiser == "tout" {
    reglages-reinitialiser(r, styles: true)
    if cles.len() > 0 { reglages-regler(r, pour: pour, commande: commande, ..cles) }
  } else {
    reglages-regler(r, pour: pour, reinitialiser: reinitialiser, commande: commande, ..cles)
  }
}

/// Clés locales d'un appel, sans les valeurs `auto` (« selon les réglages »).
#let rd-local(d) = {
  let res = (:)
  for (k, v) in d { if v != auto { res.insert(k, v) } }
  res
}

// =====================================================================
// Couleurs (dans un `context`)
// =====================================================================

/// Couleur Typst ou expression xcolor (« red!50 », « gray!8 »…) ; `none` et `auto` sont rendus tels quels.
#let rd-couleur(v, commande: "rdsheet") = {
  if v == none or v == auto { return v }
  bf-xcolor(v, commande: commande)
}
