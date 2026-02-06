#import "@preview/cetz:0.3.4"

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


///	get the type of an element by its name
///
/// - body (drawable): the chemfig body of a molecule 
/// - name (string): the name of the element to get the type
/// -> string
#let get-element-type(body, name) = {
	for element in body {
		if type(element) != dictionary {
			continue
		}
		if "name" in element and element.name == name {
			return element.type
		}
		if element.type == "branch" or element.type == "cycle" or element.type == "parenthesis" {
			let type = get-element-type(element.body, name)
			if type != none {
				return type
			}
		}
	}
	none
}