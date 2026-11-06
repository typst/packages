= Equazioni matematiche <cap:math>

La matematica si scrive tra simboli di dollaro. Senza spazi interni la formula è _inline_, cioè nel testo; con uno spazio dopo
il primo `$` e prima dell'ultimo diventa un _blocco_ centrato.

== Formule inline

#lorem(20) Ad esempio $x^2 + y^2 = r^2$ oppure $sum_(i=1)^n i = (n(n+1))/2$, con lettere greche come $alpha, beta, theta$,
vettori in grassetto come $bold(x) in RR^d$ e insiemi come $cal(V) subset.eq NN$. #lorem(20)

== Equazioni in blocco <sec:blocchi>

Una singola equazione in blocco si scrive così:

$ integral_(-infinity)^(infinity) e^(-x^2) dif x = sqrt(pi) $

#lorem(30)

Per allineare più righe si usa `&` nel punto di allineamento e `\` per andare a capo:

$
  f(x) &= (x + 1)^2 \
       &= x^2 + 2x + 1 \
       &>= 0 quad "per ogni" x in RR.
$

Il testo normale dentro una formula va tra virgolette (`"per ogni"`). Matrici, frazioni e funzioni a tratti sono
altrettanto semplici:

$ bold(A) = mat(a_11, a_12; a_21, a_22), quad det(bold(A)) = a_11 a_22 - a_12 a_21 $

$ sigma(x) = cases(
    0 & "se" x < 0,
    x & "se" 0 <= x <= 1,
    1 & "altrimenti"
  ) $

#lorem(40)
