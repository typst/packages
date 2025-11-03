#import "styles/numbered.typ": *
#import "styles/colored.typ": *
#import "styles/plain.typ": *
#import "styles/presentation.typ": *

#let apply-style(style, content) = {
  set heading(numbering: "I)1)a)i)")
 
  if style == "numbered" {
    return numbered(content)
  } else if style == "colored" {
    return colored(content)
  } else if style == "plain" {
    return plain(content)
  } else if style == "presentation" {
    return presentation(content)
  } else {
    return numbered(content)
  }
}

#let get-small-title(style, title) = {
  import "styles/" + style + ".typ" as current-style
  
  return current-style.get-small-title(title)

}