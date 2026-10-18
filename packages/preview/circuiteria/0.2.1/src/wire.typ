#import "/src/cetz.typ": draw, coordinate
#import "util.typ": opposite-anchor

/// List of valid wire styles
/// #examples.wires
#let wire-styles = ("direct", "zigzag", "dodge", "guided")
#let signal-width = 1pt
#let bus-width = 1.5pt

/// Draws a wire intersection at the given anchor
/// #examples.intersection
/// - pt (point): A CeTZ compatible point / anchor
/// - radius (number): The radius of the intersection
/// - fill (color): The fill color
#let intersection(pt, radius: .1, fill: black) = {
  draw.circle(pt, radius: radius, stroke: none, fill: fill)
}

#let get-direct-wire(pts) = {
  let anchors = (
    "start": pts.first(),
    "end": pts.last()
  )
  return (pts, anchors)
}

#let get-zigzag-wire(pts, ratio, dir) = {
  let start = pts.first()
  let end = pts.last()
  let mid = if dir == "vertical" {
    (start, ratio, (horizontal: end, vertical: ()))
  } else {
    (start, ratio, (horizontal: (), vertical: end))
  }

  let points = if dir == "vertical" {
    (
      start,
      (horizontal: mid, vertical: ()),
      (horizontal: (), vertical: end),
      end
    )
  } else {
    (
      start,
      (horizontal: (), vertical: mid),
      (horizontal: end, vertical: ()),
      end
    )
  }
  let anchors = (
    "start": start,
    "zig": points.at(1),
    "zag": points.at(2),
    "end": end
  )
  return (points, anchors)
}

#let get-dodge-wire(pts, dodge-y, margins, sides, ctx) = {
  let start = pts.first()
  let end = pts.last()
  let (margin-start, margin-end) = margins
  let (side-start, side-end) = sides

  let p1 = (start, margin-start, end)
  let p2 = (end, margin-end, start)
  
  let (ctx, p0) = coordinate.resolve(ctx, start)
  let (ctx, p3) = coordinate.resolve(ctx, end)
  p0 = (x: p0.first(), y: p0.last())
  p3 = (x: p3.first(), y: p3.last())

  let dx1 = margin-start
  let dx2 = margin-end
  
  if type(margin-start) == ratio {
    dx1 = calc.abs(p3.x - p0.x) * margin-start / 100%
  }
  if type(margin-end) == ratio {
    dx2 = calc.abs(p3.x - p0.x) * margin-end / 100%
  }
  if side-start == "west" {
    dx1 *= -1
  }
  if side-end == "east" {
    dx2 *= -1
  }
  p1 = (p0.x + dx1, p0.y)
  p2 = (p3.x - dx2, p0.y)

  let points = (
    start,
    (horizontal: p1, vertical: ()),
    (horizontal: (), vertical: (0, dodge-y)),
    (horizontal: p2, vertical: ()),
    (horizontal: (), vertical: end),
    end
  )
  let anchors = (
    "start": start,
    "start2": points.at(1),
    "dodge-start": points.at(2),
    "dodge-end": points.at(3),
    "end2": points.at(4),
    "end": end
  )

  return (points, anchors)
}

