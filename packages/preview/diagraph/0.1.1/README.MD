# diagraph

A simple graphviz binding for typst using the new webassembly plugin system

## Usage

This plugin is quite simple to use, you just need to import it:

```typ
#import "@preview/diagraph:0.1.0": *
```

It allows you to render a graphviz dot string to a svg image in three different ways:

## Render function

```typ
#render("digraph { a -> b }")
```

## Raw render function

````typ
#raw-render[
    ```dot
    digraph {
        a -> b
    }
    ```
]
````

You can see an example of this in the [example](https://github.com/Robotechnic/diagraph/tree/main/examples) folder.

For more information about the graphviz dot language, you can check the [official documentation](https://graphviz.org/documentation/).

## Functions definitions

### render

This function allow you to render a graphviz dot string to a svg image.

```typ
render(
    dot: string,
    engine: string,
    width: auto relative,
    height: auto relative,
    fit: string,
    background: string
)
```

| Parameter | Description | Default value |
| :-------: | :---------: | :-----------: |
| dot | The dot string to render | Required |
| engine | The graphviz engine to use | dot |
| width | The width of the svg | auto |
| height | The height of the svg | auto |
| fit | The fit mode of the svg | contain |
| background | The background color of the svg | transparent |

All the optional parameters are the same as the one of images, you can check the [documentation](https://typst.app/docs/reference/visualize/image/) for more details.

### raw-render

This function allow you to use raw to render a graphviz dot string.

```typ
raw-render(
    engine: string,
    width: auto relative,
    height: auto relative,
    fit: string,
    background: string,
    raw
)
```

| Parameter | Description | Default value |
| :-------: | :---------: | :-----------: |
| engine | The graphviz engine to use | dot |
| width | The width of the svg | auto |
| height | The height of the svg | auto |
| fit | The fit mode of the svg | contain |
| background | The background color of the svg | transparent |
| raw | The dot string to render | Required |

This function will panic if the provided content is not a `raw`.

## Build

This project was built with emscripten `3.1.45`. Apart from that, you just need to run `make wasm` to build the wasm file. All libraries are downloaded and built automatically to get the right version that works.

There are also some other make commands:

- `make clean`: Clean the build folder
- `make link`: Link the project to the typst plugin folder
- `make compile_database`: Generate the compile_commands.json file
- `make module`: It copy the files needed to run the plugin in a folder called `graphviz` in the current directory

## Notes

Background color is just a shortcut for the `bgcolor` attribute of the graphviz `digraph` so:

```typ
#render("digraph { bgcolor = red; a -> b }")
```

is strictly equivalent to:

```typ
#render("digraph { a -> b }", background: "red")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Changelog

### 0.1.1

- Remove the `raw-render-rule` show rule because it doesn't allow use of custom font and the `render` / `raw-render` functions are more flexible
- Add the `background` parameter to the `render` and `raw-render` typst functions and default it to `transparent` instead of `white`
- Add center attribute to draw graph in the center of the svg in the `render` c function

### 0.1.0

Initial working version
