#import "@preview/typsy:0.2.5": Int, Ratio, Str, class
#import "./core.typ": Column, Table

#let assert-column(column, expected) = assert.eq(column.data, expected)

#let test-column-construction-and-access() = {
    let column = (Column.from-data)(1, 2, 3)
    assert.eq((column.size)(), 3)
    assert.eq((column.get)(1), 2)
    assert.eq((column.first)(), 1)
    assert.eq((column.last)(), 3)
    assert.eq(((Column.from-data)(7).only)(), 7)
    assert-column((column.slice)(1, 3), (2, 3))
    assert-column((Column.range)(1, 6, step: 2), (1, 3, 5))
    assert-column((Column.constant)("x", size: 3), ("x", "x", "x"))
}

#let test-column-transformations() = {
    let left = (Column.from-data)(1, 2, 3)
    let right = (Column.from-data)(4, 5, 6)
    assert-column((left.map-with)((x, y) => x + y, right), (5, 7, 9))
    assert-column((left.filter-values)(x => x != 2), (1, 3))
    assert-column((right.filter-indices)(x => x >= 5), (1, 2))
}

#let test-column-arithmetic-and-reductions() = {
    let left = (Column.from-data)(2, 4, 8)
    let right = (Column.from-data)(1, 2, 4)
    assert-column((left.add)(right), (3, 6, 12))
    assert-column((left.add)(1), (3, 5, 9))
    assert-column((left.sub)(right), (1, 2, 4))
    assert-column((left.mul)(right), (2, 8, 32))
    assert-column((left.div)(right), (2, 2, 2))
    assert.eq((left.dot)(right), 42)
    assert.eq(((Column.from-data)(false, true).any)(), true)
    assert.eq(((Column.from-data)(true, true).all)(), true)
    assert.eq((left.min)(), 2)
    assert.eq((left.max)(), 8)
    assert.eq((left.sum)(), 14)
    assert.eq((left.product)(), 64)
}

#let test-column-cumulative-operations() = {
    let column = (Column.from-data)(1, 2, 3)
    assert-column((column.cumsum)(), (1, 3, 6))
    assert-column((column.cumsum)(initial: 10), (10, 11, 13, 16))
    assert-column((column.cumsum)(initial: 0, final: false), (0, 1, 3))
    assert-column((column.cumproduct)(), (1, 2, 6))
    assert-column((column.cumproduct)(initial: 2), (2, 2, 4, 12))
    assert-column((column.cumproduct)(initial: 1, final: false), (1, 1, 2))
}

#let expected-rows = (
    (name: "Ada", score: 10),
    (name: "Grace", score: 20),
)

#let assert-table(table) = {
    assert.eq((table.size)(), 2)
    assert.eq((table.row)(0), expected-rows.at(0))
}

#let test-table-constructors() = {
    assert-table((Table.from-columns)(
        name: (Column.from-data)("Ada", "Grace"),
        score: (Column.from-data)(10, 20),
    ))
    assert-table((Table.from-rows)(
        (name: "Ada", score: 10),
        (name: "Grace", score: 20),
    ))
    assert-table((Table.from-header)(
        ("name", "score"),
        ("Ada", 10),
        ("Grace", 20),
    ))
    let Record = class(name: "Record", fields: (person: Str, score: Int))
    let records = (Table.from-records)(
        (Record.new)(person: "Ada", score: 10),
        (Record.new)(person: "Grace", score: 20),
    )
    assert.eq((records.size)(), 2)
    assert.eq((records.row)(1), (person: "Grace", score: 20))
}

#let test-table-operations() = {
    let table = (Table.from-header)(
        ("name", "score"),
        ("Ada", 10),
        ("Grace", 20),
    )
    assert.eq((table.row)(name: "Grace"), expected-rows.at(1))
    assert.eq((table.resolve-header)("nam"), "name")
    assert-column((table.col)("sc"), (10, 20))
    assert-column(((table.col-replace)("score", (Column.from-data)(1, 2)).col)("score"), (1, 2))
    assert-column(((table.col-map-with)("score", x => x * 2).col)("score"), (20, 40))
    assert.eq((table.to-plot)(x: "score", y: "score"), ((10, 10), (20, 20)))
}

