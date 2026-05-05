# Zippy

`nimble install zippy`

![Github Actions](https://github.com/guzba/zippy/workflows/Github%20Actions/badge.svg)

[API reference](https://guzba.github.io/zippy/)

Zippy is an implementation of [DEFLATE](https://tools.ietf.org/html/rfc1951), [ZLIB](https://tools.ietf.org/html/rfc1950) and [GZIP](https://tools.ietf.org/html/rfc1952) data compression formats.

Zippy can also open [ZIP archives](https://en.wikipedia.org/wiki/Zip_(file_format)) (.zip) and [Tarballs](https://en.wikipedia.org/wiki/Tar_(computing)) (.tar, .tar.gz, .tgz, .taz).

The goal of this library is to be a pure Nim implementation that is small, performant and dependency-free.

To ensure Zippy is compatible with other implementations, `tests/validate.nim` can be run. This script verifies that data compressed by Zippy can be uncompressed by other implementations (and that other implementations can uncompress data compressed by Zippy).

This library works well using Nim's `--gc:arc` and `--gc:orc` as well as the default garbage collector. This library also works using both `nim c` and `nim cpp`, in addition to `--cc:vcc` on Windows.

## Examples

Simple examples using Zippy can be found in the [examples/](https://github.com/guzba/zippy/blob/master/examples) folder.

* [HTTP client gzip](https://github.com/guzba/zippy/blob/master/examples/http_client.nim)
* [HTTP server gzip](https://github.com/guzba/zippy/blob/master/examples/http_server.nim)
* Extract individual files from [zip archive](https://github.com/guzba/zippy/blob/master/examples/ziparchive_explore.nim).
* Extract everything from a [zip archive](https://github.com/guzba/zippy/blob/master/examples/ziparchive_extract.nim) or [tarball](https://github.com/guzba/zippy/blob/master/examples/tarball_extract.nim)

## Performance

Benchmarks can be run comparing different deflate implementations. My benchmarking shows this library performs very well, around 1.5x - 2x faster than zlib found on a fresh Linux install. Check the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/zippy/blob/master/tests/benchmark.nim).

`nim c --gc:arc -d:release -r .\tests\benchmark.nim`

The times below are measured on a Ryzen 5 5600X.

### Uncompress

```
https://github.com/guzba/zippy uncompress
name ............................... min time      avg time    std dv   runs
alice29.txt.gz ..................... 0.233 ms      0.235 ms    ±0.003  x1000
urls.10K.gz ........................ 1.140 ms      1.148 ms    ±0.007  x1000
rfctest3.gz ........................ 0.047 ms      0.048 ms    ±0.001  x1000
randtest3.gz ....................... 0.001 ms      0.001 ms    ±0.000  x1000
paper-100k.pdf.gz .................. 0.210 ms      0.212 ms    ±0.001  x1000
geo.protodata.gz ................... 0.068 ms      0.071 ms    ±0.002  x1000
tor-list.gz ....................... 27.297 ms     27.520 ms    ±0.277   x182
https://github.com/nim-lang/zip uncompress
alice29.txt.gz ..................... 0.397 ms      0.403 ms    ±0.004  x1000
urls.10K.gz ........................ 1.719 ms      1.731 ms    ±0.009  x1000
rfctest3.gz ........................ 0.054 ms      0.055 ms    ±0.002  x1000
randtest3.gz ....................... 0.008 ms      0.008 ms    ±0.000  x1000
paper-100k.pdf.gz .................. 0.250 ms      0.252 ms    ±0.001  x1000
geo.protodata.gz ................... 0.126 ms      0.132 ms    ±0.005  x1000
tor-list.gz ....................... 36.613 ms     37.061 ms    ±0.423   x135
```

### Compress

```
https://github.com/guzba/zippy compress [best speed]
name ............................... min time      avg time    std dv   runs
alice29.txt ........................ 0.643 ms      0.655 ms    ±0.017  x1000
urls.10K ........................... 1.943 ms      1.959 ms    ±0.022  x1000
rfctest3.gold ...................... 0.119 ms      0.121 ms    ±0.003  x1000
randtest3.gold ..................... 0.005 ms      0.006 ms    ±0.001  x1000
paper-100k.pdf ..................... 0.230 ms      0.235 ms    ±0.003  x1000
geo.protodata ...................... 0.192 ms      0.195 ms    ±0.003  x1000
gzipfiletest.txt ................... 0.002 ms      0.002 ms    ±0.000  x1000
tor-list.gold ..................... 26.106 ms     26.418 ms    ±0.370   x189
https://github.com/nim-lang/zip compress [best speed]
alice29.txt ........................ 1.236 ms      1.245 ms    ±0.010  x1000
urls.10K ........................... 5.155 ms      5.222 ms    ±0.092   x952
rfctest3.gold ...................... 0.205 ms      0.232 ms    ±0.009  x1000
randtest3.gold ..................... 0.076 ms      0.097 ms    ±0.013  x1000
paper-100k.pdf ..................... 1.250 ms      1.276 ms    ±0.023  x1000
geo.protodata ...................... 0.313 ms      0.320 ms    ±0.006  x1000
gzipfiletest.txt ................... 0.006 ms      0.008 ms    ±0.001  x1000
tor-list.gold .................... 178.197 ms    179.970 ms    ±1.559    x28

https://github.com/guzba/zippy compress [default]
name ............................... min time      avg time    std dv   runs
alice29.txt ........................ 2.361 ms      2.379 ms    ±0.024  x1000
urls.10K .......................... 13.364 ms     13.432 ms    ±0.036   x372
rfctest3.gold ...................... 0.335 ms      0.342 ms    ±0.009  x1000
randtest3.gold ..................... 0.048 ms      0.049 ms    ±0.000  x1000
paper-100k.pdf ..................... 0.831 ms      0.843 ms    ±0.010  x1000
geo.protodata ...................... 0.563 ms      0.570 ms    ±0.007  x1000
gzipfiletest.txt ................... 0.008 ms      0.008 ms    ±0.001  x1000
tor-list.gold .................... 409.542 ms    411.858 ms    ±1.779    x13
https://github.com/nim-lang/zip compress [default]
alice29.txt ........................ 5.726 ms      5.766 ms    ±0.053   x862
urls.10K .......................... 13.049 ms     13.106 ms    ±0.057   x381
rfctest3.gold ...................... 0.637 ms      0.644 ms    ±0.007  x1000
randtest3.gold ..................... 0.083 ms      0.087 ms    ±0.007  x1000
paper-100k.pdf ..................... 1.467 ms      1.490 ms    ±0.023  x1000
geo.protodata ...................... 0.867 ms      0.879 ms    ±0.011  x1000
gzipfiletest.txt ................... 0.009 ms      0.010 ms    ±0.001  x1000
tor-list.gold .................... 244.424 ms    246.601 ms    ±1.630    x21
```

## Testing

`nimble test`

To prevent Zippy from causing a crash or otherwise misbehaving on bad input data, a fuzzer has been run against it. You can run the fuzzer any time by running `nim c -r tests/fuzz.nim` and `nim c -r tests/stress.nim`
