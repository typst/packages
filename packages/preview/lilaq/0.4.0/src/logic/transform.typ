
/// Creates a data-to-display transformation that maps the interval 
/// $[x_0, x_1]$ to $[y_0, y_1]$ given some monotonous transformation function 
/// (e.g., identity or log(x)). 
/// 
/// -> function
#let create-trafo(
  
  /// Transformation function that takes one argument. 
  /// -> function
  transform, 
  
  /// Lower interval bound. 
  /// -> float
  x0, 
  
  /// Upper interval bound. 
  /// -> float
  x1, 

  /// Lower target interval bound. 
  /// -> float
  y0: 0, 
  
  /// Upper target interval bound. 
  /// -> float
  y1: 1
  
) = {
  let a = (y1 - y0) / (transform(x1) - transform(x0))
  let b = -a * transform(x0) + y0
  x => a * transform(x) + b
}

#assert.eq(create-trafo(x => x, -23, 4)(-23), 0)
#assert.eq(create-trafo(x => x, -23, 4)(4), 1)

#assert.eq(create-trafo(x => x, -23, 4, y0: 1, y1: -1)(-23), 1)
#assert.eq(create-trafo(x => x, -23, 4, y0: 1, y1: -1)(4), -1)

#assert.eq(create-trafo(x => calc.log(x), 2, 4)(2), 0)
#assert.eq(create-trafo(x => calc.log(x), 2, 4)(4), 1)


