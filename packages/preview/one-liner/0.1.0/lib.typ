#let fit-to-width( max-text-size: 64pt, min-text-size: 4pt, it) = context {
  
  let contentsize = measure(it)
  layout(size =>{
	if contentsize.width > 0pt { // Prevent failure on empty content 
		let ratio = size.width/contentsize.width
		let newx = contentsize.width*ratio
		let newy = contentsize.height*ratio
		let suggestedtextsize = 1em*ratio
		if (suggestedtextsize + 0pt).to-absolute() > max-text-size {
		  suggestedtextsize = max-text-size
		}
		if (suggestedtextsize + 0pt).to-absolute() < min-text-size {
		  suggestedtextsize = min-text-size
		}
		set text(size:suggestedtextsize)
		it
	}
    
  })
}
