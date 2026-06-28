// chapter1.typ — Introduction chapter
// Mirrors chapter1.tex from mitthesis package

= Introduction

#lorem(60) Postremo aliquos futuros suspicor, qui me ad alias litteras vocent, genus
hoc scribendi, etsi sit elegans, personae tamen et dignitatis esse
negent @DKE1969 @ww1920 @kirk2288a @churchill1948 @gibbs1863.

#lorem(70)

== A section discussing the first issue: $J \/ psi$

We begin with some ideas from the literature @Fong2015 @sharpe1.

$ partial/(partial t) [rho (e + |arrow(u)|^2 / 2)]
  + nabla dot [rho (h + |arrow(u)|^2 / 2) arrow(u)]
  = -nabla dot arrow(q) + rho arrow(u) dot arrow(g)
    + partial/(partial x_j) (d_(j i) u_i) $ <eqn:energy>

#lorem(65)

#lorem(65) And more citations @sharpe1 @GSL.  Then we write some more and include
our citations @Swaminathan2017IDABRO @dlmf @amsmath.  The configuration is shown
in @fig:golden2.

#figure(
  {
    set text(size: 10.95pt)
    grid(
      columns: (1fr, 1fr),
      gutter: 0.5em,
      align: top,
      {
        rect(width: 100%, height: 5.5cm, fill: luma(210), stroke: 0.5pt)
        v(5pt)
        align(center)[_(a)_ Postremo aliquos futuros suspicor, qui me ad alias
          litteras vocent, genus hoc scribendi.]
      },
      {
        rect(width: 100%, height: 5.5cm, fill: luma(210), stroke: 0.5pt)
        v(5pt)
        align(center)[_(b)_ Second subfigure.]
      },
    )
  },
  caption: [A figure with two subfigures.],
  kind: image,
) <fig:golden2>

#lorem(65)

=== Subsection eqn. (1.2) <sec:subsection-eqn>

#lorem(65)

#lorem(65)

==== A subsubsection

#lorem(65)

// ─── Matrix equation (eq. 1.2) ───────────────────────────────────────────────
$
L(bold(A)) = mat(
  phi / (phi_1\, epsilon_1),          0,                                       dots.c, dots.c, dots.c, 0;
  (phi k_(2\,1)) / (phi_2\, epsilon_1), phi / (phi_2\, epsilon_2),             0,      dots.c, dots.c, 0;
  (phi k_(3\,1)) / (phi_3\, epsilon_1), (phi k_(3\,2)) / (phi_3\, epsilon_2), phi / (phi_3\, epsilon_3), 0, dots.c, 0;
  dots.v,                              dots.v,                                  ,       dots.down, ,      dots.v;
  (phi k_(n-1\,1)) / (phi_(n-1)\, epsilon_1), (phi k_(n-1\,2)) / (phi_(n-1)\, epsilon_2), dots.c, (phi k_(n-1\,n-2)) / (phi_(n-1)\, epsilon_(n-2)), phi / (phi_(n-1)\, epsilon_(n-1)), 0;
  (phi k_(n\,1)) / (phi_n\, epsilon_1),       (phi k_(n\,2)) / (phi_n\, epsilon_2),       dots.c, dots.c, (phi k_(n\,n-1)) / (phi_n\, epsilon_(n-1)), phi / (phi_n\, epsilon_n);
  delim: "("
)
$ <eqn:WT1>

== Description of our paradigm <sec:stratified-flow>

#lorem(65) No dissertation is complete without
footnotes.#footnote[First footnote. $a_h = F_m$ See @sec:stratified-flow.]#footnote[Another
interesting detail.]#footnote[And another really important idea to have in
mind @reynolds1958 @clauser56 @lienhard2020 @johnson1980 @johnson1965 @mpl.]

#figure(
  rect(width: 6.67cm, height: 5cm, fill: luma(210), stroke: 0.5pt),
  caption: [Caption text @GSL.],
  kind: image,
) <example-image-b>

=== Conversion to a metaheuristic

#lorem(65)

#lorem(65) This concept is discussed further in @sec:stratified-flow, and
@euler1740 @fourier1822.

== Other generalizations

=== The most general case

#lorem(65) And another citation, so that our sources will be
unambiguous @montijano2014.

// ─── Chemical equations (gathered) ───────────────────────────────────────────
// Mirrors \ce{...} from mhchem package, typeset manually in Typst math.
$ x space "Na(NH"_4")HPO"_4 -->^triangle.t ("NaPO"_3)_x + x space "NH"_3 arrow.t + x space "H"_2 "O" $

