#import "@preview/cetz:0.4.2"
#import cetz.draw: *


#let lists = (
  all: "lLhHzpPnNud0123456789x.|".clusters(),
  buses: ("x","2","3","4","5","6","7","8","9"),
  buses-labelable: ("2","3","4","5","6","7","8","9"),
  half: (),
  ends-high: ("1","n","h","u",),
  ends-low: ("0","p","l","d",),
  merge-chars: ("x","u","d","/","z")
)


#let vertical-line(mark: none, config) = {
  let stroke-type = type(config.stroke)

  let paint = if stroke-type in (dictionary, std.stroke) {
    config.stroke.paint
  } else if stroke-type == color {
    config.stroke
  } else {
    black
  }


  line((0,0),(0,1))
  if mark == top {
    cetz.draw.mark((0,0.5), (0,1), ">", fill: paint, anchor: "center", scale: config.mark-scale)
  } else if mark == bottom {
    cetz.draw.mark((0,0.5), (0,0), ">", fill: paint, anchor: "center", scale: config.mark-scale)
  }
}

#let draw-timeskippers(outside, spacing, offset: 0) = {


  let base_points = (
    (0.5 - outside, -outside),
    (0.5,            0),
    (0.5,            1),
    (0.5 + outside,  1 + outside),
  )

  let (points_left, points_right) = (
    base_points.map(x => (x.first() - spacing/2, x.last())),
    base_points.rev().map(x => (x.first() + spacing/2, x.last()))
  )

  let a = (base_points.first(), base_points.last(),..base_points.slice(1,3))

  let paths = {
    bezier(..(points_left.first(), points_left.last(),..points_left.slice(1,3)))
    bezier(..(points_right.first(), points_right.last(),..points_right.slice(1,3)))
  }

  for off in offset {
    scope({
      translate(x: off)
    
      merge-path(stroke: none, fill: white,paths)
      paths

    })
  }
}


//  inset-1      inset-1
// <->          <->     
// ___          : :   ___
//    \         : :  /
//    :\        : : /:
//    : \___    ___/ :
//    <->          <->     
//     inset-2      inset-2
#let flank(start, end, inset-1, inset-2) = {
  line(
    start,
    (inset-1,start.last()),
    (inset-1+inset-2/2, 0.5),
    (inset-1+inset-2, end.last()),
    end
  )
}

//  inset-1
// <-> 
// ___
//    |
//    :\
//    : '^-._______
//    <->  :
//     inset-2
// <------->
//      symbol-width / 2      
#let lncurve(start, end, inset, cut: false) = {
  merge-path({
    line(start,(inset, start.last()))
    bezier(
      (inset, start.last()),
      (end.first()/2, end.last()),
      ((inset + end.first()/2)/3, end.last())
    )
    
    if not cut {
      line((end.first()/2, end.last()),(end.first(), end.last()))
    } 
  })
}

#let bus2lncurve(end, inset-1) = {
  merge-path({
    line((end.first(),1),(end.first() + inset-1, 1))
    bezier(
      (end.first() + inset-1, 1),
      (end.first() + 0.5, end.last()),
      (end.first() + (inset-1 + 0.5)/3, end.last()),
    )
    bezier(
      (end.first() + 0.5, end.last()),
      (end.first() + inset-1, 0),
      (end.first() + (inset-1 + 0.5)/3, end.last()),
    )
    line((end.first() + inset-1,0),(end.first(), 0))
  })
}

// _____________          _______
//    \                  /               
//     \                /                 
//      \_______    ___/_________
#let wire2bus(start,inset-1,inset-2) = {
  // _____________
  //    \
  //     \
  //      \_______
  if start.last() == 1 {
    line(
      (start.first() + inset-1 + inset-2,1),
      start,
      (start.first() + inset-1, start.last()),
      (start.first() + inset-1 + inset-2,0),
    )
  //       _______
  //      /       
  //     /        
  // ___/_________
  } else if start.last() == 0 {
    line(
      (start.first() + inset-1 + inset-2 ,1),
      (start.first() + inset-1, start.last()),
      start,
      (start.first() + inset-1 + inset-2,0),
    )
  } else { // 0.5
    line(
      (start.first() + inset-1 + inset-2,1),
      (start.first() + inset-1 + inset-2/2,1),
      (start.first() + inset-1, start.last()),
      start,
      (start.first() + inset-1, start.last()),
      (start.first() + inset-1 + inset-2/2,0),
      (start.first() + inset-1 + inset-2,0),
    )
  }
}


