#let zip(..lists) = {
  let lists = lists.pos()
  if lists == () {
    ()
  } else {
    let ret = ()
    let len = lists.fold(
      lists.first().len(), 
      (a, b) => if a > b.len() { b.len() } else { a }
    )

    for i in range(0, len) {
      let curr = ()
      for list in lists {
        curr.push(list.at(i))
      }
      ret.push(curr)
    }

    ret
  }
}

#let strspacing(s,sz,fontsz) = {
  let chars = s.split("")
  chars = chars.slice(1,chars.len()-1)
  chars.join(h(fontsz))
}

#let strjustify(s,len,fontsz) = {
  let chars = s.split("")
  chars = chars.slice(1,chars.len()-1)
  let n = len - chars.len()
  let sz = n /(chars.len()-1)
  chars.join(h(sz*fontsz))
}