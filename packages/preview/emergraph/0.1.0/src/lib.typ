#import "deps.typ": fletcher
#import "version.typ"


#let amp(node, extrude, dir: right, angle: 60deg, aspect: auto, fit: 0.8) = {
	assert(dir in (top, bottom, left, right))
  return fletcher.shapes.triangle(node, extrude, dir:dir, angle:angle, aspect:aspect, fit:fit)
}

#let box(node, extrude) = {
  return fletcher.shapes.rect(node, extrude)
}

#let consumer(node, extrude) = {
  return fletcher.shapes.hexagon(node, extrude)
}

#let interaction(node, extrude) = {
  return fletcher.shapes.chevron(node, extrude)
}

#let limit(node, extrude) = {
  return fletcher.shapes.circle(node, extrude)
}

#let producer(node, extrude) = {
	let (w, h) = node.size.map(i => i/2 + extrude)
	fletcher.cetz.draw.rect(
		(-w, -h), (+w, +h),
		radius: (east:1em + extrude),
	)
}

#let sink(node, extrude) = {
  let (w,h) = (1.1em,1em)
  fletcher.cetz.draw.group({
    fletcher.cetz.draw.line((0,0),(0,-h/2))
    fletcher.cetz.draw.line((-w/2,-h/2),(w/2,-h/2))
    fletcher.cetz.draw.line((-w/4,-h),(w/4,-h))
    fletcher.cetz.draw.line((-w/3,-3*h/4),(w/3,-3*h/4))
  })
}

#let source(node, extrude) = {
  return fletcher.shapes.circle(node, extrude,)
}

#let switch(node, extrude) = {
  let (w, h) = node.size.map(i => 1.2*i/2 + extrude)
  let hc = 0.75
  let wc = 0.85
  fletcher.cetz.draw.merge-path({
    fletcher.cetz.draw.arc-through((-w,-h),(-wc*w,0),(-w,h))
    fletcher.cetz.draw.arc-through((),(0,hc*h),(w,h))
    fletcher.cetz.draw.arc-through((),(wc*w,0),(w,-h))
    fletcher.cetz.draw.arc-through((),(0,-hc*h),(-w,-h))
  })
}

#let tank(node, extrude) = {
  let (w, h) = node.size.map(i => 1.2*i/2 + extrude)
  let r = calc.max(w,h)
  let wh = 0.4 //wall height %radius
  let rh = 1.2 //roof height %radius
  fletcher.cetz.draw.group(
    name: "tank",
    fletcher.cetz.draw.merge-path(
      name: "tank-path",
      {
        fletcher.cetz.draw.arc-through((r,0),(0,-r),(-r,0))
        fletcher.cetz.draw.line(
          (-r,0),
          (-r,wh*r),
          (0,rh*r),
          (r,wh*r),
          (r,0)
        )
      }
    )
  )
}

#let transaction(node, extrude) = {
  return fletcher.shapes.diamond(node, extrude)
}


#let ALL-ESL-SHAPES = (
	amp: amp,
  box: box,
  consumer: consumer,
  interaction:interaction,
  limit:limit,
  producer:producer,
  sink:sink,
  source:source,
  switch:switch,
  tank: tank,
  transaction:transaction,
)