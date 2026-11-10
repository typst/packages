#import "@preview/typsy:0.2.5": (
    Any, Arguments, Array, Dictionary, Function, None, Optional, Pattern, Pos, Ratio, Str, case, class, fmt, match,
    matches, panic-fmt, pattern-repr, typecheck,
)

#let _binop(self, other, op: none) = {
    let data = match(
        other,
        // adding two columns
        case(self.meta.cls, () => self.data.zip(other.data, exact: true).map(op)),
        // adding column and scalar
        case(Any, () => self.data.map(x => op((x, other)))),
    )
    (self.meta.cls.new)(data: data)
}

/// Represents a column of data, all of the same type.
/// This is essentially just a wrapper around an array, with some convenient methods and constructors.
///
/// The 'same type' requirement is interpreted in a broad sense: during construction all elements are type-checked to
/// match a single pattern, but this pattern may be `Any`.
///
/// *Example:*
///
/// ```typst
/// import "@preview/tableframe:<some-version>": Column
/// import "@preview/typsy:<some-version>": Int
///
/// let col = (Column.from-data)(1, 5, 2, type: Int)
/// let maxval = (col.max)()
/// assert.eq(maxval, 5)
/// ```
///
/// *Fields:*
///
/// - `data`: the wrapped array.
///
/// *Methods:*
///
/// - `.size() -> int`: gets the length of the column. _Warning_: do not call `.len()`, as Typsy classes are modelled as
///   dictionaries then this will give the length of the dictionary, which is an implementation detail.
/// - `.get(index: int) -> any`: gets the `index`-th value of the column. _Warning_: do not call `.at(index)`, which
///   will instead call the method of that name on the underlying Typsy dictionary.
/// - `.first() -> any`: gets the first element of the data.
/// - `.last() -> any`: gets the last element of the data.
/// - `.only() -> any`: gets the only element of the data. Panics if there is not a single element.
/// - `.slice(..args) -> Column`: slices the data, equivalent to `array.slice(..args)`.
/// - `.map-with(fn, ..cols: Column) -> Column`: calls `fn` on all every member of the `Column` (and if they are
///   provided, any other columns, which must all be of the same size as this one) and then returns a new `Column` with
///   the result. For example the first element of the returned `Column` will be
///  `fn(self.get(0), cols.at(0).get(0) ... cols.at(n).get(0))`.
/// - `.take(indices: array) -> Column`: returns a column containing the values at the supplied indices, in that order.
/// - `.filter-values(fn: function) -> Column`: filters to just the values for which `fn` returns `true`.
/// - `.filter-indices(fn: function) -> Column`: filters to just the indices for which `fn` returns `true`. (And returns
///   them as a new `Column` of integers.)
/// - `.sorted(key: function = none, by: function = none) -> Column`: returns a stably sorted column. `key` and `by`
///   have the same semantics as the corresponding arguments to `array.sorted`.
/// - `.add(other: Column) -> Column`: given another `Column`, adds together the corresponding elements of both `self`
///   and `other`.
/// - `.mul(other: Column) -> Column`: given another `Column`, multiplies together the corresponding element of both
///   `self` and `other`.
/// - `.sub(other: Column) -> Column`: given another `Column`, subtracts the corresponding elements of `self` and
///   `other`.
/// - `.div(other: Column) -> Column`: given another `Column`, divides the corresponding elements of `self` and `other`.
/// - `.dot(other: Column) -> any`: returns the dot product of two `Columns`, i.e. elementwise multiplication followed
///   by summing all values.
/// - `.any() -> bool`: assuming a `Column` of boolean values, returns if any of the values in the `Column` are `true`.
/// - `.all() -> bool`: assuming a `Column` of boolean values, returns if all of the values in the `Column` are `true`.
/// - `.min() -> any`: returns the smallest value in the `Column`.
/// - `.max() -> any`: returns the largest value in the `Column`.
/// - `.sum() -> any`: returns the sum of all values in the `Column`.
/// - `.product() -> any`: returns the product of all values in the `Column`.
/// - `.cumsum(initial: any = none, final: bool = true) -> Column`: returns the cumulative sum of all values in the
///   `Column`. If `initial` is non-`none` then it is prepended. If `final: false` then the final value will be emitted
///   from the cumulative sum. Thus `.cumsum()` will give the right-cumsum, whilst `.cumsum(initial: 0, final: false)`
///   will give the left-cumsum.
/// - `.cumproduct(initial: any = none, final: bool = true)`: as `.cumsum`, except that a product is performed instead
///   of a sum. Use `.cumproduct(initial: 1, final: true)` to perform a left-cumproduct.
///
/// *Class methods:*
///
/// - `.range(..args)`: constructs a `Column` by wrapping an `array.range(..args)`.
/// - `.constant(const: any, size: any = none)`: constructs a `Column` of length `size`, for which all elements are
///   `const`.
/// - `.from-data(..data, pattern: Pattern = Any, coerce: Function = x=>x)`: constructs a `Column` from the provided
///   positional `data`. All elements are checked to match `pattern`. `coerce` is called on each element prior to
///   typechecking and construction.
#let Column = class(
    name: "Column",
    fields: (
        data: Array(..Any),
    ),
    methods: (
        size: self => self.data.len(),
        get: (self, index) => self.data.at(index),
        first: self => self.data.first(),
        last: self => self.data.last(),
        only: self => {
            if self.data.len() != 1 {
                panic("Column does not have length 1")
            }
            self.data.at(0)
        },
        slice: (self, start, end) => {
            (self.meta.cls.new)(data: self.data.slice(start, end))
        },
        map-with: (self, fn, ..cols) => {
            if cols.named().len() != 0 {
                panic("`map-with` accepts only positional arguments")
            }
            let cols = cols.pos()
            (self.meta.cls.new)(
                data: self.data.zip(..cols.map(x => x.data)).map(x => fn(..x)),
            )
        },
        take: (self, indices) => (self.meta.cls.new)(data: indices.map(index => self.data.at(index))),
        filter-values: (self, fn) => (self.meta.cls.new)(data: self.data.filter(fn)),
        filter-indices: (self, fn) => (self.meta.cls.new)(
            data: self.data.enumerate().filter(((_, value)) => fn(value)).map(((index, _)) => index),
        ),
        sorted: (self, key: none, by: none) => {
            let args = (:)
            if key != none { args.insert("key", key) }
            if by != none { args.insert("by", by) }
            (self.meta.cls.new)(data: self.data.sorted(..args))
        },
        add: _binop.with(op: ((x1, x2)) => x1 + x2),
        mul: _binop.with(op: ((x1, x2)) => x1 * x2),
        sub: _binop.with(op: ((x1, x2)) => x1 - x2),
        div: _binop.with(op: ((x1, x2)) => x1 / x2),
        dot: (self, other) => {
            ((self.mul)(other).sum)()
        },
        any: self => self.data.any(x => x),
        all: self => self.data.all(x => x),
        min: self => calc.min(..self.data),
        max: self => calc.max(..self.data),
        sum: self => self.data.sum(),
        product: self => self.data.product(),
        cumsum: (self, initial: none, final: true) => {
            let out = ()
            let total = if initial == none {
                0
            } else {
                out.push(initial)
                initial
            }
            let data = if final {
                self.data
            } else {
                self.data.slice(0, -1)
            }
            for x in data {
                total += x
                out.push(total)
            }
            (self.meta.cls.new)(data: out)
        },
        cumproduct: (self, initial: none, final: true) => {
            let out = ()
            let total = if initial == none {
                1
            } else {
                out.push(initial)
                initial
            }
            let data = if final {
                self.data
            } else {
                self.data.slice(0, -1)
            }
            for x in data {
                total *= x
                out.push(total)
            }
            (self.meta.cls.new)(data: out)
        },
    ),
    classmethods: (
        range: (cls, ..args) => {
            (cls.new)(data: array.range(..args))
        },
        constant: (cls, const, size: none) => {
            (cls.new)(data: (const,) * size)
        },
        from-data: typecheck(
            Arguments(
                Any,
                ..Pos(Any),
                type: Optional(Pattern),
                coerce: Optional(Function),
            ),
            Any,
            (cls, ..data, type: Any, coerce: x => x) => {
                let data = data.pos().map(typecheck(Arguments(Any), type, coerce))
                (cls.new)(data: data)
            },
        ),
    ),
    tag: () => {},
)

