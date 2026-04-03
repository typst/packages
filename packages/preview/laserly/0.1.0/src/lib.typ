#let _element_order = (
  "fiber_coupler",
  "lambda-DIV-2",
  "lambda-DIV-4",
  "lens",
  "shutter",
  "iris",
  "beam_block",
  "beam_dump",
  "dichroic",
  "beam_sampler",
  "beam_splitter_cube",
  "mirror",
  "flip_mirror",
  "periscope",
  "grating",
  "aom",
  "eom",
  "laser_diode",
  "camera",
  "photodiode",
  "isolator",
  "objective",
  "cavity",
  "laser",

  // "fiber",
  // "laser_beam",
  // "info",
)

#let _rotate_around_point(img, rot, dx, dy) = {
  move(dx: dx, dy: dy, rotate(rot, move(dx: -dx, dy: -dy, img)))
}

#let _load_svg(filename, size: 1.0) = {
  let data = read(filename)

  let width_str = data.find(regex("width=\\\"[0-9]+\.[0-9]+mm"))
  let height_str = data.find(regex("height=\\\"[0-9]+\.[0-9]+mm"))

  let width = float(width_str.slice(7, -2))
  let height = float(height_str.slice(8, -2))

  if size != 1.0 {
    data = data.replace(width_str, "width=\"" + str(width * size) + "mm")
    data = data.replace(height_str, "height=\"" + str(height * size) + "mm")

    for m in data.matches(regex("stroke-width:[0-9]+\.?[0-9]*")).rev() {
      let stroke_width = float(data.slice(m.start+13, m.end))
      data = data.slice(0, m.start+13) + str(stroke_width / size) + data.slice(m.end)
    }
  }
  image(bytes(data))
}

