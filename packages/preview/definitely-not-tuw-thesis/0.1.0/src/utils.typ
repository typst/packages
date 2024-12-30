#let name-with-titles = p => {
  if "pre-title" in p {
    [#p.at("pre-title", default: "") ]
  }
  p.at("name", default: "")
  if "post-title" in p {
    [ #p.at("post-title", default: "")]
  }
}