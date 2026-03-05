# typsqlite

Query [SQLite](https://sqlite.org) databases at compile time in [Typst](https://typst.app).

Built with Zig, compiled to WASM. Full SQL support including JOINs, CTEs, window functions, subqueries, and aggregations.

## Quick Start

```typst
#import "@preview/typsqlite:0.1.0": sqlite, sqlite-table

#let db = sqlite("data.sqlite")

// Query and render as a table
#sqlite-table((db.query)("SELECT name, population FROM cities ORDER BY population DESC"))

// Use raw results
#let result = (db.query)("SELECT count(*) as n FROM cities")
Total cities: #result.rows.at(0).at(0)
```

## API

### `sqlite(path)`

Open a database file. Returns an object with:

| Method | Returns | Description |
|--------|---------|-------------|
| `query(sql)` | `{columns: [...], rows: [[...], ...]}` | Execute SQL query |
| `tables()` | `("table1", "table2", ...)` | List table names |
| `schema(table)` | `{columns: [{name, type}, ...]}` | Get column info |

### `sqlite-table(result, ..args)`

Render query results as a Typst table. Extra arguments pass through to `table()`.

```typst
#sqlite-table(
  (db.query)("SELECT * FROM cities"),
  fill: (x, y) => if y == 0 { gray.lighten(70%) },
)
```

### `query-table(db, sql)`

Query and return flat cell array for use with `table()` directly:

```typst
#table(columns: 3, ..query-table(db, "SELECT name, country, pop FROM cities"))
```

## How It Works

SQLite is compiled into a ~640KB WASM module. Typst reads database files as bytes, passes them to the plugin which opens them as an in-memory SQLite database (custom read-only VFS), executes queries, and returns JSON results.

## Source

[github.com/jrossi/typst-wasm-sqlite](https://github.com/jrossi/typst-wasm-sqlite)
