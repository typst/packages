// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Conversions entre bases, d'après \ConversionEntreBases du paquet LaTeX
// ProfLycee (Cédric Pierquet, §53 de sa documentation).
//
// Commandes :
//
//   #conversion-entre-bases(sens, nb, clés)  -> « nb = conversion », en maths ;
//   conversion(sens, clés)                   -> la fonction nb => … (pas dans
//                                               ProfLycee), à fabriquer une
//                                               fois pour toutes :
//
//   #let hexa = conversion("2->16", aff-bases: true)
//   #hexa("11111110"), #hexa("1010")
//
// `sens` : "départ->arrivée", bases de 2 à 36, comme dans ProfLycee ("16->2").
// `nb` : chaîne de chiffres (lettres majuscules ou minuscules au-delà de 9),
// ou entier dont les chiffres sont lus dans la base de départ.
//
// Clés (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   aff-bases  (version étoilée *)   bases en indice ................... false
//   espace     ([espace blocs 4…])   espace entre les blocs de 4 chiffres
//                                    d'un nombre binaire ; none : pas de
//                                    blocs (comme l'option vide []) .... 0.3em
//
// Exemples :
//   #conversion-entre-bases("16->10", "ACDC")
//   #conversion-entre-bases("16->2", "ACDC", aff-bases: true, espace: none)

#let _chiffres = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// Valeur de l'écriture s en base b.
#let _lire(s, b) = {
  let v = 0
  for c in upper(str(s)).clusters() {
    let d = _chiffres.position(c)
    assert(d != none and d < b, message: "conversion : « " + c + " » n'est pas un chiffre en base " + str(b))
    v = v * b + d
  }
  v
}

// Écriture de s (chaîne de chiffres) en base b, binaire par blocs de 4.
#let _ecrire(s, b, espace, aff-bases) = {
  let s = upper(s)
  let corps = if b == 2 and espace != none and s.len() > 4 {
    let blocs = ()
    while s.len() > 4 {
      blocs.insert(0, s.slice(s.len() - 4))
      s = s.slice(0, s.len() - 4)
    }
    blocs.insert(0, s)
    blocs.map(x => $#x$).join(h(espace))
  } else { $#s$ }
  if aff-bases { $#corps _#str(b)$ } else { corps }
}

#let conversion(sens, aff-bases: false, espace: 0.3em) = {
  let (depart, arrivee) = sens.split("->").map(x => int(x.trim()))
  assert(
    depart in range(2, 37) and arrivee in range(2, 37),
    message: "conversion : bases de 2 à 36",
  )
  nb => {
    let v = _lire(nb, depart)
    $#_ecrire(str(nb), depart, espace, aff-bases) = #_ecrire(str(v, base: arrivee), arrivee, espace, aff-bases)$
  }
}

#let conversion-entre-bases(sens, nb, ..cles) = conversion(sens, ..cles)(nb)
