# uniwarn

A tiny Typst utility for package authors who want to surface custom warnings, while still allowing users to disable those warnings by namespace.

This package exposes four functions:

- `warning` to emit a warning message.
- `register-namespace` to register a warning namespace, panics if it has already been registered.
- `disable-warnings` to suppress warnings for one namespace.
- `enable-warnings` to re-enable warnings for one namespace.

## Why this exists

Typst currently has no package-level diagnostics hooks. `uniwarn` uses a small `set text(...)` trick to inject warning messages, and allows package users to opt out when they already understand the warning.

## Installation

If installed as a local package, import from the package root:

```typst
#import "@local/uniwarn:0.1.0": warning, disable-warnings, enable-warnings
```

Otherwise:

```typst
#import "@preview/uniwarn:0.1.0": warning, disable-warnings, enable-warnings
```

## Quick start

```typst
#import "@preview/uniwarn:0.1.0" as uwarn

#let ns = "your-package"
#uwarn.register-namespace(ns) // will panic if already registered by another package
#let pkg-warning = uwarn.warning.with(namespace: ns, prefix: "[yr-pkg] ")

// Visible by default
#pkg-warning("Unsupported option \"foo\"; falling back to default.")

// Disable all warnings in this namespace
#uwarn.disable-warnings(ns)
#pkg-warning("This will not be shown.")

// Re-enable later
#uwarn.enable-warnings(ns)
#pkg-warning("Warnings are visible again.")
```

## API

### `warning(namespace: "cstm", prefix: "[custom] ", message)`

Emits a warning-like message.

- `namespace` (`str`): Warning namespace used for on/off control. Choose carefully to avoid collisions.
- `prefix` (`str`): Prefix prepended to the warning text.
- `message` (`str`): Warning body.
- returns: `content`

Use `warning.with(...)` to create a package-local warning function with fixed namespace and prefix.

### `register-namespace(namespace)`

Registers a namespace and panics if the same namespace has already been registered.
It is good practice to register your namespace, but not necessary for warnings to work.

- `namespace` (`str`): Your chosen namespace string.

Usage:

```typst
#register-namespace("uniwarn")
```

### `disable-warnings(namespace)`

Disables warnings for the given namespace.

- `namespace` (`str`): Your chosen namespace string.

Usage:

```typst
#disable-warnings("uniwarn")
```

### `enable-warnings(namespace)`

Enables warnings for the given namespace.

- `namespace` (`str`): Your chosen namespace string.

Usage:

```typ
#enable-warnings("uniwarn")
```

## Namespace rules and other Caveats

- Choose a namespace that won't collide with other packages': e.g. your own package-name.
- It is good practice to register your namespace so you can be sure nothing collides. Note that because of the way typst state works, the package that gets imported last will cause the panic, thus it might not be your fault that another package's namespace collides with yours.
- Warnings are enabled by default.
- The source location reported by Typst will generally point to the warning function internals, not the original call site. Include enough context in your message to make debugging easy.
- Because of the way typst handles warnings, they are automatically deduped if the code location and the message is the same. If you want to emit a warning more than just once, you need to change the message.

## Best practices for package authors

- Reserve one namespace per package, for example `"your-package"`.
- Bind the warning utils into your package:

```typst
//my-package/internals.typ
#import "@preview/uniwarn:0.1.0": warning, disable-warnings, enable-warnings, register-namespace
//register first
#register-namespace("your-package")
//use internally
#let warning = warning.with(namespace: "your-package", prefix: "[your-package] ")
//expose these
#let disable-warnings = disable-warnings.with("your-package")
#let enable-warnings = enable-warnings.with("your-package")

//user-doc
#import "@preview/your-package:0.1.0" as ypkg
#ypkg.disable-warnings
//and users can also disable if they import uniwarn directly
//but this only works when you choose the namespace to be your packages name. 
#import "@preview/uniwarn:0.1.0" as warnings
#warnings.disable("your-package") 
```

- Keep warning messages actionable: explain what happened, where, and how to fix it.
- Explain how users should use the warning utils you expose.

## License

MIT

## Contribution
Some ideas also by `OrangeX4`.