#let test-selection-sorting-and-columns() = {
  let column = (Column.from-data)(3, 1, 2)
  assert-column((column.take)((2, 0)), (2, 3))
  assert-column((column.sorted)(), (1, 2, 3))
  assert-column((column.sorted)(by: (a, b) => a >= b), (3, 2, 1))

  let table = (Table.from-header)(
    ("name", "score"),
    ("Ada", 30),
    ("Grace", 10),
    ("Edsger", 20),
  )
  assert.eq(((table.take)((2, 0)).col)("name").data, ("Edsger", "Ada"))
  assert.eq(((table.filter-values)(row => row.score >= 20).col)("name").data, ("Ada", "Edsger"))
  assert.eq(((table.sorted)(column: "score").col)("name").data, ("Grace", "Edsger", "Ada"))
  assert.eq(((table.sorted)(key: row => (row.score, row.name)).col)("name").data, ("Grace", "Edsger", "Ada"))
  assert.eq(((table.slice)(1, 3).col)("name").data, ("Grace", "Edsger"))
  assert.eq(((table.head)(1).col)("name").data, ("Ada",))
  assert.eq(((table.tail)(1).col)("name").data, ("Edsger",))

  let added = (table.col-add)("rank", (Column.from-data)(1, 2, 3))
  assert-column((added.col)("rank"), (1, 2, 3))
  let renamed = (added.col-rename)("rank", "position")
  assert-column((renamed.col)("position"), (1, 2, 3))
  assert.eq((renamed.col-drop)("position")._columns.keys(), ("name", "score"))

  let combined = (table.concat)((table.head)(1))
  assert.eq((combined.size)(), 4)
  assert.eq((combined.row)(3), (name: "Ada", score: 30))
}

#let test-display-layout() = {
    let table = (Table.from-columns)(
        value: (Column.from-data)("a", "b", "c", "d", "e", "f", "g"),
    )
    (table.display)(layout: 2)
}

#let test-constructors() = {
    let Record = class(
        name: "OriginalRecord",
        fields: (geography: Str, proportion: Ratio, cost: Ratio),
    )
    let records = (Table.from-records)(
        (Record.new)(geography: "EU", proportion: 35%, cost: 70%),
        (Record.new)(geography: "US", proportion: 30%, cost: 100%),
        (Record.new)(geography: "Japan", proportion: 12%, cost: 50%),
    )
    let rows = (Table.from-rows)(
        (geography: "EU", proportion: 35%, cost: 70%),
        (geography: "US", proportion: 30%, cost: 100%),
        (geography: "Japan", proportion: 12%, cost: 50%),
    )
    let columns = (Table.from-columns)(
        geography: (Column.from-data)("EU", "US", "Japan"),
        proportion: (Column.from-data)(35%, 30%, 12%),
        cost: (Column.from-data)(70%, 100%, 50%),
    )
    let header = (Table.from-header)(
        ("geography", "proportion", "cost"),
        ("EU", 35%, 70%),
        ("US", 30%, 100%),
        ("Japan", 12%, 50%),
    )
    for table in (records, rows, columns, header) {
        assert.eq((table.size)(), 3)
        assert.eq((table.row)(1), (geography: "US", proportion: 30%, cost: 100%))
    }
}

#let panic-on-column-only-with-multiple-values() = {
    ((Column.from-data)(1, 2).only)()
}

#let panic-on-ambiguous-header() = {
    let table = (Table.from-columns)(
        score: (Column.from-data)(1),
        score-adjusted: (Column.from-data)(2),
    )
    (table.resolve-header)("score")
}

#let panic-on-missing-row-value() = {
    let table = (Table.from-columns)(name: (Column.from-data)("Ada"))
    (table.row)(name: "Grace")
}
