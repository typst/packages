#import "../math.typ": percentile
#import "../assertations.typ"


#let boxplot-statistics(x, whiskers: 1.5) = {
  
  let stat = if type(x) == array {

    import "@preview/komet:0.1.0"
    return komet.boxplot(x, whisker-pos: whiskers)
    
  } else if type(x) == dictionary {

    assertations.assert-dict-keys(
      x, 
      mandatory: ("median", "q1", "q3", "whisker-low", "whisker-high"),
      optional: ("outliers", "mean"),
      missing-message: key => "Boxplot data needs to specify \"" + key + "\"",
      unexpected-message: (key, possible-keys) => "Boxplot data contains unexpected key \"" + key + "\" (expected " + possible-keys + ")"
    )
    if not "outliers" in x {
      x.outliers = ()
    }
    x

  } else {
    assert(false, message: "Boxplot data either needs to be an array of values or a dictionary specifying boxplot statistics")
  }

  let iqr = stat.q3 - stat.q1

  if type(x) == array {
    let wlo = x.filter(x => x >= stat.q1 - iqr * whiskers)
    let whi = x.filter(x => x <= stat.q3 + iqr * whiskers)
    stat.whisker-low = calc.min(stat.q1, wlo.at(0, default: stat.q1))
    stat.whisker-high = calc.max(stat.q3, whi.at(-1, default: stat.q3))
    stat.outliers = x.filter(x => x < stat.whisker-low or x > stat.whisker-high)
  }
  
  stat.inter-quartile-range = iqr


  stat
}
