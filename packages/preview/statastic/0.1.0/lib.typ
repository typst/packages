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
  if (calc.rem(len, 2) == 0) {
    let middle = calc.quo(len, 2)
    (col.at(middle - 1) + col.at(middle)) / 2
  } else {
    let middle = calc.quo(len, 2) - 1
    col.at(middle-1)
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
