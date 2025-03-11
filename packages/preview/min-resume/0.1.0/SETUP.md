
# Setup

This project uses `just` to automate all development processes. Run `just` or
refer to the _justfile_ for more information.


## Release

Install the package in default _preview_ namespace:

```
just install preview
```

To uninstall:

```
just remove preview
```


## Testing

Install the package in a separated _local_ namespace:

```
just install local
```

To uninstall:

```
just remove local
```

The command `just install-all` installs the package in both _preview_ and _local_
namespaces with just one command.


## Development

Create a direct symbolic link between this project and and the _local_ namespace,
under a special _0.0.0_ version:

```
just dev-link
```

This way, every change made into the package will instantly be available to 
Typst by using a `@local/min-article:0.0.0` import.

This command is a toggle: run it once, and it creates the link; run it again and
the link is removed; and so on.


-------------------------


## Other Useful Commands


### Debug package

Install the package in `dev/pkg/` for debug purposes:

```
just install pkg
```


### Init debug project

Initialize a template project in `dev/` for the package:

```
just init local
just init preview
```

The package must be already installed in the given namespace (see
[Release](#release) and [Testing](#testing)) for this to work. If no namespace
is given, fallback to `just preview`.


### Compile project files as PDF

Compile the Typst files — generally the template and the manual, — as PDF files:

```
just pdf
```


### Compile project files as PDF

Compile the Typst files — generally the template and the manual, — as image
files:

```
just png
```