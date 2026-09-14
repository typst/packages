volume = Volume { $n }
errata = Errata
thanks = Acknowledgements
part = Part
chapter = Chapter

edition = { $n ->
    [1] { $n }st edition
    [2] { $n }nd edition
    [3] { $n }rd edition
   *[other] { $n }th edition
}

appendix = { $number ->
  *[sing] Appendix
   [plur] Appendices
}

annex = { $number ->
  *[sing] Annex
   [plur] Annexes
}