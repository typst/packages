# oasis-align 
`oasis-align` is a package that automatically sizes your content so that their heights are equal, allowing you to cleanly place content side by side. 

To use `oasis-align` in your document, start by importing the package like this:
```typst
#import "@preview/oasis-align:0.2.0": *
```
and follow the instructions found under [configuration](#configuration).

# Examples
## Image with Text
![Animation of image being aligned with text](examples/image-with-text.gif)
## Image with Image
![Animation of image being aligned with another image](examples/image-with-image.gif)
## Text with Text
![Animation of text being aligned with differently sized text](examples/text-with-text.gif)

# Configuration

> [!TIP]
> The parameters with defined values are the defaults and do not need to be included unless desired.

```typst
#oasis-align(
  swap: false,          // boolean
  int-dir: 1,           // 1 or -1
  int-frac: 0.5,        // decimal between 0 and 1
  tolerance: 0.001pt,   // length
  max-iterations: 30,   // integer greater than 0
  debug: false          // boolean
  item1,                // content
  item2,                // content
)
```

> [!IMPORTANT]
> To change the size of the gutter in both functions, use `#set grid(column-gutter: length)`. This is necessary to allow for fixed rules that aren't possible with user-defined functions. 

### `swap`
Swap the positions of `item1` and `item2` on the grid. You can achieve an identical output by manually switching the content of `item1` and `item2`.

### `int-dir`
The initial direction that the dividing fraction is moved. Changing this value will change the initial direction.

> [!NOTE]
> The program is hardcoded to switch directions if a solution is not found in the initial direction. This parameter mainly serves to let you easily choose between [multiple solutions](#oasis-align-2).


### `int-frac`
The starting point of the search process. Changing this value may reduce the total number of iterations of the function or find an [alternate solution](#oasis-align-2).

### `tolerance`
The allowable difference in heights between `item1` and `item2`. The function will run until it has reached either this `tolerance` or `max-iterations`. Making `tolerance` larger may reduce the total number of iterations but result in a larger height difference between pieces of content.  

> [!NOTE]
> Two pieces of content may not always be able to achieve the desired `tolerance`. In that case, the function sizes the content to the iteration that had the least difference in height. _Check out [how it works](#oasis-align-2) to understand why the function may not be able achieve the desired `tolerance`._

### `max-iterations`
The maximum number of iterations the function is allowed to attempt before terminating. Increasing this number may allow you to achieve a smaller `tolerance`.

### `debug`
A toggle that lets you look inside the function to see what is happening. Enable this if you would like a log of the function process and which of the parameters above could be changed to resolve the issue. 

<!-- # FAQ

## Why won't my image align nicely with my text -->


# How It Works
Originally designed to allow for an image to be placed side-by-side with text, this function takes an iterative approach to aligning the content. When changing the width of a block of text, the height does not scale linearly, but instead behaves as a step function that follows an exponential trend (the graph below has a simplified visualization of this). This prevents the use of an analytical methodology and thus must be solved using an iterative approach.

The function starts by taking the available space and then splitting it using the `int-frac`. The content is then placed in a block with the width as determined using the split from `int-frac` before measuring its height. Based on the `int-dir`, the split will be moved left or right using the bisection method until a solution within the `tolerance` has been found. In the case that a solution within the `tolerance` is not found within the `max-iterations`, the program terminates and uses the container width fraction that had the smallest difference in height. 

![Series of graphs visualizing the block width versus height of content](examples/graph-visualization.svg)

### Multiple Solutions (1st Graph)
Depending on the type of content, the function may find multiple solutions. The parameters `int-dir` and `int-frac` will allow you to choose between them by changing the direction in which it iterates and changing the starting container width fraction respectively. 

### No Solutions (2nd Graph)
There are cases in which the text size is incompatible with an image. This can be because there is not enough or too much text, and regardless of how the content is resized, their heights do not match.   

### Tolerance Not Reached (3rd Graph)
In the case of having texts of different sizes (as seen in [the examples](#text-with-text)), the spacing between lines prevents the function from finding a solution that meets the `tolerance` and thus the closest solution is used.

<!-- # Nomenclature
"Oasis" as in a fertile spot in a desert, where water is found. -->

# Future Work
### Allow for Relative `grid.column-gutter` sizes
Presently, I am unable to make the `grid.column-gutter`absolute using the `.to-absolute()` method. Including a relative length in `#set grid(column-gutter)` will throw an error. 

### Skipping Close Approximations
The function will skip over near-solutions under certain conditions. This is a consequence of the bisection method, which is great for finding exact solutions, but not approximations. To address this, a large portion of the code would likely need to be rewritten. 

In the mean time, you can get around this by playing with `int-frac`.

### Possible Integration with [`wrap-it`](https://github.com/ntjess/wrap-it)
Seeing as the uses cases for `oasis-align` and [`wrap-it`](https://github.com/ntjess/wrap-it) are very similar, a combined package could prove to be extremely useful. Implementation would allow for text content to overflow after a solution can no longer be found using `oasis-align`.

# Contributing and sharing
If you have suggestions or feedback, please feel free to create an [issue on GitHub](https://github.com/jdpieck/oasis-align/issues).

If you end up using this package, please feel free to share how you used under [discussion on GitHub](https://github.com/jdpieck/oasis-align/discussions).

Thanks for reading to the end!

\- Jason
