/// Extracts a specific column from the given dataset based on the column.
/// 
/// - data (array): The dataset.
/// - colId (int): The identifier for the column to be extracted.
/// -> array
#let extractColumn(data, colId) = {
    let column = ()
    for row in data {
        column.push(row.at(colId))
    }
    column
}

/// Converts an array's elements to floating point numbers.
///
/// - arr (array): Array with elements to be converted.
/// -> array
#let tofloatArray(arr) = {
  let res = ()
  for el in arr {
    if el == "" {
      res.push(0.0)
    } else {
      res.push(float(el))
    }
  }
  res
}

/// Converts an array's elements to integers.
///
/// - arr (array): Array with elements to be converted.
/// -> array
#let toIntArray(arr) = {
  let res = ()
  for el in arr {
    if el == "" {
      res.push(0)
    } else {
      res.push(int(el))
    }
  }
  res
}

/// Determines if a given value is an integer.
///
/// - val (mixed): The value to be checked.
/// -> boolean
#let isInt(val) = {
  let f = float(val)
  let i = int(f)
  val == i
}

/// Calculates a value between two numbers at a specific fraction.
///
/// - lower (float): The lower number.
/// - upper (float): The upper number.
/// - fraction (float): The fraction between the two numbers.
/// -> float
#let lerp(lower, upper, fraction) = {
  let diff = upper - lower
  lower + (diff * fraction)
}

/// Calculates the average of an array's elements.
///
/// - arr (array): Array of numbers.
/// -> float
#let arrayAvg(arr) = {
  let col = tofloatArray(arr)
  col.sum() / col.len()
}

/// Calculates the average of a specific column in a dataset.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> float
#let avg(data, colId) = {
  arrayAvg(extractColumn(data, colId))
}

/// Calculates the median of an array's elements.
///
/// - arr (array): Array of numbers.
/// -> float
#let arrayMedian(arr) = {
  let col = tofloatArray(arr).sorted()
  let len = col.len()
  if calc.rem(len, 2) == 0 {
    let middle = calc.quo(len, 2)
    (col.at(middle - 1) + col.at(middle)) / 2
  } else {
    let middle = calc.quo(len, 2)
    col.at(middle)
  }
}

/// Calculates the median of a specific column in a dataset.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> float
#let median(data, colId) = {
  arrayMedian(extractColumn(data, colId))
}

/// Calculates the mode of an integer array.
/// Converts all floats to integers.
///
/// - arr (array): Array of integers.
/// -> array
#let arrayIntMode(arr) = {
  let col = arr
  let unique = col.dedup()
  let counts = (:)
  for k in unique {
    counts.insert(str(k), 0)
  }
  for k in col {
    counts.at(str(k)) += 1
  }
  let highestModeCount = 0
  for (k, v) in counts.pairs() {
    if (v > highestModeCount) {
      highestModeCount = v
    }
  }
  let modes = ()
  for (k, v) in counts.pairs() {
    if (v == highestModeCount) {
      modes.push(int(k))
    }
  }
  modes
}

/// Calculates the integer mode of a specific column in a dataset.
/// Converts all floats to integers.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> array
#let intMode(data, colId) = {
  arrayIntMode(toIntArray(tofloatArray((extractColumn(data, colId)))))
}

/// Calculates the variance of an array's elements.
///
/// - arr (array): Array of numbers.
/// -> float
#let arrayVar(arr) = {
  let col = tofloatArray(arr)
  let len = col.len()
  let mean = col.sum() / len
  let varSum = 0
  for el in col {
    varSum += calc.pow(el - mean, 2)
  }
  varSum / (len - 1)
}

/// Calculates the variance of a specific column in a dataset.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> float
#let var(data, colId) = {
  arrayVar(extractColumn(data, colId))
}

/// Calculates the standard deviation of an array's elements.
///
/// - arr (array): Array of numbers.
/// -> float
#let arrayStd(arr) = {
  let var = arrayVar(arr)
  calc.sqrt(var)
}

/// Calculates the standard deviation of a specific column in a dataset.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> float
#let std(data, colId) = {
  arrayStd(extractColumn(data, colId))
}

