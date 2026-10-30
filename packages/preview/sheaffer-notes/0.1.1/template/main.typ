#import "@preview/commute:0.3.0": node, arr, commutative-diagram
#import "@preview/sheaffer-notes:0.1.1": *

#set document(title: [Sheaf Theory Notes], author: "Your Name")
#set text(lang: "en")

// ISO B5 portrait page, with a slightly wider inner margin for binding.
#set page(
  paper: "iso-b5",
  margin: (
    top: 20mm,
    bottom: 20mm,
    inside: 25mm,
    outside: 15mm
  ),
)

// Keep this as the final show or set rule in the document.
#show: style

// Example of a custom theorem-like environment built with `thm-env`.
#let observation = thm-env("Observation")

#title-page(
  subtitle: [Sheaf Theory],
  primary: [Lectures and Seminars],
  secondary: [Spring Semester 2026/27],
)

#outline(title: [Contents], depth: 3)
#pagebreak()

= Presheaves

#epigraph(attribution: [From the course syllabus])[
  Local data that agree on overlaps must glue into a global object. Sheaf
  theory makes this idea precise.
]

== Why sheaves

A sheaf is a way to systematically store data defined on open sets of a
topological space. At each point such data form a stalk, and global objects are
recovered from local ones by the gluing axiom. This construction appears in
topology, complex analysis, algebraic geometry, and category theory.

#wrappar(width: 50%)[A sheaf is a bundle whose fiber over a point $x$ is the
stalk at $x$.]
That is why many properties of a sheaf are checked on its stalks: local
information at a point is often simpler than global information.

== Definition of a presheaf

#definition(name: [Presheaf])[
  Let $X$ be a topological space. A *presheaf of sets* $scr(F)$ on $X$ assigns
  to every open $U subset X$ a set $scr(F)(U)$ and to every inclusion
  $V subset U$ a restriction map $rho_V^U colon scr(F)(U) -> scr(F)(V)$.
  Moreover,
  + $rho_U^U = "id"_(scr(F)(U))$;
  + if $W subset V subset U$, then $rho_W^U = rho_W^V compose rho_V^U$.
] <def-presheaf>

Elements of $scr(F)(U)$ are called *sections* over $U$. For a section $s in
scr(F)(U)$ and an open $V subset U$ we write $s|_V$ instead of $rho_V^U (s)$.

#definition(name: [Morphism of presheaves])[
  A morphism of presheaves $phi colon scr(F) -> scr(G)$ is a family of maps
  $phi_U colon scr(F)(U) -> scr(G)(U)$ compatible with restrictions:
  $
    rho_V^U (phi_U(s)) = phi_V (rho_V^U (s)),
    quad s in scr(F)(U),quad V subset U.
  $ <eq-compat>
]

Presheaves of sets on $X$, together with their morphisms, form the category
$op("PSh")(X)$. If the values of a presheaf lie in the category of abelian
groups, rings, or modules, one speaks respectively of presheaves of these
structures.

== Examples

#example(name: [Continuous functions])[
  For an open $U subset X$, let $scr(C)^0_X (U)$ be the set of continuous
  functions $U -> RR$. Restricting a function to a smaller open set gives a
  presheaf that is in fact a sheaf.
]

#example(name: [Constant presheaf])[
  Fix a set $A$ and set $scr(A)(U) = A$ for nonempty open $U$, and
  $scr(A)(emptyset) = {star}$. All restrictions are identity maps.
]

#example(name: [Bounded functions])[
  Let $scr(B)(U)$ be the set of bounded continuous functions $U -> RR$. This is
  a presheaf: the restriction of a bounded function is again bounded.
]

#remark[
  The presheaf $scr(B)$ from the last example is not a sheaf. On the line the
  function $x$ is bounded on every interval $(-n, n)$ but is not bounded on the
  union $RR = union_(n >= 1) (-n, n)$.
]

Examples of presheaves also include #inline-enum[
  + locally constant functions;
  + differential forms on a smooth manifold;
  + germs of holomorphic functions.
].

== First properties

#proposition(name: [Composition of morphisms])[
  The composition of morphisms of presheaves is again a morphism of presheaves,
  and identity maps give the identity morphism. Hence $op("PSh")(X)$ is a
  category.
]

