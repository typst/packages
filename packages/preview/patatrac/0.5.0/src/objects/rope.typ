#import "../anchors.typ" as anchors
#import "../objects/object.typ": object, alias

/// Creates an object of type `"rope"`, representing a one dimensional string that wraps around
/// points and circles. 
/// 
/// ```typc
/// // Example
/// import patatrac: *
/// let C = move(circle(10), 50, 50))
/// let R = rope((0,0), C, (100, 0))
/// ```
/// 
/// Abstractly, a `rope` is completely specified by its anchors
/// and an associated list of non-negative radii associated with each anchor. 
/// This is in fact the information we provide to the constructor. The anchors 
/// location specify the points the rope wraps around and the associated radii specify 
/// the distance the rope keeps from the before mentioned points. The anchors rotation is
/// used to determine in which direction the rope must go around the points. If the anchor
/// has a zero radii that the rope passes through the anchor's location. If the anchor is 
/// the first or last anchor, the rope passes through the anchor's location even if a 
/// non-zero radii is specified. If the rope can wrap around an anchors' location with 
/// positive radii in two ways than the rotation of the anchor dictates the direction in 
/// which the rope wraps around it. Every way of going around the circle has a unique
/// starting point where the straight line becomes a curve. Each of this points lies
/// on the circumference described by the anchor location and radius.
/// Therefore each of this points describes a centrifugal direction looking from the
/// center of the circle. The wrap-around direction chosen is the one whose starting 
/// outgoing direction is best aligned with the normal of the anchors.
/// _Intuitively, the rope wants to wrap from the direction normal to the anchors rotation_.
/// 
/// This `rope(...)` function takes an arbitrary number of parameters. Every argument
/// specifies an anchor and its associated radii. In order to specify an anchor with 
/// an associated radii of zero, anything that can be converted to an anchor is fine, 
/// but if an anchor of non-zero radius is desired than a `circle` is required: the 
/// anchor's location is taken to be the circles center, the anchor's rotation is taken 
/// to be the rotation of the active anchor of the circle and the wrap-around radius 
/// is taken to be the circle's radius. The function returns an object of type `"rope"` with the 
/// inputted anchors as anchors and the associated radii stored in the metadata. 
/// The anchors names are consecutive numbers, starting from 0, converted to string. 
/// The first and last anchors appear twice: also renamed "start" and "end" respectively.
#let rope(..args) = {
  let nodes = args.pos()

  if nodes.len() < 2 { panic("The function `rope` expects at least 2 positional arguments") }

  // ARGS TO POINTS AND RADII

  let count = nodes.len()
  let points = ()
  let radii = (:)

  for (i, node) in nodes.enumerate() {
    if type(node) == function and node("type") == "circle" {
      // this is a circle
      let anchor = node("anchors").at("c") // located at the circle's center
      anchor.rot = node().rot // rotated as the active anchor
      points.push(anchor)
      radii.insert(str(i+1), node("data").radius)
    } else {
      // assume this can be converted to an anchor (radius = 0)
      let anc = anchors.to-anchor(node)
      points.push(anc)
      radii.insert(str(i+1), anc.x*0)
    }
  }

  // CALCULATE ROPE SHAPE
  
  let ancs = (:)

  // Utilities
  let point-circle-tangent-directions(point, center, radius) = {
    let d = anchors.distance(point, center)
    let r = radius
    let alpha = calc.asin(r / d)
    let theta = calc.atan2(center.x - point.x, center.y - point.y)
    let beta1 = -90deg + theta - alpha
    let beta2 = +90deg + theta + alpha
    return (beta1, beta2)
  }
  let zero-threesixty-angle(angle) = 1deg * calc.rem(calc.rem(angle/1deg, 360) + 360, 360)
  let angle-between-angles(angle1, angle2) = {
    angle1 = zero-threesixty-angle(angle1)
    angle2 = zero-threesixty-angle(angle2) // because rem can give negative results otherwise
    1deg * calc.abs(calc.rem(angle1/1deg - angle2/1deg + 180, 360) - 180)
  }
  let directed-angle-between-angles(angle1, angle2, clockwise) = {
    // Finds positive angle you have to travel from angle1 to reach angle2
    let angle1 = zero-threesixty-angle(angle1)
    let angle2 = zero-threesixty-angle(angle2)
    // Assume counter-clockwise
    let delta = if angle2 > angle1 { angle2 - angle1 } else { 360deg - (angle1 - angle2) }
    // Handle clockwise
    if clockwise { delta = 360deg - delta }
    return delta
  }
  let circle-circle-tangent-directions(current, current-radius, after, after-radius) = {
    let d = anchors.distance(after, current)

    // Crossing tangents
    let intersection-to-after-distance = d / (1 + current-radius/after-radius)
    let intersection = anchors.anchor(
      after.x + (current.x - after.x) / d * intersection-to-after-distance,
      after.y + (current.y - after.y) / d * intersection-to-after-distance,
      0deg        
    )
    let (gamma1, gamma2) = point-circle-tangent-directions(intersection, current, current-radius)
    let (kappa1, kappa2) = (180deg - gamma2, 180deg - gamma1)

    // Non-crossing tangents
    let intersection-to-after-distance = d * after-radius / current-radius
    let intersection = anchors.anchor(
      after.x + (after.x - current.x) / d * intersection-to-after-distance,
      after.y + (after.y - current.y) / d * intersection-to-after-distance,
      0deg        
    )
    let (gamma3, gamma4) = point-circle-tangent-directions(intersection, current, current-radius)
    let (kappa3, kappa4) = (gamma3, gamma4)

    return (gamma1, kappa1, gamma2, kappa2, gamma3, kappa3, gamma4, kappa4)
  }

  let tip = none // tip of the pen (we imagine drawing the rope)
  for i in range(0, count) {
    let current = points.at(i)
    let current-radius = radii.at(str(i+1))
    let after = if i + 1 < count { points.at(i + 1) } else { none }
    let after-radius = if i + 1 < count { radii.at(str(i + 2)) } else { none }

    // In this cycle we need to ensure that the next cycle can draw
    // everything it needs to draw without knowing anything about this
    // cycle apart from the value of tip. This is why we use after,
    // because in order to do so we will need to now somethings about
    // whats coming after this point.

    if tip == none {
      // This is the first point
      ancs.insert(str(i + 1), current)
      if after-radius == 0 {
        ancs.insert(str(i + 1) + "o", anchors.x-look-at(current, after))
      }
      tip = current

    } else if after == none {
      // This is the last point
      ancs.insert(str(i + 1), current)
      ancs.insert(str(i + 1) + "i", anchors.x-look-from(current, tip))

      // Add anchors for the previous point if necessary
      if i == 1 {
        ancs.insert(str(i) + "o", 
          anchors.x-look-at(tip, current)
        )
      }

      tip = current
    } else if current-radius == 0 {
      // This point has zero radius (not first not last)
      ancs.insert(str(i + 1), current)
      ancs.insert(str(i + 1) + "i", anchors.x-look-from(current, tip))
      if after-radius == 0 {
        ancs.insert(str(i + 1) + "o", anchors.x-look-at(current, after))
      }
      tip = current

    } else if current-radius != 0 {
      // This point has a finite radius, therefore there is
      //  - a straight line from tip to in-point
      //  - an arc from in-point to out-point

      // Find possible in-going directions
      let (beta1, beta2) = point-circle-tangent-directions(tip, current, current-radius)

      // Choose ingoing direction according to anchor's rotation TODO: not working
      let beta = if (
        angle-between-angles(beta1, current.rot + 90deg) <
        angle-between-angles(beta2, current.rot + 90deg)
      ) { beta1 } else { beta2 }
      
      // Find in-point on the circle
      let in-point = anchors.slide(current, current-radius, 0, rot: beta)

      // Add anchors for the previous point if necessary
      if radii.at(str(i)) == 0 or i == 1 {
        ancs.insert(str(i) + "o", 
          anchors.x-look-at(tip, in-point)
        )
      }

      // Determine if we are traveling clockwise or counter-clockwise
      let clockwise = {
        let tip-to-current = anchors.term-by-term-difference(current, tip)
        let tip-to-in-point = anchors.term-by-term-difference(in-point, tip)
        let cross-product = tip-to-current.x*tip-to-in-point.y - tip-to-current.y*tip-to-in-point.x
        cross-product > 0
      } 

      // Find the possible outgoing directions
      if after-radius == 0 or i == count - 2 {
        // The next point is a point of zero radius or is a last point/circle
        
        // Find the possible out-going directions
        let (gamma1, gamma2) = point-circle-tangent-directions(after, current, current-radius)
        gamma1 = zero-threesixty-angle(gamma1)
        gamma2 = zero-threesixty-angle(gamma2)

        let out-point1 = anchors.slide(current, current-radius, 0, rot: gamma1)
        let out-point2 = anchors.slide(current, current-radius, 0, rot: gamma2)

        // Choose the out-going direction that matches in and out clockwise/counter-clockwise
        let clockwise1 = {
          let after-to-out-point = anchors.term-by-term-difference(out-point1, after)
          let after-to-current = anchors.term-by-term-difference(current, after)
          let cross-product = after-to-current.x*after-to-out-point.y - after-to-current.y*after-to-out-point.x
          cross-product < 0 // inverse than before since we go out not in this time
        }
        // 1 c.w. => 2 c.c.w

        let gamma = if clockwise == clockwise1 { gamma1 } else { gamma2 }
        let out-point = if clockwise == clockwise1 { out-point1 } else { out-point2 }

        // Find mid-point on the circle
        let delta = directed-angle-between-angles(beta, gamma, clockwise)
        if clockwise { delta *= -1 }
        let mid-point = anchors.slide(current, current-radius, 0, rot: beta + delta/2)

        // Set rotation (it's nicer to output angles between 0deg and 360deg)
        in-point.rot = zero-threesixty-angle( beta - 90deg + if clockwise { 0deg } else { 180deg } )
        mid-point.rot = zero-threesixty-angle( beta + delta/2 - 90deg + if clockwise { 0deg } else { 180deg } )
        out-point.rot = zero-threesixty-angle( gamma - 90deg + if clockwise { 0deg } else { 180deg } )

        ancs.insert(str(i+1), current)         // circle center rotated as active anchor
        ancs.insert(str(i+1) + "i", in-point)  // arc-start
        ancs.insert(str(i+1) + "m", mid-point) // arc-mid
        ancs.insert(str(i+1) + "o", out-point) // arc-end

        tip = out-point
      } else {
        // The next point is another circle: current-radius != 0 and after-radius != 0 
        
        // Find the possible out-going directions (gamma)
        // and the possible after-in-going directions (kappa)
        let (
          gamma1, kappa1, 
          gamma2, kappa2, 
          gamma3, kappa3, 
          gamma4, kappa4
        ) = circle-circle-tangent-directions(current, current-radius, after, after-radius)
        
        let out-point1 = anchors.slide(current, current-radius, 0, rot: gamma1)
        let out-point2 = anchors.slide(current, current-radius, 0, rot: gamma2)
        let out-point3 = anchors.slide(current, current-radius, 0, rot: gamma3)
        let out-point4 = anchors.slide(current, current-radius, 0, rot: gamma4)

        let after-in-point1 = anchors.slide(after, after-radius, 0, rot: kappa1)
        let after-in-point2 = anchors.slide(after, after-radius, 0, rot: kappa2)
        let after-in-point3 = anchors.slide(after, after-radius, 0, rot: kappa3)
        let after-in-point4 = anchors.slide(after, after-radius, 0, rot: kappa4)

        // Choose between 1 and 2 and between 3 and 4
        
        let clockwise1 = {
          let after-to-out-point = anchors.term-by-term-difference(out-point1, after-in-point1)
          let after-to-current = anchors.term-by-term-difference(current, after-in-point1)
          let cross-product = after-to-current.x*after-to-out-point.y - after-to-current.y*after-to-out-point.x
          cross-product < 0 // inverse than before since we go out not in this time
        }
        let choose1 = clockwise1 == clockwise

        let clockwise3 = {
          let after-to-out-point = anchors.term-by-term-difference(out-point3, after-in-point3)
          let after-to-current = anchors.term-by-term-difference(current, after-in-point3)
          let cross-product = after-to-current.x*after-to-out-point.y - after-to-current.y*after-to-out-point.x
          cross-product < 0 // inverse than before since we go out not in this time
        }
        let choose1 = clockwise1 == clockwise
        let choose3 = clockwise3 == clockwise

        // Choose between A and B

        let kappaA = if choose1 { kappa1 } else { kappa2 }
        let gammaA = if choose1 { gamma1 } else { gamma2 }
        let out-pointA = if choose1 { out-point1 } else { out-point2 }
        let after-in-pointA = if choose1 { after-in-point1 } else { after-in-point2 }


        let kappaB = if choose3 { kappa3 } else { kappa4 }
        let gammaB = if choose3 { gamma3 } else { gamma4 }
        let out-pointB = if choose3 { out-point3 } else { out-point4 }
        let after-in-pointB = if choose3 { after-in-point3 } else { after-in-point4 }

        // Now, the choice between A and B is done considering where the after circle
        // wants the rope to come in from. One option will come from the right direction
        // and the other not. We have to do what we did for beta but this time, we will
        // use the preference given by the after circle to choose how to exit from the
        // current circle

        let chooseA = (
          angle-between-angles(kappaA, after.rot + 90deg) <
          angle-between-angles(kappaB, after.rot + 90deg)
        )

        // let kappa = zero-threesixty-angle( if chooseA { kappaA } else { kappaB } )
        let gamma = zero-threesixty-angle( if chooseA { gammaA } else { gammaB } )
        // let after-in-point = if chooseA { after-in-pointA } else { after-in-pointB }
        let out-point = if chooseA { out-pointA } else { out-pointB }
        
        // Now it's the same code as before to create the arc

        // Find mid-point on the circle
        let delta = directed-angle-between-angles(beta, gamma, clockwise)
        if clockwise { delta *= -1 }
        let mid-point = anchors.slide(current, current-radius, 0, rot: beta + delta/2)

        // Set rotation (it's nicer to output angles between 0deg and 360deg)
        in-point.rot = zero-threesixty-angle( beta - 90deg + if clockwise { 0deg } else { 180deg } )
        mid-point.rot = zero-threesixty-angle( beta + delta/2 - 90deg + if clockwise { 0deg } else { 180deg } )
        out-point.rot = zero-threesixty-angle( gamma - 90deg + if clockwise { 0deg } else { 180deg } )

        ancs.insert(str(i+1), current)         // circle center rotated as active anchor
        ancs.insert(str(i+1) + "i", in-point)  // arc-start
        ancs.insert(str(i+1) + "m", mid-point) // arc-mid
        ancs.insert(str(i+1) + "o", out-point) // arc-end

        tip = out-point
      }
    }

    i += 1
  }

  // ADD START AND END ANCHORS
  ancs.insert("start", ancs.at("1o"))
  ancs.insert("end", ancs.at(str(count) + "i"))

  return object("rope", "start", ancs, data: ("count": count, "radii": radii))
}