/// Calculates a specific percentile of an array's elements.
///
/// - arr (array): Array of numbers.
/// - p (float): The desired percentile (between 0 and 1).
/// -> float
#let arrayPercentile(arr, p) = {
  let col = tofloatArray(arr).sorted()
  let n = col.len() - 1
  let pos = p * n

  if (isInt(pos)) {
    col.at(int(pos))
  } else {
    let low = col.at(calc.floor(pos))
    let high = col.at(calc.ceil(pos))
    lerp(low, high, calc.fract(pos))
  }
}

/// Calculates a specific percentile of a column in a dataset.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// - p (float): The desired percentile (between 0 and 1).
/// -> float
#let percentile(data, colId, p) = {
  arrayPercentile(extractColumn(data, colId), p)
}

/// Computes a set of statistical measures for an array.
/// Includes: average, median, integer mode, variance, standard deviation, and some percentiles.
///
/// - arr (array): Array of numbers.
/// -> dictionary
#let arrayStats(arr) = {
  (
    "avg": arrayAvg(arr),
    "median": arrayMedian(arr),
    "intMode": arrayIntMode(arr),
    "var": arrayVar(arr),
    "std": arrayStd(arr),
    "25percentile": arrayPercentile(arr, 0.25),
    "50percentile": arrayPercentile(arr, 0.50),
    "75percentile": arrayPercentile(arr, 0.75),
    "95percentile": arrayPercentile(arr, 0.95),
  )
}

/// Computes a set of statistical measures for a specific column in a dataset.
/// Includes: average, median, integer mode, variance, standard deviation, and some percentiles.
///
/// - data (array): The dataset.
/// - colId (int): The identifier for the column.
/// -> dictionary
#let stats(data, colId) = {
  (
    "avg": avg(data, colId),
    "median": median(data, colId),
    "intMode": intMode(data, colId),
    "var": var(data, colId),
    "std": std(data, colId),
    "25percentile": percentile(data, colId, 0.25),
    "50percentile": percentile(data, colId, 0.50),
    "75percentile": percentile(data, colId, 0.75),
    "95percentile": percentile(data, colId, 0.95),
  )
}

/// Calculates the covariance between two arrays' elements.
///
/// - arrX (array): First array of numbers.
/// - arrY (array): Second array of numbers.
/// -> float
#let arrayCovariance(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  let meanX = arrayAvg(x)
  let meanY = arrayAvg(y)
  let covSum = 0.0

  for ((xi, yi)) in x.zip(y) {
    covSum += (xi - meanX) * (yi - meanY)
  }

  covSum / (n - 1)
}

/// Performs quadratic regression on two arrays of data.
/// Fits the model [$ y = a x^{2} + b x + c $].
/// Returns a dictionary with keys "a", "b", "c", and "r_squared".
///
/// - arrX (array): Array of independent variable values.
/// - arrY (array): Array of dependent variable values.
/// -> dictionary with keys "slope", "intercept", "r_squared"
#let arrayLinearRegression(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  let meanX = arrayAvg(x)
  let meanY = arrayAvg(y)
  let varX = arrayVar(x)
  let covXY = arrayCovariance(x, y)
  let slope = covXY / varX
  let intercept = meanY - slope * meanX

  // Compute R-squared
  let totalSS = 0.0
  let residualSS = 0.0

  for ((xi, yi)) in x.zip(y) {
    let yPred = intercept + slope * xi
    totalSS += calc.pow(yi - meanY, 2)
    residualSS += calc.pow(yi - yPred, 2)
  }

  let r_squared = 1 - residualSS / totalSS

  (
    "slope": slope,
    "intercept": intercept,
    "r_squared": r_squared,
  )
}

/// Performs linear regression on two columns in a dataset.
///
/// - data (array): The dataset.
/// - colX (int): The column index for the independent variable.
/// - colY (int): The column index for the dependent variable.
/// -> dictionary with keys "slope", "intercept", "r_squared"
#let linearRegression(data, colX, colY) = {
  let x = extractColumn(data, colX)
  let y = extractColumn(data, colY)
  arrayLinearRegression(x, y)
}

