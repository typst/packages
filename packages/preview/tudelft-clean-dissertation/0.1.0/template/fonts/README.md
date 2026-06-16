# Fonts

This directory contains files that are needed to compile the thesis, as you may not have them installed on your system. You do not need to install them, as you can call Typst with the `--font-path` argument.

One easy place to download fonts from is [fonts.google.com](https://fonts.google.com/)

I suggest adding each font in its own folder; that way you can include metadata and licence information for each font.

```
.
└── fonts/
    ├── permissive-licence-font-A/
    │   ├── LICENSE
    │   ├── font-A.ttf
    │   └── ...
    ├── open-source-font-B/
    │   ├── LICENSE
    │   ├── font-B.ttf
    │   └── ...
    ├── proprietary-font-C/  # this one we cannot re-distribute/
    │   ├── LICENSE
    │   ├── font-C.ttf
    │   └── ...
    ├── README.md
    └── .gitignore  # make sure propertietary-font-C is ignored!
```

### Licence for fonts

Keep in mind that your fonts will come with their own licence. Make sure you have the licence to redistribute them if you want to include them in your git respository. If you are allowed to, then make sure to include as much of the original documentation for the font.

If you are not allowed to redistribute the font, then make sure to add it to the `.gitignore` file in this directory. 

### Template Fonts

To run this template, you will need to download the following two font families:

1. [Onest](https://fonts.google.com/specimen/Onest) (for headings)
2. [Atkinson Hyperlegible](https://fonts.google.com/specimen/Atkinson+Hyperlegible) (body text)

Unzip the contents and place the font directories into this directory in the structure indicated above.