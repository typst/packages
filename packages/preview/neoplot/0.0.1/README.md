# Neoplot

A Typst package to use [gnuplot](http://www.gnuplot.info/) in Typst.

```typ
#import "@preview/neoplot:0.0.1" as gp
```

Execute gnuplot commands as a **one-line** command:
```typ
#image.decode(
    gp.eval("
        set samples 1000;
        set xlabel 'x axis';
        set ylabel 'y axis';
        plot sin(x),
             cos(x)
    ")
)
```

is the equivalent of
```typ
#image.decode(
    gp.eval("set samples 1000;set xlabel 'x axis';set ylabel 'y axis';plot sin(x),cos(x)")
)
```

Execute a gnuplot script:
~~~typ
#image.decode(
    gp.exec(
        ```
        # Can add comments since this is a script
        set samples 1000
        set xlabel 'x axis'
        set ylabel 'y axis'
        # Use a backslash to extend commands
        plot sin(x), \
             cos(x)
        ```
    )
)
~~~

To read a data file: 
```
# datafile.dat
# x  y
  0  0
  2  4
  4  0
```

~~~typ
#image.decode(
    gp.exec(
        // Use a datablock since Typst doesn't support WASI
        "$data <<EOD\n" +
        // Load "datafile.dat" using Typst
        read("datafile.dat") +
        "EOD\n" +
        "plot $data w lp"
    )
)
~~~

is equivalent to
~~~typ
#image.decode(
    gp.exec(
        ```
        $data <<EOD
        0  0
        2  4
        4  0
        EOD
        plot $data w lp
        ```
    )
)
~~~
