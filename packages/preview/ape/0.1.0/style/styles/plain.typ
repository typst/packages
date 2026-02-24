#let plain(content) = {
	
	


  show heading: it => {
    if it.body.text == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }
 	block(sticky: true, underline(it.body))
	}

	content
}