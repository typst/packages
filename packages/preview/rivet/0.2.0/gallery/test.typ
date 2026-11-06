#import "../src/lib.typ": *

#let test-yaml = schema.load("/gallery/test.yaml")
#schema.render(test-yaml, config: config.config(
  full-page: true
))

#let test-json = schema.load("/gallery/test.json")
#schema.render(test-json, config: config.blueprint(
  full-page: true
))

#let test-xml = schema.load("/gallery/test.xml")
#schema.render(test-xml, config: config.dark(
  full-page: true
))

#let test-raw = schema.load(```yaml
structures:
  main:
    bits: 4
    ranges:
      3-0:
        name: test
```)
#schema.render(test-raw, config: config.config(
  full-page: true
))

#let test-typ = schema.load((
  structures: (
    main: (
      bits: 32,
      ranges: (
        "31-28": (name: "cond"),
        "27": (name: "0"),
        "26": (name: "1"),
        "25": (name: "I"),
        "24": (
          name: "P",
          description: "pre / post indexing bit",
          values: (
            "0": "post, add offset after transfer",
            "1": "pre, add offset before transfer"
          )
        ),
        "23": (
          name: "U",
          description: "up / down bit",
          values: (
            "0": "down, subtract offset from base",
            "1": "up, addition offset to base"
          )
        ),
        "22": (
          name: "B",
          description: "byte / word bit",
          values: (
            "0": "transfer word quantity",
            "1": "transfer byte quantity"
          )
        ),
        "21": (
          name: "W",
          description: "write-back bit",
          values: (
            "0": "no write-back",
            "1": "write address into base"
          )
        ),
        "20": (
          name: "L",
          description: "load / store bit",
          values: (
            "0": "store to memory",
            "1": "load from memory"
          )
        ),
        "19-16": (
          name: "Rn",
          description: "base register"
        ),
        "15-12": (
          name: "Rd",
          description: "source / destination register"
        ),
        "11-0": (
          name: "offset",
          depends-on: "25",
          values: (
            "0": (
              description: "offset is an immediate value",
              structure: "immediateOffset"
            ),
            "1": (
              description: "offset is a register",
              structure: "registerOffset"
            )
          )
        )
      )
    ),
    immediateOffset: (
      bits: 12,
      ranges: (
        "11-0": (
          name: "12-bit immediate offset",
          description: "unsigned number"
        )
      )
    ),
    registerOffset: (
      bits: 12,
      ranges: (
        "11-4": (
          name: "shift",
          description: "shift applied to Rm"
        ),
        "3-0": (
          name: "Rm",
          description: "offset register"
        )
      )
    )
  ),
  colors: (
    main: (
      "31-28": red,
      "11-4": green
    ),
    registerOffset: (
      "11-4": rgb(240, 140, 80)
    )
  )
))

#schema.render(test-typ, config: config.config(
  full-page: true
))