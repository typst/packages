#import "@preview/cetz:0.3.1": canvas, draw
#import "./gen.typ": gen

/// Creates a new tab line
/// -> content
#let new(
  /// the tab code; see README for rough specification -> raw
  tabs,
  /// what to add at the "start" of tab canvas -> cetz drawing
  preamble: none,
  /// what to add at the "end" of tab canvas -> cetz drawing
  extra: none,
  /// scope for your code for custom elements -> dictionary
  eval-scope: (:),
  /// canvas scale length -> length
  scale-length: 0.3cm,
  /// number of strings -> int
  s-num: 6,
  /// length in cetz points of one beat -> float
  one-beat-length: 8,
  /// spacing between the lines -> float
  line-spacing: 3,
  /// enable smart scaling for better fitting to line -> boolean
  enable-scale: true,
  /// colors of things, see README -> dictionary
  colors: (:),
  /// maximum scaling for smart scale -> float
  autoscale-max: 3.0,
  /// minimal scaling for smart scale -> float
  autoscale-min: 0.9,
  /// draw "rhythm" bar
  draw-rhythm: false,
  /// render this number of notes only -> int | none
  debug-render: none,
  /// draw numbers of step -> bool
  debug-numbers: false,
) = {
  let content_type = content
  let line-spacing = line-spacing
  if draw-rhythm {
    line-spacing += 1
  }
  let tabs = gen(tabs, s-num: s-num)
  let colors = (bars: gray, lines: gray, connects: luma(50%)) + colors
  
  layout(
    size => {
      // copy variable to function
      let tabs = tabs
      let width = size.width / scale-length * 0.95
      
      let calculate-alpha(draft) = {
        let alpha = if draft.var != 0 {
          (width - draft.const) / draft.var
        } else { 1 }
        
        if alpha > autoscale-max or alpha < autoscale-min {
          1
        } else {
          alpha
        }
      }
      
      canvas(
        length: scale-length,
        {
          import draw: *
          import "./drawing.typ": *
          
          draw-bar = draw-bar.with(s-num, scale-length, colors)
          draw-lines = draw-lines.with(s-num, colors)
          draw-column = draw-column.with(s-num, colors)
          draw-slur = draw-slur.with(colors)
          draw-slide = draw-slide.with(colors)
          scale-fret-numbers = scale-fret-numbers.with(scale-length, one-beat-length, colors)
          draw-bend = draw-bend.with(colors)
          draw-vibrato = draw-vibrato.with(colors)
          draw-bar-rhythm = draw-bar-rhythm.with(colors)
          
          if preamble != none { preamble }
          
          let x = 0.0
          let y = 0
          
          let queque = ()
          queque.push(draw-bar(0, 0))
          
          let last-string-x = (-1.5,) * 6
          let last-tab-x = (0,) * 6
          let last-sign = "\\"
          let bar-index = 0
          
          let draft = (
            enable: true,
            var: 0,
            const: 0.0,
            alpha: 1.0,
            queque-line-start: 1,
            bar-start: 1,
            note-start: 0,
          )
          
          // for debug purposes
          // let ftabs = tabs.map(arr => arr.map(i => {if type(i) != str {"n"} else {i}}).join())
          let counter-lim = 0
          let debug-render = debug-render

          // bar iteration
          while bar-index < tabs.len() {
            let bar = tabs.at(bar-index)
            bar-index += 1
          
            if debug-render != none and counter-lim > debug-render {
              break
            }
            
            if bar.len() > 0 {
              if (last-sign == "\\") {
                if bar.at(0) != "||" { x += 1.; draft.const += 1 } else { x -= 0.5; draft.const -= 0.5 }
              }
            }
            
            // rhythm thing: store all notes in bar
            let bar-notes = ()
            let note-index = 0

            // note iteration
            while note-index < bar.len() {
              let n = bar.at(note-index)
              note-index += 1
              
              if debug-numbers {
                queque.push(content((x, -y + 1), {
                  set text(size: 0.3em)
                  note-index
                }))
              }
              
              if debug-render != none {
                counter-lim += 1
                if counter-lim > debug-render {
                  break
                }
              }
              
              assert(
                calc.abs(x - (draft.const + draft.var)) < 0.001,
                message: "Broken sync between drafting variables and x: " + str(x) + "  " + str(draft.const) + " " + str(draft.var) + " " + repr(n),
              )
              
              // have to make a break
              if x > width + 0.51 and (not draft.enable or not enable-scale) {
                // reset everything to draft to the last bar
                // calculate-alpha(draft) > 1
                if bar-index - draft.bar-start >= 2 and tabs.at(bar-index, default: none) != ("\\",) {
                  tabs.insert(bar-index - 1, ("\\",))
                  // jumping into bar end
                  last-sign = "\\"
                  
                  draft = (
                    enable: true,
                    var: 0,
                    bar-start: draft.bar-start,
                    queque-line-start: draft.queque-line-start,
                    alpha: 1.0,
                    note-start: draft.note-start,
                  )
                  
                  queque = queque.slice(0, draft.queque-line-start)
                  if draft.note-start == float("inf") {
                    draft.const = -0.5
                    x = -0.5
                  } else {
                    draft.const = 1.0
                    x = 1.0
                  }
                  
                  bar-index = draft.bar-start
                  bar = tabs.at(bar-index)
                  note-index = draft.note-start
                  continue
                }
                
                queque.push({
                  draw-lines(y, width - 0.5)
                  draw-bar(width - 0.5, y)
                  last-string-x = (-1.5,) * 6
                  x = 1.0
                  y += s-num + line-spacing
                  draw-bar(0.0, y)
                  
                  // can remove one note
                  // to move it to the next line
                  if note-index > 1 {
                    let _ = queque.pop()
                    if debug-numbers {
                      let _ = queque.pop()
                    }
                    note-index -= 1
                  }
                })
                last-sign = "\\"
                note-index -= 1
                draft = (
                  enable: true,
                  var: 0,
                  const: 1.0,
                  alpha: 1.0,
                  queque-line-start: queque.len(),
                  bar-start: bar-index,
                  note-start: note-index,
                )
                continue
              }
              
              if n == "\\" {
                if draw-rhythm {
                  let rhythm = draw-bar-rhythm(bar-notes, y)
                  if rhythm != none {queque.push(rhythm)}
                }
                bar-notes = ()
                if last-sign == "||" {
                  x -= 0.3
                  draft.const -= 0.3
                } else if last-sign == "|" {
                  x -= 0.5
                  draft.const -= 0.5
                } else {
                  x += 0.5
                  queque.push({ draw-bar(x, y) })
                  x += 0.5
                  draft.const += 1.0
                }
                 
                if draft.bar-start != 1 and bar-index == draft.bar-start + 1 and tabs.at(draft.bar-start - 1).len() == 1 {
                  // remove empty line
                  {
                    let _ = queque.pop()
                    let _ = queque.pop()
                    if debug-numbers {
                      let _ = queque.pop()
                    }
                  }
                } else {
                  if bar-index > 0 {
                    if draft.enable and enable-scale {
                      last-sign = "\\"
                      let alpha = calculate-alpha(draft)
                      
                      draft = (
                        enable: false,
                        var: 0,
                        bar-start: draft.bar-start,
                        queque-line-start: draft.queque-line-start,
                        alpha: alpha,
                        note-start: draft.note-start,
                      )
                      
                      queque = queque.slice(0, draft.queque-line-start)
                      bar-index = draft.bar-start
                      bar = tabs.at(bar-index - 1)
                      note-index = draft.note-start
                      
                      // jumping into bar end
                      if note-index == float("inf") {
                        draft.const = -0.5
                        x = -0.5
                      } else {
                        draft.const = 1.0
                        x = 1.0
                      }
                      continue
                    }
                  }
                   
                  queque.push({
                    draw-lines(y, x - 0.5)
                  })
                }
                
                queque.push({
                  last-string-x = (-1.5,) * 6
                  y += s-num + line-spacing
                  draw-bar(0.0, y)
                  x = -0.5
                  last-sign = "\\"
                })
                draft = (
                  enable: true,
                  var: 0,
                  const: -0.5,
                  alpha: 1.0,
                  queque-line-start: queque.len(),
                  bar-start: bar-index,
                  note-start: float("inf"),
                )
                continue
              }
              
              if n == "<" {
                draft.const -= 0.5
                x -= 0.5
                continue
              }
              if n == ">" {
                draft.const += 0.5
                x += 0.5
                continue
              }
              
              if n == ":" {
                queque.push({
                  if last-sign == none { x -= 1; draft.const -= 1 }
                  draw-column(x, y)
                  last-sign = ":"
                  x += 0.5
                  draft.const += 0.5
                })
                continue
              }
              
              if n == "||" {
                queque.push({
                  x += 0.5
                  draw-bar(x, y, width: 4)
                  x += 0.5
                  draft.const += 1.0
                  last-sign = "||"
                })
                continue
              }
              
              if n == "|" {
                queque.push({
                  if last-sign == "|" {
                    x -= 0.5
                    draft.const -= 0.5
                  }
                  draw-bar(x, y)
                  x += 0.5
                  draft.const += 0.5
                  
                  last-sign = "|"
                })
                continue
              }
              
              if type(n) == array and n.at(0) == "##" {
                assert(n.at(2) != none, message: "Empty content")
                let result = eval(n.at(2), scope: eval-scope)
                assert(type(result) == content_type or type(result) == str, message: "Eval result should be content or str, found " + type(result) + ": " + n.at(2))
                queque.push({
                  content(
                    (x, -y + 1),
                    result,
                    anchor: if n.at(1).len() > 0 { n.at(1) } else { none },
                  )
                })
                continue
              }
              
              if n.len() == 1 {
                panic(n)
              }
              
              let frets = n.notes
              let dx = one-beat-length * calc.pow(2, -n.duration) * draft.alpha
              draft.var += dx
              // pause
              if frets.len() == 0 {
                x += dx
                continue
              }
              
              for fret in frets {
                let n-y = fret.string
                queque.push({
                  if fret.connect == "^" {
                    draw-slur(x, y, n-y, last-string-x)
                  } else if fret.connect == "`" {
                    draw-slide(x, y, n-y, last-string-x, fret, last-tab-x)
                  }
                  
                  content(
                    (x, - (y + n-y - 1)),
                    scale-fret-numbers(fret.fret, n.duration, draft.alpha),
                    anchor: "west",
                  )

                  bar-notes.push((x, n.duration))
                  
                  if fret.bend != none {
                    draw-bend(x, y, n-y, dx, fret.bend-return, fret.bend)
                  }
                  
                  if fret.vib {
                    draw-vibrato(x, y, n-y, dx)
                  }
                })
                last-string-x.at(n-y - 1) = x
                last-tab-x.at(n-y - 1) = fret.fret
                last-sign = "n"
              }
              x += dx
            }
            if draw-rhythm {
              let rhythm = draw-bar-rhythm(bar-notes, y)
              if rhythm != none {queque.push(rhythm)}
            }
            x += 0.5
            draft.const += 0.5
          }
          
          let _ = queque.pop()
          
          for i in queque {
            i
          }
          extra
        },
      )
    },
  )
}