#proof[
  Compatibility with restrictions is checked componentwise: for every open $U$
  the composition of maps on sections commutes with restrictions. The category
  axioms follow from associativity of composition of maps of sets.$qed$
]

#corollary[
  A morphism of presheaves is an isomorphism if and only if all of its
  components $phi_U$ are bijective.
]

= Sheaves

== The gluing axiom

#definition(name: [Sheaf])[
  A presheaf $scr(F)$ on $X$ is called a *sheaf* if for every open $U subset X$,
  every open cover $U = union_(i in I) U_i$, and every family of sections
  $s_i in scr(F)(U_i)$ satisfying
  $
    s_i |_(U_i inter U_j) = s_j |_(U_i inter U_j)
    quad (i, j in I)
  $ <eq-gluing>
  there exists a unique section $s in scr(F)(U)$ such that
  $s|_(U_i) = s_i$ for all $i in I$.
] <def-sheaf>

The uniqueness condition is called *locality*, and the existence condition is
called *gluing*. A presheaf satisfying only the uniqueness condition is called
*separated*.

#figure(
  align(center, box(width: 62mm, height: 34mm, {
    place(top + center, text(size: 0.85em)[$X$])
    place(center + horizon, dx: -7mm, circle(radius: 11mm, stroke: 0.7pt))
    place(center + horizon, dx: 7mm, circle(radius: 11mm, stroke: 0.7pt))
  })),
  caption: [An open cover $X = U_1 union U_2$: the data on $U_1$ and $U_2$
    must agree on the intersection],
) <fig-cover>

#theorem(name: [Sheaf criterion])[
  A presheaf $scr(F)$ is a sheaf if and only if for every open $U$ and every
  cover $U = union_(i in I) U_i$ the diagram (figure #ref(<fig-cover>, supplement: none))
  $
    scr(F)(U) -> product_(i in I) scr(F)(U_i)
    -> product_(i, j in I) scr(F)(U_i inter U_j)
  $ <eq-equalizer>
  is exact, that is, $scr(F)(U)$ is identified with the set of compatible
  families $(s_i)$.
] <thm-equalizer>

#proof[
  The first arrow sends a section $s$ to the family of its restrictions
  $(s|_(U_i))$. The two arrows in the second factor are the restrictions to
  $U_i inter U_j$ by the first and by the second index. Exactness means
  precisely that a compatible family has a unique preimage in $scr(F)(U)$.$qed$
]

#example(name: [The constant presheaf is not always a sheaf])[
  Let $X$ consist of two points with the discrete topology, and let $A$ be a
  two-element set. Consider the constant presheaf $scr(A)$.
]

#solution[
  The open sets $U_1 = {x_1}$ and $U_2 = {x_2}$ cover $X$. Take sections
  $s_1 = a$ and $s_2 = b$ with $a != b$. On the empty intersection the
  compatibility conditions hold automatically, but there is no global section
  restricting to $a$ and $b$ simultaneously. Hence $scr(A)$ is not a sheaf.
]

#remark[
  In the example above the problem is that the cover has disjoint pieces: the
  presheaf cannot glue independent data. The sheaf of locally constant
  functions is different: its value on each connected component can be chosen
  independently.
]

== Examples of sheaves

#example(name: [Sheaf of continuous functions])[
  The presheaf $scr(C)^0_X$ is a sheaf. If continuous functions agree on every
  element of a cover, they also agree on the union; if they are compatible on
  intersections, they can be glued into a continuous function.
]

#example(name: [Locally constant functions])[
  Let $scr(A)_X (U)$ be the set of locally constant functions $U -> A$, that is,
  functions constant in a neighborhood of every point. Restrictions give a
  sheaf; it is called the *constant sheaf* with stalk $A$.
]

#example(name: [Sheaf of sections of a bundle])[
  For a continuous map $p colon E -> X$, assign to an open $U$ the set of
  continuous sections $s colon U -> E$ with $p compose s = id_U$. This gives a
  sheaf, called the sheaf of sections of the bundle $p$.
]

#refs(<def-presheaf>, <def-sheaf>, <thm-equalizer>, <fig-cover>)
show how presheaves, sheaves, and the geometry of covers are related. A summary
of the differences is collected in table @tab-presheaf-sheaf.

