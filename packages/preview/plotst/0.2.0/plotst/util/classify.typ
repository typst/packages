#import "util.typ": *

//-----------------
//THIS FILE CONTAINS EVERYTHING TO CLASSIFY DATA
//-----------------


/// This function is used to compare the data in the classifying process. In most cases you can leave it be. \
/// If you want a different ordinality, you can overwrite this function. \ \
/// === Return specification
/// - -1 if `val1 < val2` \
/// - 1 if `val1 > val2` \
/// - 0 if `val1 == val2` \ \
#let compare(val1, val2) = {
  return if val1 < val2 {-1} else if val1 > val2 {1} else {0}
}

/// This is the constructor function for a single `class` used to classify data. \
/// Right now, this is only used for `histograms`.
/// - lower_lim (integer): The lower limit of the class. (Inclusive)
/// - upper_lim (integer): The upper limit of the class. (Exclusive)
#let class(lower_lim, upper_lim) = {
  return (
    lower_lim: lower_lim,
    upper_lim: upper_lim,
    data: ()
  )
}

/// Generates a number of classes similarly how `axis` fills the `values` parameter on its own. It splits the area from `start` to `end` into the with `amount` specified amount of classes.\
/// Right now, this is only used for `historams`.\
/// *Example:* \
/// ```js let classes = class_generator(10000, 50000, 4)``` \ \
/// This will result in creating the following classes: `(10000 - 20000, 20000 - 30000, 30000 - 40000, 40000 - 50000, 50000 - 100000)`. \ \
/// - start (integer): The lower limit of the first generated class.
/// - end (integer): The upper limit of the last generated class.
/// - amount (integer): How many classes should be generated.
#let class_generator(start, end, amount) = {
  let step = int((end - start) / amount)
  let classes = ()
  for value in range(start, end, step: step) {
    classes.push(class(value, value + step))
  }
  return classes
}

/// Classifies the provided data into the given classes. This has to be done to create a `histogram`.
/// - data (array): The data you want to classify (needs to be comparable by the compare function). It's either an `array` of single values or an `array` of `tuples` looking like this: `(amount, value)`.
/// - classes (array): An array of classes the data should be mapped to (`lower_limit` and `uper_limit` need to be comparable).
/// - compare (function): The method used for comparing. Most of the time this doesn't need to be changed. If you want to use a different compare function, look at the specification for it (_see:_ `compare(val1, val2)`).
#let classify(data, classes, compare: compare) = {
  let data = transform_data_full(data)
  let classes = if "lower_lim" in classes {(classes,)} else {classes}
  for (idx, class) in classes.enumerate() {
    for value in data {
      if compare(value, class.lower_lim) >= 0 and compare(value, class.upper_lim) <= -1 {
        class.data.push(value)
      }
    }
    classes.at(idx) = class
  }
  return if classes.len() == 1 {classes.at(0)} else {classes}
}