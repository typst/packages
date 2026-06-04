# GitHub Admonition for Typst

> [!NOTE]
> Add GitHub style admonitions (also known as alerts) to Typst.

## Usage

Import this package, and

```typ
#note[
  Highlights information that users should take into account, even when skimming.
]

#tip[
  Optional information to help a user be more successful.
]

#important[
  Crucial information necessary for users to succeed.
]

#warning[
  Critical content demanding immediate user attention due to potential risks.
]

#caution[
  Negative potential consequences of an action.
]

#admonition(
  icon: "icons/stop.svg",
  color: color.fuchsia,
  title: "Custom Title",
)[
  The icon, color and title are customizable.
]
```

![note-me](https://github.com/FlandiaYingman/note-me/assets/9929037/639a62fa-f2f7-4d70-b922-29dc72372f46)

Further Reading: 

- https://github.com/orgs/community/discussions/16925
- https://docs.asciidoctor.org/asciidoc/latest/blocks/admonitions/

## Style

It borrows the style of GitHub's admonition.

> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.

## Credits

The admonition icons are from [Octicons](https://github.com/primer/octicons).