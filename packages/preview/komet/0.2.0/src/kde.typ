#import "plugin.typ": komet-plugin

/// Compute Kernel Density Estimation (KDE) for the given data.
///
/// This function computes a smooth density estimate from discrete data points
/// using a Gaussian kernel. It's useful for visualizing distributions in violin plots.
///
/// Parameters:
/// - `data`: An array of numerical values to compute the density for.
/// - `bandwidth`: The bandwidth of the Gaussian kernel. If `auto`, uses Scott's rule.
///              Larger values produce smoother curves.
/// - `num-points`: Number of points to evaluate the density at (default: 100).
/// - `min`: Minimum x value for evaluation. If `auto`, uses data min - 3*bandwidth.
/// - `max`: Maximum x value for evaluation. If `auto`, uses data max + 3*bandwidth.
///
/// Returns:
/// A dictionary with keys:
/// - `x`: Array of x coordinates where density was evaluated
/// - `y`: Array of density values at those x coordinates  
/// - `bandwidth`: The bandwidth used
///
/// Example:
/// ```
/// #let result = kde((1, 2, 3, 4, 5))
/// // result.x contains x coordinates
/// // result.y contains density values at those x coordinates
/// // result.bandwidth contains the computed bandwidth
/// ```
#let kde(
  data,
  bandwidth: auto,
  num-points: 100,
  min: auto,
  max: auto,
) = {
  assert(type(data) == array, message: "Data must be an array")
  assert(data.len() > 0, message: "Data cannot be empty")
  
  // Convert data to floats to handle integer inputs
  let float-data = data.map(float)
  
  // Convert bandwidth: auto becomes -1.0 to signal auto calculation
  let bw = if bandwidth == auto { -1.0 } else { float(bandwidth) }
  
  // Convert min: auto becomes negative infinity
  let xmin = if min == auto { calc.inf * -1 } else { float(min) }
  
  // Convert max: auto becomes positive infinity
  let xmax = if max == auto { calc.inf } else { float(max) }
  
  let result = cbor(komet-plugin.kde(
    cbor.encode((float-data, bw, num-points, xmin, xmax))
  ))
  
  result
}
