#let colored(content) = {
	
	

  show heading: it => {
    if it.body.text == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }
   block(breakable: false)[
        #it.body
        #move(
          dy: -4pt - measure(it.body).height,
          line(
            length: 100%,
            stroke: calc.max(1pt, calc.min(4pt, 4pt - 1pt * it.level)) + blue.darken(20% - 20% * (it.level - 1)),
          ),
        )
      ]
	}

	content
}