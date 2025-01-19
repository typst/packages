#import "styles/numbered.typ": *
#import "styles/colored.typ": *
#import "styles/plain.typ": *
#import "styles/presentation.typ": *

#let applyStyle(style, contenu) = {
  set heading(numbering: "I)1)a)i)")


	if style == "numbered" {
		return numbered(contenu)
	}else if style == "colored" {
		return colored(contenu)
	}else if style == "plain" {
	return plain(contenu)
	}else if style == "presentation" {
	return presentation(contenu)
	
	}else {
		return numbered(contenu)
	}

}

