# Submitting a new Typst package

To submit a package, simply make a pull request with the package to this
repository. There are a few requirements for getting a package published, which
are detailed in our [Packaging guidelines][packaging-guidelines].

When a package's PR has been merged and CI has completed, the package will be
available for use. However, it can currently take a longer while until the
package will be visible on [Typst Universe][universe]. We'll reduce this delay
in the future.

Once submitted, a package will not be changed or removed without good reason to
prevent breakage for downstream consumers. By submitting a package, you agree
that it is here to stay. If you discover a bug or issue, you can of course
submit a new version of your package.

There is one exception: Minor fixes to the documentation or TOML metadata of a
package are allowed _if_ they can not affect the package in a way that might
break downstream users.


[packaging-guidelines]: packaging-guidelines.md
[universe]: https://typst.app/universe/
