/// Apply all TCY classifiers from config.tcy in order.
/// Each module may export a `filter(tokens, config) => tokens` function.
///
/// - tokens (array): Token array from the transform stage.
/// - config (dictionary): Full Basho config.
/// -> array: Classified token array.
#let apply-classifiers(tokens, config) = {
  for module in config.tcy {
    tokens = (module.filter)(tokens, config)
  }
  tokens
}
