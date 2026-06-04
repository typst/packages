#import "@preview/cetz:0.3.1"

#let convert-length(ctx, num) = {
  // This function come from the cetz module
  return if type(num) == length {
    float(num.to-absolute() / ctx.length)
  } else if type(num) == ratio {
    num
  } else {
    float(num)
  }
}

/// Convert any angle to an angle between -360deg and 360deg
#let angle-correction(a) = {
  if type(a) == angle {
    a = a.deg()
  }
  if type(a) != float and type(a) != int {
    panic("angle-correction: The angle must be a number or an angle")
  }
	while a < 0 {
		a = a + 360
	}
  calc.rem(a, 360) * 1deg
}

/// Check if the angle is in the range [from, to[
#let angle-in-range(angle, from, to) = {
  if to < from {
    panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
  }
  angle = angle-correction(angle)
  angle >= from and angle < to
}

#let angle-in-range-strict(angle, from, to) = {
	if to < from {
		panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
	}
	angle = angle-correction(angle)
	angle > from and angle < to
}

#let angle-in-range-inclusive(angle, from, to) = {
	if to < from {
		panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
	}
	angle = angle-correction(angle)
	angle >= from and angle <= to
}

/// get the angle between two anchors
#let angle-between(ctx, from, to) = {
  let (ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(ctx, from)
  let (ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(ctx, to)
  let angle = calc.atan2(to-x - from-x, to-y - from-y)
  angle
}

/// get the distance between two anchors
#let distance-between(ctx, from, to) = {
  let (ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(ctx, from)
  let (ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(ctx, to)
  let distance = calc.sqrt(calc.pow(to-x - from-x, 2) + calc.pow(
    to-y - from-y,
    2,
  ))
  distance
}

/// merge two imbricated dictionaries together
/// The second dictionary is the default value if the key is not present in the first dictionary
#let merge-dictionaries(dict1, default) = {
	let result = default
	for (key, value) in dict1 {
		if type(value) == dictionary {
			result.at(key) = merge-dictionaries(value, default.at(key))
		} else {
			result.at(key) = value
		}
	}
	result
}