#let get-guided-wire(pts, margins, sides, center-guides, ctx) = {
  let start = pts.first()
  let end = pts.last()
  let (margin-start, margin-end) = margins
  let (side-start, side-end) = sides
  let (center_horizontal, center_vertical) = center-guides

  let (ctx, p0) = coordinate.resolve(ctx, start)
  let (ctx, p6) = coordinate.resolve(ctx, end)
  p0 = (x: p0.first(), y: p0.at(1))
  p6 = (x: p6.first(), y: p6.at(1))

  let box_width = calc.abs(p6.x - p0.x)
  let box_height = calc.abs(p6.y - p0.y)

  // finding correct dx and dy
  let dx1 = box_width * margin-start / 100%
  if side-start == "west" {
    dx1 *= -1
  } else if side-start == "north" or side-start == "south" { dx1 = 0}

  let dx2 = box_width * margin-end / 100%
  if side-end == "west" {
    dx2 *= -1
  } else if side-end == "north" or side-end == "south" { dx2 = 0}

  let dy1 = box_height * margin-start / 100%
  if side-start == "south" {
    dy1 *= -1
  } else if side-start == "west" or side-start == "east" { dy1 = 0}

  let dy2 = box_height * margin-end / 100%
  if side-end == "south" {
    dy2 *= -1
  } else if side-end == "west" or side-end == "east" { dy2 = 0}


  // points that are closest to the edge points
  let p1 = (p0.x + dx1, p0.y + dy1)
  let p5 = (p6.x + dx2, p6.y + dy2)


  // middle point
  let center_x = p0.x + box_width * center_horizontal / 100%
  let center_y = p0.y + box_height * center_vertical / 100%
  let p3 = (center_x, center_y)

  // setting up the points for that touch the guides
  let p2 = (0,0)
  let p4 = (0,0)
  if side-start in ("north", "south") {
    p2 = (horizontal: p3, vertical: p1)
  } else {
    p2 = (horizontal: p1, vertical: p3)
  }
  if side-end in ("north", "south") {
    p4 = (horizontal: p3, vertical: p5)
  } else if side-end in ("east", "west") {
    p4 = (horizontal: p5, vertical: p3)
  }

  // returning
  let points = (
    start,
    p1,
    p2,
    p3,
    p4,
    p5,
    end
  )
  let anchors = (
    "start": start,
    "start2": points.at(1),
    "guide-start": points.at(2),
    "center": points.at(3),
    "guide-end": points.at(4),
    "end2": points.at(5),
    "end": end
  )
  return (points, anchors)
}
/// Draws a wire between two points
/// - id (str): The wire's id, for future reference (anchors)
/// - pts (array): The two points (as CeTZ compatible coordinates, i.e. XY, relative positions, ids, etc.)
/// - bus (bool): Whether the wire is a bus (multiple bits) or a simple signal (single bit)
/// - name (none, str, array): Optional name of the wire. If it is an array, the first name will be put at the start of the wire, and the second at the end
/// - name-pos (str): Position of the name. One of: "middle", "start" or "end"
/// - slice (none, array): Optional bits slice (start and end bit indices). If set, it will be displayed at the start of the wire
/// - color (color): The stroke color
/// - dashed (bool): Whether the stroke is dashed or not
/// - style (str): The wire's style (see #doc-ref("wire.wire-styles", var: true) for possible values)
/// - reverse (bool): If true, the start and end points will be swapped (useful in cases where the start point depends on the end point, for example with perpendiculars)
/// - directed (bool): If true, the wire will be directed, meaning an arrow will be drawn at the endpoint
/// - rotate-name (bool): If true, the name will be rotated according to the wire's slope
/// - zigzag-ratio (ratio): Position of the zigzag vertical relative to the horizontal span (only with style "zigzag")
/// - zigzag-dir (str): The zigzag's direction. As either "vertical" or "horizontal" (only with dstyle "zigzag")
/// - dodge-y (number): Y position to dodge the wire to (only with style "dodge")
/// - dodge-sides (array): The start and end sides (going out of the connected element) of the wire (only with style "dodge")
/// - dodge-margins (array): The start and end margins (i.e. space before dodging) of the wire (only with style "dodge")
/// - guided-center (array): the horizontal and vertical guides of the center guides (only with style "guided")
/// - guided-margins (array): the start and end of guided margins of the wire (only with style "guided")
/// - guided-sides (array): the side of start and end array (must be either "north", "south", "west", "east") (only work with style "guided")
#let wire(
  id, pts,
  bus: false,
  name: none,
  name-pos: "middle",
  slice: none,
  color: black,
  dashed: false,
  style: "direct",
  reverse: false,
  guided-center: (50%, 50%),
  guided-margins: (5%, 5%),
  guided-sides: ("east", "west"),
  directed: false,
  rotate-name: true,
  zigzag-ratio: 50%,
  zigzag-dir: "vertical",
  dodge-y: 0,
  dodge-sides: ("east", "west"),
  dodge-margins: (5%, 5%)
) = draw.get-ctx(ctx => {
  if not style in wire-styles {
    panic("Invalid wire style '" + style + "'")
  }

  if pts.len() != 2 {
    panic("Wrong number of points (got " + str(pts.len()) + " instead of 2)")
  }
  
  let stroke = (
    paint: color,
    thickness: if bus {bus-width} else {signal-width}
  )
  if dashed {
    stroke.insert("dash", "dashed")
  }

  let points = ()
  let anchors = ()

  if style == "direct" {
    (points, anchors) = get-direct-wire(pts)
    
  } else if style == "zigzag" {
    (points, anchors) = get-zigzag-wire(pts, zigzag-ratio, zigzag-dir)
    
  } else if style == "dodge" {
    (points, anchors) = get-dodge-wire(
      pts,
      dodge-y,
      dodge-margins,
      dodge-sides,
      ctx
    )
  } else if style == "guided" {
    (points, anchors) = get-guided-wire(
      pts,
      guided-margins,
      guided-sides,
      guided-center,
      ctx
    )
  }

  let mark = (fill: color)
  if directed {
    mark = (end: ">", fill: color)
  }
  draw.group(name: id, {
    draw.line(..points, stroke: stroke, mark: mark)
    for (anchor-name, anchor-pos) in anchors {
      draw.anchor(anchor-name, anchor-pos)
    }
  })

  let first-pt = id + ".start"
  let last-pt = id + ".end"
  let first-pos = points.first()
  let second-pos = points.at(1)
  if reverse {
    (first-pt, last-pt) = (last-pt, first-pt)
  }
  
  let angle = 0deg
  if rotate-name {
    (ctx, first-pos) = coordinate.resolve(ctx, first-pos)
    (ctx, second-pos) = coordinate.resolve(ctx, second-pos)
    
    if reverse {
      (first-pos, second-pos) = (second-pos, first-pos)
    }
    let (x1, y1, ..) = first-pos
    let (x2, y2, ..) = second-pos
    angle = calc.atan2(x2 - x1, y2 - y1)
  }
  
  if name != none {
    let names = ()
    
    if type(name) == str {
      names = ((name, name-pos),)
      
    } else if type(name) == array {
      names = (
        (name.at(0), "start"),
        (name.at(1), "end")
      )
    }

    for (name, pos) in names {
      let point
      let anchor
      
      if pos == "middle" {
        point = (first-pt, 50%, last-pt)
        anchor = "south"

      } else if pos == "start" {
        point = first-pt
        anchor = "south-west"

      } else if pos == "end" {
        point = last-pt
        anchor = "south-east"
      }

      draw.content(point, anchor: anchor, padding: 3pt, angle: angle, name)
    }
  }

  if slice != none {
    let slice-txt = "[" + slice.map(b => str(b)).join(":") + "]"
    
    draw.content(
      first-pt,
      anchor: "south-west",
      padding: 3pt,
      text(slice-txt, size: 0.75em)
    )
  }
})

