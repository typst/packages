#import "plugin.typ": komet-plugin


/// Computes the statistics needed to generate a box plot, including
/// - `median`
/// - first and third quartile `q1` and `q3`,
/// - `min` and `max`,
/// - lower and upper whisker positions `whisker-low` and `whisker-high`,
/// - `mean`, and
/// - an array of `outliers`. 
/// 
/// -> dictionary
#let boxplot(

  /// An array of input float or integer values. 
  /// -> array
  values,

  /// The position of the whiskers in terms of the inter-quartil distance `q3 - q1`. 
  /// -> float
  whisker-pos: 1.5,

) = {
  // let input = ((whisker-pos,) + values).map(float).map(float.to-bytes.with(size: 8, endian: "big")).join()

  // let (
  //   mean,
  //   median,
  //   q1,
  //   q3,
  //   min,
  //   max,
  //   whisker_low,
  //   whisker_high,
  //   ..outliers,
  // ) = array(komet-plugin.boxplot(input)).chunks(8).map(bytes).map(float.from-bytes.with(endian: "big"))

  let input = cbor.encode((
    values.map(float),
    float(whisker-pos)
  ))

  cbor(komet-plugin.boxplot(input))
}
