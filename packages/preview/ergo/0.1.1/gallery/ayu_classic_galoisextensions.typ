#import "@preview/ergo:0.1.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#show: ergo-init.with(
  colors: "ayu-light",
  headers: "classic",
  inline-qed: true,
)
#set page(
  width: 18cm,
  height: 15.8cm,
  margin: 1em
)

#let Gal = $op("Gal")$
#let iso = sym.tilde.equiv
#let ang(..args) = {
  let joined = args.pos().map(x => $#x$).join(",")
  $lr(angle.l joined angle.r)$
}


#thm[Galois Subextensions][
  Let $K \/ F$ be a finite Galois extension.
  Then:
  1. If $H lt.eq G$, $K^H \/ F$ is Galois if and only if $H lt.tri.eq G$.
    In this case, $Gal(K^H \/ F) iso G / H$;
  2. If $F subset.eq E subset.eq K$, $E \/ F$ is Galois if and only if $Gal(K \/ E) lt.tri.eq G$.
    In this case $Gal(E \/ F) iso Gal(K \/ F) / Gal(K \/ E)$.
][]

#ex[Galois Correspondence][
  Let $zeta_3 = e^((2 pi i)/3)$.
  Then the splitting field of $f(X) = X^3 - 2 in QQ[X]$ is $K = QQ(root(3, 2), zeta_3)$, where $Gal(K \/ QQ) iso S_3$.
  Now consider generators of $Gal(K \/ QQ)$, $sigma_1:K -> K$ and $sigma_2:K -> K$, defined by $
    sigma_1 (zeta_3)
      &= zeta_3, quad
    sigma_1 (root(3, 2))
      &= root(3, 2) zeta_3, quad
    sigma_2 (zeta_3)
      &= zeta_3^2, quad
    sigma_2 (root(3, 2))
      &= root(3, 2).
  $
  Thus, the subgroups of $Gal(K \/ QQ)$ are given by $ang(sigma_1), ang(sigma_2), ang(sigma_1 sigma_2), ang(sigma_1^2 sigma_2)$, implying the following correspondence (which comes from comparing the generators of $Gal(K \/ QQ)$ with basis elements):

  #align(center)[#diagram(spacing: 2em, label-sep: 0.1em, {
    let (A, B, C, D, E, F) = ((2, 5), (0, 2), (3, 2), (6, 2), (9, 2), (2, -1))

    node(A, $QQ$)
    node(B, $QQ(zeta_3)$)
    node(C, $QQ(root(3, 2))$)
    node(D, $QQ(root(3, 2) zeta_3)$)
    node(E, $QQ(root(3, 2) zeta_3^2)$)
    node(F, $K$)

    edge(A, B, "->", $S_3/ang(sigma_1)$, label-side: left)
    edge(A, C, "->")
    edge(A, D, "->")
    edge(A, E, "->")

    edge(B, F, "->", $ang(sigma_1)$)
    edge(C, F, "->", $ang(sigma_2)$, label-side: left)
    edge(D, F, "->", $ang(sigma_1^2 sigma_2)$, label-side: left, label-pos: 45%)
    edge(E, F, "->", $ang(sigma_1 sigma_2)$, label-sep: 0.5em)
  })]
]

