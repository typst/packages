#let room(body) = {
  context {
    let size = measure(body)
    box(height: size.height, body)
  }
}