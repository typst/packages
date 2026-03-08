volume = Volume { $n }
errata = Errata
thanks = Remerciements
part = Partie
chapter = Chapitre

edition = { $n ->
   [one] { $n }re édition
  *[other] { $n }e édition
}

appendix = { $number ->
  *[sing] Annexe
   [plur] Annexes
}

annex = { $number ->
  *[sing] Pièce jointe
   [plur] Pièces jointes
}