/// Represents a table of values, arranged by column.
///
/// *Example:*
///
/// ```typst
/// let table = (Table.from-header)(
///     ("Geography", "Proportion", "Cost"),
///     ("EU", 35%, 70%),
///     ("US", 30%, 100%),
///     ("Japan", 12%, 50%),
/// )
/// // Just needs a unique prefix
/// let geography-column = (table.col)("Geog")
/// // Displays as a Typst table. Need to specify how non-string/content items become string/content.
/// (table.display)(to-content: ("Geog": repr, "Cost": repr))
/// ```
///
/// *Methods:*
///
/// - `.resolve-header(name) -> str`: given a name, return the name of the unique column which is prefixed by this.
///   Panics if there is not a unique such column.
/// - `.size() -> int`: all contained columns are required to be of the same length. Returns that length. _Warning_:
///   do not call `.len()`, as Typsy classes are modelled as dictionaries then this will give the length of the
///   dictionary, which is an implementation detail.
/// - `.col(name: str) -> Column`: gets the column with this name.
/// - `.row(index: int) -> dictionary` or `.row(name: any = value) -> dictionary`: gets the `index`th row of the table,
///   or the row for which the column of name `name` has value `value`, panicking if this is not unique.
/// - `.col-add(name: str, col: Column) -> Table`: adds a new, equally sized column. Panics if its name already exists.
/// - `.col-drop(name: str) -> Table`: drops the named column. Panics if this would leave the table with no columns.
/// - `.col-rename(name: str, new-name: str) -> Table`: renames a column, preserving its position.
/// - `.col-replace(name: str, col: Column) -> Table`: replaces the column of name `name` with the provided column, and
///   returns that as a new table.
/// - `.col-map-with(name: str, fn: Function) -> Table`: replaces the column of name `name` with the result of calling
///   `fn` on all of its elements, and returns that as a new table.
/// - `.take(indices: array) -> Table`: returns rows at the supplied indices, in that order.
/// - `.slice(start: int, end: int) -> Table`: returns the specified slice of rows.
/// - `.head(count: int) -> Table`: returns up to the first `count` rows.
/// - `.tail(count: int) -> Table`: returns up to the last `count` rows.
/// - `.filter-values(fn: function) -> Table`: keeps rows for which `fn(row)` returns `true`; rows are dictionaries.
/// - `.sorted(column: str = none, key: function = none, by: function = none) -> Table`: returns a stably sorted table.
///   With `column`, values from that column are sorted; otherwise whole row dictionaries are sorted. `key` and `by`
///   have the same semantics as for `array.sorted`, and may be combined. A `key` returning an array supports
///   lexicographic, multi-column sorting.
/// - `.concat(..tables: Table) -> Table`: concatenates tables row-wise. All tables must have identical columns.
/// - `.display(..args, layout: int = 1, to-content-header: Function = strong, to-content: dictionary = (:)) -> table`:
///   displays the table as a Typst `table` (i.e. `grid`) object, suitable for displaying in the document. `args` is
///   forwarded to the `table` function. `layout` determines the number of visual columns: set to >=2 to wrap e.g.
///   (with `layout: 1`)
///   ```
///   a
///   b
///   c
///   d
///   e
///   ```
///
///   into (with `layout: 2`)
///   ```
///   a d
///   b e
///   c
///   ```
///   Meanwhile `to-content-header` is called on each column name to create the header of the table. Finally, column
///   contents must be converted to type string/content before they can be displayed. `to-content` should be a
///   dictionary mapping column names to a function, which will be called on all members of that column to do this
///   conversion. For example `to-content: ("my-integer-column": str)`.
/// - `.to-plot(x: str = none, y: str = none) -> array`: for use with Cetz plotting. Given
///   `let plotdata = (table.to-plot)(x: "column to use for x axis", y: "column to use for y axis")`, you can then call
///   e.g. `cetz-plot.plot.plot(plotdata)` or `cetz-plot.plot.add-bar(plotdata)`.
///
/// *Class methods:*
///
/// Each of these is used to construct a `Table`.
///
/// - `.from-columns(..columns: Column) -> Table`: pass named arguments to create a table with those names. Use
///    dictionary unpacking for non-identifier strings. _Examples:_
///   `(Table.from-columns)(foo: (Column.from-data)(), bar: (Column.from-data)())`,
///   `(Table.from-columns)(..("some string": (Column.from-data)()))`,
/// - `.from-rows(..rows: dictionary) -> Table`: pass positional arguments, which are dictionaries all with the same
///    keys, to construct the table.
/// - `.from-header(header: array, ..rows: array)`: pass a header as an array-of-strings, and then positional arguments
///   each of which are arrays-of-values. All arrays must be the same length.
/// - `.from-records(..records: <any Class>)`: pass positional arguments, all of which should be an instance of the same
///   Typsy class. The fields of this class are extracted and treated as the keys used in `.from-rows`.
#let Table = class(
    name: "Table",
    fields: (
        _columns: Dictionary(..Column),
    ),
    methods: (
        resolve-header: (self, name) => {
            let matching-headers = self._columns.keys().filter(x => x.starts-with(name))
            let num = matching-headers.len()
            if num != 1 {
                panic-fmt("`{}` is not a prefix of a unique header name, as it matches {} headers", name, str(num))
            }
            matching-headers.at(0)
        },
        size: self => (self._columns.values().at(0).size)(),
        col: (self, name) => {
            let name = (self.resolve-header)(name)
            self._columns.at(name)
        },
        row: (self, ..args) => {
            let index = if args.named().len() == 0 and args.pos().len() == 1 {
                args.pos().at(0)
            } else if args.pos().len() == 0 and args.named().len() == 1 {
                let (name, value) = args.named().pairs().at(0)
                let name = (self.resolve-header)(name)
                (((self._columns.at(name).filter-indices)(colval => colval == value)).only)()
            } else {
                assert(
                    "`Table.row` must be called with precisely one positional argument or precisely one named argument.",
                )
            }
            let out = (:)
            for (name, column) in self._columns.pairs() {
                out.insert(name, (column.get)(index))
            }
            out
        },
        col-replace: (self, name, col) => {
            let name = (self.resolve-header)(name)
            if not matches(Column, col) {
                panic-fmt("`col` is not a `Column`, got `{}`.", repr(col))
            }
            let columns = self._columns
            columns.insert(name, col)
            (self.meta.cls.new)(_columns: columns)
        },
        col-map-with: (self, name, fn) => {
            let name = (self.resolve-header)(name)
            let new-col = ((self.col)(name).map-with)(fn)
            (self.col-replace)(name, new-col)
        },
        col-add: (self, name, col) => {
            assert(not name in self._columns, message: "Column already exists.")
            assert(matches(Column, col), message: "`col` must be a `Column`.")
            assert.eq((col.size)(), (self.size)(), message: "Columns must have equal lengths.")
            let columns = self._columns
            columns.insert(name, col)
            (self.meta.cls.new)(_columns: columns)
        },
        col-drop: (self, name) => {
            let name = (self.resolve-header)(name)
            assert(self._columns.len() > 1, message: "A table must have at least one column.")
            let columns = self._columns
            columns.remove(name)
            (self.meta.cls.new)(_columns: columns)
        },
        col-rename: (self, name, new-name) => {
            let name = (self.resolve-header)(name)
            assert(not new-name in self._columns, message: "Column already exists.")
            let columns = (:)
            for (key, col) in self._columns {
                columns.insert(if key == name { new-name } else { key }, col)
            }
            (self.meta.cls.new)(_columns: columns)
        },
        take: (self, indices) => {
            let columns = (:)
            for (name, col) in self._columns {
                columns.insert(name, (col.take)(indices))
            }
            (self.meta.cls.new)(_columns: columns)
        },
        slice: (self, start, end) => (self.take)(array.range((self.size)()).slice(start, end)),
        head: (self, count) => (self.slice)(0, calc.min(count, (self.size)())),
        tail: (self, count) => (self.slice)(calc.max(0, (self.size)() - count), (self.size)()),
        filter-values: (self, fn) => {
            let indices = array.range((self.size)()).filter(index => fn((self.row)(index)))
            (self.take)(indices)
        },
        sorted: (self, column: none, key: none, by: none) => {
            let indices = array.range((self.size)())
            let sort-key = if column == none {
                index => {
                    let row = (self.row)(index)
                    if key == none { row } else { key(row) }
                }
            } else {
                let col = (self.col)(column)
                index => {
                    let value = (col.get)(index)
                    if key == none { value } else { key(value) }
                }
            }
            let args = (key: sort-key)
            if by != none { args.insert("by", by) }
            (self.take)(indices.sorted(..args))
        },
        concat: (self, ..tables) => {
            let columns = (:)
            for (name, col) in self._columns {
                let data = col.data
                for other in tables.pos() {
                    assert.eq(other._columns.keys(), self._columns.keys(), message: "Tables must have identical columns.")
                    data += (other.col)(name).data
                }
                columns.insert(name, (Column.from-data)(..data))
            }
            (self.meta.cls.new)(_columns: columns)
        },
        display: (self, ..args, layout: 1, to-content-header: strong, to-content: (:)) => {
            if args.pos().len() != 0 {
                panic("`display` only accepts named arguments")
            }
            assert(layout >= 1, message: "`layout` must be at least 1")
            for (name, fn) in to-content {
                self = (self.col-map-with)(name, fn)
            }
            let column-count = self._columns.len()
            let rows-per-layout = calc.ceil((self.size)() / layout)
            let headers = self._columns.keys().map(to-content-header)
            let cells = ()
            for row in array.range(rows-per-layout) {
                for column in array.range(layout) {
                    if column != 0 {
                        cells.push([])
                    }
                    let index = row + column * rows-per-layout
                    if index < (self.size)() {
                        for value in (self.row)(index).values() {
                            cells.push(value)
                        }
                    } else {
                        for _ in array.range(column-count) {
                            cells.push(none)
                        }
                    }
                }
            }
            let widths = (auto,) * column-count
            for _ in array.range(1, layout) {
                widths.push(1em)
                for _ in array.range(column-count) {
                    widths.push(auto)
                }
            }
            let table-args = args.named()
            let stroke = table-args.at("stroke", default: 1pt + black)
            if "stroke" in table-args {
                table-args.remove("stroke")
            }
            table(
                columns: widths,
                stroke: (x, y) => {
                    if calc.rem(x, column-count + 1) == column-count {
                        none
                    } else {
                        stroke
                    }
                },
                ..table-args,
                table.header(
                    ..array.range(layout).map(x => if x == 0 { headers } else { ([],) + headers }).flatten(),
                ),
                ..cells,
            )
        },
        to-plot: (self, x: none, y: none) => {
            if x == none {
                panic("`(Table.plot)(x: ...) must be provided with a column name.")
            }
            if y == none {
                panic("`(Table.plot)(y: ...) must be provided with a column name.")
            }
            (self.col)(x).data.zip((self.col)(y).data)
        },
    ),
    classmethods: (
        from-columns: (cls, ..columns) => {
            if columns.pos().len() != 0 {
                panic("`Table.from-columns expects not positional arguments.")
            }
            (cls.new)(_columns: columns.named())
        },
        from-rows: (cls, ..rows) => {
            let rows = rows.pos()
            assert.ne(rows.len(), 0, message: "Must have at least one row to determine field names.")
            let fields = rows.at(0).keys()
            let data = (:)
            for field in fields {
                data.insert(field, ())
            }
            for row in rows {
                assert.eq(row.keys(), fields, message: "Rows had different keys.")
                for field in fields {
                    data.at(field).push(row.at(field))
                }
            }
            let columns = (:)
            for (key, val) in data.pairs() {
                columns.insert(key, (Column.from-data)(..val))
            }
            (cls.new)(_columns: columns)
        },
        from-header: (cls, headers, ..rows) => {
            if rows.named().len() != 0 {
                panic("`from_header` expects only positional arguments.")
            }
            let rows = rows.pos()
            let cols = (:)
            for header in headers {
                cols.insert(header, ())
            }
            for row in rows {
                for (header, value) in headers.zip(row, exact: true) {
                    cols.at(header).push(value)
                }
            }
            let columns = (:)
            for (key, val) in cols.pairs() {
                columns.insert(key, (Column.from-data)(..val))
            }
            (cls.from-columns)(..columns)
        },
        from-records: typecheck(Arguments(Any, ..Pos(Any)), Any, (cls, ..records) => {
            let records = records.pos()
            assert.ne(records.len(), 0, message: "Must have at least one record to determine field names.")
            let record_cls = records.at(0).meta.cls
            let fields = record_cls.fields.keys()
            let rows = ()
            for record in records {
                assert(matches(record_cls, record), message: fmt(
                    "Got a record that was not of type `{}`",
                    pattern-repr(record_cls),
                ))
                let row = (:)
                for field in fields {
                    row.insert(field, record.at(field))
                }
                rows.push(row)
            }
            (cls.from-rows)(..rows)
        }),
    ),
    tag: () => {},
)

