#import "@preview/suiji:0.5.1": *
#import "@preview/simple-plot:0.8.0": *
#import "@preview/distro:0.1.0": binomial, categorical, poisson

== Sampling Random Variates

=== Categorical Distribution
#let Cat = categorical.new((0.1, 0.3, 0.2, 0.4))

// Random variate generation
#let n_samples = 1000
#let counts = (0,) * Cat.weights.len()
#let (rng, u) = (gen-rng-f(42), none)
#for _ in range(n_samples) {
  (rng, u) = uniform-f(rng)
  let result = categorical.sample(Cat, u)
  counts.at(result) += 1
}

// Frequency Table
#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: center,
  [*Category*], [*Count*], [*%*],
  ..for (i, count) in counts.enumerate() {
    (
      [#i],
      [#count],
      [#(calc.round(count / n_samples * 100, digits: 1))%],
    )
  },
)

=== Binomial Distribution
#let n = 10
#let p = 0.3
#let Bi = binomial.new(n, p)

#let n_samples = 100
#let counts = (0,) * (n + 1)
#let (rng, u) = (gen-rng-f(42), none)
#for _ in range(n_samples) {
  (rng, u) = uniform-f(rng)
  let result = binomial.sample(Bi, u)
  counts.at(result) += 1
}

#let ks = range(0, n + 1)
#let empirical_pmf = counts.map(i => i / n_samples)
#let true_pmf = ks.map(binomial.pmf(Bi))
#plot(
  ..(
    scatter(ks.zip(true_pmf)),
    scatter(ks.zip(empirical_pmf), mark-fill: orange),
  ),
  xmin: 0,
  xmax: n,
  ymin: 0,
  ymax: 1,
  axis-y-extend: 0,
)

=== Poisson Distribution

#let λ = 2
#let Po = poisson.new(λ)

#let n_samples = 100
#let counts = (0,) * 15
#let (rng, u) = (gen-rng-f(42), none)
#for _ in range(n_samples) {
  (rng, u) = uniform-f(rng)
  let result = poisson.sample(Po, u)
  // To avoid out-of-bounds error in case of large samples
  // we artificially restrict the support of the sampled distribution for plotting purposes.
  if result < counts.len() {
    counts.at(result) += 1
  }
}

#let ks = range(0, counts.len())
#let empirical_pmf = counts.map(i => i / n_samples)
#let true_pmf = ks.map(poisson.pmf(Po))
#plot(
  ..(
    scatter(ks.zip(true_pmf)),
    scatter(ks.zip(empirical_pmf), mark-fill: orange),
  ),
  xmin: 0,
  xmax: counts.len() - 1,
  ymin: 0,
  ymax: 1,
  axis-y-extend: 0,
)
