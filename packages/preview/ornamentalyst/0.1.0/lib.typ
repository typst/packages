#import "dimensions.typ": bp, dimensions
#import "ornaments.typ": ornaments

// Converts a string corresponding to a float to a length (in bp)
#let _to_length(s) = {
  if s.at(-1) == "." {
    s = s.slice(0,-1)
  }
  float(s) * bp;
}

// Scales content to fit to the parent container (without changing the aspect ratio)
#let fit-to-dim(it) = context {
  let contentsize = measure(it)
  layout(size => {
	if contentsize.width > 0pt { // Prevent failure on empty content 
		let ratio-x = size.width/contentsize.width
		let ratio-y = size.height/contentsize.height
		let ratio-min = if ratio-x < ratio-y {
              ratio-x	
          } else {
              ratio-y
          }
        scale(ratio-min*100%, it)
	}
  })
}


// Reads a .pgf file and draw the symbol from the code
#let symbol-from-pgf-string(
  pgf-string,
  width: auto,
  height: auto,
  symmetry: none,
  fill: black,
  xscale: 100%,
  yscale: 100%,
) = {
  let lines = pgf-string.split("\n")
  let current_path = ();
  let max_x = 0pt;
  let max_y = 0pt;
  let min_x = 0pt;
  let min_y = 0pt;
  let paths = ();
  for l in lines {
    if l.len() > 1 {
      let command = l.at(1)
      let split_l = l.split(regex("\\s+"))
      if command == "m" {
        current_path.push(curve.move(
          (
            _to_length(split_l.at(1)),
            _to_length(split_l.at(2))
          ),
        )) 
      }
      else if command == "o" {
        current_path.push(curve.close()) 
      }
      else if command == "l" {
        current_path.push(curve.line(
          (
            _to_length(split_l.at(1)),
            _to_length(split_l.at(2))
          ),
        )) 
      }
      else if command == "c" {
        current_path.push(curve.cubic(
          (
            _to_length(split_l.at(1)),
            _to_length(split_l.at(2))
          ),
          (
            _to_length(split_l.at(3)),
            _to_length(split_l.at(4))
          ),
          (
            _to_length(split_l.at(5)),
            _to_length(split_l.at(6))
          ),
        ))
      }
      else if command == "k" {
        paths.push(curve(..current_path))
        current_path = ()
      }
      else if command == "i" {
        // Clip is not supported...
        current_path = ()
      }
      else if command == "s" {
        paths.push(curve(fill: fill,..current_path))
        current_path = ()
      }

      if ("m","l","c").contains(command) {
        min_x = calc.min(_to_length(split_l.at(1)),min_x)
        min_y = calc.min(_to_length(split_l.at(2)),min_y)
        max_x = calc.max(_to_length(split_l.at(1)),max_x)
        max_y = calc.max(_to_length(split_l.at(2)),max_y)
      }
    } 
  }

  if width == auto {
    width = max_x - min_x
    height = max_y - min_y
  }

  // Convention for the direction of y-axis is reversed for PGF
  let yscale = -yscale
  let pos = bottom + left
  if symmetry == "h" {
    pos = top + left
    yscale = -yscale
  }
  else if symmetry == "v" {
    pos = bottom + right
    xscale = -xscale
  }
  else if symmetry == "c" {
    pos = top + right
    xscale = -xscale
    yscale = yscale
  }

  box(width: width*calc.abs(xscale),height: height*calc.abs(xscale),inset: 0pt)[
    // Mirrored imaged is not in the correct position
    #place(pos)[
      #scale(x: xscale, y: yscale)[
        #for p in paths {
          place(left + top,p)
        }
      ]
    ]
  ]
}

// Renders one of the built-in ornaments
#let ornament(num, collection: "vectorian", width: auto, height: auto, ..args) = {
  let num_str = str(num)
  let ref_width = dimensions.at(collection).at(num_str).at(0)
  let ref_height = dimensions.at(collection).at(num_str).at(1)
  let xscale = 100%
  let yscale = 100%
  if (width != auto and height != auto) {
    xscale = width / ref_width * 100%
    yscale = height / ref_height * 100%
  }
  else if (width != auto and height == auto) {
    xscale = width / ref_width * 100%
    yscale = width / ref_width * 100%
  }
  else if (width == auto and height != auto) {
    xscale = height / ref_height * 100%
    yscale = height / ref_height * 100%
  }
  symbol-from-pgf-string(
    ornaments.at(collection).at(num_str),
    width: ref_width, 
    height: ref_height,
    xscale: xscale,
    yscale: yscale,
    ..args
  )
}

