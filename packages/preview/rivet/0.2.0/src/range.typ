#import "util.typ"

#let key(start, end) = {
  return str(start) + "->" + str(end)
}

#let bits(range) = {
  return range.end - range.start + 1
}

#let parse-span(span) = {
  let start-end = span.split("-")
  if start-end.len() == 1 {
    start-end.push(start-end.first())
  }
  let start = int(start-end.last())
  let end = int(start-end.first())
  return (start, end)
}

#let make(
  start,
  end,
  name,
  description: "",
  values: none,
  depends-on: none
) = {
  return (
    start: start,
    end: end,
    name: name,
    description: description,
    values: values,
    depends-on: depends-on,
    last-value-y: -1
  )
}

#let load(start, end, data) = {
  let values = none
  let bits = end - start + 1

  if "values" in data {
    values = (:)
    for (val, desc) in data.values {
      val = util.z-fill(val, bits)
      values.insert(val, desc)
    }
  }

  let depends-on = data.at("depends-on", default: none)
  if depends-on != none {
    depends-on = parse-span(str(depends-on))
  }

  return make(
    start,
    end,
    str(data.name),
    description: data.at("description", default: ""),
    values: values,
    depends-on: depends-on
  )
}