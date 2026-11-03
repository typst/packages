## Introduction

If you are frustrated by the [new page run](https://github.com/typst/typst/issues/8631) behavior, you may try this package to freeze a setsuna, i.e. style state snapshot at a specific moment, to fight against `set` and `show` added after the moment.



## Usage

```typ
#setsuna.capture(apply => {
    apply({})
})
```



## Use with ose-pic

```typ
// Captured, Header
#setsuna.capture(apply => {
  AddToShipoutBGAll({
    place(top + left, dy: -18mm, box(width: 100%, inset: 35mm, apply[
      #grid(
        columns: (1fr, auto),
        align: (left, right),
        gutter: 12pt,
        [setsuna captured header], [#context here().page()],
      )
    ]))
  })
})
// --- OR ---
// Not captured, Footer
#AddToShipoutBGAll({
  place(bottom + left, dy: 18mm, box(width: 100%, inset: 35mm, [
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      gutter: 12pt,
      [raw footer], [#context here().page()],
    )
  ]))
})
```

Using with bare `set page(background: {...})` or `set page(foreground: {...})` should be similar.
