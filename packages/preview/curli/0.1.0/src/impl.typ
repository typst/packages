

#let no-break = text(0pt, sym.space.nobreak)

#let no-break-box(body) = no-break + box(body) + no-break
  
  #let place-diacritic(base, diacritic, at: start) = context {
  let width = measure(base).width
  
  let dx = width / 4.5
  let dx = .13em
  if at == start {
    dx = -dx
  }

  no-break-box({
    base
    place(
      bottom + if at == start { right } else { left }, 
      dx: dx, 
      place(bottom + center, diacritic)
    )
  })
}

#let clip(body, dx: 0pt, dy: 0pt, width:  10pt, height: 10pt) = place({
  move(dx: -dx, dy: -dy - height, box(
    width: width, height: height, clip: true,
    place(dx: dx, dy: dy, bottom, body)
  ))
})

#let simsalabim(body) = {
    

  show "->": [→]
  show "äq": [q\u{0308}]
  show "ui": place-diacritic[u][\u{02D9}]
  show "ai": place-diacritic[a][\u{02D9}]
  show "iu": place-diacritic(at: end)[u][\u{02D9}]
  show "mi": place-diacritic[m][\u{02D9}]
  show "im": place-diacritic(at: end)[m][\u{02D9}]
  show "ni": place-diacritic[n][\u{02D9}]
  show "yi": place-diacritic[y][\u{02D9}]
  show "iy": place-diacritic(at: end)[y][\u{02D9}]
  
  show regex("in[^u]"): it => {
    // don't destroy the ligature n+u+u
    let t = it.text
    no-break
    place-diacritic(at: end)[n][\u{02D9}]
    t.at(2)
  }

  
  show "mj": no-break-box({
    hide[m]
    clip(height: 1em, width: .56em)[m] 
    clip(height: 1em, width: .5em, dx: -.56em, dy: .2em)[m]
    place(dx: .521em, clip(height: 1em, dy: -.8em, dx: .1em, width: 1em)[j])
    place(dx: .521em, clip(height: 1em, dy: .5em, dx: .1em, width: 1em)[j])
  })
  show "nj": no-break-box({
    hide[n]
    clip(height: 1em, width: .31em)[n] 
    clip(height: 1em, width: .5em, dx: -.31em, dy: .2em)[n]
    place(dx: .266em, clip(height: 1em, dy: -.8em, dx: .1em, width: 1em)[j])
    place(dx: .266em, clip(height: 1em, dy: .5em, dx: .1em, width: 1em)[j])
  })
  show "aj": no-break-box({
    hide[q]
    clip(height: 1em, width: .37em, dy: -.02em)[q] 
    clip(height: 1em, width: .5em, dx: -.31em, dy: .2em)[q]
    place(dx: .233em, clip(height: 1em, dy: -.8em, dx: .1em, width: 1em)[j])
    place(dx: .233em, clip(height: 1em, dy: .5em, dx: .1em, width: 1em)[j])
  })
  show "jp": no-break-box({
    hide[p]
    clip(height: 1em, width: .9em, dy: .3em, dx: -.15em)[p] 
    clip(height: 1em, width: .9em, dy: -.1em, dx: -.17em)[p] 
    place(dx: -.0331em, clip(height: 1.5em, dy: -.5em, dx: .1em, width: 1em)[j])
  })
  show "nu": no-break-box({
    hide[n#h(-.2409em)u]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .6em)[n] 
    clip(height: 1em, width: .9em, dy: .2em, dx: -.3em)[n] 
    place(dx: .2909em, clip(height: 1.5em, dy: -.2em, dx: -.2em, width: 1em)[u])
    place(dx: .2909em, clip(height: .5em, dy: -.2em, dx: .8em, width: 1em)[u])
  })
  show "hu": no-break-box({
    hide[h#h(-.2409em)u]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .6em)[h] 
    clip(height: 1em, width: .9em, dy: .2em, dx: -.3em)[h] 
    place(dx: .2909em, clip(height: 1.5em, dy: -.2em, dx: -.2em, width: 1em)[u])
    place(dx: .2909em, clip(height: .5em, dy: -.2em, dx: .8em, width: 1em)[u])
  })
  show "hn": no-break-box({
    hide[h#h(-.2409em)n]
    clip(height: 1em, width: 1.9em, dy: -.2em, dx: .6em)[h] 
    place(dx: .012em, clip(height: 1.5em, dy: -.2em, dx: -.43em, width: 1em)[m])
  })
  show "an": no-break-box({
    hide[a#h(-.28em)n]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .0em)[a] 
    place(dx: .18em, clip(height: 1.5em, dy: .2em, dx: -.181em, width: 1em)[n])
    place(dx: .18em, clip(height: 1.5em, dy: -.2em, dx: -.3em, width: 1em)[n])
  })
  show "am": no-break-box({
    hide[a#h(-.28em)m]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .0em)[a] 
    place(dx: .18em, clip(height: 1.5em, dy: .2em, dx: -.181em, width: 1em)[m])
    place(dx: .18em, clip(height: 1.5em, dy: -.2em, dx: -.3em, width: 1em)[m])
  })
  show "mm": no-break-box({
    hide[m#h(-.271em)m]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[m] 
    place(dx: .271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
    place(dx: 2*.271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
  })
  show "mmm": no-break-box({
    hide[m#h(-.271em)m#h(-.271em)m]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[m] 
    place(dx: .271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
    place(dx: 2*.271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
    place(dx: 3*.271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
    place(dx: 4*.271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
  })
  
  
  show "mn": no-break-box({
    hide[m#h(-.2909em)n]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[m] 
    place(dx: .271em, clip(height: 1em, dy: -.2em, dx: -.39em, width: 1em)[m])
  })
  show "mr": no-break-box({
    hide[m#h(-.2909em)r]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[m] 
    place(dx: .53em, clip(height: 1em, dy: -.2em, dx: -.178em, width: 1em)[r])
  })
  show "nr": no-break-box({
    hide[n#h(-.2909em)r]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[n] 
    place(dx: .275em, clip(height: 1em, dy: -.2em, dx: -.178em, width: 1em)[r])
  })
  show "ur": no-break-box({
    hide[u#h(-.2909em)r]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[u] 
    place(dx: .26em, clip(height: 1em, dy: .3em, dx: -.178em, width: 1em)[r])
  })
  show "mi": no-break-box({
    hide[m#h(-.2909em)i]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[m] 
    place(dx: .532em, clip(height: 1em, dy: .15em, dx: -.087em, width: 1em)[i])
  })
  show "ai": no-break-box({
    hide[a#h(-.2909em)i]
    clip(height: 1em, width: .9em, dy: -.2em, dx: 0em)[a] 
    place(dx: .19em, clip(height: 1em, dy: .25em, dx: -.087em, width: 1em)[i])
  })
  show "ap": no-break-box({
    hide[a#h(-.28em)p]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .528em)[a] 
    place(dx: .213em, clip(height: 1.1em, dy: -1em, dx: .84em, width: 1em)[p])
    place(dx: .213em, clip(height: 1.1em, dy: -1.2em, dx: .3em, width: 1em)[p])
    place(dx: .18em, clip(height: 1.5em, dy: .2em, dx: -.161em, width: 1em)[p])
    place(dx: .18em, clip(height: 1.5em, dy: -.2em, dx: -.25em, width: 1em)[p])
  })
  show "qp": no-break-box({
    hide[q#h(-.28em)p]
    clip(height: 1.2em, width: .9em, dy: -.6em, dx: .4em)[q] 
    place(dx: .267em, clip(height: 1.1em, dy: -.5em, dx: -.1em, width: 1em)[p])
  })

  show "uu": no-break-box({
    hide[u#h(-.33em)u]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .0em)[u] 
    place(dx: .2em, clip(height: 1.5em, dy: -.2em, dx: -.181em, width: 1em)[u])
  })
  show "nuu": no-break-box({
    hide[n#h(-0.05em)u]
    clip(height: 1em, width: .9em, dy: -.2em, dx: .6em)[n] 
    clip(height: 1em, width: .9em, dy: .2em, dx: -.3em)[n] 
    place(dx: .2909em, clip(height: 1.5em, dy: -.2em, dx: -.2em, width: 1em)[u])
    place(dx: .2909em, clip(height: .5em, dy: -.2em, dx: .8em, width: 1em)[u])

    
    place(dx: .4909em, clip(height: 1.5em, dy: -.2em, dx: -.181em, width: 1em)[u])
  })
    
  
  body
}