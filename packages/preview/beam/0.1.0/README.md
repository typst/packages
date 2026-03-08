# beam for typst

**beam** aims to simplify the creation of schematics for experiment setups in the field of optics.

```typst
#import "@preview/beam:0.1.0"

#beam.setup({
    import beam: *

    // draw your setup here
})
```

## Examples
A Michelson interferometer and [more](./examples)

![michselson interferometer](./examples/michelson.png)

## Documentation
Automatically generate the [manual](manual.pdf) via [tidy](https://typst.app/universe/package/tidy/)
```shell
typst compile --root . docs/main.typ manual.pdf
```

## Tests
Run tests locally with [tytanic](https://github.com/typst-community/tytanic)
```shell
tytanic run --no-fail-fast
```

## Credits
I built this package on the foundations of the fabulous [zap](https://typst.app/universe/package/zap/).
