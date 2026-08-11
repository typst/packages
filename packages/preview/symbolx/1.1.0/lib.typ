#let (symbolx-rule, symbol) = {
  let parse-symbol(s) = eval(repr(s).trim("symbol", at: start, repeat: false))

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

  let is-invalid-variant-value(typst-version) = if typst-version < version(0, 14) {
    x => type(x) != str or x.codepoints().len() != 1
  } else {
    x => type(x) != str or x.clusters().len() != 1
  }

  let register(map, value) = {
    assert.ne(map.next, 0x10fffe, message: "maximum of 65534 multi-character variants exceeded")
    let char = str.from-unicode(map.next)
    map.next += 1
    map.insert(char, value)
    (map, char)
  }

  let symbol(..args) = {
    let validate-named-arguments(typst-version: version(0, 12, 0)) = {
      assert.eq(type(typst-version), version, message: "`typst-version` has to be of type `version`")
      (typst-version: typst-version)
    }
    let (typst-version,) = validate-named-arguments(..args.named())

    let is-invalid-variant-value = is-invalid-variant-value(typst-version)

    let args = args.pos()
    let map = args.at(0, default: none)
    if type(map) == dictionary {
      assert("next" in map, message: "invalid map")
      let _ = args.remove(0)
    } else {
      map = (next: 0x100000)
    }

    let flat-args = ()
    for x in args {
      if type(x) == array and x.len() == 1 and type(x.first()) == std.symbol {
        flat-args += parse-symbol(x.first())
      } else if type(x) == array and x.len() == 2 and type(x.first()) == std.symbol and type(x.last()) == function {
        flat-args += parse-symbol(x.first()).map(x.last()).filter(y => y != ())
      } else {
        flat-args.push(x)
      }
    }

    let new-args = ()
    for x in flat-args {
      if type(x) == array and x.len() == 2 and is-invalid-variant-value(x.last()) {
        let char
        (map, char) = register(map, x.last())
        new-args.push((x.first(), char))
      } else if type(x) != array and is-invalid-variant-value(x) {
        let char
        (map, char) = register(map, x)
        new-args.push(char)
      } else {
        // Note that the std.symbol constructor will already check that x has the correct type.
        new-args.push(x)
      }
    }

    if new-args == flat-args {
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
#let symbolx = symbol.with(typst-version: sys.version)
