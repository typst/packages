# Contributing

If you want to test the package, you must clone the repository in the local packages folder; depending on your operating system it will be:

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

Then, the structure will be `typst/packages/local/{package.name}/{package.version}` where `name` and `version` are matching the `typst.toml` file. In this project they are `elegant-polimi-thesis` and `0.1.1`.

Finally, create a new project with:

```shell
typst init "@local/{package.name}:{package.version}"
```

See the [official documentation](https://github.com/typst/packages?tab=readme-ov-file#local-packages).

> [!TIP]
> Create a symlink to the location Typst needs to the location where the repository is. For instance in a Linux environment it would be:
>
> ```shell
> mkdir ~/.local/share/typst/packages/local/PACKAGE.NAME
> ln -s REPO_FOLDER \
> ~/.local/share/typst/packages/local/PACKAGE.NAME/PACKAGE.VERSION
> ```
>
> You could do the same for the `preview` namespace, will be the one used for the template on Typst Universe. There is the `symlink.sh` to account for those operations: make sure to configure the correct paths.
> 
