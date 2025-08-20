# Neoplot

A Typst package to use [gnuplot](http://www.gnuplot.info/) in Typst.

```typ
#import "@preview/neoplot:0.0.2" as gp
```

Execute gnuplot commands:
````typ
#gp.exec(
    kind: "command",
    ```gnuplot
    reset;
    set samples 1000;
    plot sin(x),
         cos(x)
    ```
)
````

Execute a gnuplot script:
````typ
#gp.exec(
    ```gnuplot
    reset
    # Can add comments since it is a script
    set samples 1000
    # Use a backslash to extend commands
    plot sin(x), \
         cos(x)
    ```
)
````

To read a data file:
```
# datafile.dat
# x  y
  0  0
  2  4
  4  0
```

````typ
#gp.exec(
    ```gnuplot
    $data <<EOD
    0  0
    2  4
    4  0
    EOD
    plot $data with linespoints
    ```
)
````

or
```typ
#gp.exec(
    // Use a datablock since Typst doesn't support WASI
    "$data <<EOD\n" +
    // Load "datafile.dat" using Typst
    read("datafile.dat") +
    "EOD\n" +
    "plot $data with linespoints"
)
```

To print `$data`:
```typ
#gp.exec("print $data")
```