#let _add_element(arr, o) = {
  if type(o) == dictionary {
    if o.type not in arr {
      arr.insert(o.type, (o.variant,))
    } else {
      if o.variant not in arr.at(o.type) {
        arr.at(o.type).push(o.variant)
      }
    }
  }
  else {
    if o.at(0) not in arr {
      arr.insert(o.at(0), o.at(1))
    } else {
      for variant in o.at(1) {
        if variant not in arr.at(o.at(0)) {
          arr.at(o.at(0)).push(variant)
        }
      }
    }
  }
  return arr
}
#let assemble(rot: 0deg, stroke: 1pt+black, objs) = {
  if type(objs) != array {
    objs = (objs,)
  }

  let elements = (:)

  let min_dx = 0pt
  let max_dx = 0pt
  let min_dy = 0pt
  let max_dy = 0pt

  let contents = {
    let dist = 20pt

    let dx = 0pt
    let dy = 0pt

    let light_angle = rot

    let infos_list = ()
    let drawings_list = ()
    let laser_lines_list = ()

    let i = 0
    for o_fct in objs {
      let o = o_fct(stroke: stroke)

      elements = _add_element(elements, o)

      let om = measure(o.obj)
      let rot = 0deg

      let ndx = dx + o.dist * calc.cos(light_angle)
      let ndy = dy + o.dist * calc.sin(light_angle)

      let p = (o.pivot)(o.obj)
      let rotated_object = _rotate_around_point(o.obj, light_angle +o.rot, p.x, p.y)
      drawings_list.push(place(rotated_object, dx: ndx -om.width/2, dy: ndy -om.height/2))

      if i >= 0 {
        laser_lines_list.push(place(line(start: (dx, dy), end: (ndx, ndy), stroke: stroke)))
      }

      dx = ndx
      dy = ndy

      // Somehow we can't just measure(rotated_object), so we have to do it manually
      let em = measure(o.obj)
      let em_w = calc.abs(em.width * calc.cos(light_angle +o.rot) + em.height * calc.sin(light_angle +o.rot))
      let em_h = calc.abs(em.width * calc.sin(light_angle +o.rot) + em.height * calc.cos(light_angle +o.rot))

      min_dx = calc.min(min_dx, ndx - em_w / 2)
      max_dx = calc.max(max_dx, ndx + em_w / 2)
      min_dy = calc.min(min_dy, ndy - em_h / 2)
      max_dy = calc.max(max_dy, ndy + em_h / 2)

      // Draw the info circle
      if o.info-pos != none {
        let margin = 2pt
        if o.type == "arrow" {
          margin = 6pt
        }

        let idx = 0
        let idy = 0
        if o.info-pos == left { idx = -1 }
        else if o.info-pos == right { idx = 1 }
        else if o.info-pos == top { idy = -1 }
        else if o.info-pos == bottom { idy = 1 }
        else { assert(false, "o.info needs to be one of [top, right, bottom, left]") }

        let info_img_data = read("assets/info/1.svg")

        info_img_data = info_img_data.replace(">1<", ">" + str(o.info-num) + "<")

        let info_img = image(bytes(info_img_data))
        let im = measure(info_img)
        place(info_img,
          dx: dx -im.width/2 +idx*(em_w/2 + im.width/2 + margin),
          dy: dy -im.height/2 +idy*(em_h/2 + im.height/2 + margin))

        min_dx = calc.min(min_dx, min_dx + idx*(im.width + margin))
        max_dx = calc.max(max_dx, max_dx + idx*(im.width + margin))

        min_dy = calc.min(min_dy, min_dy + idy*(im.height + margin))
        max_dy = calc.max(max_dy, max_dy + idy*(im.height + margin))
      }

      if o.reflect > 0% {
        light_angle += 2*o.rot
      }

      // The following is an attempt to make a deflected order of an aom that I didn't fully finish
      // if o.type == "aom" {
      //   // let j = i+1
      //   let j
      //   for j_ in array.range(i+1, objs.len()) {
      //     j = j_
      //     if objs.at(j_).reflect <= 0% { break }
      //   }
      //   let sub1 = assemble(objs.slice(i+1, j+1), rot: 275deg)
      //   drawings_list.push(place(sub1.content, dx: ndx +sub1.dims.min_dx, dy: ndy +sub1.dims.min_dy))
      //   // for s in sub1.elements.pairs() { elements = _add_element(elements, s) }
      //   // [#sub1.content]
      // }

      if "subcomponents" in o {
        let sub1 = assemble(o.subcomponents.at(0), rot: light_angle, stroke: stroke)
        drawings_list.push(place(sub1.content, dx: ndx +sub1.dims.min_dx, dy: ndy +sub1.dims.min_dy))
        for s in sub1.elements.pairs() { elements = _add_element(elements, s) }

        min_dx = calc.min(min_dx, sub1.dims.min_dx + ndx)
        max_dx = calc.max(max_dx, sub1.dims.max_dx + ndx)
        min_dy = calc.min(min_dy, sub1.dims.min_dy + ndy)
        max_dy = calc.max(max_dy, sub1.dims.max_dy + ndy)

        let sub2 = assemble(o.subcomponents.at(1), rot: light_angle +90deg +2*o.rot, stroke: stroke)
        drawings_list.push(place(sub2.content, dx: dx +sub2.dims.min_dx, dy: dy +sub2.dims.min_dy))
        for s in sub2.elements.pairs() { elements = _add_element(elements, s) }

        min_dx = calc.min(min_dx, sub2.dims.min_dx + ndx)
        max_dx = calc.max(max_dx, sub2.dims.max_dx + ndx)
        min_dy = calc.min(min_dy, sub2.dims.min_dy + ndy)
        max_dy = calc.max(max_dy, sub2.dims.max_dy + ndy)

        let sub3 = (content: [], dims: (min_dx: 0pt, max_dx: 0pt, min_dy: 0pt, max_dy: 0pt))
        if o.subcomponents.at(2) != none {
          sub3 = assemble(o.subcomponents.at(2), rot: light_angle -90deg +2*o.rot, stroke: stroke)
          drawings_list.push(place(sub3.content, dx: dx +sub3.dims.min_dx, dy: dy +sub3.dims.min_dy))
          for s in sub3.elements.pairs() { elements = _add_element(elements, s) }

          min_dx = calc.min(min_dx, sub3.dims.min_dx + ndx)
          max_dx = calc.max(max_dx, sub3.dims.max_dx + ndx)
          min_dy = calc.min(min_dy, sub3.dims.min_dy + ndy)
          max_dy = calc.max(max_dy, sub3.dims.max_dy + ndy)
        }
      }

      i += 1
    }

    for ll in laser_lines_list {
      ll
    }
    // We iterate the drawings list in reverse order to draw the optics above the lasers
    // when we have subcomponents (e.g. from splitters), since there the drawing already includes
    // the beams
    // The sub-paths are always added after the main component, so if we draw it in reverse order,
    // it means we draw the sub-path first, then the main component on top of it
    for d in drawings_list.rev() {
      d
    }
  }

  contents = move(contents, dx: -min_dx, dy: -min_dy)
  contents += h(max_dx -min_dx)
  contents += v(max_dy -min_dy -19.8pt) //there is a default offset of 19.8pt for some reason

  return (content: contents, elements: elements, dims: (min_dx: min_dx, max_dx: max_dx, min_dy: min_dy, max_dy: max_dy))
}

