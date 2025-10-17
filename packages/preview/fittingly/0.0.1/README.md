_Linear Fitting for Typst_

This package performs simple weighted linear fits in Typst.


## Documentation

```typ
#weighted_least_squares(
  x_vals: array,
  y_vals: array,
  y_weights: array
)
```

Performs a weighted least squares fit to the line y = a + bx, returning a fit dictionary containing:
- The parameters a and b
- The variance of a and b
- The covariance of a with b 
- The chi-squared and reduced chi-squared.

```typ
#confidence_interval(
  x_vals: array,
  fit: dictionary,
  sigma: 1)
```

Calculates a confidence band from the fit dictionary, which can be used in plots or further calculations. See `example.typ` for an example which uses [Lilaq](https://lilaq.org) to plot the confidence band.

## Planned Features
- Orthogonal Distance Regression (ODR)
- Nonlinear fitting (Levenberg–Marquardt)
