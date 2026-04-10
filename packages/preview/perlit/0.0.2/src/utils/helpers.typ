#let array_to_dict(arr, key) = {
  assert(arr.all(el => key in el))

  let res = (:)

  for el in arr {
    res.insert(el.at(key), el)
  }

  res
}

#let get_color(element) = {
  if "color" not in element {
    black
  } else if element.color.first() != "#" {
    let color_map = (
      "0": black,
      "1": red,
      "2": orange,
      "3": yellow,
      "4": green,
      "5": teal,
      "6": purple,
    )

    if element.color in color_map {
      color_map.at(element.color)
    } else {
      black
    }
  } else {
    rgb(element.color)
  }
}

