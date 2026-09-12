/// This package currently requires a function input, because otherwise it is not possible to read files from the consuming project
/// out of the package. In the future this might be solved with a path type: https://github.com/typst/typst/issues/971

#let version = version(0, 2, 0)

/// Method to simplify reading Oicana inputs in Typst projects.
/// Pass a read function to `setup` to allow it to read project files:
/// ```typst
/// #import "@preview/oicana:0.2.0": setup
///
/// #let read-project-file(path) = return read(path, encoding: none);
/// #let (input, oicana-image, oicana-config) = setup(read-project-file);
/// ```
/// With the following inputs configured in the projects `typst.toml` manifest
/// ```toml
/// [[tool.oicana.inputs]]
/// type = "json"
/// key = "invoice"
/// default = "invoice.json"
/// schema = "invoice.schema.json"
///
/// [[tool.oicana.inputs]]
/// type = "blob"
/// key = "logo"
/// default = { file = "logo.jpg", meta = { image_format = "jpg" } }
/// ```
/// You can now use `input` and `oicana-image` like so:
/// ```typst
/// #let buyer-name = input.invoice.buyer.name
/// #let logo = oicana-image("logo")
/// ```
///
/// Returns a tuple of three values:
/// - `input`: dictionary of resolved input values, keyed by input key
/// - `oicana-image`: helper function that takes a blob input key and returns a Typst image
/// - `oicana-config`: dictionary with compilation metadata (e.g. `production: true/false`)
///
/// Inputs are required by default. Set `required = false` in the input definition to allow
/// missing values. Required inputs without a value cause a compile error.
///
/// See https://oicana.com/docs/templates/inputs for more details.
///
/// -> (dictionary, function, dictionary)
#let setup(
  /// Function to read a project file at the given path.
  ///
  /// This method gives Oicana access to the project files. You can define it like:
  /// ```typst
  /// let read-project-file(path) = return read(path, encoding: none);
  /// ```
  /// -> function
  read-project-file,
) = {
  let manifest = toml(read-project-file("typst.toml"))
  if (
    not manifest.keys().contains("tool")
      or not type(manifest.tool) == dictionary
      or not manifest.tool.keys().contains("oicana")
  ) {
    panic(
      "This Typst project is not an Oicana template. Please add a `[tool.oicana]` section in your `typst.toml` file.",
    )
  }

  let oicana-manifest = manifest.tool.oicana
  if (
    not oicana-manifest.keys().contains("manifest_version")
      or not type(oicana-manifest.manifest_version) == int
  ) {
    panic("The `[tool.oicana]` section has to contain a `manifest_version`.")
  }
  if not oicana-manifest.manifest_version == 1 {
    panic(
      "The `manifest_version` "
        + str(oicana-manifest.manifest_version)
        + " is not supported by this package version. Please check for updates at https://typst.app/universe/package/oicana",
    )
  }
  let input-definitions = if oicana-manifest.keys().contains("inputs") {
    manifest.tool.oicana.inputs
  } else { (:) }
  let typst-inputs = if sys.inputs.keys().contains("oicana-inputs") {
    sys.inputs.at("oicana-inputs")
  } else { (:) }
  let input = (:)

  let oicana-config = if sys.inputs.keys().contains("oicana-config") {
    let config = sys.inputs.at("oicana-config")
    if (
      not config.keys().contains("production")
        or not type(config.at("production")) == bool
    ) {
      panic(
        "oicana config found but does not contain a 'production' property of type bool!",
      )
    }
    config
  } else { (production: false) }

  for definition in input-definitions {
    let key = if (
      definition.keys().contains("key") and type(definition.key) == str
    ) {
      definition.key
    } else {
      panic("Every input needs a 'key' property of type string")
    }

    let is-required = if definition.keys().contains("required") {
      if type(definition.required) != bool {
        panic(
          "The 'required' property of input '" + key + "' is not of type bool",
        )
      }
      definition.required
    } else {
      true
    }

    if definition.type == "json" {
      let json-input = if typst-inputs.keys().contains(key) {
        json(bytes(typst-inputs.at(key)))
      } else if (
        definition.keys().contains("development")
          and oicana-config.production == false
      ) {
        json(read-project-file(definition.development))
      } else if (definition.keys().contains("default")) {
        json(read-project-file(definition.default))
      }
      if json-input == none and is-required {
        panic(
          "No value for the required input '"
            + key
            + "' was supplied. Pass a value or set a default/development value in your typst.toml.",
        )
      }
      input.insert(key, json-input)
    } else if definition.type == "blob" {
      let resolved = if typst-inputs.keys().contains(key) {
        typst-inputs.at(key)
      } else if (
        definition.keys().contains("development")
          and oicana-config.production == false
      ) {
        let development = (:)
        development.insert(
          "bytes",
          read-project-file(definition.development.file),
        )
        if definition.development.keys().contains("meta") {
          development.insert("meta", definition.development.meta)
        } else {
          development.insert("meta", (:))
        }
        development
      } else if (definition.keys().contains("default")) {
        let default = (:)
        default.insert("bytes", read-project-file(definition.default.file))
        if definition.default.keys().contains("meta") {
          default.insert("meta", definition.default.meta)
        } else {
          default.insert("meta", (:))
        }
        default
      }
      if resolved == none and is-required {
        panic(
          "No value for the required input '"
            + key
            + "' was supplied. Pass a value or set a default/development value in your typst.toml.",
        )
      }
      input.insert(key, resolved)
    } else {
      panic(
        "Found unknown input type '"
          + definition.type
          + "'. Should be \"json\" or \"blob\".",
      )
    }
  }

  let oicana-image = (key, ..args) => {
    if input.keys().contains(key) and not input.at(key) == none {
      let blob-input = input.at(key)
      image(
        blob-input.bytes,
        format: if blob-input.meta.keys().contains("image_format") {
          blob-input.meta.image_format
        } else {
          auto
        },
        ..args,
      )
    }
  }

  return (input, oicana-image, oicana-config)
}
