# Checklist for a smooth package review

We recommend going through this list and making sure you can tick all the boxes
before submitting your package for review.

The following rules have to be checked manually.

- [ ] The package should adhere to our [naming guidelines][name].
- [ ] The examples in the README should work.
- [ ] Version numbers in the documentation and README should be up-to-date.
- [ ] The authors and copyright year in the license file (if any) should be correct.
- [ ] The license file contents and the `license` field in the manifest should match.
- [ ] There should be no [copyrighted material][copyright] in the package.

The following rules are checked automatically in CI when you open a pull request,
by [`typst-package-check`][check] (which you can run locally too).

- [ ] The package manifest (`typst.toml`) is valid (no syntax error, and follows
  [the defined schema][manifest]).
- [ ] The package can be imported without errors. In particular, it should not
  contain any syntax errors. This does not mean that the package must be 
  flawless; it's always possible for bugs to slip in. If you find a mistake or 
  bug after the package is accepted, you can simply submit a patch release.
- [ ] If the package is a template, it should compile as it is out-of-the-box.
  In particular, it should use the "absolute" package import and not a relative
  one (i.e `@preview/my-package:0.1.0` and not `../lib.typ`).
- [ ] Identifiers should preferably use kebab-case, as this is the convention that
  is used in the standard library and in most packages. There can be exceptions
  (for instance it can make sense to have a variable called `Alpha` and not
  `alpha`) and if you have a strong preference for camelCase or snake_case, it
  can be accepted.
- [ ] Large files should be excluded from the package archive or simply not be
  committed to this repository, [as explained here][exclusion].
- [ ] The README and license file should never be [excluded][exclusion] from the
  package archive.
- [ ] The author of a package update should be the same person as the one who
  submitted the previous version. If not, the previous author will be asked
  before approving and publishing the new version.
- [ ] Example files should preferably [use the absolute package
  import][absolute-import], as it allows people to copy/paste them and start
  from there immediately.
- [ ] The `homepage` and `repository` fields of the manifest should not be the
  same and they should be valid URLs. If there is a repository, but no dedicated
  website, only the `repository` field should be kept.

[manifest]: manifest.md
[exclusion]: tips.md#what-to-commit-what-to-exclude
[absolute-import]: typst.md#use-package-specification-in-imports
[check]: https://github.com/typst/package-check
[name]: manifest.md#naming-rules
[copyright]: licensing.md#copyrighted-material
