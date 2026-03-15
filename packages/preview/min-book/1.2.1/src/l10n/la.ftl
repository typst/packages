volume = Volumen { $n }
errata = Corrigenda
thanks = Gratiarum actio
part = Pars
chapter = Capitulum

edition = { $n ->
    [1] Editio prima
    [2] Editio secunda
    [3] Editio tertia
    [4] Editio quarta
    [5] Editio quinta
    [6] Editio sexta
    [7] Editio septima
    [8] Editio octava
    [9] Editio nona
   [10] Editio decima
   [11] Editio undecima
   [12] Editio duodecima
   [13] Editio tertiadecima
   [14] Editio quartadecima
   [15] Editio quintadecima
   [16] Editio sextadecima
   [17] Editio septimadecima
   [18] Editio duodevicesima
   [19] Editio undevicesima
   [20] Editio vicesima
  *[other] Editio { $n }
}

appendix = { $number ->
  *[sing] Appendix
   [plur] Appendices
}

annex = { $number ->
  *[sing] Additamentum
   [plur] Additamenta
}