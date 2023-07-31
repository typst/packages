#import "is.typ": same-type

// Math

#let minmax( a, b ) = (
  calc.min(a, b),
  calc.max(a, b)
)

#let clamp( min, max, value ) = {
  assert.eq(type(min), type(max),
    message:"Can't clamp values of different types!"
  )
  assert.eq(type(min), type(value),
    message:"Can't clamp values of different types!"
  )
  // (min, max) = minmax(min, max)
	if value < min { return min }
	else if value > max { return max }
	else { return value }
}

#let lerp( min, max, t ) = {
  assert.eq(type(min), type(max),
    message:"Can't lerp values of different types!"
  )
 // (min, max) = minmax(min, max)
  return min + (max - min) * t
}

#let map( min, max, range-min, range-max, value ) = {
  assert.eq(type(min), type(max),
    message:"Can't map values from ranges of different types!"
  )
  assert.eq(type(range-min), type(range-max),
    message:"Can't map values to ranges of different types!"
  )
  assert.eq(type(min), type(value),
    message:"Can't map values with different types as the initial range!"
  )
  // (min, max) = minmax(min, max)
  // (range-min, range-max) = minmax(range-min, range-max)
	let t = (value - min) / (max - min)
	return range-min + t * (range-max - range-min)
}
