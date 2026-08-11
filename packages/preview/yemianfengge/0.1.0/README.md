## Introduction

This package affords the ability to set and get page styles on the fly in the document stream.



## Commands

### pagestyle
Set global pagestyle.

Example:

```typ
#pagestyle("plain")
```

### thispagestyle
Set pagestyle of this page only.

Example:

```typ
#thispagestyle("empty")
```

### getpagestyle
Get the pagestyle of the current page.

Example:

```typ
#getpagestyle(sty => {
    if sty == "plain" { [...] }
})
```





## Integration

Plain foreground:

```typ
#set page(foreground: {
    getpagestyle(sty => context {
        if sty == "plain" {
            place(top + center, dy: -10mm, inset: 20mm, [...])
        }
        place(bottom + center, dy: 10mm, inset: 20mm, [...])
    })
})
```

Use with `ose-pic`:

```typ
#AddToShipoutFG({
    getpagestyle(sty => context {
        if sty == "plain" {
            place(top + center, dy: -10mm, inset: 20mm, [...])
        }
        place(bottom + center, dy: 10mm, inset: 20mm, [...])
    })
})
```