#figure(
  table(
    columns: (1.2fr, 1fr, 1fr),
    [Property], [Presheaf], [Sheaf],
    [Data on open sets], [yes], [yes],
    [Restrictions], [yes], [yes],
    [Locality], [not required], [required],
    [Gluing], [not required], [required],
    [Stalks], [defined], [defined],
  ),
  caption: [Comparison of a presheaf and a sheaf],
) <tab-presheaf-sheaf>

= Abelian sheaves and stalks

== Abelian presheaves

#definition(name: [Abelian presheaf])[
  A presheaf $scr(F)$ is called *abelian* if every $scr(F) (U)$ is an abelian
  group and all restriction maps are group homomorphisms. Presheaves of modules
  over a sheaf of rings are defined similarly.
]

For abelian presheaves, kernels, images, and cokernels are defined pointwise:
for example, $(ker phi) (U) = ker(phi_U)$. For sheaves these constructions have
to be sheafified: the pointwise kernel of a morphism of sheaves is again a
sheaf, but the pointwise cokernel is not always.

#definition(name: [Exact sequence of sheaves])[
  A sequence of sheaves of abelian groups
  $
    0 -> scr(F) -> scr(G) -> scr(H) -> 0
  $
  is called *exact* if the induced sequence of groups is exact in every stalk.
]

== Stalks

#definition(name: [Stalk])[
  Let $scr(F)$ be a presheaf on $X$ and $x in X$. The *stalk* $scr(F)_x$ is
  defined as the direct limit
  $
    scr(F)_x = lim_(x in U) scr(F) (U)
  $
  over all open neighborhoods $U$ of $x$. Elements of the stalk are called
  *germs* of sections.
] <def-stalk>

In other words, a germ is an equivalence class of pairs $(U, s)$ with
$s in scr(F) (U)$, where two pairs are equivalent if their restrictions agree on
some smaller neighborhood of $x$. For a morphism $phi colon scr(F) -> scr(G)$,
the map on stalks $phi_x colon scr(F)_x -> scr(G)_x$ sends the germ $(U, s)$ to
the germ $(U, phi_U (s))$.

#lemma(name: [Isomorphism on stalks])[
  A morphism of sheaves $phi colon scr(F) -> scr(G)$ is an isomorphism if and
  only if for every point $x in X$ the map $phi_x colon scr(F)_x -> scr(G)_x$ is
  bijective.
] <lem-stalks>

#proof[
  If $phi$ is an isomorphism, the induced maps on stalks are invertible.
  Conversely, suppose all $phi_x$ are bijective. Then the kernel and cokernel of
  $phi$ have zero stalks. A sheaf with zero stalks is zero: a section whose
  germ is zero at every point is zero by locality. Therefore $phi$ is injective
  and surjective.$qed$
]

#example(name: [Germs of continuous functions])[
  The stalk of the sheaf $scr(C)^0_X$ at a point $x$ consists of germs of
  continuous functions at $x$. Two functions define the same germ if they agree
  in some neighborhood of $x$.
]

#example(name: [Stalk of the constant sheaf])[
  If $X$ is connected, the stalk of the constant sheaf $scr(A)_X$ at any point
  is isomorphic to $A$.
]

#observation[
  The stalk is a local object: it sees the behavior of the sheaf arbitrarily
  close to a point and does not detect global obstructions to gluing. That is
  precisely why a condition on stalks alone is not enough to compute global
  sections; this is the job of cohomology.
]

== Sheafification

#theorem(name: [Sheafification])[
  For every presheaf $scr(F)$ on $X$ there exist a sheaf $scr(F)^"sh"$ and a
  morphism $scr(F) -> scr(F)^"sh"$ such that for every sheaf $scr(G)$ and every
  morphism $scr(F) -> scr(G)$ there is a unique morphism
  $scr(F)^"sh" -> scr(G)$ making the diagram commute.
] <thm-sheafification>

#proof[
  One construction is to first identify the stalks and then consider sections
  that lift locally to $scr(F)$. The resulting presheaf $scr(F)^+$ is separated;
  applying the operation again gives a sheaf
  $scr(F)^"sh" = (scr(F)^+)^+$. The universal property is checked stalkwise, and
  uniqueness follows from lemma @lem-stalks.$qed$
]

#corollary[
  Sheafification preserves stalks: $(scr(F)^"sh")_x = scr(F)_x$ for all
  $x in X$. Moreover, sheafification is left adjoint to the forgetful functor
  from sheaves to presheaves.
]

