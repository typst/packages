#import "../lib.typ": *

#show: doc.with(
	lang: "fr",

  title: ("Chapitre I", "Polynômes d'endomorphismes"),
  authors: (),
  style : "numbered",

  title-page: false,
  outline: false,
)



#let card = "card"
#let ah = $arrow.r.hook$
#let Inter = $inter.big$
#let Union = $union.big$ 
#let Id = "Id"
#let cb = $cal(B)$
#let Mat = "Mat"
#let Vect = "Vect"
#let Ann = $"Ann"$
#let diag = "diag"


Dans tout ce chapitre $E$ désigne un $KK$ espace vectoriel.

#def[Polynôme d'endomorphisme et de matrice][
  
Soit $display(P = sum_(k=0)^n a_k X^k) in KK_n [X]$, $E$ un $KK$-espace vectoriel,  $f in cal(L)(E)$ et $A in cal(M)_n (KK)$, on note :  $ P(f) = sum_(k=0)^n a_k f^k  "      et      " P(A)= sum_(k=0)^n a_k A^k, $

avec $A^0 = Id$  et $A^0 = I_n$.
]



#remarque[][ 
Même si $A = 0_n$ ( resp. $f = 0_(cal(L)(E))$), on a $A^0 = I_n$ (resp. $f^0 = Id$).
]
#prop[Règles de calcul][


Soit $f in cal(L)(E)$, $A in cal(M)_n (KK)$ et $(P,Q) in KK[X]$.
- #block[
Supposons que $E$ est de dimension finie et notons $cb$ une des ses bases, on a :
$ Mat_cb (P(f)) = P(Mat_cb (f)). $

#h(100%)  
]
- #block[
Soit $M in cal(G L)_n (KK)$, on a :
$ P(M A M^(-1)) = M P(A) M^(-1). $


 #h(100%) 
]
- #block[
Soit $lambda in KK$, on a :
$ (lambda P + Q)(f) = lambda P(f) + Q(f) "    et    " (lambda P + Q)(A) = lambda P(A) + Q(A). $ 

  #h(100%)
]
- #block[
On a :
$ (P Q)(f) = P(f) Q(f) "      et      "(P Q)(A) = P(A) Q(A). $

  #h(100%)
]
- #block[
Soit $k in NN^*$ et $(A_(i,j))_((i,j) in [|1,k|]^2) in (cal(M)_n (KK))^((k(k+1))/2)$, on a :
$ P(mat(A_(1,1), A_(1,2),dots,A_(1,k); 0, dots.down, dots.down, dots.v; dots.v, dots.down, dots.down,A_(k-1,k) ; 0, dots,0, A_(k,k))) = mat(P(A_(1,1)), A_(1,2),dots,A_(1,k); 0, dots.down, dots.down, dots.v; dots.v, dots.down, dots.down,A_(k-1,k) ; 0, dots,0, P(A_(k,k))). $

En particulier $P( "diag"(A_(1,1),dots,A_(k,k)))) = "diag"(P(A_(1,1)),dots,P(A_(k,k)))$.
  #h(100%) 
 ]
- #block[
Soit $(f,g) in cal(L)(E)^2$, tel que $f g = g f$, on a :
$ P(f) Q(g) = Q(g) P(f). $
#h(100%)
 ]

]

#demo[
 
- #block[
Soit $f in cal(L)(E)$, $lambda in KK$ et $k in NN$.

Le résultat tombe en appliquant les propriétés :
$ Mat_cb (f^k) = (Mat_cb (f))^k, space Mat_cb (lambda f + g) = lambda Mat_cb (f) + Mat_cb (g)  $

à chaque monôme du polynôme.

  #h(100%)
]

- #block[
Soit $k in NN$.

Le résultat tombe par combinaison linéaire et en appliquant la propriété :
$ (M A M^(-1))^k = M A^k M^(-1)  $

à chaque monôme du polynôme.

#h(100%)
  
]
- Cette propriété est patente.

