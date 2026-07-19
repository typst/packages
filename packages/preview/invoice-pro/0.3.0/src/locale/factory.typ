/// Merges a depth-2 patch dictionary onto a base dictionary.
/// Panics if the patch contains keys not present in the base schema.
#let base-pull-deep-merge(base, patch) = {
  if type(patch) != dictionary { return base }

  let result = base

  for (group-key, base-group) in base {
    if group-key not in patch { continue }

    let patch-group = patch.at(group-key, default: (:))

    if type(patch-group) != dictionary { continue }

    let base-sub-keys = base-group.keys()
    let patch-sub-keys = patch-group.keys()

    let valid = patch-sub-keys.all(k => k in base-sub-keys)
    if not valid {
      let bad-key = patch-sub-keys.find(k => k not in base-sub-keys)
      panic(
        "Invalid key '"
          + bad-key
          + "' found in group '"
          + group-key
          + "'. Allowed keys: "
          + str(base-sub-keys),
      )
    }

    result.insert(group-key, base-group + patch-group)
  }

  return result
}

#let build-locale(lang, region) = {
  (..overrides, base-lang, base-region) => {
    // 1. Extract the user DSL arrays safely
    let user-lang-patches = overrides
      .pos()
      .flatten()
      .filter(p => type(p) == dictionary)
      .map(p => p.at("strings", default: (:)))

    let user-region-patches = overrides
      .pos()
      .flatten()
      .filter(p => type(p) == dictionary)
      .map(p => p.at("region", default: (:)))

    // 2. Language Pipeline
    let final-lang = (
      lang,
      ..user-lang-patches,
    ).fold(base-lang, base-pull-deep-merge)

    // 3. Region Pipeline
    let specific-region = region(final-lang)
    let final-region = (
      specific-region,
      ..user-region-patches,
    ).fold(base-region, base-pull-deep-merge)

    // 4. Return Final Context
    return (
      strings: final-lang,
      format: final-region.format,
      normalize: final-region.normalize,
      currency: final-region.currency,
      tax: final-region.tax,
      meta: final-region.meta,
    )
  }
}
