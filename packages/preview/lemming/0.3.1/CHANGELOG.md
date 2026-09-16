# 0\.3\.1
- fix: Change default show rule of `environment` to make use of `end-marker`

# 0\.3\.0
- feat: Emit `math-environment` and `math-proof` tags when exporting to html
- feat: Add `end-marker` parameter to `environment`. This allows putting a symbol at the end of math environments, similar to the QED symbol.
- fix: Make proofs and environments full width, such that equation-only statements display correctly
- fix: Do not insert QED symbols to figure captions, place them afterwards instead.


# 0\.2\.0
- feat: Provide a wrapper for `elembic.fields` to facilitate custom `show`-rules.
- fix: References now link to their targets.

# 0\.1\.0
- First release with support for `environment` and `proof`. Based on elembic.