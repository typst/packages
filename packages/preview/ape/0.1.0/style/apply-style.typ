#import "styles/numbered.typ": *
#import "styles/colored.typ": *
#import "styles/plain.typ": *
#import "styles/presentation.typ": *

#let apply-style(style, content) = {
  set heading(numbering: "I)1)a)i)")


	if style == "numbered" {
		return numbered(content)
	}else if style == "colored" {
		return colored(content)
	}else if style == "plain" {
	return plain(content)
	}else if style == "presentation" {
	return presentation(content)
	
	}else {
		return numbered(content)
	}

}

