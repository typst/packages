
#import "../assertations.typ"
#import "../process-styles.typ": merge-strokes, merge-fills
#import "../utility.typ": if-none
#import "../model/mark.typ": mark, marks

#import "map.typ": petroff10
#import "cycle.typ": generic


#let _auto = rgb("#0000A1AA")

#let style = std.circle

#let process-stroke(stroke, color) = {
  if stroke == none { return none }
  if stroke.paint == _auto {
    std.stroke(paint: color, thickness: stroke.thickness, cap: stroke.cap, join: stroke.join, dash: stroke.dash, miter-limit: stroke.miter-limit)
  } else { 
    stroke
  }
}



#let init(body) = {
    
  show mark: it => {
    let color = style.fill
    (it.align)((
      size: it.inset.length, 
      fill: if it.fill == _auto { color } else { it.fill }, 
      stroke: process-stroke(it.stroke, color),
      color: color
    ))
  }
  
  
  set style(fill: black)
  set mark(fill: _auto, stroke: _auto + .7pt, align: marks.at("."), inset: 4pt)
  body
}




#let prepare-path(body, stroke: auto, fill: none, element: curve) = context {
  
  set element(stroke: merge-strokes(style.stroke, style.fill), fill: merge-fills(fill, style.fill))
  set element(stroke: stroke) if stroke != auto
  body
}

#let prepare-line(body, stroke: auto) = context {
  set line(stroke: merge-strokes(style.stroke, style.fill))
  set line(stroke: stroke) if stroke != auto
  body
}

#let resolve-mark(mark) = {
  if mark == none { 
    mark = "none" 
  }

  if type(mark) == str { 
    if mark not in marks {
      assert(false, message: "Unknown mark \"" + mark + "\"")
    }
    marks.at(mark) 
  } else if type(mark) == function or mark == auto {
    mark
  } else {
    assert(false, message: "Invalid mark " + repr(mark))
  }
}



#let process-cycles-arg(cycle) = {
  assert(cycle.len() > 0, message: "The style cycle for the diagram must not be empty")
  if type(cycle.first()) == color {
    generic(style, fill: cycle)
  } else if type(cycle.first()) == dictionary {
    cycle.map(c => {
      assertations.assert-dict-keys(c, optional: ("color", "stroke", "mark"))
      
      it => {
        set style(fill: c.color) if "color" in c
        set style(stroke: c.stroke) if "stroke" in c
        set mark(align: resolve-mark(c.mark)) if "mark" in c
        it
      }
    })
  } else {
    cycle
  }
}




#let prepare-mark(
  body, 
  color: auto, 
  stroke: auto, 
  func: auto,
  fill: auto,
  size: auto
) = {
  set style(fill: color) if color != auto
  func = resolve-mark(func)
  set mark(align: func) if func != auto
  set mark(fill: fill) if fill != auto
  set mark(inset: size) if size != auto
  body
}






#show raw.where(block: true): block.with(fill: luma(95%), inset: 1em)
#show raw.where(block: false): box.with(fill: luma(95%), outset: (y: .3em), inset: (x: .3em,), radius: .2em)

#show: init





== Mark sizes 
Marks are deliberately designed to match in optical size for the same size setting. This results in the `mark.size` not giving a precise definition of the width or radius of some marks. The optical size is subjective and is influenced by a combination of the area and the dimensions of a mark. 

Adjustments made:
- The square is a bit smaller to better match the optical size of the circle. 
- The polygons with low $n$ are drawn with a larger circumference
- Stars are drawn a bit larger to compensate their lack of area. 
- ... and some more. 
- The circle mark has (at least when the stroke is set to `none`) the exact radius as given through `mark.size`
In addition, polygons with 3, 5, and 7 sides are lowered by a fraction to improve the optical center. 




#{

  
  let config = (size: 20pt, fill: blue, stroke: blue + 1pt)
  marks.pairs().map(((name, mark)) => box({
    table(
      text(.8em, raw(name)),
      box(
        width: config.size*1.5, height: config.size*1.5,
        
        stroke: 1pt + gray,
        {
          set line(stroke: .5pt + gray)
          place(line(start: (0%, 50%), length: config.size*1.5))
          place(line(start: (50%, 0%), angle: 90deg, length: config.size*1.5))
          place(mark(config), dx: 50%, dy: 50%)
        }
      )
    )
  })).join()
}


