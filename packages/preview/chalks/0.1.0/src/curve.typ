// Function-sampled curves.
#import "shapes.typ": path

/// Sample `f` over `domain = (lo, hi)` into a hand-drawn curve.
/// `f(x)` may return a float (plotted as (x, f(x))) or an (x, y) pair
/// (parametric). Note page coordinates are y-down; put fn-curve inside
/// `sketch(origin: "bottom-left")` for math-convention plots.
///
/// ```typst
/// fn-curve(x => x * x / 40, (0, 80), samples: 40)
/// ```
///
/// - f (function): Maps each sampled x value to either y or `(x, y)`.
/// - domain (array): Inclusive numeric interval `(lo, hi)`.
/// - samples (int): Number of equal domain intervals; the output contains
///   `samples + 1` points. Default: `32`.
/// - ..style (arguments): Shared stroke style overrides.
#let fn-curve(f, domain, samples: 32, ..style) = {
  let (lo, hi) = (float(domain.at(0)), float(domain.at(1)))
  let pts = range(samples + 1).map(i => {
    let x = lo + (hi - lo) * i / samples
    let y = f(x)
    if type(y) == array { y } else { (x, float(y)) }
  })
  path(pts, ..style)
}
