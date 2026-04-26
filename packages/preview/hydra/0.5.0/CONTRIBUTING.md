# Contribution
## Bug fixes
If you want to fix an issue please leave a comment there so others know you are working on it. If
you want to fix a bug which doesn't have an issue yet, please create an issue first. Exceptions are
typos or minor improvements, just making the PR will be enough in those cases.

## Features
When adding features, make sure you add regression tests for this feature. See the testing section
below on testing. Make sure to document the feature, see the manual section on manual and examples
below.

## Testing
To ensure that your changes don't break exisiting code test it using the package's regression tests.
This is done automatically on pull requests, so you don't need not install [typst-test], but it's
nontheless recommended for faster iteration. In general, running `typst-test run` will be enough to
ensure your changes are correct.

## Manual and examples
The manual and example images are created from a quite frankly convoluted nushell script. If you
have, or don't mind installing, [nushell], [just] and [imagemagick], then you can simply run `just
gen` to generate a new manual and examples.

The examples inside the docs currently don't make it easy to simplify this without generating them
manually the whole time. Typst is missing a feature or plugin that allows embedding whole other
Typst documents at the moment.

That being said, it's fine to leave this step out on a PR and have me generate it once the rest of
the PR is done.

[typst-test]: https://github.com/tingerrr/typst-test
[just]: https://just.systems/
[nushell]: https://www.nushell.sh/
[imagemagick]: https://imagemagick.org/
