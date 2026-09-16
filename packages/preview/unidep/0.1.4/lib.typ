#import "@preview/cetz:0.5.0"

#let _wasm-plugin = plugin("unidep_plugin.wasm")

#let dependency-tree(
  conllu-text, 
  word-spacing: 2.0, 
  level-height: 1.0,
  arc-roundness: 0.18,
  tail-spacing: none,
  head-spacing: none,
  tail-angle: 90deg,
  head-angle: 90deg,
  tail-offset: 0.1,
  head-offset: 0.0,
  text-gap: 0.5em,
  sentence-gap: 1em,
  show-text: false,
  show-upos: false,
  show-xpos: false,
  show-lemma: false,
  show-enhanced-as-dashed: true,
  show-root: true,
  highlights: (:) 
) = {
  show text: it => align(horizon, it)
  show par: it => align(top, it)

  let _resolve-angle(value) = if value == none {
    none
  } else if type(value) == int or type(value) == float {
    value * 1deg
  } else {
    value
  }

  let resolved-tail-spacing = if tail-spacing == none { 0.0 } else { tail-spacing }
  let resolved-head-spacing = if head-spacing == none { 0.0 } else { head-spacing }
  let resolved-tail-angle = _resolve-angle(tail-angle)
  let resolved-head-angle = _resolve-angle(head-angle)
  let _same-arc(a, b) = (
    a.dep_id == b.dep_id and
    a.start_idx == b.start_idx and
    a.end_idx == b.end_idx and
    a.label == b.label and
    a.level == b.level and
    a.is_head_left == b.is_head_left and
    a.is_enhanced == b.is_enhanced
  )

  let raw-json = _wasm-plugin.layout_unidep(bytes(conllu-text))
  let sentences = json(raw-json)

  for sentence in sentences {
    let tree = cetz.canvas({
      import cetz.draw: *

      for (i, token) in sentence.tokens.enumerate() {
        let x = float(i) * float(word-spacing)
        let safe-name = "word-" + str(token.id).replace(".", "-")
        
        content((x, 0.0), [#token.form], name: safe-name)
        
        let y-offset = -0.45
        if show-lemma and token.lemma != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("555555"), token.lemma))
          y-offset -= 0.35
        }
        if show-upos and token.upos != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("0055aa"), token.upos))
          y-offset -= 0.35
        }
        if show-xpos and token.xpos != "_" {
          content((x, y-offset), text(size: 8pt, fill: rgb("aa5500"), token.xpos))
          y-offset -= 0.35
        }
      }

      let global-max-level = 0
      for arc in sentence.arcs {
        if arc.level > global-max-level { global-max-level = arc.level }
      }

      if show-root {
        let root-y = float(global-max-level + 1) * float(level-height)
        for root in sentence.roots {
          let base-x = float(root.idx) * float(word-spacing)
          
          let is-highlighted = root.dep_id in highlights
          let root-color = if is-highlighted { highlights.at(root.dep_id) } else { black }
          let root-width = if is-highlighted { 1.5pt } else { 0.75pt }
          
          line(
            (base-x, root-y), (base-x, 0.3),
            stroke: (paint: root-color, thickness: root-width),
            mark: (end: "stealth", fill: root-color, scale: 0.75),
            name: "root-" + str(root.idx)
          )
          content(
            (base-x, root-y + 0.15),
            box(
              fill: white, inset: (x: 2pt, y: 1pt), radius: 2pt,
              text(size: 8pt, weight: "bold", fill: root-color, root.label)
            )
          )
        }
      }

      for arc in sentence.arcs {
        let x-start = float(arc.start_idx) * float(word-spacing)
        let x-end = float(arc.end_idx) * float(word-spacing)
        let start-has-arrow = not arc.is_head_left
        let end-has-arrow = arc.is_head_left
        
        let start-slot = 1
        let end-slot = 1
        let start-count = 1
        let end-count = 1

        for other in sentence.arcs {
          if not _same-arc(other, arc) {
            let other-start-has-arrow = not other.is_head_left
            let other-end-has-arrow = other.is_head_left
            let same-start-side = (
              other.start_idx == arc.start_idx and
              other-start-has-arrow == start-has-arrow
            )
            let same-end-side = (
              other.end_idx == arc.end_idx and
              other-end-has-arrow == end-has-arrow
            )

            if same-start-side and other.level < arc.level {
              start-slot += 1
            }
            if same-end-side and other.level < arc.level {
              end-slot += 1
            }
            if same-start-side {
              start-count += 1
            }
            if same-end-side {
              end-count += 1
            }
          }
        }

        let peak-y = float(arc.level) * float(level-height)
        let base-y = 0.3
        
        let ctrl-y = (peak-y - 0.25 * base-y) / 0.75
        let start-tail-lane = start-count - start-slot + 1
        let end-tail-lane = end-count - end-slot + 1
        let tail-shift-start = float(start-tail-lane) * float(resolved-tail-spacing)
        let tail-shift-end = float(end-tail-lane) * float(resolved-tail-spacing)
        let head-shift-start = float(start-slot) * float(resolved-head-spacing)
        let head-shift-end = float(end-slot) * float(resolved-head-spacing)

        let adj-x-start = if start-has-arrow {
          x-start + head-shift-start
        } else {
          x-start + tail-shift-start
        }
        let adj-x-end = if end-has-arrow {
          x-end - head-shift-end
        } else {
          x-end - tail-shift-end
        }

        let start-y = if arc.is_head_left { base-y + tail-offset } else { base-y + head-offset }
        let end-y   = if arc.is_head_left { base-y + head-offset } else { base-y + tail-offset }
        let span-offset = (adj-x-end - adj-x-start) * arc-roundness
        let start-angle = if start-has-arrow { resolved-head-angle } else { resolved-tail-angle }
        let end-angle = if end-has-arrow { resolved-head-angle } else { resolved-tail-angle }
        let start-offset = if start-angle == none {
          span-offset
        } else if start-angle == 90deg {
          0.0
        } else {
          (ctrl-y - start-y) / calc.tan(start-angle)
        }
        let end-offset = if end-angle == none {
          span-offset
        } else if end-angle == 90deg {
          0.0
        } else {
          (ctrl-y - end-y) / calc.tan(end-angle)
        }

        let start-pt = (adj-x-start, start-y)
        let end-pt = (adj-x-end, end-y)

        let ctrl-pt-start = (adj-x-start + start-offset, ctrl-y)
        let ctrl-pt-end = (adj-x-end - end-offset, ctrl-y)
        
        let is-highlighted = arc.dep_id in highlights
        
        let stroke-color = if is-highlighted { 
          highlights.at(arc.dep_id) 
        } else if arc.is_enhanced and show-enhanced-as-dashed { 
          rgb("0055aa") 
        } else { 
          black 
        }
        
        let stroke-dash = if arc.is_enhanced and show-enhanced-as-dashed and not is-highlighted { 
          "dashed" 
        } else { 
          "solid" 
        }
        let stroke-width = if is-highlighted { 1.5pt } else { 0.75pt }
        
        let mark-style = (fill: stroke-color, scale: 0.75)
        let mark-arg = if arc.is_head_left {
          (end: "stealth", ..mark-style)
        } else {
          (start: "stealth", ..mark-style)
        }
        
        bezier(
          start-pt, end-pt, ctrl-pt-start, ctrl-pt-end, 
          stroke: (paint: stroke-color, dash: stroke-dash, thickness: stroke-width),
          mark: mark-arg,
          name: "arc-" + str(arc.start_idx) + "-" + str(arc.end_idx)
        )

        let mid-x = (adj-x-start + adj-x-end) / 2.0
        content(
          (mid-x, peak-y + 0.15), 
          box(
            fill: white, inset: (x: 2pt, y: 1pt), radius: 2pt,
            text(size: 8pt, fill: if is-highlighted { stroke-color } else { luma(30) }, arc.label)
          )
        )
      }
    })
    if show-text and sentence.text != "" {
      context {
        let tree-width = measure(tree).width
        box(width: tree-width, align(center, strong(sentence.text)))
      }
      v(text-gap)
    }

    tree
    
    v(sentence-gap) 
  }
}
