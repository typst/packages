#let links_state = state("links")
#let reflink(dest, body) = {
  let it = link(dest, body)
  links_state.update(links=>{
    links
    [+ #it] 
  })
  it
}

#let stars(num) = {
  for _ in range(num) {
    [\u{2B50}]
  }
}
