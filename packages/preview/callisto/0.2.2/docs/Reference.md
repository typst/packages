# API Reference

## Configuration

The main functions and their aliases can be configured by calling `config`. This function accepts almost all the parameters of the other functions, and returns a dict with all main and alias functions preconfigured accordingly. For example

```typst
#let (output, render) = callisto.config(
   nb: json("notebook.ipynb"),
   output-type: ("display_data", "execution_result"),
   item: 0,
)
```

configures `output` and `render` to use `notebook.ipynb` as notebook, keep only display and result outputs (ignoring errors and streams), and in case of multiple outputs to keep only the first one.

## Cell specification

Most functions accept a cell specification as positional argument. Below we use the `render` function for illustration. The cell specification can be:

-  An integer: by default this refers to the cell index in the notebook, but `count: "execution"` can be used to have this refer to the execution count. Examples:

   ```typst
   render(0) // render first cell
   render(1, count: "execution") // render cell with execution_count equal to 1
   ```

-  A string: by default this can be either a cell label, ID, or tag. A cell label refers to a `label` field in the cell metadata. This field can be defined by adding a special header at the top of the cell source:

   ```
   #| label: xyz
   ...
   ```

   The `name-path` parameter of the `cells` function can be used to change how the string is matched to cells.

   Examples:

   ```typst
   // Render cell(s) with label or tag "plot1"
   render("plot1") 
   // Render cell(s) with `metadata.type` field equal to "scatter"
   // (for example a cell with `#| type: scatter` in the header).
   render("scatter", name-path: "metadata.type")
   ```

-  A function which is passed a cell dict and must return `true` for desired cells, `false` otherwise. Example:

   ```typst
   // Results of cells with execution count larger than 3
   #results(c => c.execution_count > 3)
   ```

-  A literal cell (a dictionary as returned by a `cells` call). Example:

   ```typst
   // Get the first three cells as dicts
   #let c = cells(range(3))
   // Render only the code cells among them
   render(c, cell-type: "code")
   ```

-  An array of the above. Example:

   ```typst
   // Render the first 10 cells
   #render(range(10))
   ```

## Main functions

-  `cells([spec], nb: none, count: "index", name-path: auto, cell-type: "all", keep: "all")`

   Retrieves cells from a notebook. Each cell is returned as a dict. This is a low-level function to be used for further processing.

   -  `spec` is an optional argument used to select cells: if omitted, all cells are selected. See the [cell specification](#cell-specification) section. Example:

      ```typst
      // Get the first five cells
      #cells(range(5))
      ```

   -  `count` can be `"index"` or `"execution"`, to select if a cell number refers to its position in the notebook (zero-based) or to its execution count. Example:

      ```typst
      // Cells with execution count between 5 and 9
      #cells(range(5, 10), count: "execution")
      ```

   -  `name-path` can be a string or an array of strings, or `auto` for the default paths: `("metadata.label", "id", "metadata.tags")`. Each string in the array specifies a path in the cell dict. The strings will be tried in order to check if a particular cell should be selected. A string of the form `x.y` refers to path `y` in path `x` of the cell. Example:

      ```typst
      // Get cells that have `type: "scatter"` in the metadata.
      #cells("scatter", name-path: "metadata.type")
      ```

      Note that for code cells, a metadata key-value pair such as `type: "scatter"` can be defined with a [header line](#cell-data-and-cell-header) of the form `#| type: scatter` in the cell source.

   -  `cell-type` can be `"markdown"`, `"raw"`, `"code"`, an array of these values, or `"all"`. Example:

      ```typst
      // Get cells with index between 0 and 9 and discard the raw cells
      #cells(range(10), cell-type: ("markdown", "code"))
      ```

   -  `keep` can be a cell index, an array of cell indices, `"all"`, or `"unique"` to raise an error if the call doesn't match exactly one cell. This filter is applied after all the others described above. This parameter cannot be set in `config`: it has meaning only in conjunction with the other `cells` arguments. Example:

      ```typst
      // Get first and last non-raw cells with index between 0 and 9
      #cells(range(10), cell-type: ("markdown", "code"), keep: (0, -1))
      ```

