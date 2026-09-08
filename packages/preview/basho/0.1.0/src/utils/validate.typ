/// Validate a Basho configuration dictionary.
/// Panics with a descriptive message when required fields are missing or have invalid types.
///
/// - config (dictionary): The merged configuration to validate.
/// -> none
#let validate-config(config) = {
  assert(
    type(config) == dictionary,
    message: "basho: config must be a dictionary",
  )

  assert(
    config.font == none or type(config.font) == str,
    message: "basho: config.font must be a string or none",
  )
  assert(
    type(config.features) == array,
    message: "basho: config.features must be an array (e.g. (\"vert\", \"vrt2\"))",
  )

  if type(config.rendering) == array {
    for module in config.rendering {
      if "transform" in module {
        assert(
          type(module.transform) == function,
          message: "basho: each config.rendering entry with 'transform' must have a function value, got "
            + repr(type(module.transform)),
        )
      }
      if "node-renderers" in module {
        assert(
          type(module.node-renderers) == dictionary,
          message: "basho: each config.rendering entry with 'node-renderers' must have a dictionary value",
        )
      }
    }
  } else {
    assert(
      false,
      message: "basho: config.rendering must be an array of rendering modules",
    )
  }

  if type(config.tcy) == array {
    assert(
      config.tcy.len() > 0,
      message: "basho: config.tcy must contain at least one TCY module",
    )
    for tcy-mod in config.tcy {
      assert(
        "filter" in tcy-mod,
        message: "basho: each config.tcy entry must have a 'filter' function",
      )
      assert(
        type(tcy-mod.filter) == function,
        message: "basho: each config.tcy.filter must be a function",
      )
      assert(
        "pattern" in tcy-mod,
        message: "basho: each config.tcy entry must have a 'pattern' field (regex)",
      )
      assert(
        "sizes" in tcy-mod,
        message: "basho: each config.tcy entry must have a 'sizes' field (array of lengths)",
      )
    }
  } else {
    assert(false, message: "basho: config.tcy must be an array of TCY modules")
  }

  if type(config.kinsoku) == dictionary {
    assert(
      "resolve" in config.kinsoku,
      message: "basho: config.kinsoku must have a 'resolve' function",
    )
    assert(
      type(config.kinsoku.resolve) == function,
      message: "basho: config.kinsoku.resolve must be a function",
    )
  } else {
    assert(
      false,
      message: "basho: config.kinsoku must be a dictionary with resolver settings",
    )
  }

  if type(config.list) == dictionary {
    if "bullet" in config.list {
      assert(
        type(config.list.bullet) == dictionary,
        message: "basho: config.list.bullet must be a dictionary",
      )
      assert(
        "flatten" in config.list.bullet,
        message: "basho: config.list.bullet must have a 'flatten' function",
      )
      assert(
        type(config.list.bullet.flatten) == function,
        message: "basho: config.list.bullet.flatten must be a function",
      )
    }
    if "numbered" in config.list {
      assert(
        type(config.list.numbered) == dictionary,
        message: "basho: config.list.numbered must be a dictionary",
      )
      assert(
        "flatten" in config.list.numbered,
        message: "basho: config.list.numbered must have a 'flatten' function",
      )
      assert(
        type(config.list.numbered.flatten) == function,
        message: "basho: config.list.numbered.flatten must be a function",
      )
    }
  } else {
    assert(
      false,
      message: "basho: config.list must be a dictionary with 'bullet' and 'numbered' keys",
    )
  }

  if type(config.layout) == dictionary {
    assert(
      type(config.layout.columns) == int,
      message: "basho: config.layout.columns must be an integer >= 1",
    )
    assert(
      config.layout.columns >= 1,
      message: "basho: config.layout.columns must be >= 1",
    )
    assert(
      type(config.layout.gap) == length,
      message: "basho: config.layout.gap must be a length (e.g. 1em)",
    )
    assert(
      type(config.layout.column-gap) == length,
      message: "basho: config.layout.column-gap must be a length (e.g. 2em)",
    )
  } else {
    assert(
      false,
      message: "basho: config.layout must be a dictionary with layout parameters",
    )
  }

  if type(config.sizing) == dictionary {
    assert(
      type(config.sizing.char-box) == length,
      message: "basho: config.sizing.char-box must be a length (e.g. 1em)",
    )
  }

  if "categories" in config and type(config.categories) == dictionary {
    if "classify" in config.categories {
      assert(
        type(config.categories.classify) == function,
        message: "basho: config.categories.classify must be a function returning \"horizontal\", \"rotated\", or \"char\"",
      )
    }
  }
}