== Implementation notes and ramble

Marks are essential for visualizing data. The configuration and selection of marks is therefore of greatest importance and requires a well-thought-out solution. 

Things to consider:
- Marks need a mechanism to inherit their color (both fill and stroke) from the current line style by default, so the user needs to set the color only once for both line and marks. At the same time, marks also need an option to specify their color separately. 
- Marks need to be configurable in cycle styles (style sets that determine how consecutive calls to plot functions will be styled by default). 
- Some default marks have a configurable parameter such as the angle or the number of spikes. 
- It should be easy to create a custom mark shape. Marks should be just functions that get passed information about the color and stroke to be used for the mark. 

For these reasons, `mark` should be a type defined as the following:

#show "#type": text.with(red)
```typc
#type mark {
  /// How to fill the mark. 
  fill: auto | color | gradient | tiling = auto,
  
  /// How to stroke the mark. 
  stroke: none | stroke = 1pt,

  /// The size of the mark. 
  size: length = 4pt
  
  /// Mark function or known mark name. 
  mark: str | function = "o"
}
```
The mark functions receive a dictionary with `size`, `fill`, and `stroke` which they can use to create the content of the mark, e.g., 
```typ
#let circle = mark => {
  circle(radius: mark.size / 2, fill: mark.fill, stroke: mark.stroke)
}
```
Alternatively, `mark` could always be contextual content (`any`), e.g, 
```typ
#let circle = context {
  std.circle(radius: mark.size/2, fill: mark.fill, stroke: mark.stroke)
}

#show mark: it => {
  let color = style.fill
  set mark(
    inset: it.inset.length, 
    fill: if it.fill == auto { color } else { it.fill }, 
    stroke: process-stroke(mark.stroke, color),
  )
  it.mark
}
```
This might be yet a bit cleaner. #highlight[Actually, it's muuuuuch worse in performance. Moreover the first version can be optimized to compute many marks at once. ]


Possible behaviors for filled marks:
- Are by default filled *and* stroked with `color` and a `1pt` outline. 
- Stroke and fill color can be set manually to vary from the line `color`. Setting `fill` to `none` results in an unfilled mark. 
or
- Are by default *only* filled
- If `stroke: auto`, they show no stroke. 

// #[
    
//   #set mark(align: circle)
//   #mark()~
//   #set style(fill: red)
//   #mark()~
//   #set mark(fill: orange)
//   #mark()~
//   #mark(fill: green)~
//   #set mark(fill: none, stroke: .5pt)
//   #mark()~
//   #set mark(fill: _auto, stroke: blue)
//   #mark()~
// ]


Possible behaviors for (only) stroked marks:
- Can only be stroked
- Are by default stroked with `color` and `1pt`. 
- The stroke can be set manually
or
- If `stroke: auto` or `stroke.fill: auto` they inherit the color 
  - firstly from `mark.fill`
  - secondly from `style.fill`

Currently, we have the first (and probably better) behavior for both. 
// #let mymark = context {
//   std.circle(radius: mark.inset.length/2, fill: mark.fill, stroke: mark.stroke)
// }

// #set style(fill: green)
// #range(42000).map(x => mark()).join()
// #range(4200).map(x => {
//   set mark(inset: calc.sqrt(x) *.1pt, fill: green)
//   box(mymark)}
// ).join()
// #range(4000).map(x => place(circle()((size: calc.sqrt(x) *.2pt, fill: green, stroke:blue)))).join()


// #[
    
//   #set mark(align: cross)
//   #mark()~
//   #set style(fill: red)
//   #mark()~
//   #set mark(fill: orange)
//   #mark()~
//   #set mark(stroke: 1.5pt)
//   #set mark(stroke: (cap: "round"), inset: 10pt)
//   #mark()~
//   #set mark(stroke: green)
//   #mark(stroke: 2pt)~
  
// ]