/// Performs exponential regression on two arrays of data.
/// Fits the model [$ y = a e^{b x} $].
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - arrX (array): Array of independent variable values.
/// - arrY (array): Array of dependent variable values.
/// -> dictionary
#let arrayQuadraticRegression(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  // Compute sums needed for the normal equations
  let sumX = x.sum()
  let sumY = y.sum()
  let sumXX = x.map(xi => xi * xi).sum()
  let sumXXX = x.map(xi => calc.pow(xi, 3)).sum()
  let sumXXXX = x.map(xi => calc.pow(xi, 4)).sum()
  let sumXY = x.zip(y).map(((xi, yi)) => xi * yi).sum()
  let sumXXY = x.zip(y).map(((xi, yi)) => calc.pow(xi, 2) * yi).sum()

  // Build the matrices for the normal equations
  let Sxx = sumXX - (sumX * sumX) / n
  let Sxy = sumXY - (sumX * sumY) / n
  let Sxx2 = sumXXX - (sumXX * sumX) / n
  let Sx2x2 = sumXXXX - (sumXX * sumXX) / n
  let Sx2y = sumXXY - (sumXX * sumY) / n

  // Calculate the coefficients
  let denom = Sxx * Sx2x2 - calc.pow(Sxx2, 2)
  if denom == 0 {
    error("Denominator in quadratic regression is zero")
  }

  let a = (Sx2y * Sxx - Sxy * Sxx2) / denom
  let b = (Sxy * Sx2x2 - Sx2y * Sxx2) / denom
  let c = (sumY - b * sumX - a * sumXX) / n

  // Compute R-squared
  let y_mean = sumY / n
  let totalSS = y.map(yi => calc.pow(yi - y_mean, 2)).sum()
  let residualSS = x.zip(y).map(((xi, yi)) => {
    let yi_pred = a * calc.pow(xi, 2) + b * xi + c
    calc.pow(yi - yi_pred, 2)
  }).sum()
  let r_squared = 1 - residualSS / totalSS

  (
    "a": a,
    "b": b,
    "c": c,
    "r_squared": r_squared,
  )
}

/// Performs quadratic regression on two columns in a dataset.
/// Returns a dictionary with keys "a", "b", "c", and "r_squared".
///
/// - data (array): The dataset.
/// - colX (int): The column index for the independent variable.
/// - colY (int): The column index for the dependent variable.
/// -> dictionary
#let quadraticRegression(data, colX, colY) = {
  let x = extractColumn(data, colX)
  let y = extractColumn(data, colY)
  arrayQuadraticRegression(x, y)
}

/// Performs logarithmic regression on two arrays of data.
/// Fits the model [$ y = a + b \ln(x) $].
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - arrX (array): Array of independent variable values.
/// - arrY (array): Array of dependent variable values.
/// -> dictionary
#let arrayExponentialRegression(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  // Transform y by taking the natural logarithm
  let lnY = y.map(yi => calc.ln(yi))

  // Now perform linear regression on x and lnY
  let meanX = arrayAvg(x)
  let meanLnY = arrayAvg(lnY)
  let varX = arrayVar(x)
  let covXY = arrayCovariance(x, lnY)

  let b = covXY / varX
  let lnA = meanLnY - b * meanX
  let a = calc.exp(lnA)

  // Compute R-squared
  let y_pred = x.map(xi => a * calc.exp(b * xi))
  let totalSS = y.map(yi => calc.pow(yi - arrayAvg(y), 2)).sum()
  let residualSS = y.zip(y_pred).map(((yi, ypi)) => calc.pow(yi - ypi, 2)).sum()
  let r_squared = 1 - residualSS / totalSS

  (
    "a": a,
    "b": b,
    "r_squared": r_squared,
  )
}

/// Performs exponential regression on two columns in a dataset.
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - data (array): The dataset.
/// - colX (int): The column index for the independent variable.
/// - colY (int): The column index for the dependent variable.
/// -> dictionary
#let exponentialRegression(data, colX, colY) = {
  let x = extractColumn(data, colX)
  let y = extractColumn(data, colY)
  arrayExponentialRegression(x, y)
}


