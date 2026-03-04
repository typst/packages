# Manifesto for Typst

**Manifesto** 📚 is the first HTML Typst documentation template for packages, built to be very easy to use. It is **100% written in Typst, responsive** and directly uses your `typst.toml` to automatically get your package information.

[Report a bug](https://github.com/l0uisgrange/manifesto/issues?new) — [Forum](https://github.com/l0uisgrange/manifesto/discussions/categories/q-a)

You are free to check either [this example](https://bone.grangelouis.ch) from `bone` or [this one](https://zap.grangelouis.ch) from `zap`.

<img width="1232" height="758" alt="Manifesto documentation website example" src="https://github.com/user-attachments/assets/076e3071-6feb-4453-8b44-e5de1a32ec53" />

## Quick usage

The template is very easy to use, and will transform your whole project into a stunning online documentation in just a second.

```typst
#import "@preview/manifesto:0.1.0": template

#show: it => template(it, title: "MyPackage", toml: "PATH_TO/typst.toml")

= My first title

Lorem ipsum
```

## Options

The `template` function accepts a few parameters to customize the data displayed on the website.

| Option | Default value | Description |
| --- | --- | --- |
| `title` (required) |  | The title of your package |
| `toml` | `none` | The path to the `typst.toml` file |
| `version` | `none` | Your package version |
| `description` | `none` | Your package description |
| `repository` | `none` | Your package repository URL (e.g. GitHub) |
| `universe` | `none` | Your package name on Typst universe name |
| `license` | `none` | Your package license |

Note that giving the `toml` file is aready enough, and will fill in the other options.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining this template takes time and love. If you'd like to help, don't hesitate to join the journey 🤩!
