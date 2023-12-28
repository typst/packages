# Changelog of `ascii-ipa`

follows [semantic versioning][semver]

## 1.1.1

- Fixed a bug in X-SAMPA where ``` ` ``` falsely took precedence over ``` @` ``` (https://github.com/imatpot/typst-packages/issues/1)

## 1.1.0

- Translations will now return a [`string`][typst-string] if the font is not overridden
- The library now explicitly exposes functions via a "gateway" entrypoint
- Update internal project structure
- Update package metadata
- Update documentation

## 1.0.0

- Initial release

[semver]: https://semver.org
[typst-string]: https://typst.app/docs/reference/foundations/str/
