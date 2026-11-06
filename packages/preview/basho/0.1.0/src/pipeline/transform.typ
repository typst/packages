/// Apply all rendering transforms from config.rendering in order.
/// Each module may export a `transform(tokens) => tokens` function.
///
/// - tokens (array): Token array from the flatten stage.
/// - config (dictionary): Full Basho config.
/// -> array: Transformed token array.
#let apply-transforms(tokens, config) = {
  for module in config.rendering {
    if "transform" in module {
      tokens = (module.transform)(tokens, config)
    }
  }
  tokens
}
