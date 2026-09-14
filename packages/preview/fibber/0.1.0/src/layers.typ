#import "deps.typ": cetz
#import cetz: draw, vector


#let deposit-helper(layer-height, layer, width, height, position, color) = {
  draw.rect(
    (position, layer*layer-height),
    (position+width, (layer+height)*layer-height+0.01),
    fill: color,
    stroke: none
  )
}

#let etch-helper(layer-height, bottom, top, width, position, color) = {
    draw.rect(
      (position, (bottom + 1)*layer-height),
      (position + width, (top + 1)*layer-height+0.02),
      fill: color,
      stroke: none
    )
}
   
#let deposit(material: none, height: 1, pattern: ((left, middle, right)) => ((left, right),), start-layer: none) = {
  
  (layer-height, current-layer, materials, device-anchors, background-color) => {
    let layer = current-layer
    if type(start-layer) == int or type(start-layer) == float or type(start-layer) == decimal {
      layer = start-layer
    } else if type(start-layer) == function {
      layer = start-layer(current-layer)
    } else if start-layer == none {
      layer = current-layer
    } else {
      panic("start-layer has invalid type")
    }


    // code to make it so that if you specify start-layer below or above current-layer, layer does not increment
    let layer-increment = 0
    if start-layer == none {
      layer-increment = height
    } else if current-layer == start-layer {
      layer-increment = height
    }     
    ( 
     layer-increment,
      for p in pattern(device-anchors) {
        deposit-helper(layer-height, layer, p.at(1) - p.at(0), height, p.at(0), materials.at(material))
      }
    )
  }
}

#let etch(height: 1, pattern: ((left, middle, right)) => ((left, right),), start-layer: none) = {
  (layer-height, current-layer, materials, device-anchors, background-color) => {
    let layer = current-layer - 1
    if type(start-layer) == int or type(start-layer) == float or type(start-layer) == decimal {
      layer = start-layer
    } else if type(start-layer) == function {
      layer = start-layer(current-layer)
    } else if start-layer == none {
      layer = current-layer - 1
    } else {
      panic("start-layer has invalid type")
    }
    let layer-increment = 0
    (
      layer-increment,
      for p in pattern(device-anchors) {
        etch-helper(layer-height, layer - height, layer, p.at(1) - p.at(0), p.at(0), background-color)
      }
    )
  }
}

#let set-active-layer(new-layer: current-layer => current-layer) = {
  (layer-height, current-layer, materials, device-anchors, background-color) => {
    let layer = 0
    if type(new-layer) == int or type(new-layer) == float or type(new-layer) == decimal {
      layer = new-layer
    } else if type(new-layer) == function {
      layer = new-layer(current-layer)
    } else {
      panic("new-layer has invalid type")
    }
    let layer-increment = layer - current-layer
    (
      layer-increment,
      ()
    )
  }
}

#let device(width: 8, layer-height: 1, background-color: white, materials: (), steps: ()) = {
  let device-anchors = ( (left: 0, middle: width/2, right: width) )
  cetz.canvas({
    let layer = 0
    for s in steps {
      let (height, execute-step) = s(layer-height, layer, materials, device-anchors, background-color)
      execute-step
      layer += height
    }
  })
}

#let device-height(width: 8, layer-height: 1, background-color: white, materials: (:), steps: ()) = {
  let device-anchors = ( (left: 0, middle: width/2, right: width) )
  let layer = 0
  for s in steps {
    let (height, execute-step) = s(layer-height, layer, materials, device-anchors, background-color)
    layer += height
  }
  layer
}

#let device-steps(width: 8, layer-height: 1, background-color: white, materials: (), steps: (), display-steps: ()) = {
  if display-steps.len() == 0 {
    display-steps = range(0, steps.len())
  }
  let device-anchors = ( (left: 0, middle: width/2, right: width) )
  let device-height = device-height(width: width, layer-height: layer-height, background-color: background-color, materials: materials, steps: steps)
  let step-diagrams = ()
  for i in display-steps {
    let current-steps = steps.slice(0,i+1)
    step-diagrams.push(
      layout(ly => {
        cetz.canvas(length: 1/width * 100% * ly.width, {
          let layer = 0
          for s in current-steps {
            let (height, execute-step) = s(layer-height, layer, materials, device-anchors, background-color)
            execute-step
            layer += height
          }
          draw.content((0,device-height), []) 
        })
      })
    )
  }
  step-diagrams
}

#let generate-legend(materials) = {
  let legend = (:)
  for m in materials.keys() {
    legend.insert(m, 
      layout(ly => {
        cetz.canvas(length: 100% * ly.width, {
          draw.rect((0,0), (1,1), fill: materials.at(m), stroke: none)
      })})
    ) 
  }
  legend
}