/// Draws a wire stub (useful for unlinked ports)
///
/// #examples.stub
/// - port-id (str): The port anchor
/// - side (str): The side on which the port is (one of "north", "east", "south", "west")
/// - name (none, str): Optional name displayed at the end of the stub
/// - vertical (bool): Whether the name should be displayed vertically
/// - length (number): The length of the stub
/// - name-offset (number): The name offset, perpendicular to the stub
#let stub(port-id, side, name: none, vertical: false, length: 1em, name-offset: 0) = {
  let end-offset = (
    north: (0, length),
    east: (length, 0),
    south: (0, -length),
    west: (-length, 0)
  ).at(side)
  
  let name-offset = (
    north: (name-offset, length),
    east: (length, name-offset),
    south: (name-offset, -length),
    west: (-length, name-offset)
  ).at(side)

  draw.line(
    port-id,
    (rel: end-offset, to: port-id)
  )
  if name != none {
    let text-anchor = if vertical {
      (
        "north": "west",
        "south": "east",
        "west": "south",
        "east": "north"
      ).at(side)
    } else { opposite-anchor(side) }
    draw.content(
      anchor: text-anchor,
      padding: 0.2em,
      angle: if vertical {90deg} else {0deg},
      (rel: name-offset, to: port-id),
      name
    )
  }
}
