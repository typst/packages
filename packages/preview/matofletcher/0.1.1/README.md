# [Matofletcher]

> [!NOTE]
> This is a fork of [autofletcher], which had its last update on 2024-05-20 and
> has [an open and untouched PR] since 2025-05-08. While it's being
> unmaintained, this fork will provide minimal necessary updates to be able to
> continue using this package.

This small module provides functions to (sort of) abstract away manual
placement of coordinates.

See the [manual] for usage examples.

## Development

After cloning the repository run

```sh
just init
```

to create a pre-commit Git hook. It will use `typstyle` and `typst` to format
code and compile manual. More specifically, it will check if both actions were
already done. Otherwise the hook will fail.

See [`.justfile`] for more details and other recipes.

## Credits

- [fletcher]
- [autofletcher]

[Matofletcher]: https://codeberg.org/Andrew15-5/matofletcher
[fletcher]: https://github.com/Jollywatt/typst-fletcher
[autofletcher]: https://github.com/3akev/autofletcher
[an open and untouched PR]: https://github.com/3akev/autofletcher/pull/1
[manual]: ./manual.pdf
[`.justfile`]: ./.justfile
