#import "@preview/synkit:0.0.1": *
#set page(height: auto, width: auto, margin: (bottom: 1em, top: 1em, x: 1em))

Tree from Fox & Johnson (2016, p. 7).

#tree(
  "[IP [IP [IP [IP [DP† [D the_2] [\\muP every woman] ] [IP [I] [VP is smiling] ] ] [IP [and] [IP [DP‡ [D the_2] [\\muP every man] ] [IP [I] [VP is frowning] ] ] ] ] [\\lambda2] ] [QP [Q \\forall ] [\\muP\\* [\\muP] [CP who came in together] ] ] ]",
  annotation: (
    (
      "IP1",
      [$forall$_y_ [_y_ is a woman+man $and$ _y_ came in together] $arrow$ \
        [the woman part of _y_ is smiling and the man part of _y_ is frowning]],
    ),
    (
      "IP2",
      [$lambda$_x_ : _x_ has a has a unique maximal woman part \
        and a unique maximal man part. \
        the woman part of x is smiling and \
        the man part of x is frowning],
    ),
    (
      "QP1",
      [$lambda$_Q_$forall$_y_[_y_ is woman+man \
        $and$ _y_ came in together] $arrow$ _Q(y)_],
    ),
    (
      "IP3",
      [the woman part of g(2) is smiling \
        and the man part of g(2) is frowning],
    ),
    (
      "DP†1",
      [the woman part \
        of g(2)],
    ),
    (
      "DP‡1",
      [the man part \
        of g(2)],
    ),
  ),
  annotation-size: 0.8,
  dominance: (
    (from: "muP4", to: "muP1", ctrl: (-6.1, 8.5)),
    (from: "muP4", to: "muP2", ctrl: (-6, 5)),
  ),
  scale: 0.8,
  spread: 0.8,
  terminal-branch: true,
)
