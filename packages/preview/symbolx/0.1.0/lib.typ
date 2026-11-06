#let (symbolx-rule, symbol) = {
  let symbolx-rule(map) = body => {
    assert.eq(type(map), dictionary, message: "invalid map")
    assert("next" in map, message: "invalid map")
    let map = map
    let _ = map.remove("next")

    if map.len() == 0 {
      return body
    }
    let char-class = "[" + map.keys().sum() + "]"
    show regex(char-class): c => map.at(c.text)
    body
  }

  let symbol(..args) = {
    let no-named-arguments() = { }
    no-named-arguments(..args.named())

    let args = args.pos()
    let map = args.at(0, default: none)
    if type(map) == dictionary {
      assert("next" in map, message: "invalid map")
      let _ = args.remove(0)
    } else {
      map = (next: 0x100000)
    }

    let new-args = ()
    for x in args {
      if type(x) == array and x.len() == 2 and (type(x.last()) != str or x.last().codepoints().len() != 1) {
        assert.ne(map.next, 0x10fffe, message: "maximum of 65534 multi-character variants exceeded")
        let char = str.from-unicode(map.next)
        map.next += 1
        new-args.push((x.first(), char))
        map.insert(char, x.last())
      } else {
        new-args.push(x)
      }
    }

    if new-args == args {
      // no new codepoints assigned
      std.symbol(..new-args)
    } else {
      (
        map,
        std.symbol(..new-args),
      )
    }
  }

  (symbolx-rule, symbol)
}