-  `sources(..cell-args, result: "value", lang: auto, raw-lang: none)`

   Retrieves the source from selected cells. The `cell-args` are the same as for the `cells` function.

   -  `result`: how the function should return its result: `"value"` to return a list of values that can be inserted, or `"dict"` to return a dictionary that contains a `"value"` field and a `"cell"` field with the cell index, ID, type, execution count (for code cells) and metadata.

      ```typst
      // Get a dict with source and various metadata for each code cell
      #sources(cell-type: "code", result: "dict")
      ```

   -  `lang`: the language to set on the returned raw blocks for code cells. By default this is inferred from the notebook metadata. Example:

      ```typst
      // Get source of all cells, setting the language to python for code cells
      #sources(lang: "python")
      ```

   -  `raw-lang`: the language to set on the returned raw blocks for raw cells.

      ```typst
      // Get source of all cells, setting `lang` to `typ` for raw cells
      #sources(raw-lang: "typ")
      ```

-  `outputs(..cell-args, output-type: "all", format: default-formats, handlers: auto, ignore-wrong-format: false, stream: "all", result: "value")`

   Retrieves outputs from selected cells. The `cell-args` are the same as for the `cells` function. This function operates only on code cells; other cell types are ignored.

   -  `output-type` can be `"display_data"`, `"execute_result"`, `"stream"`, `"error"`, an array of these values, or `"all"`.

      The `execute_result` output is normally the value returned by the last line in a code cell; this output is normally missing if the last line returns nothing. It is possible to have other cell lines generate results (for example using `sys.displayhook` in Python) but that is uncommon and not recommended. A single result can be stored in multiple formats in the notebook, to let the reader choose a preferred format. Use the `format` parameter to choose particular format for the result (see below).

      A `display_data` output is a display object generated by the cell, in addition to (or instead of) the cell result. A cell can have many display outputs. As for `execute_result` outputs, each display output can be stored in multiple formats in the notebook.

      A `stream` is a piece of text written by the cell either on the standard output or the standard error (see the `stream` parameter below). When a cell produces interleaved messages on both streams, each message is stored in the notebook as a separate stream item so that the order of messages is preserved. If you want to know the stream name for each stream item, set `result` to `"dict"` (see below).

      An `error` stores information on an error raised during the execution of a cell. Set `result` to `"dict"` (see below) to get detailed information on the error, including a backtrace.

      Example:

      ```typst
      // Get the results and/or errors of all code cells
      #outputs(output-type: ("execute_result", "error"))
      ```
      
   -  `format` is used to select an output format for a given output (Jupyter notebooks can store the same output in several formats to let the viewer choose a format). This should be a format MIME string, or an array of such strings. The array order sets the preference: the first match is used. Every listed format must have a corresponding handler (see `handlers`). The value `auto` refers to the default value: `("image/svg+xml", "image/png", "text/markdown", "text/latex", "text/plain")`. The value `auto` can also be used as one element of an array of values; in this case the default values will be inserted at that position in the array. Example:

      ```typst
      // Get PNG version of all display outputs, error if a display has no PNG
      #outputs(output-type: "display_data", format: "image/png")
      // Get PNG version where available, use default precedence otherwise
      #outputs(output-type: "display_data", format: ("image/png", auto))
      ```

   -  `handlers` is a dictionary mapping MIME strings to handler functions. Each handler function should accept a data string and return the value that should be included in the Typst document. The dict passed to `handlers` is added to the dict of default handlers, overriding default values for the same keys. Example:

      ```typst
      // Show all text outputs in uppercase
      #outputs(handlers: ("text/plain": upper))
      ```

   -  `ignore-wrong-format`: by default an error is raised if a selected output has no format matching the list of desired formats (see `format`). Set to `true` to skip the output silently. Example:

      ```typst
      // Get PNG version of all display outputs, ignoring displays without PNG
      #outputs(format: "image/png", ignore-wrong-format: true)
      ```

   -  `stream`: for stream outputs, this selects the type of streams that should be returned. Can be `"stdout"`, `"stderr"` or `"all"`. Example:

      ```typst
      // Get all errors, and all messages written to stderr
      #outputs(output-type: ("error", "stream"), stream: "stderr")
      ```

   -  `result`: how the function should return its result: `"value"` to return a list of values that can be inserted, or `"dict"` to return a dictionary that contains a `"value"` field as well as metadata. Example:

      ```typst
      // Get the traceback of every error
      #outputs(output-type: "error", result: "dict").map(x => x.traceback)
      ```