#remark[
  If $scr(F)$ is already a sheaf, the canonical morphism
  $scr(F) -> scr(F)^"sh"$ is an isomorphism. In practice sheafification is often
  applied to cokernels and images of morphisms in order to stay in the category
  of sheaves.
]

= Maps and ringed spaces

== Direct and inverse image

#definition(name: [Direct image])[
  Let $f colon X -> Y$ be a continuous map and $scr(F)$ a sheaf on $X$. The
  *direct image* $f_* scr(F)$ is the sheaf on $Y$ given by
  $
    (f_* scr(F))(V) = scr(F)(f^(-1) (V))
  $
  for open $V subset Y$.
]

#definition(name: [Inverse image])[
  Let $scr(G)$ be a sheaf on $Y$. The *inverse image* $f^(-1) scr(G)$ is the
  sheafification of the presheaf
  $
    U |-> lim_(f (U) subset V) scr(G)(V)
  $
  on $X$.
]

#proposition(name: [Adjunction])[
  For a continuous $f colon X -> Y$, a sheaf $scr(G)$ on $Y$, and a sheaf
  $scr(F)$ on $X$, there is a natural bijection
  $
    op("Hom")_X (f^(-1) scr(G), scr(F))
    tilde.equiv op("Hom")_Y (scr(G), f_* scr(F)).
  $
]

#remark[
  The direct image is covariant and the inverse image is contravariant in maps
  of spaces. In particular, for the inclusion of an open set $j colon U -> X$,
  the inverse image $j^(-1) scr(F)$ is the restriction of the sheaf to $U$.
]

== Ringed spaces

#definition(name: [Ringed space])[
  A *ringed space* is a pair $(X, scr(O)_X)$, where $X$ is a topological space
  and $scr(O)_X$ is a sheaf of rings on $X$. A morphism of ringed spaces
  $(f, f^"#") colon (X, scr(O)_X) -> (Y, scr(O)_Y)$ consists of a continuous map
  $f$ and a morphism of sheaves of rings
  $f^"#" colon f^(-1) scr(O)_Y -> scr(O)_X$.
]

#definition(name: [Module over the structure sheaf])[
  An $scr(O)_X$-module is a sheaf of abelian groups $scr(M)$ in which every
  $scr(M) (U)$ is equipped with the structure of an $scr(O)_X (U)$-module
  compatible with restrictions.
]

#example(name: [Structure sheaf])[
  On a topological space $X$, the sheaf $scr(C)^0_X$ of continuous real-valued
  functions is a sheaf of rings. The pair $(X, scr(C)^0_X)$ is a ringed space.
  If $X$ is a smooth manifold, the sheaf $scr(C)^infinity_X$ of smooth functions
  plays an analogous role.
]

#definition(name: [Skyscraper])[
  Let $x in X$ and let $A$ be an abelian group. The *skyscraper* $i_(x,*) A$ is
  the sheaf on $X$ for which
  $
    (i_(x,*) A) (U) = cases(
      A &quad"if" x in U,
      0 &quad"otherwise" ,
    )
  $
  with the obvious restriction maps.
]

#remark[
  If the point $x$ is closed, the skyscraper $i_(x,*) A$ is a flabby sheaf:
  restriction to a smaller open set is surjective. This makes it a convenient
  example for computing cohomology.
]

= Sheaf cohomology

Sheaf cohomology measures how far global sections of a sheaf are from being
recovered from local data. Formally, it is the derived functors of the global
sections functor.

== Derived functors

#definition(name: [Global sections])[
  For a sheaf of abelian groups $scr(F)$ on $X$, its *global sections* are
  $
    Gamma(X, scr(F)) = scr(F)(X).
  $
  The functor $Gamma(X, -)$ sends a sheaf to an abelian group and is left exact:
  from an exact sequence $0 -> scr(F) -> scr(G) -> scr(H)$ one obtains the exact
  sequence
  $0 -> Gamma(X, scr(F)) -> Gamma(X, scr(G)) -> Gamma(X, scr(H))$.
] <def-global-sections>

#remark[
  Right exactness fails in general: a surjective morphism of sheaves need not
  be surjective on global sections. A typical example is the exponential
  sequence on the circle.
]

