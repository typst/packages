# Writing high-quality Typst files

No specific code style is mandated, but two spaces of indent and kebab-case for
variable and function names are recommended. There can be exceptions (for
instance it can make sense to have a variable called `Alpha` and not `alpha`)
and if you have a strong preference for camelCase or snake_case, it can be
accepted.

## Use package specifications in imports

When writing example files, it is better to use the full package
specification when importing your own package, instead of relative imports. The
reasoning here is that it should be possible to copy any provided file as is and
start working from that. In other words, it is better to write:

```typ
#import "@preview/my-package:1.0.0": my-function
```

than:

```typ
#import "../lib.typ": my-function
```

For template files, this is not only a recommendation but a requirement. Users
should never have to edit a project freshly created from a template to make it
compile.

This recommendation does not apply to files that are directly part of the package
however, as this could cause a cyclic import.

## Only exposing specific functions publicly

When writing your package, you will probably create internal functions and
variables that should not be accessible to the end user. However, Typst
currently doesn't provide any keyword to indicate that a given binding should be
public or private, as most other programming languages do.

Fortunately, there is an easy pattern to select specific items to be public, and
keep the rest private to your package: instead of putting actual code in the
entrypoint of the package, simply import the items you want to be public from
other files.

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

## Template customization

When providing a template, it is often desirable to let users customize the
styles you provide. You may also want to let them override the default contents
you provide (for example, what elements are shown on the title page and how they
are displayed).

However, the way Typst templates currently work, this code often lives in the
library part of the package, that is not copied to the users project, and thus
cannot be modified to fit their needs. Only placeholder configuration and
content is generally part of the template code that the user can edit in their
own project.

There is no proper solution to that problem for now. In the future, types
and custom elements will be a good way to give user control over the template
contents and appearance if they need, while providing good defaults.
