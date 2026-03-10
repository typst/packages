# Manifesto for Typst

**Manifesto** 📚 is the first HTML Typst documentation template for packages, built to be very easy to use. It is **100% written in Typst, responsive** and directly uses your `typst.toml` to automatically get your package information.

[Report a bug](https://github.com/l0uisgrange/manifesto/issues?new) — [Forum](https://github.com/l0uisgrange/manifesto/discussions/categories/q-a)

You are free to check either [this example](https://bone.grangelouis.ch) from `bone` or [this one](https://zap.grangelouis.ch) from `zap`.

<img width="1452" height="922" alt="Preview example" src="https://github.com/user-attachments/assets/9e388dc2-267a-4131-a63b-79a052bf9b85" />

## Quick usage

The template is very easy to use, and will transform your whole project into a stunning online documentation in just a second.

```typst
#import "@preview/manifesto:0.1.1": template

#show: it => template(it, toml: toml("/typst.toml"))

= My first title

Lorem ipsum
```

## Options

The `template` function accepts a few parameters to customize the data displayed on the website.

| Option | Default value | Description |
| --- | --- | --- |
| `name` |  | The name of your package |
| `toml` | `none` | The path to the `typst.toml` file |
| `version` | `none` | Your package version |
| `description` | `none` | Your package description |
| `repository` | `none` | Your package repository URL (e.g. GitHub) |
| `license` | `none` | Your package license |

Note that giving the `toml` file is aready enough, and will fill in the other options.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining this template takes time and love. If you'd like to help, don't hesitate to join the journey 🤩!
