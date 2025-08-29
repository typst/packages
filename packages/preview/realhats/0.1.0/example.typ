#set page("a5", margin: (2em))
#import "@preview/physica:0.8.1": hbar, bra, ket, braket
#import "@local/realhats:0.1.0": hat, realhats-list

#let grace-example(hat) = [
  The transition probability between two states is related to the off-diagonal matrix elements of the perturbation Hamiltonian. Since our perturbation Hamiltonian is proportial to the identity operator, there are no off-diagonal matrix elements, making the transition probability from an eigenstate of $hat(H)_0$ to some other state $ket(m^((0)))$ zero.

  Using the interaction picture, the time evolution for a state is given by 
  $
    i hbar d / (d t) ket(Psi)_I 
    &= i hbar d / (d t) (hat(U)_0^dagger ket(Psi)_S) \
    &= i hbar i / hbar hat(H)_0 hat(U)_0^dagger ket(Psi)_S + hat(U)_0^dagger hat(H) ket(Psi)_S \
    &= (-hat(H)_0 + hat(U)_0^dagger hat(H) hat(U)_0) hat(U)_0^dagger ket(Psi)_S \
    &= hat(U)_0^dagger (-hat(H)_0 + hat(H)) hat(U)_0 ket(Psi)_i \
    &= hat(U)_0^dagger hat(V) hat(U)_0 ket(Psi)_I
  $

  where we use the following definitions:
  $ ket(Psi)_I = hat(U)_0^dagger ket(Psi)_S, $
  $ hat(O)_I (t) = hat(U)_0^dagger (t, t_0) hat(O)_S hat(U)_0 (t, t_0) $
  $ hat(U)_0 = e^(- i(t - t_0) / hbar hat(H)_0) $

  #v(1em)
  #line(length: 100%)
  #v(1em)

  #show math.equation: set text(font: "TeX Gyre Bonum Math")
  #set text(font: "TeX Gyre Bonum")

  Just for fun:
  $
    (sqrt(hat(a)^2 + hat(b)^2) + sum_(n=1)^oo ((-1)^n / n!) ln((n^2 + hat(pi)) / e^hat(gamma)))
    / (integral_0^(hat(aleph)_9 + 42) x^(hat(alpha) - 1) (1 - hat(x))^(hat(beta) - 1) d x)
    + product_(k=1)^oo (1 - hat(Xi) / (k^2 hat(xi)))
  $
]

#grace-example(math.hat)

#pagebreak()

#grace-example(hat)