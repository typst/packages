/// Loads a schema from a file or a raw block.
/// This function returns a dictionary of structures
/// 
/// Supported formats: #schema.valid-extensions.map(e => raw("." + e)).join(", ")
/// - path-or-schema (str, raw, dictionary):
///   #list(
///     [If it is a string, defines the path to load.\ #emoji.warning Warning: this will only work if this package is part of your project, as packages installed in the `@local` or `@preview` namespace cannot access project files],
///     [If it is a raw block, its content is directly parsed (the block's language will define the format to use)],
///     [If it is a dictionary, it directly defines the schema structure]
///   )
/// -> dictionary
#let load(path-or-schema) = {}

/// Renders the given schema
/// This functions
/// - schema (dictionary): A schema dictionary, as returned by @@load()
/// - config (auto, dictionary): The configuration parameters, as returned by #doc-ref("config.config")
/// - width (ratio, length): The width of the generated figure
#let render(schema, config: auto, width: 100%) = {}