# [unreleased](https://github.com/jamesrswift/frackable/)


# [v0.1.1](https://github.com/jamesrswift/frackable/releases/tag/v0.1.1)
## Added
- Named argument `whole` (default `none`) to display mixed fractions.
- `generator(font-size: 0.5em, shift-numerator: -0.3em, shift-denominator: 0.05em)`, which yields a function having the same signature as `frackable`, but does not rely on font features. The arguments of `generator` will depend heavily on the chosen font, defaults are appropriate for `Linux Libertine`.

## Removed

## Changed
- Use positional arguments instead of named for numerator and denominator
- (**breaking**) Depend on font features rather than uniocode codepoints for a cleaner display, at the cost of some fonts not working.
  
## Migration Guide from v0.1.0
- Remove argument names `numerator` and `denominator` from calls to `frackable`, and enters these arguments positionally instead.
- If your font does not support the `frac` feature, use `generator` to yield a `frackable`-like function.
- 
---

# [v0.1.0](https://github.com/jamesrswift/frackable/releases/tag/v0.1.0)
Initial Release