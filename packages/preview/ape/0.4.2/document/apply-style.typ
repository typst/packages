#import "styles/numbered.typ": *
#import "styles/colored.typ": *
#import "styles/plain.typ": *
#import "styles/presentation.typ": *
#import "styles/book.typ": *

#let apply-style(style, content) = {
  set heading(numbering: "I)1)a)i)")
 
  if style == "numbered" or style == "numbered-book" {
    return numbered(content, style)  
  } else if style == "book" {
    return book(content)
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

#let get-small-title(style, title, authors) = {
	if(style == "numbered-book" ){
		style = "numbered"
	}
  import "styles/" + style + ".typ" as current-style
  
  return current-style.get-small-title(title, authors)

}