$ limits(""^234)_90 "Th" -> limits(""^0)_(-1) beta + limits(""^234)_91 "Pa" $

$ "SO"_4^(2-) + "Ba"^(2+) -> "BaSO"_4 arrow.b $

$ "Zn"^(2+)
  arrows.lr^("+ 2OH"^-)_("+ 2H"^+)
  underbrace("Zn(OH)"_2 arrow.b, "amphoteric hydroxide")
  arrows.lr^("+ 2OH"^-)_("+ 2H"^+)
  underbrace(["Zn(OH)"_4]^(2-), "tetrahydroxozincate") $

These examples of chemical formulæ are copied directly from the documentation of
the `mhchem` package, which was used to typeset them.

== Baroclinic generation of vorticity <sec:baroclinic>

Substitution of the particle acceleration and application of Stokes' theorem
leads to the _Kelvin–Bjerknes circulation theorem_, for $rho != op("fn")(p)$:

// ─── Circulation theorem (align, eqs. 1.3–1.6) ───────────────────────────────
$
  (d Gamma)/(d t) &= d / (d t) integral_(cal(C)) bold(u) dot d bold(r) \
  &= integral_(cal(C)) (D bold(u))/(D t) dot d bold(r)
     + underbrace(integral_(cal(C)) bold(u) dot d((d bold(r))/(d t)), = 0) \
  &= integral.double_(cal(S)) nabla times (D bold(u))/(D t) dot d bold(A) \
  &= integral.double_(cal(S)) nabla p times nabla (1/rho) dot d bold(A)
$

Baroclinic generation of vorticity accounts for the sea breeze and various other
atmospheric currents in which temperature, rather than pressure, creates density
gradients.  Further, this phenomenon accounts for ocean currents in straits joining
more and less saline seas, with surface currents flowing from the fresher to the
saltier water and with bottom currents going oppositely.

// ─── Table 1.1: error function values ────────────────────────────────────────
#figure(
  caption: [The error function and complementary error function],
  kind: table,
)[
  #set text(size: 10.95pt)
  #table(
    columns: 6,
    stroke: none,
    align: (center,) * 6,
    inset: (x: 6pt, y: 3pt),
    table.hline(stroke: 1.5pt),
    table.header(
      $x$, $op("erf")(x)$, $op("erfc")(x)$,
      $x$, $op("erf")(x)$, $op("erfc")(x)$,
    ),
    table.hline(stroke: 0.75pt),
    [0.00],[0.00000],[1.00000],  [1.10],[0.88021],[0.11980],
    [0.05],[0.05637],[0.94363],  [1.20],[0.91031],[0.08969],
    [0.10],[0.11246],[0.88754],  [1.30],[0.93401],[0.06599],
    [0.15],[0.16800],[0.83200],  [1.40],[0.95229],[0.04771],
    [0.20],[0.22270],[0.77730],  [1.50],[0.96611],[0.03389],
    [0.30],[0.32863],[0.67137],  [1.60],[0.97635],[0.02365],
    [0.40],[0.42839],[0.57161],  [1.70],[0.98379],[0.01621],
    [0.50],[0.52050],[0.47950],  [1.80],[0.98909],[0.01091],
    [0.60],[0.60386],[0.39614],  [1.82],[0.99000],[0.01000],
    [0.70],[0.67780],[0.32220],  [1.90],[0.99279],[0.00721],
    [0.80],[0.74210],[0.25790],  [2.00],[0.99532],[0.00468],
    [0.90],[0.79691],[0.20309],  [2.50],[0.99959],[0.00041],
    [1.00],[0.84270],[0.15730],  [3.00],[0.99998],[0.00002],
    table.hline(stroke: 1.5pt),
  )
] <tab:1>

== Summary

#lorem(65)

#lorem(65)

// ─── Nomenclature (two-column) ────────────────────────────────────────────────
// Mirrors \begin{nomenclature*}[2em][Nomenclature for Chapter 1][section]
== Nomenclature for Chapter 1 <sec:nomenclature>

#columns(2)[
  _Roman letters_

  #table(
    columns: (2em, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 1.5pt),
    align: (left, left),
    [$cal(C)$],    [material curve],
    [$bold(r)$],   [material position [m]],
    [$bold(u)$],   [velocity [m s#super[−1]]],
  )

  #colbreak()

  _Greek letters_

  #table(
    columns: (2em, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 1.5pt),
    align: (left, left),
    [$Gamma$],     [circulation [m#super[2] s#super[−1]]],
    [$rho$],       [mass density [kg m#super[−3]]],
    [$omega$],     [vorticity [s#super[−1]]],
  )
]
