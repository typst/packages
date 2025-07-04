# Nerd Icons
Easy access to all nerd font icons in your typst documents  
This is my first time working with typst, so this package is very similar to
[fontawesome package](https://typst.app/universe/package/fontawesome)

## Setting up
You need to install a nerd font from your preferred source

On my system, I use Symbols Nerd Font Mono, hence it's the default  
If you have installed a different one, you can specify it with `#change-nerd-font`

### Example
```typst
#import "@preview/typst-nerdfont:0.2.0": change-nerd-font
#change-nerd-font("monoid nerd font")
```

## Usage
Import the `nf-icon` function from this package, and call it with a valid
nerd font icon name, which are found on the [nerdfonts website](https://www.nerdfonts.com/cheat-sheet)

### Example
```typst
#import "@preview/typst-nerdfont:0.2.0": nf-icon
#nf-icon("nf-md-dog")
```

QoL update: Now, you don't have to specify the prefix (in the example above "nf-md-"),
the library will resolve every possible prefix until it finds one that is valid

### Example
```typst
#import "@preview/typst-nerdfont:0.2.0": nf-icon, set-favorite-nf-prefix
#nf-icon("dog") // Will resolve to nf-md-dog
#set-favorite-nf-prefix("fa")
#nf-icon("dog") // Will resolve to nf-fa-dog

#nf-icon("lua") // Will resolve to nf-dev-lua,
                // as fa and md variants don't exist
```

The processing order for the prefix is:  
md, fa, dev, cod, linux, oct, weather, fae, seti, custom, ple, pom, pl, iec  
(they are in order from most to least icons)

Each icon is also defined as a constant that you can use directly

### Example
```typst
#import "@preview/typst-nerdfont:0.2.0": *
#nf-md-dog()
```

Any additional arguments to either two functions will be passed to the text
function. If you want a blue dog, do `#nf-md-dog(fill: blue)`

Because of how typst works, referencing a mutable value in a function
makes it so the return value is content, which isn't always ideal  
The function `nf-icon-string` returns the utf-16 character as
a string, although without taking in account your favorite prefix
