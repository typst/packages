#let in-outline = state("turbocharged-dhbw-in-outline", false)


#let source(body) = context {
  if not in-outline.get() {
    let bare-cite = (
      type(body) == content and body.func() in (cite, ref)
    )
    if bare-cite { [ #body] } else { [ (#body)] }
  }
}
