# Writing package documentation

Packages must contain a `README.md` file documenting (at least briefly) what the
package does and all definitions intended for usage by downstream users.
Examples in the README should show how to use the package through a `@preview`
import. Also consider running [`typos`][typos] through your package before
release.

More complete documentation (usually written in Markdown, or in a PDF
generated from a Typst file) can be linked from this README.

If your package has a dedicated documentation website, it can be linked in the
README, but also via the `homepage` field of your [manifest].

When linking to a manual, images, etc. from another git repository, consider
linking to a specific tag or revision, instead of the `main` branch. This will
ensure that the linked resources always match the version of the package.

## Differences from standard Markdown

Typst Universe processes your package README before displaying it,
in ways that differ from standard Markdown and from what GitHub or other
Git forges do. Here is what you need to know to make sure your README
will be displayed as expected.

The most visible processing that is done is to remove top-level headings: a web
page should only have a single `<h1>` tag for accessibility and SEO reasons, and
Typst Universe already shows the name of the package in such a heading.

Also note that some Markdown extensions that are present on GitHub, like
[alert blocks] or [emoji shortcodes] are not available on Typst Universe.

## Theme-responsive images

You can include images that will work with both light and dark theme in your README
using the following snippet:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="example-dark.png">
  <img alt="Example output" src="example-light.png">
</picture>
```

[typos]: https://github.com/crate-ci/typos
[manifest]: manifest.md
[alert blocks]: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts
[emoji shortcodes]: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#using-emojis
