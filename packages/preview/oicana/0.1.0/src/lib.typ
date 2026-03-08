/// This package currently requires a function input, because otherwise it is not possible to read files from the consuming project
/// out of the package. In the future this might be solved with a path type: https://github.com/typst/typst/issues/971

#let version = version(0, 1, 0)

/// Method to simplify reading Oicana inputs in Typst projects.
/// Pass a read function to `setup` to allow it to read project files:
/// ```typst
/// #import "@preview/oicana:0.1.0": setup
///
/// #let read-project-file(path) = return read(path, encoding: none);
/// #let (input, oicana-image, config) = setup(read-project-file);
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
/// #let issuing-date = input.invoice.buyer.name
/// #let logo = oicana-image("logo")
/// ```
/// -> (dictionary, function)
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
        + " is not supported by this package. Please check if there is an update available!",
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
        or type(config.at("production")) != bool
    ) {
      panic("oicana config found but does not contain a 'production' boolean!")
    }
    config
  } else { (production: false) }

  for definition in input-definitions {
    if definition.type == "json" {
      let json-input = if typst-inputs.keys().contains(definition.key) {
        json(bytes(typst-inputs.at(definition.key)))
      } else if (
        definition.keys().contains("development")
          and oicana-config.production == false
      ) {
        json(read-project-file(definition.development))
      } else if (definition.keys().contains("default")) {
        json(read-project-file(definition.default))
      }
      input.insert(definition.key, json-input)
    } else if definition.type == "blob" {
      if typst-inputs.keys().contains(definition.key) {
        input.insert(definition.key, typst-inputs.at(definition.key))
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
        input.insert(definition.key, development)
      } else if (definition.keys().contains("default")) {
        let default = (:)
        default.insert("bytes", read-project-file(definition.default.file))
        if definition.default.keys().contains("meta") {
          default.insert("meta", definition.default.meta)
        } else {
          default.insert("meta", (:))
        }
        input.insert(definition.key, default)
      }
    }
  }

  let oicana-image = key => {
    if input.keys().contains(key) {
      image(
        input.at(key).bytes,
        format: if input.at(key).meta.keys().contains("image_format") {
          input.at(key).meta.image_format
        } else {
          auto
        },
      )
    }
  }

  return (input, oicana-image, oicana-config)
}