#definition(name: [Sheaf cohomology])[
  Let $scr(F)$ be a sheaf of abelian groups on $X$. Choose an injective
  resolution
  $
    0 -> scr(F) -> scr(I)^0 -> scr(I)^1 -> scr(I)^2 -> dots
  $
  in the category of sheaves of abelian groups. *Cohomology* is defined as
  $
    H^i (X, scr(F)) = R^i Gamma(X, scr(F))
    = H^i (Gamma(X, scr(I)^bullet)).
  $
] <def-cohomology>

The category of sheaves of abelian groups has enough injectives, so an
injective resolution exists, and the result does not depend on its choice up to
canonical isomorphism. In particular, $H^0 (X, scr(F)) = Gamma(X, scr(F))$.

#pagebreak()
#theorem(name: [Long exact sequence])[
  Every short exact sequence of sheaves of abelian groups
  $
    0 -> scr(F) -> scr(G) -> scr(H) -> 0
  $
  induces a long exact sequence
  #align(center, commutative-diagram(
    node-padding: (30pt, 30pt),
    node((0, 0), [$0$]),
    node((0, 1), [$H^0 (X, scr(F))$]),
    node((0, 2), [$H^0 (X, scr(G))$]),
    node((0, 3), [$H^0 (X, scr(H))$]),
    node((1, 1), [$H^1 (X, scr(F))$]),
    node((1, 2), [$H^1 (X, scr(G))$]),
    node((1, 3), [$H^1 (X, scr(H))$]),
    node((1, 4), [$...$]),
    arr((0, 0), (0, 1), []),
    arr((0, 1), (0, 2), []),
    arr((0, 2), (0, 3), []),
    arr((0, 3), (1, 1), []),
    arr((1, 1), (1, 2), []),
    arr((1, 2), (1, 3), []),
    arr((1, 3), (1, 4), []),
  ))
] <thm-les>

#proof[
  This is a standard property of derived functors: a short exact sequence of
  complexes yields a long exact sequence of cohomology. The connecting
  homomorphisms are constructed using the snake lemma.$qed$
]

== Flabby sheaves and computation

#definition(name: [Flabby sheaf])[
  A sheaf $scr(F)$ on $X$ is called *flabby* if for all open $V subset U$ the
  restriction map $scr(F) (U) -> scr(F)(V)$ is surjective.
]

#lemma(name: [Acyclicity of flabby sheaves])[
  If $scr(F)$ is a flabby sheaf on $X$, then $H^i (X, scr(F)) = 0$ for all
  $i > 0$.
] <lem-flasque>

#proof[
  Flabby sheaves form a class adapted to the global sections functor: every
  flabby sheaf is acyclic. This is proved by splitting short exact sequences of
  flabby sheaves and induction on the cohomological degree.$qed$
]

#corollary[
  To compute $H^i (X, scr(F))$ one may use any flabby resolution, for example the
  Godement resolution. In particular, if $scr(F)$ itself is flabby, then all
  higher cohomology vanishes.
]

#example(name: [Cohomology of a skyscraper])[
  Let $x in X$ be a closed point, $A$ an abelian group, and
  $scr(F) = i_(x,*) A$. Compute $H^i (X, scr(F))$.
]

#solution[
  The global sections of the skyscraper are $A$, so $H^0 (X, scr(F)) = A$. The
  sheaf $scr(F)$ is flabby; hence, by lemma @lem-flasque,
  $H^i (X, scr(F)) = 0$ for $i > 0$.
]

== Čech cohomology

#definition(name: [Čech cochains])[
  Let $cal(U) = {U_i}_(i in I)$ be an open cover of $X$, and let $scr(F)$ be a
  sheaf of abelian groups. *Čech cochains* of degree $p$ are
  $
    C^p (cal(U), scr(F))
    = product_(i_0 < dots < i_p) scr(F)(U_(i_0) inter dots inter U_(i_p)).
  $
  The differential $delta$ is given by the alternating sum of restrictions to
  $(p+1)$-fold intersections.
] <def-cech>

#theorem(name: [Comparison with sheaf cohomology])[
  If all finite intersections $U_(i_0) inter dots inter U_(i_p)$ are acyclic with
  respect to $scr(F)$, then the Čech cohomology of the cover $cal (U)$ agrees
  with sheaf cohomology:
  $
    H^p (cal(U), scr(F)) ≅ H^p (X, scr(F)).
  $ <eq-cech>
] <thm-cech>

