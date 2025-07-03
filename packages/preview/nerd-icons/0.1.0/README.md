# Nerd Icons
Easy access to all nerd font icons in your typst documents
This is my first time working with typst, so this package is very similar to
[fontawesome package](https://typst.app/universe/package/fontawesome)

## Setting up
You need to install a nerd font from your preferred source

On my system, I use System Nerd Font Mono, hence it's the default  
If you have installed a different one, you can specify it with `#change-nerd-font`

### Example
```typst
#import "@preview/nerd-icons:0.1.0": change-nerd-font
#change-nerd-font("monoid nerd font")
```
## Usage
Import the nf-icon function from this package, and call it with a valid
nerd font icon name, which are found on [nerd fonts website](https://www.nerdfonts.com/cheat-sheet)

### Example
```typst
#import "@preview/nerd-icons:0.1.0": nf-icon
#nf-icon("nf-md-dog")
```

Each icon is also defined as a constant that you can use directly

### Example
```typst
#import "@preview/nerd-icons:0.1.0": *
#nf-md-dog()
```

Any additional arguments to either two functions will be passed to the text
function. If you want a blue dog, do `#nf-md-dog(fill: blue)`