- `render(..cell-args, ..input-args, ..output-args, input: true, output: true, template: "notebook")`

   Renders selected cells in the Typst document.

   -  `cell-args` can be passed to select cells as described for the `cells` function. Example:

      ```typst
      // Render the first 10 cells
      #render(range(10))
      ```

   -  `input-args` can be passed to affect the rendering of cell inputs, as described in the `sources` function. Example:

      ```typst
      // Render all cells, using `typ` as language for raw cells
      #render(raw-lang: "typ")
      ```

   -  `output-args` can be passed to select outputs as described for the `outputs` function. Example:

      ```typst
      // Render all cells, preferring SVG over other output formats
      #render(format: ("image/svg+xml", auto))
      ```

   -  `input` specifies if cell inputs should be rendered. Example:

      ```typst
      // Render only the cell outputs
      #render(input: false)
      ```

   -  `output` specifies if cell outputs should be rendered. Example:

      ```typst
      // Render only the cell inputs
      #render(output: false)
      ```

   -  `template` specifies the [template](#templates) to use for rendering. Example:

      ```typst
      // Decorate cell source, show cell output in notebook style
      // (and ignore raw cells and markdown cells)
      #let input-template(cell, input-args: none, ..args) = block(
        inset: (left: 1.2em, y: 1em),
        stroke: (left: 3pt+luma(96%)),
        callisto.source(cell, ..input-args),
      ),
      #render(template: (input: input-template, output: "notebook"))
      ```

## Alias functions

The main functions have many aliases defined for convenience. Each alias corresponds to a call to a main function with some keyword arguments preconfigured.

### Aliases for output type

-  The `outputs` function has aliases `displays`, `results`, `stream-items` and `errors` to select only a particular output type. Example:

   ```typst
   // Get the results of the first 10 cells
   #results(range(10))
   // Get all stream items from cell "A" and merge them in one text value
   #stream-items("A").join()
   ```

-  The `outputs` function has a `streams` alias similar to `stream-items`, but `streams` merges all selected streams that belong to the same cell, and always returns an item (possibly with an empty string as value) for each selected code cell. Example:

   ```typst
   // Get the stdout messages as one text value for each of cells 1, 3 and 5:
   #streams((1, 3, 5), stream: "stdout")
   ```

### Aliases for single values

The functions `sources` and `outputs` are in plural form: they always return an array of items. For convenience there is a singular alias defined for each plural form:

-  `cell` is the same as `cells` with `keep: "unique"` preconfigured. Example:

   ```typst
   // The first cell
   #cell(0)
   ```

-  `source`, `output`, `display`, `result`, `stream-item`, `error` and `stream` are the same as the plural form, except that they take an additional `item` keyword argument preconfigured to the value `"unique"` (technically, these functions are wrappers rather than aliases of the plural form). Example:

   ```typst
   // The unique display item in the first cell's output
   #display(0)
   ```

The singular form is useful in two ways:

1. We're often interested in a single value (e.g. the result of one cell), but `results("plot1")` will return an array even if it contains only one element. It's nicer to write `result("plot1")` than `results("plot1").first()`. 

2. A call such as `result("plot1")` will check for us that there is only one item of "result" type that matches the "plot1" cell specification. If more than one is found, by default an error is raised.

The check for uniqueness can be disabled using the `keep` argument for `cells` and the `item` argument for other functions. Use for example `cell(..., keep: 0)` to get the first matching cell, and `display(..., item: -1)` to get the last display of the matching cell(s).

Note that `keep` is used to filter the cells matching the cell specification while `item` is used to pick one item extracted from the cell(s) . Both can be used together. Example:

```typst
// Second display of the first cell matching "plot1"
#display("plot1", keep: 0, item: 1)
```

### Aliases for rendering

The `render` function always returns a `content` value, but it also has an alias to check that only one cell matches the specification:

-  `Cell` is the same as `render` but preconfigured with `keep: "unique"`. Example:

   ```typst
   // Render the unique cell matching "plot1"
   #Cell("plot1")
   ```

The `Cell` function itself has aliases to render only the cell input or output:

-  `In` renders the input of one cell,

-  `Out` renders the output of one cell.

Example:

```typst
The following code:
#In(0)
produces the following figure:
#Out(0)
```

## Templates

A template function must accept the following positional argument:

-  a literal cell (a dictionary as returned by a `cells` call),

and the following keyword arguments:

-  a `handlers` dictionary with MIME types as keys and decoding functions as values,

- an `input` boolean, set to `true` if the template should render the cell input,

- an `output` boolean, set to `true` if the template must render the cell output,

- an `input-args` dictionary with configuration the template should forward if calling input functions such as `source`,

- and `output-args` dictionary with configuration the template should forward if calling output functions such as `outputs`,

- any additional keyword argument (for compatibility with future versions).

The rendering template can be changed by setting the `template` parameter in `config` (or directly in the `render` function and its aliases `Cell`, `In` and `Out`). Possible values are

- a template function as described above,

- a built-in template name, currently `"notebook"` or `"plain"`,

- a dict with keys among `raw`, `markdown`, `code`, `input` and `output`,

- the value `none`.

The dict form can be used to compose a template from several subtemplates. When rendering a cell, `render` will call the subtemplate corresponding to the cell type. For code cells, the `code` subtemplate will be called if defined. Otherwise the `input` and output subtemplates will be called if the corresponding subtemplate is defined, and if the corresponding `input`/`output` argument to `render` is `true`.

Note that all subtemplates are called with the same arguments. In particular the `input` and `output` templates also receive the `input` and `output` keyword arguments and can use this information for example to produce smaller spacing between input and output when both components are rendered (but the `input` template for example should *not* show the cell output when called with `output=true`).

Each subtemplate can be specified using any of the forms above (function, built-in template name, dict or `none`). When a subtemplate is missing or defined to `none`, the corresponding content will not be rendered.

Example:

```typst
// Decorate cell source, show cell output in notebook style
// (and ignore raw cells and markdown cells)
#let input-template(cell, input-args: none, ..args) = block(
  inset: (left: 1.2em, y: 1em),
  stroke: (left: 3pt+luma(96%)),
  callisto.source(cell, ..input-args),
),
#render(template: (input: input-template, output: "notebook"))
```

## Cell data and cell header

The lower-level `cells` function (and its `cell` alias) can be used to retrieve literal cell dicts reflecting the notebook JSON structure, with minimal processing applied:

-  A cell ID is generated if missing (this field is mandatory since nbformat 4.5).

-  An `index` field is added with the cell index in the notebook, starting at 0.

-  The cell source is normalized to be a simple string (nbformat also allows an array of strings).

-  For code cells, a **metadata header** is processed and removed if present: if the first source lines are of the form `#| key: value`, they are treated as metadata. The key-values pairs are added to the `cell.metadata` dictionary, and the header lines are removed from the cell source. For example, a code cell `c` containing the following source:

   ```
   #| label: plot1
   #| type: scatter
   scatter(x)
   ```

   will have the first two lines replaced by two entries in the cell dict: `c.metadata.label = "plot1"` and `c.metadata.type = "scatter"`.

Cell dicts can be used in two ways:

-  The `render` function renders cells by calling template functions with a cell dict as parameter.

-  A cell dict or an array of cell dicts can be used as cell specification when calling functions such as `sources` or `result`. 
