#import "counters.typ": figure-counter

// Note that we also used `figure`
// to wrap the theorem templates
// Here we only set the rules for "normal" figures
// which has kind `image` (`image` is a function!)
#let figure-rules(body) = {
  // Set the numbering of the figure
  set figure(numbering: it => {
    figure-counter.display()
  })

  show figure.where(kind: image): it => {
    let nothing = locate(loc => {
      figure-counter.step(level: 3)
    })

    it

    // Hide the empty content here
    // to execute the operations inside
    hide(nothing)
  }

  body
}

