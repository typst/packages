#import "@preview/formal:0.2.0": accent-color, formal-text, marginalia, note

#show: formal-text.with(
  authors: [J. Willard Gibbs],
  date: [October 1898],
)

= Lecture: Equilibrium of Heterogeneous Substances

A system is in thermodynamic equilibrium when no spontaneous change can occur: nothing
inside wants to rearrange, and nothing outside is driving it.

#marginalia(title: [Key idea])[
  Equilibrium means the appropriate potential $A$ is at a minimum under the imposed
  constraints ($A = U$, $F$, or $G$ depending on what is fixed). Two things to keep
  in mind:
  - The minimum must be _global_, not just a local stationary point.
  - Different subsystems of the same body share the same $T$, $p$, and $mu_j$ at
    equilibrium.
]

== Fundamental equation

=== Total differential
A body with variable composition has energy $U = U(S, V, m_1, dots, m_n)$. Any
small reversible change satisfies

$
  dif U = T dif S - p dif V + sum_(j=1)^n mu_j dif m_j
$ <fundamental>

where $T$ is temperature, $p$ pressure, and $mu_j$ the chemical potential of component
$j$. Each term pairs an intensive variable with the differential of its conjugate
extensive variable.

#note(title: [Water and steam])[
  Liquid water and steam in a sealed vessel. At equilibrium $T$, $p$, and $mu$ are
  equal in both phases. Transferring a small mass from liquid to vapor leaves the total
  energy unchanged to first order --- that is exactly what @fundamental encodes.
]

#marginalia(title: [Reading @fundamental])[
  Each term is intensive $times$ $dif$(extensive): $T dif S$, $p dif V$,
  $mu_j dif m_j$. Think of the intensive quantity as a "force" and the extensive
  differential as the conjugate "displacement". This structure recurs throughout
  thermodynamics.
]

=== Chemical potential
$mu_j$ measures the tendency of component $j$ to move between phases. If $mu_j$ is
higher in phase A than in phase B, matter flows from A to B until the potentials
equalize @clausius1865. This single condition governs solubility limits, vapor
composition, and the direction of every diffusive process.

== Thermodynamic potentials

#marginalia({
  import "@preview/lilaq:0.6.0" as lq
  let a(x) = calc.pow(x - 0.6, 2)
  let xs = lq.linspace(0, 1, num: 100)
  let ys = xs.map(a)
  lq.diagram(
    width: 100%,
    height: 3cm,
    xlim: (0, 1),
    ylim: (-0.1, 0.4),
    fill: none,
    grid: none,
    xlabel: [Extent of reaction, $xi$],
    ylabel: [Potential $A$],
    xaxis: (ticks: ((0, [0]),), subticks: none, mirror: false),
    yaxis: (ticks: none, subticks: none, mirror: false),

    lq.plot(xs, ys, stroke: accent-color, mark: none),
    lq.place(0.6, -0.05, [$Delta A = 0$]),
  )
})

=== Legendre transforms
In practice we control temperature, not entropy. We therefore work with transformed
potentials. Write $A$ for the potential appropriate to the given constraints.
At fixed $T, V$: $A = F = U - T S$. At fixed $T, p$: $A = G = U - T S + p V$.
Equilibrium is always a minimum of $A$.

#table(
  columns: 4,

  table.header[Potential][Natural variables][Eq. condition][Typical context],
  [Internal energy $U$], [$S, V, m_j$], [Minimum at constant $S, V$], [Isolated systems],
  [Helmholtz $F$], [$T, V, m_j$], [Minimum at constant $T, V$], [Sealed vessels],
  [Gibbs $G$], [$T, p, m_j$], [Minimum at constant $T, p$], [Open-atmosphere],
)

#marginalia(title: [Common mistake])[
  The default choice is $G$, but that is only correct when $p$ is fixed. A sealed
  rigid vessel fixes $V$ --- use $F$. Choosing the wrong potential yields equilibrium
  conditions expressed in the wrong variables, which complicates rather than clarifies.
]

=== Stability conditions
A stationary point of $A$ is necessary but not sufficient --- we need a minimum. This
requires positive heat capacity at constant volume, positive isothermal compressibility,
and analogous inequalities for each chemical degree of freedom @maxwell1871. Where
these fail lies the _spinodal curve_: inside it a single homogeneous phase cannot
persist.

== Phase rule

=== Degrees of freedom
For $n$ components and $r$ coexisting phases the phase rule is $f = n - r + 2$. It
counts the independent intensive variables that remain after imposing equal $T$, $p$,
and $mu_j$ across every phase. The rule assumes only $p V$ work and that every
component is present in every phase; additional effects require extra constraints.

=== One-component systems
Pure water has $n = 1$. One phase gives $f = 2$; two phases in coexistence give $f = 1$,
so fixing temperature determines the boiling pressure; at the triple point $f = 0$ and
no variable is free.

#marginalia(
  v(-2cm),
  bibliography(title: none, "refs.bib"),
)