#let element(type, variant: 1, dist: 30pt, rot: 0deg, size: 1.0, info-pos: none, info-num: -1) = {
  let f(stroke: none) = {
    let pivot(img) = { (x: 0pt, y: 0pt) }

    let r = _load_svg("assets/" + type + "/" + str(variant) + ".svg", size: size)

    return (obj: r, type: type, variant: variant, info-pos: info-pos, info-num: info-num, dist: dist, rot: rot, reflect: 0%, pivot: pivot)
  }
  return f
}
#let mirror(type: "mirror", variant: 1, dist: 30pt, rot: 0deg, size: 1.0, info-pos: none, info-num: -1) = {
  let f(stroke: none) = {
    let pivot(img) = {
      return (x: 0pt, y: 0pt)
    }

    let r = {
      context {
        let img = _load_svg("assets/" + type + "/" + str(variant) + ".svg", size: size)

        let p = pivot(img)
        move(_rotate_around_point(img, -90deg, -measure(img).width/2, 0pt), dx: measure(img).width/2)
      }
    }
    return (obj: r, type: type, variant: variant, info-pos: info-pos, info-num: info-num, dist: dist, rot: rot, reflect: 100%, pivot: pivot)
  }

  return f
}

#let type-fct = type
#let splitter(path1, path2, path3: none, type: "beam_splitter_cube", variant: 1, dist: 30pt, rot: 0deg, size: 1, info-pos: none, info-num: -1) = {
  let f(stroke: none) = {
    let pivot(img) = { (x: 0pt, y: 0pt) }

    let path1_ = path1
    let path2_ = path2
    let path3_ = path3

    if type-fct(path1) != array {
      path1_ = (path1,)
    }
    if type-fct(path2) != array {
      path2_ = (path2,)
    }
    if path3 != none and type-fct(path3) != array {
      path3_ = (path3,)
    }

    let r = _load_svg("assets/" + type + "/" + str(variant) + ".svg", size: size)

    return (obj: r, type: type, variant: variant, info-pos: info-pos, info-num: info-num, dist: dist, rot: rot, reflect: 0%, pivot: pivot, subcomponents: (path1_, path2_, path3_))
  }
  return f
}

