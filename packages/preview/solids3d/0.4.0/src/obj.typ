// obj.typ — minimal Wavefront OBJ reader (port of Asymptote's obj.asy):
// vertices (v) and polygonal faces (f) become planar patches.
//
//   #let s = obj(read("model.obj"))
//   #picture(draw(s, palegreen))
//
// Faces may reference vertices as "i", "i/j", "i//k" or "i/j/k" (1-based,
// negative indices count from the end). Group colours: pass a dictionary
// colors: ("groupname": color) to colour patches per `g`/`usemtl` group.

#import "vec.typ": *
#import "path3.typ": line3
#import "surface.typ": patch, surface-from-patches

#let obj(text, colors: (:), transform: none) = {
  let verts = ()
  let patches = ()
  let group = ""
  for raw in text.split("\n") {
    let line = raw.trim()
    if line == "" or line.starts-with("#") { continue }
    let parts = line.split(regex("\\s+")).filter(s => s != "")
    if parts.len() == 0 { continue }
    let key = parts.at(0)
    if key == "v" and parts.len() >= 4 {
      let v = (float(parts.at(1)), float(parts.at(2)), float(parts.at(3)))
      if transform != none { v = tpoint(transform, v) }
      verts.push(v)
    } else if key == "g" or key == "usemtl" or key == "o" {
      group = if parts.len() > 1 { parts.at(1) } else { "" }
    } else if key == "f" and parts.len() >= 4 {
      let idx = parts.slice(1).map(tok => {
        let i = int(tok.split("/").at(0))
        if i < 0 { verts.len() + i } else { i - 1 }
      })
      if idx.all(i => i >= 0 and i < verts.len()) {
        let pts = idx.map(i => verts.at(i))
        let col = colors.at(group, default: none)
        patches.push(patch(line3(pts, cyclic: true), color: col))
      }
    }
  }
  surface-from-patches(patches)
}
