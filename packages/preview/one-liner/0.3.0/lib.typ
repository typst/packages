#let fit-to-width(max-text-size: auto, min-text-size: 4pt, it) = context {
  let effective-max-text-size = if max-text-size == auto { 
		text.size * 3
	} else { 
		max-text-size 
	}

	let effective-min-text-size = if min-text-size == auto { 
		text.size * 0.33
	} else { 
		min-text-size 
	}

  let contentsize = measure(it)
  layout(size =>{
	if contentsize.width > 0pt { // Prevent failure on empty content 
		let ratio-x = size.width/contentsize.width
		let ratio-y = size.height/contentsize.height
		let ratio = if ratio-x < ratio-y {
				ratio-x	
			} else {
				ratio-y
			}
		
		let newx = contentsize.width*ratio
		let newy = contentsize.height*ratio
		let suggestedtextsize = 1em*ratio
		if (suggestedtextsize + 0pt).to-absolute() > effective-max-text-size {
		  suggestedtextsize = effective-max-text-size
		}
		if (suggestedtextsize + 0pt).to-absolute() < effective-min-text-size {
		  suggestedtextsize = effective-min-text-size
		}
		text(size:suggestedtextsize,it)
	}
    
  })
}

#let grow-to-width(max-text-size: auto,  it) = context {
	//set minimal size to current size so it never shrinks and only grows.
	let current-text-size = text.size
	fit-to-width(max-text-size: max-text-size,min-text-size: current-text-size,it)
}

#let shrink-to-width(min-text-size: auto,  it) = context {
	//set minimal size to current size so it never shrinks and only grows.
	let current-text-size = text.size
	fit-to-width(max-text-size: current-text-size,min-text-size: min-text-size,it)
}