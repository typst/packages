#let _convert-heading-numbering-sep(sep) = {
  if type(sep) == none {
    box(width: 0pt)
  } else if type(sep) == length {
    box(width: sep)
  } else if type(sep) == str or type(sep) == content {
    sep
  } else {
    sym.wj
  }
}

#let _heading-container(heading-numbering, body) = context {
  if type(heading-numbering) == dictionary and heading-numbering.at("runin", default: false) {
    box(body)
  } else {
    body
  }
}

#let _config-heading-numbering-str(heading-numbering, body) = {
  set heading(numbering: heading-numbering)
  body
}

#let _make-heading-numbering-config(
  format: none,
  sep: auto,
  first-line-indent: 0em,
  hanging-indent: auto,
  align: left,
  prefix: none,
  suffix: none,
) = {
  let config = (
    format: none,
    sep: auto,
    prefix: none,
    suffix: none,
    align: left,
    first-line-indent: 0em,
    hanging-indent: auto,
  )
  if format != none {
    config.format = format
  }
  if sep != auto {
    config.sep = _convert-heading-numbering-sep(sep)
  } else {
    config.sep = sym.wj
  }
  if prefix != none {
    config.prefix = prefix + sym.wj
  }
  if suffix != none {
    config.suffix = suffix + sym.wj
  }
  if align != left {
    config.align = align
  }
  if first-line-indent != 0em {
    config.first-line-indent = first-line-indent
  }
  if hanging-indent != auto {
    config.hanging-indent = hanging-indent
  }
  config
}

#let _heading-show-rule(heading-numbering, it) = {
  show: block.with(width: 100%, sticky: true)
  if heading-numbering == none {
    it.body
  } else if type(heading-numbering) == dictionary {
    let heading-numbering = _make-heading-numbering-config(..heading-numbering)
    let it-number = counter(heading).display(it.numbering)
    let it-number-full = (
      heading-numbering.prefix,
      it-number,
      heading-numbering.suffix,
      heading-numbering.sep,
    ).join()
    if heading-numbering.hanging-indent == auto {
      heading-numbering.hanging-indent = measure(it-number-full).width
    }
    set align(heading-numbering.at("align", default: left))
    set par(
      first-line-indent: heading-numbering.first-line-indent,
      hanging-indent: heading-numbering.hanging-indent
    )
    show: par
    if it-number == none {
      it.body
    } else {
      box(width: heading-numbering.hanging-indent, it-number-full) + it.body
    }
  } else {
    it
  }
}

#let _config-heading-numbering-dictionary(heading-numbering, body) = {
  let heading-numbering = _make-heading-numbering-config(..heading-numbering)
  set heading(numbering: (..nums) => {
    let counts = nums.pos();
    numbering(heading-numbering.format, ..counts)
  })
  show heading: _heading-show-rule.with(heading-numbering)
  body
}

#let _config-heading-numbering-array(heading-numbering, body) = {
  set heading(numbering: (..nums) => {
    let it-level = nums.pos().len()
    let heading-numbering = heading-numbering.at(it-level - 1, default: heading-numbering.last())
    if type(heading-numbering) == str {
      heading-numbering = heading-numbering
    } else if type(heading-numbering) == dictionary {
      heading-numbering = _make-heading-numbering-config(..heading-numbering).format
    } else {
      panic("heading-numbering must be a string, dictionary or an array of strings/dictionaries")
    }
    if heading-numbering == none {
      none
    } else {
      numbering(heading-numbering, ..nums)
    }
  })
  show heading: it => {
    show: _heading-show-rule.with(heading-numbering.at(it.level - 1, default: heading-numbering.last()))
    it
  }
  body
}

#let _config-heading-numbering(heading-numbering) = {
  if type(heading-numbering) == str {
    _config-heading-numbering-str.with(heading-numbering)
  } else if type(heading-numbering) == dictionary and heading-numbering.keys().contains("format") {
    _config-heading-numbering-dictionary.with(heading-numbering)
  } else if type(heading-numbering) == array {
    _config-heading-numbering-array.with(heading-numbering)
  } else {
    panic("heading-numbering must be a string, dictionary or an array of strings/dictionaries")
  }
}


