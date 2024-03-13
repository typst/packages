# [Chromo](https://github.com/julien-cpsn/typst-chromo)

Generate printer tests directly in Typst.
For now, only generates with CMYK colors (as it is by far the most used).

I personally place one of these test on all my exam papers to ensure the printer's quality over time.

## Documentation

To import any of the functions needed, you may want to use the following line:

```typst
#import "@preview/chromo:0.1.0": square-printer-test, gradient-printer-test, circular-printer-test, crosshair-printer-test
```

### Square test

```typst
#square-printer-test()
```

### Gradient test

```typst
#gradient-printer-test()
```

### Circular test

```typst
#circular-printer-test()
```

### Crosshair test

```typst
#crosshair-printer-test()
```

## Contributors

- [Julien-cpsn](https://github.com/julien-cpsn)