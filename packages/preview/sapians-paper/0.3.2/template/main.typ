#import "@preview/sapians-paper:0.3.2": * // x-release-please-version

#show: sapians-article.with(
  title: "Paper Title: A Clear Statement of the Contribution",
  abstract: [
    One paragraph stating the problem, the approach, and the headline
    result. Aim for four sentences: context, gap, method, and the number
    or finding that justifies reading further.
  ],
  authors: (
    (name: "First Author", affiliation: "Institution One"),
    (name: "Second Author", affiliation: "Institution Two"),
  ),
  keywords: ("Keyword One", "Keyword Two", "Keyword Three"),
  // Branding defaults are SAPIANS; override them for your venue:
  // kicker: "RESEARCH ARTICLE",
  // journal: "Journal or Venue Name",
  // lang: "pt", abstract-title: "Resumo", keywords-title: "Palavras-chave",
)

= Introduction

State the problem and why it matters, with citations @ribeiro2016lime.
End the section with an explicit statement of the contribution.

Mathematical claims render in display style:

$ xi(x) = limits("arg min")_(g in G) cal(L)(f, g, pi_x) + Omega(g) $

where $f$ is the reference model, $g$ the local surrogate, $pi_x$ the
proximity measure around the analyzed instance, and $Omega(g)$ penalizes
surrogate complexity.

= Method

Describe the approach precisely enough to reproduce. Use the accent card
for the assumption or hypothesis the whole paper leans on:

#accent-card(title: "Working Hypothesis")[
  Even when $f$ is highly non-linear globally, within the neighborhood
  $B_epsilon (x)$ its decision surface is approximately affine.
]

= Experiments

Report what was run, on what data, and what came out. Code listings use
the design system's code box:

#code-box(title: "Local Sampling", lang: "Python")[
  ```python
  import numpy as np

  def sample_local_space(x, num_samples=1000, sigma=0.25):
      noise = np.random.normal(0, sigma, size=(num_samples, x.shape[0]))
      samples = x + noise
      weights = np.exp(-np.sum(noise**2, axis=1) / (sigma**2))
      return samples, weights
  ```
]

= Conclusion

One paragraph: what was shown, its limits, and the next question.

#bibliography("references.bib", style: "ieee")
