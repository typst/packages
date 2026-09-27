#import "@preview/simple-plot:0.8.0": line-plot, plot, scatter
#import "@preview/distro:0.1.0": *

= Distribution plots

== Discrete distributions

#table(
  columns: (auto, auto, auto),
  // inset: 10pt,
  align: horizon,
  table.header([*Distribution*], [*PMF*], [*CDF*]),
  [Uniform],
  [
    #let Unif = discrete-uniform.new(0.0, 4.0)
    #let pmf = discrete-uniform.pmf(Unif)
    #let points = range(0, 5).map(i => scatter(((i, pmf(i)),)))
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 5,
      ymin: 0,
      ymax: 1.1,
      // ytick-labels: ($1/n$, $1$),
      // ytick: (.2, 1),
      axis-y-extend: 0,
      ..points,
    )
  ],
  [
    #let Unif = discrete-uniform.new(0.0, 4.0)
    #let cdf = discrete-uniform.cdf(Unif)
    #let points = range(0, 5).map(i => scatter(((i, cdf(i)),)))
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 5,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      ..points,
    )
  ],

  [Categorical],
  [
    #let Cat = categorical.new((0.1, 0.3, 0.2, 0.4))
    #let pmf = categorical.pmf(Cat)
    #let points = range(0, Cat.weights.len()).map(i => scatter(((i, pmf(i)),)))
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: Cat.weights.len(),
      ymin: 0,
      ymax: calc.max(..Cat.weights) * 1.1,
      axis-y-extend: 0,
      ..points,
    )
  ],
  [
    #let Cat = categorical.new((0.1, 0.3, 0.2, 0.4))
    #let cdf = categorical.cdf(Cat)
    #let points = range(0, Cat.weights.len()).map(i => scatter(((i, cdf(i)),)))
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: Cat.weights.len(),
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      ..points,
    )
  ],

  [Bernoulli],
  [
    #let Be = bernoulli.new(0.8)
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: 1.4,
      ymin: 0,
      ymax: 1,
      xlabel: $k$,
      ylabel: $p(k)= cases(1-p &"if" k = 0, p &"if" k = 1)$,
      axis-y-extend: 0,
      axis-x-extend: 0,
      scatter(
        ((0, bernoulli.pmf(Be)(0)),),
        label: $1-p=#{ calc.round(1 - Be.p, digits: 2) }$,
        label-anchor: "south-west",
      ),
      scatter(
        ((1, bernoulli.pmf(Be)(1)),),
        label: $p=#{ calc.round(Be.p, digits: 2) }$,
        label-anchor: "south",
      ),
    )
  ],
  [
    #let Be = bernoulli.new(0.8)
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: 1.1,
      ymin: 0,
      ymax: 1.1,
      xlabel: $k$,
      ylabel: $F(k) = cases(0 &"if" k < 0, 1-p &"if" 0 <= k < 1, 1 &"if" k >= 1)$,
      axis-y-extend: 0,
      axis-x-extend: 0,
      scatter(
        ((0, bernoulli.cdf(Be)(0)),),
        label: $1-p=#{ calc.round(1 - Be.p, digits: 2) }$,
        label-anchor: "south-west",
      ),
      scatter(
        ((1, bernoulli.cdf(Be)(1)),),
        label: $p=#{ calc.round(Be.p, digits: 2) }$,
        label-anchor: "south",
      ),
    )
  ],

  [Binomial],
  [
    #let Bi = binomial.new(10, 0.3)
    #let points = range(0, Bi.n + 1).map(i => scatter(((i, binomial.pmf(Bi)(i)),)))
    #let ymax = 1.2 * calc.max(..points.map(p => p.points.at(0).at(1)))

    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: Bi.n,
      ymin: 0,
      ymax: ymax,
      xlabel: $k$,
      // ylabel-pos: ,
      ylabel: $p(k) = binom(n, k) p^k (1-p)^(n-k)$,
      axis-y-extend: 0,
      ..points,
    )],

  [
    #let Bi = binomial.new(10, 0.3)
    #let points = range(0, Bi.n + 1).map(i => scatter(((i, binomial.cdf(Bi)(i)),)))
    #let ymax = 1.2 * calc.max(..points.map(p => p.points.at(0).at(1)))
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: Bi.n,
      ymin: 0,
      ymax: ymax,
      xlabel: $k$,
      // ylabel-pos: ,
      ylabel: $F(k) = sum_(i=0)^(k) p(i)$,
      axis-y-extend: 0,
      ..points,
    )
  ],

  [Geometric],
  [
    #let Ge = geometric.new(0.2)
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: 10,
      ymin: 0,
      ymax: 0.3,
      xlabel: $k$,
      ylabel: $p(k) = (1-p)^(k-1)p$,
      ylabel-pos: (4.3, .25),
      axis-y-extend: 0,
      ..range(0, 9).map(i => scatter(((i, geometric.pmf(Ge)(i)),))),
    )
  ],

  [
    #let Ge = geometric.new(0.2)
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: 10,
      ymin: 0,
      ymax: 1,
      xlabel: $k$,
      ylabel: $F(k) = 1 - (1-p)^k$,
      ylabel-pos: (4.3, .8),
      axis-y-extend: 0,
      ..range(0, 9).map(i => scatter(((i, geometric.cdf(Ge)(i)),))),
    )
  ],

  [Poisson],
  [
    #let Pois = poisson.new(3)
    #let n = 11
    // #let points = range(0, n).map(i => scatter(((i, Pois(i)),)))
    #let points = range(0, n).map(i => scatter(((i, poisson.pmf(Pois)(i)),)))
    #let ymax = 1.2 * calc.max(..points.map(p => p.points.at(0).at(1)))

    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: n,
      ymin: 0,
      ymax: ymax,
      xlabel: $k$,
      ylabel: $p(k) = (lambda^k e^(-lambda)) / k!$,
      axis-y-extend: 0,
      ..points,
    )
  ],
  [
    #let Pois = poisson.new(3)
    #let n = 10
    #let points = range(0, n + 1).map(i => scatter(((i, poisson.cdf(Pois)(i)),)))
    #let ymax = 1.2 * calc.max(..points.map(p => p.points.at(0).at(1)))
    #plot(
      width: 4,
      height: 4,
      xmin: 0,
      xmax: n,
      ymin: 0,
      ymax: ymax,
      xlabel: $k$,
      ylabel: $F(k) = sum_(i=0)^(k) (lambda^i e^(-lambda)) / i!$,
      axis-y-extend: 0,
      ..points,
    )
  ],
)

