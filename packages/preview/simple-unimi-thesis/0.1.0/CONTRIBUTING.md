# Contributing

If you want to test the package, you must clone the repository in the local packages folder; depending on your operating system it will be:

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

Then, the structure will be `typst/packages/local/{package.name}/{package.version}` where `name` and `version` are matching the `typst.toml` file. In this project they are `simple-unimi-thesis` and `1.0.0`.

Finally, create a new project with:

```shell
typst init "@local/{package.name}:{package.version}"
```

See the [official documentation](https://github.com/typst/packages?tab=readme-ov-file#local-packages).

> [!TIP]
> Create a symlink to the location Typst needs to the location where the repository is. For instance in a Linux environment it would be:
>
> ```shellSper
> mkdir ~/.local/share/typst/packages/local/{package.name}
> ln -s REPO_FOLDER \
> ~/.local/share/typst/packages/local/{package.name}/{package.version}
> ```
>
> You could do the same for the `preview` namespace, will be the one used for the template on Typst Universe.
