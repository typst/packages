#import "../math.typ": percentile



#assert.eq(percentile((1,2,3), 50%), 2)
#assert.eq(percentile((1,2,3), 25%), 1.5)
#assert.eq(percentile((1,2,3), 0%), 1)
#assert.eq(percentile((1,2,3), 100%), 3)


#let boxplot-statistics(x, whiskers: 1.5) = {
  x = x.sorted()
  let stat = (
    mean: x.sum() / x.len(),
    median: percentile(x, 50%),
    q1: percentile(x, 25%),
    q3: percentile(x, 75%),
    min: x.at(0),
    max: x.at(-1),
  )
  let iqr = stat.q3 - stat.q1
  let whisker-low = stat.q1 - iqr * whiskers
  let whisker-high = stat.q3 + iqr * whiskers

  let wlo = x.filter(x => x >= whisker-low)
  let whi = x.filter(x => x <= whisker-high)
  whisker-low = calc.min(stat.q1, wlo.at(0, default: stat.q1))
  whisker-high = calc.max(stat.q3, whi.at(-1, default: stat.q1))
  
  
  stat.inter-quartile-range = iqr
  stat.whisker-high = whisker-high
  stat.whisker-low = whisker-low

  stat.outliers = x.filter(x => x < whisker-low or x > whisker-high)

  stat
}

#boxplot-statistics((-12,1,100,1,1,1,2,3,4,5,6))
#boxplot-statistics((range(9)) + (40,))