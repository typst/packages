#import "@preview/boxproof:0.1.0": *

#start(
  pf(
    (
      $forall x. (forall y. ("child"(y, x) -> "fly"(y)) and "dragon"(x) -> "happy"(x))$,
      premise,
    ),
    (
      $forall x. ("green"(x) and "dragon"(x) -> "fly"(x))$,
      premise,
    ),
    (
      $forall x. (exists y. ("parent"(y, x) and "green"(y)) -> "green"(x))$,
      premise,
    ),
    (
      $forall z. forall x. ("child"(x, z) and "dragon"(z) -> "dragon"(x))$,
      premise,
    ),
    (
      $forall x. forall y. ("child"(y, x) -> "parent"(x, y))$,
      premise,
    ),
    pfbox(
      ($c$, fic),
      pfbox(
        ($"dragon"(c)$, ass),
        pfbox(
          ($"green"(c)$, ass),
          pfbox(
            ($d$, fic),
            pfbox(
              ($"child"(d,c)$, ass),
              ($forall y. ("child"(y,c) -> "parent"(c,y))$, fae(5)),
              ($"parent"(c,d)$, impe(10, 11)),
              ($"parent"(c,d) and "green"(c)$, andi(12, 8)),
              ($exists y. ("parent"(y,d) and "green"(y))$, exi(13)),
              ($"green"(d)$, faie(14, 3)),
              ($"child"(d,c) and "dragon"(c)$, andi(10, 7)),
              (
                $forall x. ("child"(x,c) and "dragon"(c) -> "dragon"(x))$,
                fae(4),
              ),
              ($"dragon"(d)$, faie(16, 17)),
              ($"green"(d) and "dragon"(d)$, andi(15, 18)),
              ($"fly"(d)$, faie(19, 2)),
            ),
            ($"child"(d,c) -> "fly"(d)$, impi(10, 20)),
          ),
          ($forall y. ("child"(y,c) -> "fly"(y))$, fai(9, 21)),
        ),
        ($(forall y. ("child"(y,c) -> "fly"(y))) and "dragon"(c)$, andi(22, 7)),
        ($"happy"(c)$, faie(23, 1)),
      ),
      ($"green"(c) -> "happy"(c)$, impi(8, 24)),
    ),
    ($"dragon"(c) -> ("green"(c) -> "happy"(c))$, impi(7, 25)),
    ($forall x. ("dragon"(x) -> ("green"(x) -> "happy"(x)))$, fai(6, 26)),
  ),
)
