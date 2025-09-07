#import "../../tools/miscellaneous.typ" : content-to-string
#let plain(content) = {
    set text(10pt)
    
    show heading: it => {

    if content-to-string(it.body) == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }

  	block(sticky: true, underline(it.body))
	}

	content
}