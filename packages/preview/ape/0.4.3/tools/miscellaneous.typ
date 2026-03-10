#let content-to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else {
    ""
  }
}

#let to-array(content) = {
  if type(content) == array {
    return content
  }else {
    return (content,)
  }
}
