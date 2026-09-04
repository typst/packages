## Line Referencing

- Explore alternatives for line referencing
    - Inject invisible figures/metadata at the end of the line?
    - Create a function for adding a label, like lovelace?
- If we keep the current option to detect line labels, we should make the API more flexible: instead of requiring that the label starts with "line:", we could add a regex parameter to the `enable-line-refs` show rule to specify the pattern of line labels

## Submitting a New Version

- [ ] Have you updated the version numbers (both of the package and the Typst compiler) in:
    - [ ] `typst.toml`?
    - [ ] `README.md`?
    - [ ] `examples/`?
- [ ] Have you recorded all changes in `CHANGELOG.md`?