//   inset-1
// <->
// ___<-> inset-2
//    \ :             
//     >:                
// ___/
#let bus2wire(end,inset,step) = {
  if end.last() == 1 {
    line(
      (end.first(),1),
      (end.first() + inset,1),
      (end.first() + inset + step, end.last()),
      (end.first() + inset,0),
      (end.first(),0),
    )
  } else if end.last() == 0 {
    line(
      (end.first(),0),
      (end.first() + inset,0),
      (end.first() + inset + step, end.last()),
      (end.first() + inset,1),
      (end.first(),1),
    )
  } else { // 0.5
    line(
      (end.first(),1),
      (end.first() + inset,1),
      (end.first() + inset + step/2, end.last()),
      (end.first() + inset + step, end.last()),
      (end.first() + inset + step/2, end.last()),
      (end.first() + inset,0),
      (end.first(),0),
    )
  }
}



//   inset-1
// <->
// ___<-> inset-2
//    \ :             
//     >:                
// ___/
#let bus-close(x-start, inset-1, inset-2) = {
  line(
    (x-start,0),
    (x-start + inset-1,0),
    (x-start + inset-1 + inset-2 / 2, 0.5),
    (x-start + inset-1,1),
    (x-start,1),
  )
}

#let bus-open(inset-1,step-2) = {
  line(
    (inset-1 + step-2, 1),
    (inset-1 + step-2/2,0.5),
    (inset-1 + step-2, 0),
  )
}


#let bus-build(prev, next, current, config) = {
  // here the check is reversed, since its easier to handle.
  let (inset-1,inset-2) = (config.inset-1,config.inset-2)

  //   .<-----------x
  //
  //
  if prev.first() == none {
    line((current.len(),1),(0,1))
  } else {
    line((current.len(),1),(inset-1 + inset-2,1))
  }

  if lower(prev.first()) in (..lists.ends-high) { // go left
    //_______________x
    //  \
    //   \
    wire2bus((0,1), config.inset-1, config.inset-2)
  } else if lower(prev.first()) in (..lists.ends-low) {
    //    ___________x
    //   /
    //__/
    wire2bus((0,0), config.inset-1, config.inset-2)
  } else if lower(prev.first()) in ("z",) {
    //    ___________x
    //___/
    //   \
    wire2bus((0,0.5), config.inset-1, config.inset-2)
  } else if prev.first() in (lists.buses) {
    //    ___________x
    //   /
    //   \
    bus-open(config.inset-1, config.inset-2)
  }
  
  //   _____________
  //   :
  //   x----------->.
  // 
  if prev.first() == none {
    line((0,0),(current.len(),0))
  } else {
    line((inset-1 + inset-2,0),(current.len(),0))
  }

  if next.first() in (lists.buses) {
    // __ 
    //   \
    // __/
    bus-close(current.len(), config.inset-1, config.inset-2)
  } else if lower(next.first()) in ("1",) {
    //_______________
    //   /
    //__/
    bus2wire((current.len(),1), config.inset-1, config.inset-2)
  } else if lower(next.first()) in ("0",) {

    //__
    //  \
    //__/\___________
    bus2wire((current.len(),0), config.inset-1, config.inset-2)
  } else if lower(next.first()) in ("z",) {
    //__
    //  '-.____________
    //__^''
    bus2lncurve((current.len(),0.5), config.inset-1)
  } else if lower(next.first()) in ("u",) {
    // __________
    //     ,^'
    // ___/
    bus2lncurve((current.len(),1), config.inset-1)
  } else if lower(next.first()) in ("d",) {
    // ___
    //    \
    // ____'-.___
    bus2lncurve((current.len(),0), config.inset-1)
  }
}
