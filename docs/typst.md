# Writing high-quality Typst files

No specific code style is mandated, but two spaces of indent and kebab-case for
variable and function names are recommended.

## Use package specification in imports

When writing a package, it is better to use the full package specification
when importing your own package, instead of relative imports. In other words,
it is better to write:

```typ
#import "@preview/my-package:1.0.0": my-function"
```

than:

```typ
#import "../lib.typ": my-function"
```

This is especially true for example files. The reasoning here is that
it should be possible to copy any provided file as is and start working
from that.

For template files, this is not only a recommendation but a requirement. Users
should never have to edit a project freshly created from a template to make it
compile.

## Only exposing specific functions publicly

When writing your package, you will probably create internal functions
and variables that should not be accessible to the end user. However,
Typst doesn't provide any keyword to indicate that a given binding should
be public or private, as most other programming languages do.

Fortunately, there is an easy pattern to select specific items to be public,
and keep the rest private to your package: the entrypoint of the package
should not contain any actual code, but simply import the items you want to
be public from other files.

Let's look at an example. Here is my `package.typ` file:

```typ
#let private(a, b) = a + b
#let public(a, b, c) = private(a, b) * private(b, c)
```

Then, if your package entrypoint is set to `lib.typ`, you can chose what
to export to the user by writing the following in `lib.typ`:

```typ
#import "package.typ": public
```

The user won't be able to call the `private` function, but can access the one
named `public` as they wish.

## Editable templates

When providing a template, it is often desirable to let users customize the
styles you provide. You may also want to let them override the default contents
you provide (for example, what elements are shown on the title page and how they
are displayed).

However, the way Typst templates currently work, this code often lives in the
library part of the package, that is not copied to the users project, and thus
cannot be modified to fit their needs. Only placeholder configuration and
content is generally part of the template code that the user can edit in their
own project.

There are still strategies to make your template as customizable as possible.

The main one is to always split styles and content. Template generally export a
global function that define styles using `show` and `set` rules, and wrap the
document body in some common structure (title page, abstract, outline, etc.). To
make it possible to customize the content provided by the template, they should
actually be defined in another function that the styles. This way it is possible
to first apply the template styles, customize them, and finally include the
common structure with modified styles.

```typ
#import "@preview/my-template:1.0.0"

// Apply the default styles
#show: my-template.default-styles
// Overwrite some of them
#set text(font: "Comic Neue")
// Show the template contents
#show: my-template.layout

The contents of the document go here.
```

Another solution is to provide a lot of different parameters to your main
template function to let the user override as much of the content and styles as
they want. The downside here is that it adds a lot of complexity, both for users
and package maintainers.

If you are curious, possible future solutions to properly address this problem
have been discussed in [this forum thread][forum].

[forum]: https://forum.typst.app/t/overriding-template-parameters-missing-social-convention-or-typst-design-flaw