- #block[
Notons : 
$ P = sum_(k=0)^(+oo) a_k X^k "        et        " Q = sum_(k=0)^(+oo) b_k X^k. $

On a : 
$ P(f) Q(f) & = (sum_(i=0)^(+oo) a_i f^i) (sum_(j=0)^(+oo) b_j f^j)
\ & = sum_(i + j =0)^(+oo) a_i b_j f^(i+j)
\ & = sum_(n = 0)^(+oo) (sum_(i + j = n)^(+oo) a_i b_j) f^n
\ & = P Q (f).
$
#h(100%)  
]
- #block[
Soit $(n,k) in NN^2$ et $(a_1,dots,a_n) in KK^n$.

Comme $"diag"(a_1,dots,a_n)^k = "diag"(a_1^k,dots,a_n^k)$, le résultat est patent par combinaison linéaire (idem pour les matrices triangulaires).

  #h(100%)
]
- #block[
Montrons par récurrence que, pour tout $n in NN$, $P(n)$ :" $ forall (p,q) in NN$, $p+q =n$, $f^p g^q = g^q f^p$" est vraie.

#underline[Initialisation] : $P(0)$ est évidemment vraie.

#underline[Hérédité :] Soit $n in NN$. On suppose que $P(0), dots, P(n)$ sont vraies.

Soit $(p,q) in NN$, tel que $p+q = n+1$.

-  Si $p=0$ ou $q=0$, alors le résultat est trivial.

- #block[Si $p=1$, alors $q=n$ et :
$
f g^n &= f g g^(n-1)
\ & = g f g^(n-1)
\ & = g g^(n-1) \ & = g^n f^n.
$
d'après $P(n)$.
#h(100%)
]
- Sinon, on a :
$ 
f^p g^q &= f f^(p-1) g^q
\ & = f g^q f^(p-1) "  d'après "P(n),
\ & = g^ q f f^(p-1) "  d'après "P(q+1),
\ & = g^q f^p.
$
Donc la propriété $P(n+1)$ est vraie.

Il vient en reprenant les notations précédentes :
$
P(f) Q(g)& =(sum_(i=0)^(+oo) a_i f^i)(sum_(j=0)^(+oo) b_j g^j) \ & = sum_(i,j = 0)^(+oo) a_i  f^i b_j g^j
\ & = sum_(i,j = 0)^(+oo)  b_j g^j a_i f^i 
\ & = (sum_(j=0)^(+oo) b_j g^j)(sum_(i=0)^(+oo) a_i f^i)
\ & = Q(g) P(f) .


$
D'où le résultat.
]


]
#def[][
Soit $f in cal(L)(E), A in cal(M)_n (KK)$..

On note :
$ KK[f] &= {P(f) backslash P in KK[X]} = Vect((f^k)_(k in NN)),
\ KK[A] &= {P(A) backslash P in KK[X]} = Vect((A^k)_(k in NN)).
$
De plus, pour $n in NN$, on note :
$ KK_n [f] = {P(f) backslash P in KK[X]} = Vect(I_d, f, dots, f^n), \ KK_n [A] = {P(A) backslash P in KK[X]} = Vect(I_n, A, dots, A^n).
$
  
]

#def[Polynômes annulateurs][
Soit $f in cal(L)(E)$ et $A in cal(M)_n (KK)$.

On définit l'ensemble des polynômes annulateurs de $f$ par :
$ Ann(f) = {P in KK[X] backslash P(f) = 0_(cal(L)(E))}. $

Del la même manière, on définit l'ensemble des polynômes annulateurs de $A$ par :
$ Ann(A) = {P in KK[X] backslash P(A) = 0_n}. $
  
]

#exemple[][
Soit $n in NN$, $(lambda_1,dots,lambda_n) in KK^k$ et $A = "diag"(lambda_1,dots,lambda_n)$.

On a :$ P(A) = P(diag(lambda_1,dots,lambda_n)) = diag(P(lambda_1),dots, P(lambda_n)).
$
Alors :
$ Ann(A) = {P in KK[X] backslash forall i in [|1,n|], P(lambda_i) = 0}. $
] 