///////////////////////////

/// Performs logarithmic regression on two arrays of data.
/// Fits the model [$ y = a + b \ln(x) $].
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - arrX (array): Array of independent variable values (must be > 0).
/// - arrY (array): Array of dependent variable values.
/// -> dictionary
#let arrayLogarithmicRegression(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  // Check that x values are greater than zero
  if x.any(xi => xi <= 0) {
    error("All x values must be greater than zero for logarithmic regression")
  }

  // Transform x by taking the natural logarithm
  let lnX = x.map(xi => calc.ln(xi))

  // Now perform linear regression on lnX and y
  let meanLnX = arrayAvg(lnX)
  let meanY = arrayAvg(y)
  let varLnX = arrayVar(lnX)
  let covXY = arrayCovariance(lnX, y)

  let b = covXY / varLnX
  let a = meanY - b * meanLnX

  // Compute R-squared
  let y_pred = lnX.map(xi => a + b * xi)
  let totalSS = y.map(yi => calc.pow(yi - meanY, 2)).sum()
  let residualSS = y.zip(y_pred).map(((yi, ypi)) => calc.pow(yi - ypi, 2)).sum()
  let r_squared = 1 - residualSS / totalSS

  (
    "a": a,
    "b": b,
    "r_squared": r_squared,
  )
}

/// Performs logarithmic regression on two columns in a dataset.
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - data (array): The dataset.
/// - colX (int): The column index for the independent variable (must be > 0).
/// - colY (int): The column index for the dependent variable.
/// -> dictionary
#let logarithmicRegression(data, colX, colY) = {
  let x = extractColumn(data, colX)
  let y = extractColumn(data, colY)
  arrayLogarithmicRegression(x, y)
}


///////////////////////////////////////


/// Performs power regression on two arrays of data.
/// Fits the model [$ y = a x^{b} $].
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - arrX (array): Array of independent variable values (must be > 0).
/// - arrY (array): Array of dependent variable values (must be > 0).
/// -> dictionary
#let arrayPowerRegression(arrX, arrY) = {
  let x = tofloatArray(arrX)
  let y = tofloatArray(arrY)
  let n = x.len()

  if n != y.len() {
    error("Arrays must have the same length")
  }

  // Check that x and y values are greater than zero
  if x.any(xi => xi <= 0) or y.any(yi => yi <= 0) {
    error("All x and y values must be greater than zero for power regression")
  }

  // Transform both x and y by taking the natural logarithm
  let lnX = x.map(xi => calc.ln(xi))
  let lnY = y.map(yi => calc.ln(yi))

  // Now perform linear regression on lnX and lnY
  let meanLnX = arrayAvg(lnX)
  let meanLnY = arrayAvg(lnY)
  let varLnX = arrayVar(lnX)
  let covXY = arrayCovariance(lnX, lnY)

  let b = covXY / varLnX
  let lnA = meanLnY - b * meanLnX
  let a = calc.exp(lnA)

  // Compute R-squared
  let y_pred = x.map(xi => a * calc.pow(xi, b))
  let totalSS = y.map(yi => calc.pow(yi - arrayAvg(y), 2)).sum()
  let residualSS = y.zip(y_pred).map(((yi, ypi)) => calc.pow(yi - ypi, 2)).sum()
  let r_squared = 1 - residualSS / totalSS

  (
    "a": a,
    "b": b,
    "r_squared": r_squared,
  )
}

/// Performs power regression on two columns in a dataset.
/// Returns a dictionary with keys "a", "b", and "r_squared".
///
/// - data (array): The dataset.
/// - colX (int): The column index for the independent variable (must be > 0).
/// - colY (int): The column index for the dependent variable (must be > 0).
/// -> dictionary
#let powerRegression(data, colX, colY) = {
  let x = extractColumn(data, colX)
  let y = extractColumn(data, colY)
  arrayPowerRegression(x, y)
}