#proof[
  In this case the Čech complex is a resolution of the sheaf $scr(F)$ adapted to
  the global sections functor. Comparison with any injective resolution gives a
  canonical isomorphism of cohomology.$qed$
]

#remark[
  The acyclicity condition on the cover holds automatically, for example, for a
  cover all of whose finite intersections are contractible, if $scr(F)$ is a
  locally constant sheaf. Without such conditions Čech cohomology may differ
  from sheaf cohomology.
]

#remark[
  For a smooth manifold $M$, the sheaf cohomology of the constant sheaf $RR$
  agrees with de Rham cohomology: the Poincaré lemma gives a resolution of the
  constant sheaf by differential forms.
]

A summary of the main properties of cohomology is given in table
@tab-cohomology.

#figure(
  table(
    columns: (1.3fr, 2fr),
    [Object], [Property],
    [$H^0 (X, scr(F))$], [global sections $scr(F) (X)$],
    [Short exact sequence], [long exact sequence @thm-les],
    [Flabby sheaf], [all higher cohomology vanishes],
    [Injective resolution], [can be used to compute $H^i$],
    [$H^1$], [measures the obstruction to lifting sections],
  ),
  caption: [Properties of sheaf cohomology],
) <tab-cohomology>

#refs(<def-cohomology>, <thm-les>, <lem-flasque>, <thm-cech>, <eq-cech>, <tab-cohomology>)
collect the main definitions and results of the section.

= Appendix: template features

== Lists and terms

The template supports ordinary bulleted and numbered lists with nesting:

- presheaf
  - separated presheaf
  - sheaf
- morphism
  - kernel
  - cokernel

+ Choose a cover of the space.
  + Check compatibility on intersections.
  + Apply the gluing axiom.
+ Pass to stalks.
  + Compute the germ at each point.
  + Compare the induced maps.

List of terms:

/ Sheaf: a presheaf with the locality and gluing axioms.
/ Stalk: the direct limit of sections over neighborhoods of a point.
/ Cohomology: the derived functors of global sections.

For multi-level conditions, `conditions` is used:

#conditions[
  + Let $scr(F)$ be a sheaf on $X$.
    + Then the stalks $scr(F)_x$ are defined at all points.
    + Morphisms of sheaves induce maps of stalks.
  + Let $0 -> scr(F) -> scr(G) -> scr(H) -> 0$ be an exact sequence.
    + Then a long exact sequence of cohomology arises.
]

== Code and quotes

Inline code: `#let stalk = scr(F)_x`.

Code block with highlighting:

```typ
#import "@preview/sheaffer-notes:0.1.1": *

#set document(title: [Sheaf Theory Notes], author: "Your Name")
#show: style

#definition(name: [Sheaf])[
  A presheaf with the gluing axiom.
]
```

#quote(block: true, attribution: [Alexander Grothendieck])[
  A sheaf is not merely a collection of data on open sets, but a way of
  passing coherently from the local to the global.
]

== Links and footnotes

Internal references automatically receive abbreviated labels:
@def-sheaf, @thm-equalizer, @lem-stalks, @thm-les. A page reference can be
obtained like this: @fig-cover has page #ref(<fig-cover>, form: "page").
A labeled footnote#footnote[This is an example footnote; its number is
highlighted in VERMILION.] <fn-example> remains clickable: @fn-example. Numbers
of local references are set in `VERMILION`, external URLs in `BLUE`.

The `wrapnote` function#wrapnote[Lives only in the margin and does not appear in
the footnote list at the bottom of the page.]
works like `wrappar`: at the declaration point it places a superscript marker
and takes the number from the footnote counter, so footnote numbers and those of
such notes share one counter.

If the number is needed right in the text but the note text below, use
`wrapnotemark` and `wrapnote`: the mark takes a number, and the next note claims
it. An example#wrapnotemark() in a sentence.

#wrapnote[The note text wraps around this paragraph.]
This paragraph wraps around the note. #lorem(30)

Grouping references by type is done with the `refs` function:
#refs(<def-presheaf>, <def-sheaf>, <fig-cover>, <tab-presheaf-sheaf>).

== Title page and structure

Document metadata is set with `set document`, the title page with `title-page`,
and the layout is enabled by the `show: style` rule. Chapters start with a
single `=`, sections with `==`, and subsections with `===`.
