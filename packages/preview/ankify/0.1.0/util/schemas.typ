#import "@preview/valkyrie:0.2.2" as z

#let default-configuration = (
  ankiconnect-url: "http://127.0.0.1:8765",
  verbose: false,
  scale: 1.5,
  defaults: (
    model: "Basic",
    deck: "Default",
    format: "svg",
    tags: (),
    other: none,
    render: (note: none, field: none, field-content: none) => { field-content },
  ),
  setup: body => {
    set page(margin: 1cm, width: 16cm)
    body
  },
  cache: (
    enabled: true,
    custom-file: none,
  ),
  checks: (
    typst: true,
    ankiconnect: (
      model: true,
      deck: true,
      tags: true,
    ),
  ),
)

/// Validates the structure and content of a note data dictionary.
///
/// - data (dictionary): The note data dictionary to validate.
/// -> none
#let validate-data(data) = {
  assert(type(data) == dictionary, message: "Note data must be a dictionary")
  assert(data.len() > 0, message: "Note data dictionary must not be empty")
  for (key, value) in data {
    assert(
      type(value) in (content, str, dictionary),
      message: "Values of note data dictionary must be content, strings, or dictionaries",
    )
    if type(value) == dictionary {
      // Ensure dictionary values are not empty
      assert(value.len() > 0, message: "Values of note data dictionary must not be empty dictionaries")
      for (subkey, subvalue) in value {
        assert(
          subkey in ("value", "format"),
          message: "Keys of dictionary values of note data dictionary must be \"value\" or \"format\"",
        )
        if (subkey == "value") {
          assert(
            type(subvalue) in (content, str),
            message: "Value of \"value\" in dictionary value of note data dictionary must be content or string",
          )
        } else if (subkey == "format") {
          assert(
            subvalue in ("png", "svg", "plain"),
            message: "Value of \"format\" in dictionary value of note data dictionary must be \"png\", \"svg\", or \"plain\"",
          )
        }
      }
      assert(
        "value" in value,
        message: "A field's (value, format) dictionary must contain a \"value\" key",
      )
    }
  }
}

#let note-schema = z.dictionary((
  label: z.string(assertions: (z.assert.length.min(1),)),
  deck: z.string(default: default-configuration.defaults.deck, assertions: (z.assert.length.min(1),)),
  model: z.string(default: default-configuration.defaults.model, assertions: (z.assert.length.min(1),)),
  format: z.choice(("svg", "png", "plain"), default: default-configuration.defaults.format),
  tags: z.array(z.string(assertions: (z.assert.length.min(1),)), default: default-configuration.defaults.tags),
  render: z.function(default: default-configuration.defaults.render),
  data: z.any(
    pre-transform: (self, it) => {
      if (it != none) { validate-data(it) }
      return it
    },
  ),
  other: z.any(types: (dictionary), optional: true),
))

#let defaults-schema = z.dictionary((
  deck: z.string(default: default-configuration.defaults.deck, assertions: (z.assert.length.min(1),)),
  model: z.string(default: default-configuration.defaults.model, assertions: (z.assert.length.min(1),)),
  format: z.choice(("svg", "png", "plain"), default: default-configuration.defaults.format),
  tags: z.array(z.string(assertions: (z.assert.length.min(1),)), default: default-configuration.defaults.tags),
  render: z.function(default: default-configuration.defaults.render),
  other: z.any(types: (dictionary), optional: true),
))


#let configuration-schema = z.dictionary((
  ankiconnect-url: z.string(
    default: default-configuration.ankiconnect-url,
    assertions: (z.assert.length.min(1),),
  ),
  verbose: z.boolean(default: default-configuration.verbose),
  scale: z.number(default: default-configuration.scale),
  defaults: defaults-schema,
  setup: z.function(default: default-configuration.setup),
  cache: z.dictionary((
    enabled: z.boolean(default: default-configuration.cache.enabled),
    custom-file: z.string(optional: true),
  )),
  checks: z.dictionary(
    (
      typst: z.boolean(default: default-configuration.checks.typst),
      ankiconnect: z.dictionary((
        model: z.boolean(default: default-configuration.checks.ankiconnect.model),
        deck: z.boolean(default: default-configuration.checks.ankiconnect.deck),
        tags: z.boolean(default: default-configuration.checks.ankiconnect.tags),
      )),
    ),
    optional: true,
  ),
))
