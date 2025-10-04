#import "../lib.typ": *


#show: doc.with(
	lang: "fr",
  outline: true,
  title: ("Chapitre IX", "Espaces Préhilbertiens"),
  authors: ("Espaces Préhilbertiens"),
  style : "numbered-book",
)



#let cm = $cal(M)$
#let Ker = "Ker"
#let Im = "Im"
#let cm = $cal(M)$
#let cl = $cal(L)$
#let cb = $cal(B)$
#let iff = $ <==> $
#let du = $dif u$
#let ds = $dif s$
#let sp = "sp"
#let RC = "RC"
#let Fr = $cal(F r)$
#let SL = $cal(S L)$
#let GL = $cal(G L)$
#let OS = $cal(O S)$
#let Tr = "Tr"
#let notin = $in.not$
#let cm = $cal(M)$
#let cb = $cal(B)$
#let normm(a) = $interleave #a interleave$
#let dis(a) = text(size :8pt)[$display(#a)$]
#let blockdiag = "blockdiag"
#let Sum(a,b) = $dis(sum_(#a)^(#b))$


= Produits scalaires usuels

== Produit scalaire canonique de $cm_(n,p)(RR)$

#prop[][
Soit $A, B in cm_(n,p)(RR)$.

Le produit scalaire canonique de $A$ par $B$ est défini par :
$ scal(A,B) = sum_(i=1)^n sum_(j=1)^p a_(i,j) b_(i,j) = tr(A^tack.b B). $
]

#remarque[][
  Si $A, B$ et $C$ sont des matrices de tailles adéquates, on a :
  $ scal(A B, C) = scal(B, A^tack.b C) = scal(A, C B^tack.b). $
]
#remarque[][
Si $p=1$, on travaille avec des vecteurs colonnes. 

Soit $X = mat(x_1; dots.v; x_n)$ et $Y = mat(y_1; dots.v; y_n)$, comme on assimile $cm_(n,1)(RR)$ à $RR^n$ :
$ scal(X, Y) = sum_(i=1)^n x_i y_i = tr(X^tack.b Y) = X^tack.b Y. $

]
== Produit scalaire intégral

#prop[][
  Soit $f, g in C^0([0,1], RR)$. L'application suivante est un produit scalaire :
  $ scal(f,g) = integral_0^1 f(t) g(t) dt. $
]
#prop[][
  De même, si $theta in C^0([0,1], RR_+^ast)$, l'application suivante est également un produit scalaire :
  $ scal(f,g) = integral_0^1 f(t) g(t) theta(t) dt. $
]

== Produit scalaire sur $RR[X]$

#prop[][
Sur l'espace vectoriel des polynômes à coefficients réels $RR[X]$, on peut définir un produit scalaire par :
$ scal(P,Q) = integral_0^1 P(t) Q(t) dt. $
]




= Orthogonalité et projection orthogonale

Soit $E$ un espace préhilbertien, muni d'un produit scalaire $scal(.,.)$.
== Généralités
#def[Orthogonal et orthogonal d'une partie][
- Soit $A in cal(P)(E)$, on note $A^perp$ l'orthogonal de $A$ défini par :
  $ A^perp = {x in E | forall a in A, scal(x,a) = 0}. $
- Soit $(A, B) in (cal(P)(E))^2$, $A perp B$ signifie que pour tout $x in A$ et pour tout $y in B$, on a $scal(x,y)=0$.
  Cela est équivalent à $A subset B^perp$ ou $B subset A^perp$, c'est-à-dire :

$ A perp B <==> forall x in A, quad forall y in B, quad scal(x,y) = 0  <==> A subset B^perp "ou" B subset A^perp. $

]