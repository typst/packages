#import "@preview/physica:0.9.5": *
#import "@local/ergo:0.1.0": *
#show: ergo-init.with(colors: "gruvbox_dark", headers: "sidebar")

#set page(
  width: 18cm,
  height: 21.7cm,
  margin: 1em
)


We now wish to use the Euler-Lagrange equation to solve classical mechanics problems.
To do this, we want to find some function $L(t, x, dot(x))$ such that evaluating the Euler-Lagrange equation implies Newton's Second Law for a particle subject to conservative forces:
$
  dv(, t) (m dot(x)) = -dv(U, x).
$
Comparing with the form of the Euler-Lagrange Equation, we see we must have
$
  pdv(L, dot(x)) = m dot(x); quad pdv(L, x) = -dv(U, x).
$
Solving the first equation by separation of variables gives
$
  L = 1 / 2 m dot(x)^2 + g(t, x).
$
Now since $U$ is only a function of $x$, we need not consider $t$ dependence in a solution for our second PDE, meaning we can let $g$ be a function of $x$ alone.
From here we deduce
$
  pdv(g, x) = -dv(U, x) => g(x) = -U(x),
$
implying one solution to our system of PDEs is simply
$
  L = T - U.
$
This is called the *Lagrangian* of our system, and it gives us a powerful new formulation of mechanics.
Importantly, because we did not consider the PDE solution in full generality, it is not unique in its implication of Newton's Second Law.

#defn[Action and Least Action Principle][
  Given a mechanical system described by $N$ dynamical generalized coordinates $q_k (t)$, with $k = 1, 2, dots, N$, define its *action* by
  #eqbox[
    $
      S[q_k (t)] = integral_(t_a)^(t_b) dd(t) L(t, q_1, q_2, dots, dot(q)_1, dot(q)_2, dots).
    $
  ]
  Here, we assume the particle begins at some position $(q_1, q_2, dots)_a$ at time $t_a$ and ends at position $(q_1, q_2, dots)_b$ at time $t_b$.
  Now the *least action principle* states that, for trajectories $q_k (t)$ where $S$ is stationary, i.e.,
  $
    delta S = delta integral_(t_a)^(t_b) L(t, q_k dot(q)_k) dd(t) = 0
  $
  holds, then the $q_k (t)$'s satisfy the equations of motions for a system with these boundary conditions.
]

