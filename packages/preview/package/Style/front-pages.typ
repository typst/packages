#let front-pages(title, titlePage, authors, outline, customOutline) = {
	

	let smallTitle3 = {
		 line(length: 100%)
    text(
      size: 22pt,
      font: "Noto Sans Georgian",
      align(
        center,
        [
          *#title.at(0) - #title.at(1)*
        ],
      ),
    )


    line(length: 100%)
    v(15pt)
	}
	let smallTitle2 = {
		
  align(
      center,
      box(
        width: 110%,
        inset: 0.75cm,

        radius: 0.5cm,
        stroke: 1pt,
        [



          #place(
            dy: -1.2cm,
            [
              #rect(fill: white)[
                #text(size: 20pt, [*#title.at(0)*])
              ]
            ],
          )




          #{
            if title.at(1).len() > 0 {
              place(
                dy: 0.3cm,
                dx: 99% - measure(text(size: 16pt, [*#title.at(1)*])).width,
                [
                  #rect(fill: white)[
                    #text(size: 16pt, [*#title.at(1)*])
                  ]
                ],
              )
            }
          }

        ],
      ),
    )

	}
	let smallTitle1 = {
	if type(title) == "string" {
  align(
      center,
      box(
        width: 110%,
        inset: 0.75cm,

        radius: 0.5cm,
        stroke: 1pt,
        [
					#set text(size: 20pt)
					#strong(title)
				]
			))
	}}
	
	let smallTitle = {
		if type(title) == "array" {
			if titlePage or outline {
				smallTitle3
			}else{
				smallTitle2
			}
		}else {
			smallTitle1
		}
	}
	
	
	if titlePage {
    align(
      center + horizon,
      [
        #text(size: 60pt, hyphenate: false, {
					if type(title) == "string" {
						[*#title*]
					}else{
						[
							*#title.at(1)* 
							#v(-30pt)
							#text(size: 25pt, title.at(0))
					]
					}
				}) 

        #set text(size: 12pt)
        #v(1cm)
        #{
					if authors.len() > 0 { 
					[
						#authors.at(0)
					]
					}
					if authors.len() > 1 { 
					[
						#authors.slice(1).join(" - ")
					]
					}
				}
        


      ],
    )

    pagebreak()
    if outline {
      customOutline
      pagebreak()
    }

   smallTitle
  } else {
    if outline {
      customOutline
      pagebreak()
    }

			smallTitle

    v(15pt)
  }

	
}