# Neoplot

A Typst package to use [gnuplot](http://www.gnuplot.info/) in Typst.

## Installation

```typ
#import "@preview/neoplot:0.0.3" as gp
```

## Getting Started

Execute a gnuplot script:
````typ
#gp.exec(
    ```gnuplot
    # Remember to `reset`
    reset
    # Can add comments since it is a script
    set samples 1000
    # Use a backslash to extend commands
    plot sin(x), \
         cos(x)
    ```
)
````

Read a data file:
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
    reset
    $data <<EOD
    0  0
    2  4
    4  0
    EOD
    plot $data with lines
    ```
)
````

or
```typ
#gp.exec(
    // Use a datablock since Typst doesn't support WASI
    "reset; $data <<EOD\n" +
    // Load "datafile.dat" using Typst
    read("datafile.dat") +
    "EOD\n" +
    "plot $data with lines"
)
```

## Examples

A simple example:
````typ
// Import neoplot
#import "@preview/neoplot:0.0.3" as gp

#figure(
    gp.exec(
        // Set the width of the graph
        width: 55%,
        ```gnuplot
        reset
        set term svg size 500,400
        set xrange[-2.5*pi:2.5*pi]
        set yrange[-1.3:1.3]
        plot sin(x), cos(x)
        ```
    ),
    caption: "Graphs of Sine and Cosine",
)
````

A complex use case:
````typ
// Import neoplot
#import "@preview/neoplot:0.0.3" as gp

// A csv text in Typst
#let csvdata = ```
Date,A,B,C
2025-01-01,1,2,3
2025-01-02,2,3,4
2025-01-03,1,2,6
2025-01-04,2,1,8
```.text

#gp.exec(
```gnuplot
reset
# Set the terminal font
set term svg font "New Computer Modern,20"
# Read data from an external variable
$data <<EOD

```.text + csvdata +
```gnuplot

EOD
# Set the data format
set datafile sep ',' columnheaders
set xdata time
set timefmt "%Y-%m-%d"
# Set tick labels
set xtics timedate format '%m-%d' time 1 day rotate by 90 right
set ytics format '%.1f'
# Add a legend
set bmargin 4.5
set key right bmargin autotitle columnheader samplen 2 spacing 1 font ",8"
# Set axis labels
set xlabel "{/:Italic x}" offset 0,1
set ylabel "{/:Italic y}" offset 1,0
# Add grid lines
set grid
# Plot
plot for [i=2:*] $data using 1:i with linespoints
```.text
)
````

## Known Issues

- Cannot output `fit.log`
- No handling of `fit` exceptions
