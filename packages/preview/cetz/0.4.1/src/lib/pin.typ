#let _pin-name(name) = "cetz-pin-" + name

/// Place a pin aka. cetz anchor in the document
#let pin(name) = [ #metadata("cetz-pin-tracker") #label(_pin-name(name)) ]

/// Returns all pins
#let get-pin() = context {
  let result = ()
  for item in locate(metadata) {
    if item.value.starts-with("cetz-pin-") {
      let name = item.value.slice(9)

      result.insert(name, item)
    }
  }
  panic(result)
}
