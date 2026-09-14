#import "@preview/cetz:0.4.2"

#let plugin = plugin("calabi_yau.wasm")

#let cmap-jet(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  let t = if calc.abs(z-hi - z-lo) > 1e-10 { 
    (z - z-lo) / (z-hi - z-lo) 
  } else { 0.5 }
  t = calc.max(0, calc.min(1, t))
  
  if t < 0.25 {
    rgb(0, 0, int(255 * (0.5 + 2 * t)))
  } else if t < 0.5 {
    rgb(0, int(255 * (4 * t - 1)), 255)
  } else if t < 0.75 {
    rgb(int(255 * (4 * t - 2)), 255, int(255 * (3 - 4 * t)))
  } else {
    rgb(255, int(255 * (4 - 4 * t)), 0)
  }
}

#let cmap-viridis(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  let t = if calc.abs(z-hi - z-lo) > 1e-10 { (z - z-lo) / (z-hi - z-lo) } else { 0.5 }
  t = calc.max(0, calc.min(1, t))
  rgb(int(68 + t * (253 - 68)), int(1 + t * (231 - 1)), int(84 + t * (37 - 84)))
}

#let cmap-plasma(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  let t = if calc.abs(z-hi - z-lo) > 1e-10 { (z - z-lo) / (z-hi - z-lo) } else { 0.5 }
  t = calc.max(0, calc.min(1, t))
  rgb(int(13 + t * (240 - 13)), int(8 + t * (249 - 8)), int(135 + t * (33 - 135)))
}

#let cmap-cool(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  let t = if calc.abs(z-hi - z-lo) > 1e-10 { (z - z-lo) / (z-hi - z-lo) } else { 0.5 }
  t = calc.max(0, calc.min(1, t))
  rgb(int(t * 255), int((1 - t) * 255), 255).lighten(20%)
}

#let cmap-hot(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  let t = if calc.abs(z-hi - z-lo) > 1e-10 { (z - z-lo) / (z-hi - z-lo) } else { 0.5 }
  t = calc.max(0, calc.min(1, t))
  let r = calc.min(1, t * 3)
  let g = calc.max(0, calc.min(1, t * 3 - 1))
  let b = calc.max(0, calc.min(1, t * 3 - 2))
  rgb(int(r * 255), int(g * 255), int(b * 255))
}

#let get-colormap(name) = {
  if name == "viridis" { cmap-viridis }
  else if name == "plasma" { cmap-plasma }
  else if name == "cool" { cmap-cool }
  else if name == "hot" { cmap-hot }
  else { cmap-jet }
}

#let project-point(x, y, z, cos-rx, sin-rx, cos-ry, sin-ry, cos-rz, sin-rz, scale) = {
  let y1 = y * cos-rx - z * sin-rx
  let z1 = y * sin-rx + z * cos-rx
  
  let x2 = x * cos-ry + z1 * sin-ry
  let z2 = -x * sin-ry + z1 * cos-ry
  
  let x3 = x2 * cos-rz - y1 * sin-rz
  let y3 = x2 * sin-rz + y1 * cos-rz

  (x3 * scale, y3 * scale)
}

#let render-mesh(mesh, color-func, z-lo, z-hi, scale-factor, rotation) = {
  import cetz.draw: *
  
  let rows = mesh.len()
  let cols = mesh.at(0).len()
  
  let (rx, ry, rz) = rotation
  let crx = calc.cos(rx)
  let srx = calc.sin(rx)
  let cry = calc.cos(ry)
  let sry = calc.sin(ry)
  let crz = calc.cos(rz)
  let srz = calc.sin(rz)

  for i in range(rows - 1) {
    for j in range(cols - 1) {
      let p00 = mesh.at(i).at(j)
      let p01 = mesh.at(i).at(j + 1)
      let p10 = mesh.at(i + 1).at(j)
      let p11 = mesh.at(i + 1).at(j + 1)
      
      let z-avg = (p00.z + p01.z + p10.z + p11.z) / 4
      let color = color-func(0, 0, z-avg, 0, 1, 0, 1, z-lo, z-hi)
      
      let v00 = project-point(p00.x, p00.y, p00.z, crx, srx, cry, sry, crz, srz, scale-factor)
      let v01 = project-point(p01.x, p01.y, p01.z, crx, srx, cry, sry, crz, srz, scale-factor)
      let v10 = project-point(p10.x, p10.y, p10.z, crx, srx, cry, sry, crz, srz, scale-factor)
      let v11 = project-point(p11.x, p11.y, p11.z, crx, srx, cry, sry, crz, srz, scale-factor)

      line(v00, v01, v10, close: true, fill: color, stroke: none)
      line(v01, v11, v10, close: true, fill: color, stroke: none)
    }
  }
}

#let calabi-yau(
  power: 3,
  angle: 0.5,
  subdivisions: 15,
  colormap: "jet",
  scale-factor: 3.0,
  rotation: (0deg, 0deg, 0deg),
  width: 400pt,
  height: 400pt,
) = {
  assert(power == int(power) and power > 0, message: "Power must be a positive integer")
  
  let n = power
  let alpha = angle
  let color-func = get-colormap(colormap)
  
  let input_str = str(n) + "," + str(alpha) + "," + str(subdivisions)
  let outputs_bytes = plugin.generate_calabi_yau(bytes(input_str))
  let outputs_str = str(outputs_bytes)
  let outputs_list = outputs_str.split(",")

  let floats = outputs_list.map(it => float(it))
  let z-max = floats.pop()
  let z-min = floats.pop()

  let n_branches = power * power
  let rows = subdivisions + 1
  let cols = subdivisions + 1

  let meshes = ()
  for b in range(n_branches) {
    let start = b * rows * cols * 3
    let branch_floats = floats.slice(start, start + rows * cols * 3)
    
    let branch_mesh = ()
    for i in range(rows) {
      let row_start = i * cols * 3
      let row = ()
      for j in range(cols) {
        let idx = row_start + j * 3
        row.push((
          x: branch_floats.at(idx),
          y: branch_floats.at(idx+1),
          z: branch_floats.at(idx+2),
        ))
      }
      branch_mesh.push(row)
    }
    meshes.push(branch_mesh)
  }

  cetz.canvas({
    import cetz.draw: *
    
    for mesh in meshes {
      render-mesh(mesh, color-func, z-min, z-max, scale-factor, rotation)
    }
  }, length: width)
}