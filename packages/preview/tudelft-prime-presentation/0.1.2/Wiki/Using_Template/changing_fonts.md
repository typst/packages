# Using Different Fonts

You can check the fonts that typst have access to in your system by running:

```bash
typst fonts
```

You can add new fonts from the local `fonts` directory. For example, if you want to use "Comic Mono" as your font, 
copy the `ttf` font file in the local `fonts` directory, then set it up in the template with 

```typst
#let heading-fonts = ("Comic Mono")
#let normal-fonts = ("Comic Mono")
```

and then compile the main file with the command

```bash
typst compile --font-path "./fonts" main.typ
```

