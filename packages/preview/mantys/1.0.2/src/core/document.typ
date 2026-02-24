#import "../util/typing.typ" as t
#import "../util/utils.typ" as util
#import "schema.typ"

/// Creates a document by parsing the supplied arguments agains the document schema using #universe("valkyrie").
/// -> document
#let create(
  /// Arguments accepted by @type:document.
  /// -> any
  ..args,
) = t.parse(args.named(), schema.document)

/// Saves the @type:document in an internal state.
/// -> content
#let save(
  /// The @type:document created by @cmd:document:create.
  /// -> document
  doc,
) = state("mantys:document").update(doc)

/// Updates the @type:document in the internal state.
/// -> content
#let update(
  /// An update function to be passed to #typ.state: #lambda("document", ret:"document")
  /// -> function
  func,
) = state("mantys:document").update(func)

/// Updates the value at #arg[key] with the update function #arg[func]: #lambda("any", "any")
/// #arg[key] may be in dot-notation to update values in nested dictionaries.
/// #property(see: (<cmd:utils:dict-update>))
#let update-value(key, func) = update(doc => {
  doc.insert(key, func(doc.at(key, default: default)))
  doc
})

/// Retrieves the document at the current location from the internally saved state.
/// #property(requires-context: true)
#let get() = state("mantys:document").get()

/// Retrieves the final document from the internally saved state.
/// #property(requires-context: true)
#let final() = state("mantys:document").final()

/// Gets a value from the internally saved document.
/// #property(requires-context: true)
#let get-value(key, default: none) = util.dict-get(get(), key, default: default)

/// Retrieves the @type:document from the internal state and passes is to #arg[func].
/// #property(requires-context: true)
#let use(
  /// A function to receive the @type:document.
  /// -> function
  func,
) = context func(get())

/// Gets a value from the internally saved document.
/// #property(requires-context: true)
#let use-value(
  /// Key to retrieve. May be in dot-notation.
  /// -> str
  key,
  /// Function to receive the value.
  /// -> function
  func,
  /// default value to use, if #arg[key] is not found.
  /// -> any
  default: none,
) = context func(util.dict-get(get(), key, default: default))
