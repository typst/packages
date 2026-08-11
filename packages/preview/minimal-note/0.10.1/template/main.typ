#import "@preview/minimal-note:0.10.1": *

#show: minimal-note.with(
  title: [Paper Title],
  author: [Your Name],
  date: datetime.today().display("[month repr:long], [year]")
)

= Basic Probability Laws

These probability laws, such as the #link(<chain-rule>, "Chain Rule") are fundamental. You can learn more about the link Chain Rule in #link("https://www.youtube.com/watch?v=wl1myxrtQHQ", "this video").

== Chain Rule
<chain-rule>

For two events $A$ and $B$, the *Chain Rule* states $ PP(A inter B) = PP(B bar A) PP(A). $
== PSRL

The PSRL algorithm @strens2000bayesian is shown in #link(<psrl-alg>, "Algorithm 1").

#algorithm-figure(
  "Posterior Sampling for Reinforcement Learning (PSRL)",
  inset: 3.5pt,
  {
    import algorithmic: *
    [*Input:* Prior $P(cal(M) in dot)$]
  },
  {
    [*for* $k in [K]$ *do*]
  },
  {
    [#h(2%) Sample $M_k ~ PP(cal(M) in dot bar H_k)$]
  },
  {
    [#h(2%) Obtain optimal policy $pi^k = pi^*_(M_k)$]
  },
  {
    [#h(2%) Execute $pi^{(k)}$ and get trajectory $tau_k$]
  },
  {
    [#h(2%) Update history $H_{k+1} = H_k union tau_k$]
  },
  {
    [#h(2%) Induce posterior $P(cal(M) in dot bar H_{k+1})$]
  },
  {
    [*end for*]
  }
) <psrl-alg>


Now, consider an application of the Chain Rule, mentioned in @chain-rule:

#green-box("Green Box", lorem(100))
#orange-box("Orange Box", lorem(100))

// See https://typst.app/docs/reference/model/bibliography/ for more on styling your bibliography
#bibliography("refs.bib", style: "institute-of-electrical-and-electronics-engineers")