#let arrow(dist: 30pt, size: none, dir: 1, info-pos: none, info-num: -1) = {
  let f(stroke: none) = {
    let pivot(img) = { (x: 0pt, y: 0pt) }

    let size_ = size
    if size == none {
      size_ = stroke.thickness * 3
    }

    let r = {
      place(line(start: (0pt, 0pt), end: (-dir*size_, -size_), stroke: stroke))
      place(line(start: (0pt, 0pt), end: (-dir*size_, size_), stroke: stroke))
    }

    return (obj: r, type: "arrow", variant: 1, info-pos: info-pos, info-num: info-num, dist: dist, rot: 0deg, reflect: 0%, pivot: pivot)
  }

  return f
}

#let combine-assemblies(..assemblies) = {
  let elements = (:)

  let min_dx = 0pt
  let min_dy = 0pt
  let max_dx = 0pt
  let max_dy = 0pt

  let cx = {
    // v(1.20em)
    for objs in assemblies.pos() {
      assert("assembly" in objs, message: "Call the function as combine_assemblies((assembly: a1), ...)")

      let m = measure(objs.assembly.content)

      let dx = 0pt
      let dy = 0pt
      if "dx" in objs { dx = objs.dx }
      if "dy" in objs { dy = objs.dy }

      min_dx = calc.min(min_dx, dx)
      min_dy = calc.min(min_dy, dy)
      max_dx = calc.max(max_dx, dx+m.width)
      max_dy = calc.max(max_dy, dy+m.height)

      move(objs.assembly.content, dx: dx, dy: dy)
      // linebreak()
      v(-1.20em) // TODO: figure out what this is
      // h(-m.width)
      v(-m.height)
      for e in objs.assembly.elements.pairs() { elements = _add_element(elements, e) }
    }
  }

  cx = move(cx, dx: -min_dx, dy: -min_dy)
  cx += h(max_dx -min_dx)
  cx += v(max_dy -min_dy ) //there is a default offset of 19.8pt for some reason

  return (content: cx, elements: elements)
}

#let legend(components,
        labels: (),
        alt-text: (),
        pic-scale: 0.7,
        pic-text-size: 10pt,
        info-text-size: 11pt,
        pic-padding: 0.5em,
        info-padding: 0.7em) = {
  let str-fmt(s, alt-text) = {
    let c = s.at(0).to-unicode()
    if c >= 97 and c <= 122 {
      c -= 32
    }

    s = str.from-unicode(c) + s.slice(1)

    s = s.replace("lambda", "λ")
    s = s.replace("Lambda", "λ")

    s = s.replace("-DIV-", "/")

    s = s.replace("_", " ")

    for r in alt-text {
      s = s.replace(r.at(0), r.at(1))
    }

    return s
  }

  context {
    set align(center)

    let content = {
      set par(leading: 0.2em)

      let pic_text_margin = 5pt
      for k in _element_order {
        if components.at(k, default: none) != none {
          let v = components.at(k)
          let img_content = {
            for i in v {
              let img = box(_load_svg("assets/" + k + "/" + str(i) + ".svg", size: pic-scale))
              img + h(pic_text_margin)
            }
          }
          let t = box(text(str-fmt(k, alt-text), font: "Linux Biolinum", size: pic-text-size))
          box(box(img_content) + box(t, inset: (y: measure(img_content).height/2 - measure(t).height/2)))
          h(10pt)
        }
      }
    }

    let info_content = {
      let i = 1
      for info_text in labels {
        box(str(i) + ": " + text(info_text, size: info-text-size) + h(10pt))
        i += 1
      }
    }

    let c = rect(
      rect(content + v(pic-padding),
        stroke: (bottom: 0.0pt),
        inset: (x: pic-padding, y: pic-padding -7pt)
      )
      + v(-1.5em)
      + rect(line(length: 95%), width: 100%, stroke: 0pt)
      + v(-1.5em)
      + rect(info_content,
          inset: (x: info-padding, y: info-padding),
          stroke: 0.0pt)
      + v(-0.5em),
      inset: (x: 0pt, y: 0.5em),
      stroke: 0.8pt)

    box(c)
  }
}
