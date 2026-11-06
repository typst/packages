#import "@preview/cetz:0.3.4"

/// Convert any angle to an angle between 0deg and 360deg
#let angle-correction(a) = {
  if type(a) == angle {
    a = a.deg()
  }
  if type(a) != float and type(a) != int {
    panic("angle-correction: The angle must be a number or an angle")
  }
	while a < 0 {
		a += 360
	}

  calc.rem(a, 360) * 1deg
}

/// Check if the angle is in the range [from, to[
/// 
/// - angle (float, int, angle): The angle to check
/// - from (float): The start of the range
/// - to (float): The end of the range
/// -> true if the angle is in the range
#let angle-in-range(angle, from, to) = {
  if to < from {
    panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
  }
  angle = angle-correction(angle)
  angle >= from and angle < to
}

/// Check if the angle is in the range ]from, to[
///
/// - angle (float, int, angle): The angle to check
/// - from (float): The start of the range
/// - to (float): The end of the range
/// -> true if the angle is in the range
#let angle-in-range-strict(angle, from, to) = {
	if to < from {
		panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
	}
	angle = angle-correction(angle)
	angle > from and angle < to
}

/// Check if the angle is in the range [from, to]
///	
/// - angle (float, int, angle): The angle to check
/// - from (float): The start of the range
/// - to (float): The end of the range
/// -> true if the angle is in the range
#let angle-in-range-inclusive(angle, from, to) = {
	if to < from {
		panic("angle-in-range: The 'to' angle must be greater than the 'from' angle")
	}
	angle = angle-correction(angle)
	angle >= from and angle <= to
}

/// get the angle between two anchors
/// 
/// - ctx (cetz-ctx): The cetz context
/// - from (anchor): The first anchor
/// - to (anchor): The second anchor
#let angle-between(ctx, from, to) = {
  let (ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(ctx, from)
  let (ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(ctx, to)
  let angle = calc.atan2(to-x - from-x, to-y - from-y)
  angle
}

/// Calculate the angle from an object with "relative", "absolute" or "angle" key
/// according to the alchemist context (see the manual to see how angles are calculated)
///
/// - ctx (alchemist-ctx): the alchemist context 
/// - object (dict): the object to get the angle from
/// - default (angle): the default angle
/// -> the calculated angle
#let angle-from-ctx(ctx, object, default) = {
  if "relative" in object {
    object.at("relative") + ctx.relative-angle
  } else if "absolute" in object {
    object.at("absolute")
  } else if "angle" in object {
    object.at("angle") * ctx.config.angle-increment
  } else {
    default
  }
}

/// Overwrite the offset based on the angle
#let angle-override(angle, ctx) = {
  if ctx.in-cycle {
    ("offset": "left")
  } else {
    (:)
  }
}