#pagebreak()

== Continuous distributions

#table(
  columns: (auto, auto, auto),
  // inset: 10pt,
  align: horizon,
  table.header([*Distribution*], [*PMF*], [*CDF*]),
  [Normal],
  [
    #let Z = normal.new(mean: 0, std: 3)
    #plot(
      width: 5,
      height: 5,
      xmin: -5,
      xmax: 5,
      ymin: 0,
      ymax: 0.5,
      axis-y-extend: 0,
      (fn: normal.pdf(Z)),
    )
  ],
  [
    #let Z = normal.new(mean: 0, std: 1)
    #plot(
      width: 5,
      height: 5,
      xmin: -4,
      xmax: 4,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: normal.cdf(Z)),
    )
  ],

  [Uniform],
  [
    #let Unif = continuous-uniform.new(0, 1)
    #plot(
      width: 5,
      height: 5,
      xmin: -1,
      xmax: 2,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: continuous-uniform.pdf(Unif)),
    )
  ],
  [
    #let Unif = continuous-uniform.new(0, 1)
    #plot(
      width: 5,
      height: 5,
      xmin: -1,
      xmax: 2,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: continuous-uniform.cdf(Unif)),
    )
  ],

  [Beta],
  [
    #let X = beta.new(alpha: 2, beta: 3)
    #plot(
      width: 5,
      height: 5,
      xmin: -0.5,
      xmax: 1.5,
      ymin: 0,
      ymax: 2.5,
      axis-y-extend: 0,
      (fn: beta.pdf(X)),
    )
  ],
  [
    #let X = beta.new(alpha: 2, beta: 3)
    #plot(
      width: 5,
      height: 5,
      xmin: -0.5,
      xmax: 1.5,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: beta.cdf(X)),
    )
  ],

  [Exponential],
  [
    #let Exp = exponential.new(1)
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 5,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: exponential.pdf(Exp)),
    )
  ],
  [
    #let Exp = exponential.new(1)
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 5,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: exponential.cdf(Exp)),
    )
  ],

  [Gamma],
  [
    #let X = gamma.new(shape: 2, rate: 0.5)
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 10,
      ymin: 0,
      ymax: 0.2,
      axis-y-extend: 0,
      (fn: gamma.pdf(X)),
    )
  ],
  [
    #let X = gamma.new(shape: 2, rate: 0.5)
    #plot(
      width: 5,
      height: 5,
      xmin: 0,
      xmax: 10,
      ymin: 0,
      ymax: 1.1,
      axis-y-extend: 0,
      (fn: gamma.cdf(X)),
    )
  ],
)
