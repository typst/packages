#let output-label = state("output-label", none)
#let output-num = state("output-num", 0)
#let debug = state("debug", true)
#let count = counter("output")

#let fig(label, body) = {
  context{
  let num = count.get().at(0)
  if (debug.get() and not num == 0){
    pagebreak()
  }
  if debug.get() {
    [Debug mode. Switch to the output mode in the show rules. \
    Figure No. #num with label: #raw(label)\ ]
  }
  if (debug.get() or label == output-label.get() or num == output-num.get()){
    body
  }
  }
  count.step()
}

#let set-output-label(label) = {
  output-label.update(label)
}

#let set-debug(d) = {
  debug.update(d)
}

#let set-output-num(num) = {
  output-num.update(num)
}

#let fig-plucker(
  debug: false,
  output-label: none,
  output-num: -1,
  margin: 2pt,
  body
) = {
  set-debug(debug)
  set-output-label(output-label)
  set-output-num(output-num)

  
  set page(width: auto, height: auto, margin: margin)
  
  if output-num >= 0 and not (output-label == none) {
    [Error: Please specify the rendered figure by label #emph[or] number, but not by both!]
  } else {
    body
    context{
      if not debug and output-num >= count.get().at(0) [Error: output-num larger than total figure number!]
    }
  }
}
